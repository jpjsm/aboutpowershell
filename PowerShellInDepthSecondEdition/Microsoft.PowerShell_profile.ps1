function prompt {
    $size = '32 bit';
    if ([System.IntPtr]::Size -eq 8)
        { $size = '64 bit'; }

    $admin = 'non-Admin';
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    $secprin = New-Object Security.Principal.WindowsPrincipal $currentUser
    if ($secprin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
        { $admin = 'Administrator'; }

    $hostinfo = get-host
    $verinfo = "ver: " + $hostinfo.Version

    $host.UI.RawUI.WindowTitle = "$admin  $size  $verinfo [$(get-location)]"

    "¶ >"
}