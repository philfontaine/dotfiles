#:property PublishAot=true
#:property InvariantGlobalization=true
#:property DebugType=none

// Added-comment collector, PostToolUse(Write|Edit).
//
// Records the comment lines each edit adds, for hook-comment-review.exe to replay once the turn
// ends. Reading tool_input rather than a git diff is what keeps the list to this agent's own
// text: another agent may hold uncommitted changes in the same working tree, and scoping a diff
// to the files touched this turn does not separate them either, since both agents may have
// edited the same file.
//
// A Write carries no old_string to subtract from, so rewriting an existing file re-reports every
// comment already in it. That over-reporting is accepted: a false positive costs one line of
// self-review.
//
// Every failure is swallowed. This runs after an edit that already succeeded, so there is
// nothing left to protect, and an error here would be reported against a tool call that worked.

using System.Text.Json;
using System.Text.Json.Serialization;

try
{
    Collect();
}
catch
{
    // ignored
}

return;

static void Collect()
{
    var input = JsonSerializer.Deserialize(Console.In.ReadToEnd(), HookJson.Default.HookInput);
    var toolInput = input?.ToolInput;
    string? filePath = toolInput?.FilePath;
    if (input?.SessionId is not { } sessionId || filePath is null || IsProse(filePath))
    {
        return;
    }

    string[] added = CommentLines(toolInput?.NewString ?? toolInput?.Content)
        .Except(CommentLines(toolInput?.OldString))
        .Select(line => $"{filePath}\t{line}")
        .ToArray();
    if (added.Length == 0 || SessionFilePath(sessionId) is not { } sessionFile)
    {
        return;
    }

    Append(sessionFile, added);
}

// Markers are matched at the start of a line only, so a `//` inside a string literal does not
// count as a comment. `#` is left out because it would match C# preprocessor directives.
//
// Lines are trimmed before the caller subtracts the old text from the new, so re-indenting a
// comment block does not report all of it as freshly added.
static IEnumerable<string> CommentLines(string? text) =>
    (text ?? "").Split('\n')
    .Select(line => line.Trim())
    .Where(line => line.StartsWith("//", StringComparison.Ordinal)
                   || line.StartsWith("/*", StringComparison.Ordinal)
                   || line.StartsWith('*')
                   || line.StartsWith("<!--", StringComparison.Ordinal));

// In prose the same markers mean something else: every `* item` bullet and every `<!-- -->` in a
// Markdown file would be reported as a comment.
static bool IsProse(string filePath) =>
    Path.GetExtension(filePath).ToLowerInvariant() is ".md" or ".markdown" or ".txt" or ".rst";

static string? SessionFilePath(string sessionId)
{
    if (sessionId.Length == 0 || !sessionId.All(c => char.IsAsciiLetterOrDigit(c) || c is '-' or '_'))
    {
        return null;
    }

    string directory = Path.Combine(Path.GetTempPath(), "claude-comment-review");
    Directory.CreateDirectory(directory);
    return Path.Combine(directory, $"{sessionId}.txt");
}

static void Append(string sessionFile, string[] lines)
{
    // Tool calls issued in the same batch each spawn this hook, so two appends to one session
    // file can overlap.
    for (var attempt = 0;; attempt++)
    {
        try
        {
            File.AppendAllLines(sessionFile, lines);
            return;
        }
        catch (IOException) when (attempt < 4)
        {
            Thread.Sleep(20);
        }
    }
}

internal sealed record HookInput
{
    [JsonPropertyName("session_id")] public string? SessionId { get; init; }
    [JsonPropertyName("tool_input")] public ToolInput? ToolInput { get; init; }
}

internal sealed record ToolInput
{
    [JsonPropertyName("file_path")] public string? FilePath { get; init; }
    [JsonPropertyName("old_string")] public string? OldString { get; init; }
    [JsonPropertyName("new_string")] public string? NewString { get; init; }
    [JsonPropertyName("content")] public string? Content { get; init; }
}

[JsonSerializable(typeof(HookInput))]
internal sealed partial class HookJson : JsonSerializerContext;