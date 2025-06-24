param($root_folder, $text2find)
function FindTextInFiles($root_folder, $text2find)
{
    Get-ChildItem -Path $root_folder -Recurse 
        | Where-Object { ! $_.PSIsContainer }
        | ForEach-Object { Write-Progress -Activity "Find all files containing '$text2find'" -Status $_.FullName; $_}
        | Select-String -Pattern $text2find -List
        | Select-Object -Property Path
        | ForEach-Object { $path = $_.Path; "$path"}
}

FindTextInFiles $root_folder $text2find