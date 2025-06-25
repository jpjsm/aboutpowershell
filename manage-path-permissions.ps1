$path = "C:\Hyper-V"
$me = whoami
$acl = Get-ACL -Path $path
$user = New-Object System.Security.Principal.Ntaccount($me)
$acl.SetOwner($User)
$acl | Set-Acl -Path $path

$acl = Get-ACL -Path $path
$acl.SetAccessRuleProtection($true,$false)
$ACL | Set-Acl -Path $path

$acl = Get-ACL -Path $path
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users","FullControl","Allow")
$acl.SetAccessRule($accessRule)
$acl | Set-Acl -Path $path

$acl = Get-ACL -Path $path
$acl.Access | Format-Table IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -AutoSize

Get-ChildItem -Path $path -Recurse |
   ForEach-Object {
      $acl | Set-Acl -Path $_.FullName
      Get-ACL -Path $_.FullName
   }