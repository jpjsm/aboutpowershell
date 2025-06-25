param($binary_file)
function BinaryFile2Base64File($binary_file)
{
    Set-Content -LiteralPath "$binary_file.b64" -Encoding ascii -Value ([convert]::ToBase64String((Get-Content -path "$binary_file" -AsByteStream )))
}

BinaryFile2Base64File $binary_file
