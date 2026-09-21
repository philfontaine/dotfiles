#:property PublishAot=true
#:property InvariantGlobalization=true
#:property DebugType=none

// OneDrive `find` guard, PreToolUse(Bash).
//
// Recursing into a OneDrive folder forces Files On-Demand to download every file it touches, so a
// `find` scoped anywhere near one is denied outright.
//
// This runs on EVERY Bash call, so the non-find fast path below must stay first and cheap.

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
if (string.IsNullOrEmpty(command) || !FindCommand.MentionsOneDrive().IsMatch(command))
{
    return;
}

if (!FindCommand.Verb().IsMatch(command))
{
    return;
}

HookResponse response = new()
{
    HookSpecificOutput = new PermissionDecision
    {
        HookEventName = "PreToolUse",
        Decision = "deny",
        Reason = "Blocked by OneDrive guard: this 'find' scans a OneDrive folder, which forces "
                 + "OneDrive to download every file on demand. Scope the search to the project "
                 + "directory, or use the Grep/Glob tools instead.",
    },
};
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
    public required PermissionDecision HookSpecificOutput { get; init; }
}

internal sealed record PermissionDecision
{
    [JsonPropertyName("hookEventName")] public required string HookEventName { get; init; }

    [JsonPropertyName("permissionDecision")]
    public required string Decision { get; init; }

    [JsonPropertyName("permissionDecisionReason")]
    public required string Reason { get; init; }
}

[JsonSerializable(typeof(HookInput))]
[JsonSerializable(typeof(HookResponse))]
internal sealed partial class HookJson : JsonSerializerContext;

internal static partial class FindCommand
{
    [GeneratedRegex("onedrive", RegexOptions.IgnoreCase)]
    public static partial Regex MentionsOneDrive();

    // The leading alternation on a shell separator, rather than an anchor on ^ alone, keeps the
    // guard on `find` in any position — `cd foo && find ...`, `( find ... )` — without matching it
    // inside another word, where `grep -r onedrive` or a path ending in `/find` would trip it.
    [GeneratedRegex(@"(?:^|[;&|(`])\s*find(?:\.exe)?\s", RegexOptions.IgnoreCase | RegexOptions.Multiline)]
    public static partial Regex Verb();
}