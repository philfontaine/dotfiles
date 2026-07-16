---
name: csharp-style
description: The user's C# coding conventions and style preferences. Use whenever writing, editing, generating, or reviewing C# code (.cs files) — before producing any C# so the output matches these conventions.
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
