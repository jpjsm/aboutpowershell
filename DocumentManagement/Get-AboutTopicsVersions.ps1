class AboutTopicsVersions {
        [string]$simplename
        [string]$label
        [string]$path
        [string]$version

        AboutTopicsVersions ([string]$s, [string]$l, [string]$p, [string]$v){
            $this.simplename = $s
            $this.label = $l
            $this.path = $p
            $this.version = $v
        }
}
function Get-AboutTopicsVersions () {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {Test-Path -Path $_ -PathType Container })]
        [string]$ReferenceFolder
    )
    
    BEGIN {
        [string]$simplename = [string]::Empty
        [string]$label = [string]::Empty
        [string]$path = [string]::Empty
        [string]$version = [string]::Empty
        [AboutTopicsVersions[]]$abouttopics = Get-ChildItem -path $ReferenceFolder -Filter "about_*.md" -Recurse |
            Where-Object { (-not $_.PSIsContainer) -and ($_.FullName -notlike "*ignore*") } |
            ForEach-Object { 
                $label = [System.IO.Path]::GetFileNameWithoutExtension($_.FullName)
                $simplename = $label.ToLowerInvariant()
                $path = [System.IO.Path]::GetDirectoryName($_.FullName.Substring($ReferenceFolder.Length).TrimStart('\'))
                $version = $path.Split('\')[0]

                if ([string]::IsNullOrWhiteSpace($label) -or ($label -notlike "about*")) {
                    Write-OUTPUT "Empty label at: $_"
                }

                [AboutTopicsVersions]::new($simplename, $label, $path, $version)
            }

    }

    END{
        $abouttopics
    }
}