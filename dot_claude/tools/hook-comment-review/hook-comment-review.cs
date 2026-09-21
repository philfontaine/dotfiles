#:property PublishAot=true
#:property InvariantGlobalization=true
#:property DebugType=none

// Added-comment review, Stop.
//
// Replays the comments hook-comment-collector.exe recorded this turn, stripped of the diff that
// made each one feel worth writing, so the model reads them the way someone opening the file in
// six months will. It prompts and does not enforce: no rule can tell a genuinely surprising
// comment from a diff annotation, so both go in front of the model while it can still act.
//
// Reading the session file deletes it, which is the loop guard: a second Stop finds nothing to
// report and lets the turn end. stop_hook_active covers the same ground from the other side.
//
// Every failure is swallowed, for the same reason the collector swallows its own: a reminder
// about comments must never be able to wedge a session.

using System.Text.Json;
using System.Text.Json.Serialization;

try
{
    Review();
}
catch
{
    // ignored
}

return;

static void Review()
{
    var input = JsonSerializer.Deserialize(Console.In.ReadToEnd(), HookJson.Default.HookInput);
    if (input?.SessionId is not { } sessionId
        || input.StopHookActive == true
        || SessionFilePath(sessionId) is not { } sessionFile
        || !File.Exists(sessionFile))
    {
        return;
    }

    string[] entries = File.ReadAllLines(sessionFile);
    File.Delete(sessionFile);

    string report = Report(entries);
    if (report.Length == 0)
    {
        return;
    }

    HookResponse response = new() { Decision = "block", Reason = Reason(report) };
    Console.Out.Write(JsonSerializer.Serialize(response, HookJson.Default.HookResponse));
}

static string Report(string[] entries)
{
    var files = entries
        .Distinct()
        .Select(entry => entry.Split('\t', 2))
        .Where(parts => parts.Length == 2)
        .GroupBy(parts => parts[0], parts => parts[1]);

    return string.Join("\n\n", files.Select(FileSection));

    static string FileSection(IGrouping<string, string> file) =>
        string.Join("\n", file.Select(comment => $"    {comment}").Prepend($"  {file.Key}"));
}

// A multi-line interpolation is inserted verbatim, so the report keeps its own indentation
// rather than picking up this literal's.
static string Reason(string report) =>
    $"""
     You added these comments this turn. You are seeing them with no diff context —
     the same way someone opening the file in six months will:

     {report}

     For each one, answer: does it make sense to a reader who never saw the change?
     If it justifies the change, compares to how the code used to be, or names an
     alternative you rejected, delete it — that belongs in the commit message.
     Then finish your turn.
     """;

static string? SessionFilePath(string sessionId) =>
    sessionId.Length > 0 && sessionId.All(c => char.IsAsciiLetterOrDigit(c) || c is '-' or '_')
        ? Path.Combine(Path.GetTempPath(), "claude-comment-review", $"{sessionId}.txt")
        : null;

internal sealed record HookInput
{
    [JsonPropertyName("session_id")] public string? SessionId { get; init; }
    [JsonPropertyName("stop_hook_active")] public bool? StopHookActive { get; init; }
}

internal sealed record HookResponse
{
    [JsonPropertyName("decision")] public required string Decision { get; init; }
    [JsonPropertyName("reason")] public required string Reason { get; init; }
}

[JsonSerializable(typeof(HookInput))]
[JsonSerializable(typeof(HookResponse))]
internal sealed partial class HookJson : JsonSerializerContext;