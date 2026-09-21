#:property PublishAot=true
#:property InvariantGlobalization=true
#:property DebugType=none

// Shadow Build slot pinning, PreToolUse(Bash).
//
// Pins agent builds to a numbered shadow slot by exporting CLAUDE_SHADOW_SLOT, which
// ~/.claude/ShadowBuild.props turns into an ArtifactsPath outside the repo, and drops
// --no-restore, which cannot work against a cold slot.
//
// This hook deliberately enforces nothing else. In particular it does NOT police `dotnet run`
// or `dotnet watch`: the dotnet-shadow-build skill asks agents not to launch an app, but some
// projects (prototypes, benchmarks) want agents running things freely, and a global hook is the
// wrong place to decide that.
//
// Not load-bearing either: ShadowBuild.props already redirects on its own (to slot-lsp) if
// nothing sets the variable.

using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

HookInput? input;
try
{
    input = JsonSerializer.Deserialize(Console.In.ReadToEnd(), HookJson.Default.HookInput);
}
catch (JsonException)
{
    return;
}

string? command = input?.ToolInput?.Command;
if (string.IsNullOrEmpty(command) || !BuildCommand.MentionsDotnet().IsMatch(command))
{
    return;
}

if (!BuildCommand.Verb().IsMatch(command))
{
    return;
}

string rewritten = BuildCommand.NoRestoreFlag().Replace(command, "");

// Leave an explicit slot alone: that is an agent escalating past a locked slot. Match an
// assignment, not the bare name, or a command that merely echoes or greps for the variable
// silently loses its slot.
if (!BuildCommand.SlotAssignment().IsMatch(rewritten))
{
    rewritten = "export CLAUDE_SHADOW_SLOT=0; " + rewritten;
}

if (rewritten == command)
{
    return;
}

HookResponse response = new()
{
    HookSpecificOutput = new UpdatedInput
    {
        HookEventName = "PreToolUse",
        ToolInput = new ToolInput { Command = rewritten },
    },
};

// The relaxed encoder leaves `&&`, `<` and `>` as themselves. The default one escapes them to
// & and friends, which parses back the same but makes a rewritten shell command unreadable.
Console.Out.Write(JsonSerializer.Serialize(response, HookJson.Default.HookResponse));

internal sealed record HookInput
{
    [JsonPropertyName("tool_input")] public ToolInput? ToolInput { get; init; }
}

internal sealed record ToolInput
{
    [JsonPropertyName("command")] public string? Command { get; init; }
}

internal sealed record HookResponse
{
    [JsonPropertyName("hookSpecificOutput")]
    public required UpdatedInput HookSpecificOutput { get; init; }
}

internal sealed record UpdatedInput
{
    [JsonPropertyName("hookEventName")] public required string HookEventName { get; init; }
    [JsonPropertyName("updatedInput")] public required ToolInput ToolInput { get; init; }
}

[JsonSerializable(typeof(HookInput))]
[JsonSerializable(typeof(HookResponse))]
internal sealed partial class HookJson : JsonSerializerContext;

internal static partial class BuildCommand
{
    [GeneratedRegex("dotnet|msbuild", RegexOptions.IgnoreCase)]
    public static partial Regex MentionsDotnet();

    // The leading negative lookbehind, rather than an anchor on ^ or a shell separator, is
    // deliberate. Anchoring missed every shape that does not start the line —
    // `CONFIG=Release dotnet build`, `time dotnet build`, `( dotnet build )`,
    // `if true; then dotnet build; fi`, and a plain second line of a multi-line command — and each
    // miss fell through to the language server's slot, which is the one place a build can still
    // collide with a held file lock.
    //
    // `run` and `watch` are here because they build too: pinning them to a real slot keeps an
    // autonomous prototype run out of both the repo and the language server's slot.
    [GeneratedRegex(
        @"(?<![A-Za-z0-9_./\\-])(dotnet\s+(build|test|msbuild|publish|pack|restore|clean|run|watch)|msbuild)\b",
        RegexOptions.IgnoreCase)]
    public static partial Regex Verb();

    // --no-restore fails outright against a cold slot, which has no project.assets.json yet, and
    // a warm restore costs almost nothing. Dropping it removes the failure mode entirely.
    // The lookahead keeps it from eating the prefix of another token: a `\b` here also matched
    // `--no-restore-cache`, rewriting it to a bare `-cache`.
    [GeneratedRegex(@"\s--no-restore(?=\s|\z)")]
    public static partial Regex NoRestoreFlag();

    [GeneratedRegex(@"CLAUDE_SHADOW_SLOT\s*=")]
    public static partial Regex SlotAssignment();
}