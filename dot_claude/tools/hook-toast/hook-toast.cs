#:property PublishAot=true
#:property TargetFramework=net10.0-windows10.0.17763.0
#:property DebugType=none

// Windows toast notification, Notification + Stop hooks.

using System.Text.Json;
using System.Text.Json.Serialization;
using Windows.UI.Notifications;

// Toasts are attributed to the shortcut this AppUserModelID belongs to, so it stays pointed at
// PowerShell's: a notifier using an unregistered id silently shows nothing.
const string appId = @"{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe";

ToastInput? input = null;
try
{
    input = JsonSerializer.Deserialize(Console.In.ReadToEnd(), ToastJson.Default.ToastInput);
}
catch (JsonException)
{
}

string hookEvent = input?.HookEventName ?? "";
string hookMessage = input?.Message ?? "";
string message = hookEvent switch
{
    "SessionStart" => "Session started",
    "SessionEnd" => "Session completed",
    "Stop" => "Response finished",
    "Notification" => hookMessage,
    _ => $"{hookEvent} : {hookMessage}",
};

var template = ToastNotificationManager.GetTemplateContent(ToastTemplateType.ToastText02);
var texts = template.GetElementsByTagName("text");
texts[0].InnerText = "Claude Code";
texts[1].InnerText = message;
ToastNotificationManager.CreateToastNotifier(appId).Show(new ToastNotification(template));

internal sealed record ToastInput
{
    [JsonPropertyName("hook_event_name")] public string? HookEventName { get; init; }
    [JsonPropertyName("message")] public string? Message { get; init; }
}

[JsonSerializable(typeof(ToastInput))]
internal sealed partial class ToastJson : JsonSerializerContext;