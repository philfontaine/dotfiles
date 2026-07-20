---
name: csharp-style
description: The user's C# coding conventions and style preferences. Use whenever writing, editing, generating, or reviewing C# code (.cs files).
user-invocable: false
---

Apply these conventions to any C# code you write, edit, or review. If the surrounding file already follows a different established convention, match the file over these rules — consistency within a file wins.

## Record constructors

Prefer explicit property declarations with the `required` and `init` keywords over using a record primary constructor, unless the argument order is non-ambiguous.

```csharp
// OK as positional record — order is conventional/unambiguous
public record Point(int X, int Y);

// Should use explicit properties — same-typed params, order easy to mix up
public record Employee
{
    public required string FirstName { get; init; }
    public required string LastName { get; init; }
    public required string Department { get; init; }
}
```

## Null-forgiving operator

Don't use `null!` to work around a non-nullable property you haven't actually initialized — it lies to the compiler, defeats nullable reference type checks, and risks a `NullReferenceException` at runtime instead of a compile-time error. Instead, reflect reality:

- If the value truly must always be set, use `required` so the compiler enforces it.
- If the value can genuinely be absent, make the property nullable (`Person?`) and let callers handle the null case.

```csharp
// Bad — lies about Person being initialized; a missed assignment becomes a runtime NRE
public Person Person { get; set; } = null!;

// Good — value is always expected to be set; compiler enforces it
public required Person Person { get; set; }

// Good — value is genuinely optional; caller must handle the null case
public Person? Person { get; set; }
```

## TryGet pattern

For a `TryGet`-style method with a reference type `out` parameter, declare the parameter as nullable and annotate it with `[NotNullWhen(true)]` so the compiler understands the parameter is guaranteed non-null when the method returns `true`.

```csharp
using System.Diagnostics.CodeAnalysis;

// Good — caller doesn't need a null-forgiving operator or manual null check after a true return
public bool TryGetPerson(int id, [NotNullWhen(true)] out Person? person)
{
    person = _people.GetValueOrDefault(id);
    return person is not null;
}
```

## Variable naming

Don't use unclear or cryptic abbreviations (e.g. `pmOpen` for "parameters menu open") — prefer a descriptive name like `paramsMenuOpen`. Shortening a word to a clear, common abbreviation (e.g. `Parameters` → `params`) is fine as long as the meaning stays obvious. Exception: in boilerplate-heavy methods where a variable is used many times (~dozens), a short name (even a single letter) is acceptable if it keeps the code readable.

```csharp
// Bad — cryptic abbreviation
bool pmOpen;

// Good — "Parameters" shortened to "params" but still clear
bool paramsMenuOpen;

// Acceptable — used dozens of times in a boilerplate-heavy method
var a = advancedParams;
```
