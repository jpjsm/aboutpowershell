## Define parameters
$Metadata = @{
    "keywords" = "dsc,powershell,configuration,setup" 
    "ms.date" = [DateTime]::Now.ToString("yyyy-MM-dd")
    "ms.topic" = "conceptual"
    "author" = "eslesar"
}

## , "schema"
## , "locale"

$TagsToRemove = @(
, "applies_to"
, "author"
, "caps.latest.revision"
, "manager"
, "ms.assetid"
, "ms.author"
, "ms.custom"
, "ms.devlang"
, "ms.prod"
, "ms.reviewer"
, "ms.suite"
, "ms.technology"
, "ms.tgt_pltfr"
)



Update-MetadataInTopics -mdDocumentsFolder "C:\Repos\GitHub\msft\PowerShell-Docs\dsc" -NewMetadata $Metadata -MetadataTagsToRemove $TagsToRemove  -Verbose

