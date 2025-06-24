Param (
    [String] $env_arg
)

while (-not $env_arg) {
    Write-Host "Provide environment to work on."
    Write-Host "Valid values are: dev | ppe | prod | exit | x"
    $env_arg = Read-Host -Prompt "Env: "
    if (-not ('prod', 'ppe', 'dev', 'exit', 'x' -contains $env_arg)) {
        $env_arg = $null
    }
}

if ('exit', 'x' -contains $env_arg) {
    throw 'Script terminated on user request'
}

$DebugPreference = "Continue"


$global:Environment = $env_arg
Write-Debug "$(Get-Date -Format 'yyyy-MM-dd HH:mm K') [Env: ${Environment}]"
