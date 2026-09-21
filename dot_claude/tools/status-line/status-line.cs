#:property PublishAot=true
#:property InvariantGlobalization=true
#:property DebugType=none

using System.Diagnostics;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

const string colorReset = "\e[0m";
const string colorDim = "\e[2m";
const string red = "\e[31m";
const string green = "\e[32m";
const string yellow = "\e[33m";
const string blue = "\e[34m";
const string magenta = "\e[35m";
const string cyan = "\e[36m";
const string white = "\e[37m";

SessionStatus? session = null;
try
{
    session = JsonSerializer.Deserialize(Console.In.ReadToEnd(), StatusLineJson.Default.SessionStatus);
}
catch (JsonException)
{
}

// With every section present the line looks like this:
//
//   dotfiles@main | Opus 5 [high] | ctx:43% | 5h: 31% (12PM) | 7d: 12% (Wed Sep 23 6PM)
//   Repo            Model           Context   FiveHour         SevenDay
//
// A section returns null when the session has nothing to show for it, and only the separators
// between the sections that survive are drawn.
string?[] sections =
[
    RepoSection(session),
    ModelSection(session),
    ContextUsageSection(session),
    FiveHourLimitSection(session),
    SevenDayLimitSection(session),
];

Console.Out.Write(string.Join($" {colorDim}|{colorReset} ", sections.OfType<string>()));

return;

// "dotfiles@main" — the working directory's own name, plus the branch checked out there
static string? RepoSection(SessionStatus? session)
{
    string? cwd = OrNull(session?.Cwd);
    if (cwd is null)
    {
        return null;
    }

    string directory = cwd.Split(['\\', '/'], StringSplitOptions.RemoveEmptyEntries) is { Length: > 0 } segments
        ? segments[^1]
        : cwd;
    var label = $"{cyan}{directory}{colorReset}";

    string? branch = ReadGitBranch(cwd);
    if (branch is not null && branch != "HEAD")
    {
        label += $"{colorDim}@{colorReset}{magenta}{branch}{colorReset}";
    }

    return label;
}

// "Opus 5 [high]" — the model's display name, with the effort level when one is set
static string ModelSection(SessionStatus? session)
{
    string name = OrNull(session?.Model?.DisplayName) ?? OrNull(session?.Model?.Id) ?? "?";
    name = ModelName.ContextSuffix().Replace(name, "", 1).Trim();

    string? effort = OrNull(session?.Effort?.Level);
    string label = effort is not null ? $"{name} {colorDim}[{effort}]{colorReset}" : name;

    return $"{blue}{label}{colorReset}";
}

// "ctx:43%" — how much of the context window is used, green until 70%, then yellow, then red
static string? ContextUsageSection(SessionStatus? session)
{
    if (session?.ContextWindow?.UsedPercentage is not { } used)
    {
        return null;
    }

    var percentage = (int)Math.Round(used);

    return $"{ThresholdColor(percentage, green)}ctx:{percentage}%{colorReset}";
}

// "5h: 31% (12PM)" — how much of the five hour window is used, and the hour it resets
static string? FiveHourLimitSection(SessionStatus? session) =>
    RateLimitSection(session?.RateLimits?.FiveHour, "5h", withDate: false);

// "7d: 12% (Wed Sep 23 6PM)" — the same for the seven day window, dated because its reset is
// usually days away
static string? SevenDayLimitSection(SessionStatus? session) =>
    RateLimitSection(session?.RateLimits?.SevenDay, "7d", withDate: true);

// Shared by both windows: the label and percentage, then the reset time, or "(resetting)" once the
// window is already past it
static string? RateLimitSection(RateLimitWindow? window, string label, bool withDate)
{
    if (window?.UsedPercentage is not { } used)
    {
        return null;
    }

    var percentage = (int)Math.Round(used);
    var text = $"{label}: {percentage}%";

    if (window.ResetsAt is { } resetsAt)
    {
        var resetTime = DateTimeOffset.FromUnixTimeSeconds((long)resetsAt).ToLocalTime();
        if (resetTime > DateTimeOffset.Now)
        {
            string[] dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
            string[] monthNames =
                ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
            string date = withDate
                ? $"{dayNames[(int)resetTime.DayOfWeek]} {monthNames[resetTime.Month - 1]} {resetTime.Day} "
                : "";
            text += $" ({date}{FormatHour(resetTime)})";
        }
        else
        {
            text += " (resetting)";
        }
    }

    return $"{ThresholdColor(percentage, $"{colorDim}{white}")}{text}{colorReset}";
}

// An absent field and an empty one are the same thing to every caller here, matching the script
// this replaces, where both were falsy.
static string? OrNull(string? value) => string.IsNullOrEmpty(value) ? null : value;

static string ThresholdColor(int percentage, string belowThreshold) =>
    percentage >= 90 ? red : percentage >= 70 ? yellow : belowThreshold;

static string FormatHour(DateTimeOffset time)
{
    int hour = time.Hour % 12;
    return $"{(hour == 0 ? 12 : hour)}{(time.Hour >= 12 ? "PM" : "AM")}";
}

// Spawning git costs ~40ms, which is most of what this program spends, so the branch comes from
// .git/HEAD directly. Anything that file cannot answer falls back to git rather than guessing.
static string? ReadGitBranch(string workingDirectory)
{
    try
    {
        for (DirectoryInfo? directory = new(workingDirectory); directory is not null; directory = directory.Parent)
        {
            string gitPath = Path.Combine(directory.FullName, ".git");
            if (Directory.Exists(gitPath))
            {
                return ReadHeadBranch(gitPath) ?? RunGitBranch(workingDirectory);
            }

            // A worktree or submodule has a .git file pointing at the real git directory
            if (File.Exists(gitPath))
            {
                string? linkedPath = ReadGitDirLink(gitPath, directory.FullName);
                return (linkedPath is null ? null : ReadHeadBranch(linkedPath)) ?? RunGitBranch(workingDirectory);
            }
        }

        return null;
    }
    catch (Exception)
    {
        return RunGitBranch(workingDirectory);
    }
}

static string? ReadHeadBranch(string gitPath)
{
    string headPath = Path.Combine(gitPath, "HEAD");
    if (!File.Exists(headPath))
    {
        return null;
    }

    string head = File.ReadAllText(headPath).Trim();
    // A detached HEAD holds a commit id, which `git rev-parse --abbrev-ref HEAD` reports as "HEAD"
    if (!head.StartsWith("ref: ", StringComparison.Ordinal))
    {
        return "HEAD";
    }

    string reference = head["ref: ".Length..].Trim();
    return reference.StartsWith("refs/heads/", StringComparison.Ordinal)
        ? reference["refs/heads/".Length..]
        : null;
}

static string? ReadGitDirLink(string gitFilePath, string containingDirectory)
{
    foreach (string line in File.ReadAllLines(gitFilePath))
    {
        if (line.StartsWith("gitdir:", StringComparison.Ordinal))
        {
            return Path.GetFullPath(Path.Combine(containingDirectory, line["gitdir:".Length..].Trim()));
        }
    }

    return null;
}

static string? RunGitBranch(string workingDirectory)
{
    try
    {
        using var git = Process.Start(new ProcessStartInfo
        {
            FileName = "git",
            ArgumentList = { "-C", workingDirectory, "--no-optional-locks", "rev-parse", "--abbrev-ref", "HEAD" },
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true,
        });
        if (git is null)
        {
            return null;
        }

        string branch = git.StandardOutput.ReadToEnd().Trim();
        git.WaitForExit();
        return git.ExitCode == 0 && branch.Length > 0 ? branch : null;
    }
    catch (Exception)
    {
        return null;
    }
}

internal sealed record SessionStatus
{
    [JsonPropertyName("cwd")] public string? Cwd { get; init; }
    [JsonPropertyName("model")] public ModelInfo? Model { get; init; }
    [JsonPropertyName("effort")] public EffortInfo? Effort { get; init; }
    [JsonPropertyName("context_window")] public ContextWindow? ContextWindow { get; init; }
    [JsonPropertyName("rate_limits")] public RateLimits? RateLimits { get; init; }
}

internal sealed record ModelInfo
{
    [JsonPropertyName("display_name")] public string? DisplayName { get; init; }
    [JsonPropertyName("id")] public string? Id { get; init; }
}

internal sealed record EffortInfo
{
    [JsonPropertyName("level")] public string? Level { get; init; }
}

internal sealed record ContextWindow
{
    [JsonPropertyName("used_percentage")] public double? UsedPercentage { get; init; }
}

internal sealed record RateLimits
{
    [JsonPropertyName("five_hour")] public RateLimitWindow? FiveHour { get; init; }
    [JsonPropertyName("seven_day")] public RateLimitWindow? SevenDay { get; init; }
}

internal sealed record RateLimitWindow
{
    [JsonPropertyName("used_percentage")] public double? UsedPercentage { get; init; }
    [JsonPropertyName("resets_at")] public double? ResetsAt { get; init; }
}

[JsonSerializable(typeof(SessionStatus))]
internal sealed partial class StatusLineJson : JsonSerializerContext;

internal static partial class ModelName
{
    [GeneratedRegex(@"\s*\(1M context\)", RegexOptions.IgnoreCase)]
    public static partial Regex ContextSuffix();
}
