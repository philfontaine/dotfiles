# Startup script of the Windows Terminal profiles that get a window of their own, like Rocket.
#
# Gives the hosting Terminal window its own taskbar identity: a taskbar group separate from the
# regular Terminal windows, with the profile's icon. The taskbar takes the group's icon, and what a
# pin launches, from the Start Menu shortcut carrying the same AppUserModelID, so that shortcut
# is rewritten here too. Pin it from the taskbar button or from the Start Menu.
#
# -Name is the profile name. The window name and the icon in Terminal's LocalState are the same
# name in lowercase: the Rocket profile opens in `wt -w rocket` with rocket.ico.

param(
    [Parameter(Mandatory)]
    [string] $Name
)

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;

public static class TaskbarWindow
{
    [StructLayout(LayoutKind.Sequential, Pack = 4)]
    private struct PropertyKey
    {
        public Guid FormatId;
        public uint PropertyId;
    }

    [StructLayout(LayoutKind.Explicit, Size = 16)]
    private struct PropVariant
    {
        [FieldOffset(0)] public ushort Type;
        [FieldOffset(8)] public IntPtr Value;
    }

    [ComImport, Guid("886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IPropertyStore
    {
        void GetCount(out uint count);
        void GetAt(uint index, out PropertyKey key);
        void GetValue(ref PropertyKey key, out PropVariant value);
        void SetValue(ref PropertyKey key, ref PropVariant value);
        void Commit();
    }

    [ComImport, Guid("000214F9-0000-0000-C000-000000000046"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IShellLinkW
    {
        void GetPath(IntPtr file, int maxLength, IntPtr findData, uint flags);
        void GetIDList(out IntPtr idList);
        void SetIDList(IntPtr idList);
        void GetDescription(IntPtr name, int maxLength);
        void SetDescription([MarshalAs(UnmanagedType.LPWStr)] string name);
        void GetWorkingDirectory(IntPtr dir, int maxLength);
        void SetWorkingDirectory([MarshalAs(UnmanagedType.LPWStr)] string dir);
        void GetArguments(IntPtr args, int maxLength);
        void SetArguments([MarshalAs(UnmanagedType.LPWStr)] string args);
        void GetHotkey(out short hotkey);
        void SetHotkey(short hotkey);
        void GetShowCmd(out int showCmd);
        void SetShowCmd(int showCmd);
        void GetIconLocation(IntPtr iconPath, int maxLength, out int iconIndex);
        void SetIconLocation([MarshalAs(UnmanagedType.LPWStr)] string iconPath, int iconIndex);
        void SetRelativePath([MarshalAs(UnmanagedType.LPWStr)] string relativePath, uint reserved);
        void Resolve(IntPtr window, uint flags);
        void SetPath([MarshalAs(UnmanagedType.LPWStr)] string file);
    }

    [ComImport, Guid("00021401-0000-0000-C000-000000000046")]
    private class ShellLink
    {
    }

    [DllImport("shell32.dll")]
    private static extern int SHGetPropertyStoreForWindow(IntPtr window, ref Guid interfaceId, out IPropertyStore store);

    [DllImport("kernel32.dll")]
    private static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    private static extern IntPtr GetAncestor(IntPtr window, uint flags);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern IntPtr LoadImage(IntPtr instance, string name, uint type, int width, int height, uint flags);

    [DllImport("user32.dll")]
    private static extern IntPtr SendMessage(IntPtr window, uint message, IntPtr wParam, IntPtr lParam);

    private const uint GA_ROOTOWNER = 3;
    private const uint IMAGE_ICON = 1;
    private const uint LR_LOADFROMFILE = 0x10;
    private const uint WM_SETICON = 0x80;
    private const int ICON_SMALL = 0;
    private const int ICON_BIG = 1;
    private const ushort VT_LPWSTR = 31;
    private static readonly PropertyKey AppUserModelId = new PropertyKey
    {
        FormatId = new Guid("9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3"),
        PropertyId = 5,
    };

    public static void WriteShortcut(string shortcutPath, string target, string arguments, string iconPath, string appId)
    {
        var link = (IShellLinkW)new ShellLink();
        link.SetPath(target);
        link.SetArguments(arguments);
        link.SetIconLocation(iconPath, 0);
        SetString((IPropertyStore)link, AppUserModelId, appId);
        ((IPropertyStore)link).Commit();
        ((IPersistFile)link).Save(shortcutPath, true);
    }

    public static void ApplyToWindow(string appId, string iconPath)
    {
        // Under ConPTY the console window is a hidden pseudo-window owned by the Terminal window hosting this shell
        var terminalWindow = GetAncestor(GetConsoleWindow(), GA_ROOTOWNER);

        var interfaceId = typeof(IPropertyStore).GUID;
        IPropertyStore store;
        Marshal.ThrowExceptionForHR(SHGetPropertyStoreForWindow(terminalWindow, ref interfaceId, out store));
        SetString(store, AppUserModelId, appId);
        store.Commit();

        SetIcon(terminalWindow, ICON_BIG, iconPath, 256);
        SetIcon(terminalWindow, ICON_SMALL, iconPath, 32);
    }

    private static void SetString(IPropertyStore store, PropertyKey key, string value)
    {
        var variant = new PropVariant { Type = VT_LPWSTR, Value = Marshal.StringToCoTaskMemUni(value) };
        try
        {
            store.SetValue(ref key, ref variant);
        }
        finally
        {
            Marshal.FreeCoTaskMem(variant.Value);
        }
    }

    private static void SetIcon(IntPtr window, int iconKind, string iconPath, int size)
    {
        var icon = LoadImage(IntPtr.Zero, iconPath, IMAGE_ICON, size, size, LR_LOADFROMFILE);
        SendMessage(window, WM_SETICON, (IntPtr)iconKind, icon);
    }
}
'@

$appId = "PhilFontaine.$Name"
$iconPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\$($Name.ToLower()).ico"

[TaskbarWindow]::WriteShortcut(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$Name.lnk",
    "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe",
    "-w $($Name.ToLower()) -p $Name",
    $iconPath,
    $appId)
[TaskbarWindow]::ApplyToWindow($appId, $iconPath)
