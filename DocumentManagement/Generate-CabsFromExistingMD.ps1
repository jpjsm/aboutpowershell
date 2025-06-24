function Generate-CabsFromExistingMd()
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [string] $versionFolder,
        [parameter(Mandatory=$true)] [string] $outputfolder
    )

    Get-ChildItem -Path $versionFolder |
        Where-Object { $_.PSIsContainer } |
        ForEach-Object {
            $moduleName = $_.Name
            $tmpFolder = [System.IO.Path]::Combine(([System.IO.Path]::GetTempPath()), ([System.Guid]::NewGuid()))
            New-Item -ItemType Directory -Path $tmpFolder > $null
            $landingPage = [System.IO.Path]::Combine($tmpFolder, ($moduleName + ".md"))
            $moduleOutputFolder = [System.IO.Path]::Combine($outputfolder, $moduleName)

            Write-Verbose "Processing Module: $moduleName"
            Write-Verbose "`tTemporary folder created: $tmpFolder"  

            Get-ChildItem -Path ($_.FullName) -Filter "*.md" -Recurse |
                Where-Object { -not $_.PSIsContainer } |
                Copy-Item -Destination $tmpFolder

            New-ExternalHelpCab -CabFilesFolder $tmpFolder -LandingPagePath $landingPage -OutputFolder $moduleOutputFolder 

            Remove-Item -Path $tmpFolder -Recurse -Force
            Write-Verbose "`tModule cab/zip generated" 
    }
}


