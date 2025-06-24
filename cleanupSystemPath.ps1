# Based on https://codingbee.net/powershell/powershell-make-a-permanent-change-to-the-path-environment-variable

function Optimize-SystemPath {

    $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
    $timestamp = $(Get-Date -Format o) -replace ':', '.'
    $oldpath -split ';' | out-file -FilePath "PATH-old.$timestamp.txt" -Encoding utf8NoBOM

    $elements = @{}
    $newPath = $oldpath -split ';' | 
        foreach-object {
            $element = $_.ToLower()
            if ( [String]::IsNullOrWhiteSpace($element)) {
                Write-Output $([String]::Empty)
            }
            elseif (-not $elements.ContainsKey($element)) {
                $elements.Add($element, $null)
                Write-Output $element
            }
        } | Join-String -Separator ';'

    $newPath -split ';' | out-file -FilePath "PATH-new.$timestamp.txt" -Encoding utf8NoBOM
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
}

Optimize-SystemPath
