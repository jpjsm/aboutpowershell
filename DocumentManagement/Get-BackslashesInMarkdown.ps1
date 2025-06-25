[int] $rownumber = 1
Get-ChildItem -Path "C:\PSReferenceConversion\reference\" -Filter "*.md" -Recurse |
    Select-String -Pattern "[^\\]\\[-_<>\[\]()]" -AllMatches |
    ForEach-Object {
        Add-Member -InputObject $_ -NotePropertyName "RowNumber" -NotePropertyValue $rownumber -PassThru
        $rownumber++
    } |
    Format-Table -Property RowNumber,Path,linenumber,line -Wrap -AutoSize