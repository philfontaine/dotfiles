---
name: add-tfw-arch-testing
description: Wires ArchUnitNET-based architecture tests into a TFW-based .NET solution. Adds the Tfw.Tests.Architecture project to the solution, ensures a test project exists, generates ArchitectureTests.cs with the correct assembly names and test framework syntax, and verifies the test runs. Use when the user asks to add architecture tests or TFW arch testing to a project.
---

# Add TFW Architecture Testing

Wire ArchUnitNET-based architecture tests into the current TFW project by following these six steps in order.

---

## Step 1 — Add `Tfw.Tests.Architecture` to the solution

1. Find the solution file at the repo root. (`*.slnx` or `*.sln`).
2. Locate the Tfw submodule. It is typically at `<repo>/Tfw`. If that directory does not exist,
   stop and tell the user to initialize the submodule
3. Check that `Tfw/Tfw.Tests.Architecture/Tfw.Tests.Architecture.csproj` exists.
   - If it does **not** exist, stop and tell the user:
     > The `Tfw.Tests.Architecture` project was not found in your Tfw submodule. This feature was
     > added in a recent version of Tfw. Please update your Tfw submodule to the latest version and
     > try again.
4. Add the project to the solution (skip if already present):
   - **`.slnx`**: Edit the XML to add inside `<Solution>`:
     ```xml
     <Project Path="Tfw/Tfw.Tests.Architecture/Tfw.Tests.Architecture.csproj"/>
     ```
   - **`.sln`**: Run `dotnet sln <solution-file> add Tfw/Tfw.Tests.Architecture/Tfw.Tests.Architecture.csproj`.
     If that fails (some SDK versions don't support `.slnx` via CLI), fall back to the XML edit.

---

## Step 2 — Ensure a test project exists

**Detecting the test framework** in an existing project — check the csproj for these
`PackageReference` includes:

| Framework   | Package(s) to look for                          | ArchUnitNET adapter package              |
|-------------|--------------------------------------------------|------------------------------------------|
| xUnit v2    | `xunit` (no `.v3`) + `Microsoft.NET.Test.Sdk`   | `TngTech.ArchUnitNET.xUnit`              |
| xUnit v3    | `xunit.v3` or `XUnit.v3`                         | `TngTech.ArchUnitNET.xUnit`              |
| TUnit       | `TUnit`                                          | `TngTech.ArchUnitNET.TUnit` *(if available, otherwise fall back to the xUnit adapter and note it)* |
| NUnit       | `NUnit`                                          | `TngTech.ArchUnitNET.NUnit`              |
| MSTest      | `MSTest.TestFramework`                           | `TngTech.ArchUnitNET.MSTestV2`           |

Record the detected framework as `<TestFramework>`.

1. Search for any `*.csproj` under the repo root whose content matches one of the package patterns
   above. Also accept a top-level `Tests/Tests.csproj` if present.
2. **If found**: record its path as `<TestsCsproj>`, its directory as `<TestsDir>`, and its
   detected framework as `<TestFramework>`. Skip to step 2d.
3. **If not found**: create one using xUnit v2 as the default.
   - Read `<TargetFramework>` from the App csproj to use the same value.
   - Run: `dotnet new xunit -o Tests -f <TargetFramework>`
   - Add it to the solution (`.slnx` XML edit or `dotnet sln add Tests/Tests.csproj`).
   - Record `Tests/Tests.csproj` as `<TestsCsproj>`, `Tests/` as `<TestsDir>`, `xunit` as
     `<TestFramework>`.
4. Add the appropriate ArchUnitNET adapter package if not already present (see table above):
   ```
   dotnet add <TestsCsproj> package <ArchUnitNET-adapter-package>
   ```
   Also add the base package `TngTech.ArchUnitNET` if the adapter does not pull it in transitively
   (check after restore).

---

## Step 3 — Determine the App and UiApp assembly names

**Identify the App project** (contains States/Services/Model, not an executable):

- Heuristic: a `*.csproj` that has **no** `<OutputType>Exe</OutputType>` and contains a
  `<ProjectReference>` pointing to `Tfw.csproj` (the Tfw core library).

**Identify the UiApp project** (entry point, contains Views):

- Primary heuristic: a `*.csproj` named `*Views*`, or any project that references the App project
  **and** contains `.cs` files with classes inheriting from `TfwView` (grep for `: TfwView` or
  `TfwView<`).
- Fallback heuristic: a `*.csproj` that has `<OutputType>Exe</OutputType>` (or is a WPF/Avalonia
  app) and contains a `<ProjectReference>` pointing to the App project.

**Disambiguation**: if more than one candidate is found for either role, list them to the user with
`AskUserQuestion` and let them pick.

**Resolve assembly names** for both chosen projects:

- Read `<AssemblyName>` from the csproj. If that tag is absent, use the project file name without
  `.csproj` (e.g., `App.csproj` → `App`).
- Record as `<AppAssembly>` and `<UiAppAssembly>`.

> **Critical**: `TfwArchitecture` takes assembly names (what the CLR loads), not project names or
> namespaces. Getting this wrong causes an `Assembly.Load` exception at runtime — which is the
> diagnostic signal used in step 6.

---

## Step 4 — Add project references to the test project

Add the following references to `<TestsCsproj>`, skipping any that are already present:

```
dotnet add <TestsCsproj> reference <App-csproj-path>
dotnet add <TestsCsproj> reference <UiApp-csproj-path>
dotnet add <TestsCsproj> reference Tfw/Tfw.Tests.Architecture/Tfw.Tests.Architecture.csproj
```

---

## Step 5 — Generate `ArchitectureTests.cs`

- Target path: `<TestsDir>/ArchitectureTests.cs`.
- If the file already exists, leave it untouched and inform the user.
- Resolve the namespace: read `<RootNamespace>` from the test csproj; fall back to the project file
  name without `.csproj`.
- Pick the using directive, attribute, and method signature based on `<TestFramework>`:

| Framework      | `using` directive             | Attribute      | Method signature       |
|----------------|-------------------------------|----------------|------------------------|
| xUnit v2/v3    | `using ArchUnitNET.xUnit;`    | `[Fact]`       | `public void`          |
| NUnit          | `using ArchUnitNET.NUnit;`    | `[Test]`       | `public void`          |
| MSTest         | `using ArchUnitNET.MSTestV2;` | `[TestMethod]` | `public void`          |
| TUnit          | `using ArchUnitNET.TUnit;`    | `[Test]`       | `public async Task`    |

- Write the file using the template below, substituting all five placeholders:

```csharp
<using-directive>
using Tfw.Tests.Architecture;

namespace <RootNamespace>;

public class ArchitectureTests
{
    [<attribute>]
    public <method-signature> CheckTfwRules()
    {
        var tfwArchitecture = new TfwArchitecture("<AppAssembly>", "<UiAppAssembly>");
        tfwArchitecture.GetStrictRules().Check(tfwArchitecture.Architecture);
    }
}
```

  For TUnit add `await` before `tfwArchitecture.GetStrictRules().Check(...)` only if the adapter's
  `Check` method is awaitable; otherwise keep it synchronous and change the signature back to
  `public void`.

---

## Step 6 — Build and run the test

1. Build:

   ```
   dotnet build --no-restore
   ```

   If that fails with a restore error, run `dotnet restore` first, then retry.
   Fix any build errors before continuing.

2. Run only the architecture test:

   ```
   dotnet test --filter "FullyQualifiedName~ArchitectureTests.CheckTfwRules"
   ```

3. Interpret the result:
   - **Pass** → done. Report what was set up (paths touched, assembly names used).
   - **Fail with architecture rule violations** (output mentions class names or rule descriptions
     from `TfwArchitecture`) → the wiring is correct. Report the violations to the user as findings
     — this is a success for the setup, not a failure of the skill.
   - **Fail with `Could not load file or assembly` / `FileNotFoundException`** → assembly name
     mismatch. Re-examine step 3 (check for a custom `<AssemblyName>` tag), ask the user to confirm
     which project is App vs UiApp, fix `ArchitectureTests.cs`, and re-run.
   - **Any other failure** → diagnose and fix before reporting done.

4. End with a short summary: files created or modified, assembly names used, test outcome.
