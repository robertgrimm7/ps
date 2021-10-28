# Get the currently logged in user from the WMI object and split it into a new variable with just the username
$user = Get-WMIObject -class Win32_ComputerSystem | Select-Object -expandproperty username
$username = $user.split('\')[1]
#Translate it to a SID for registry reasons and then find the profile path from the HKLM hive
$sidObject = New-Object System.Security.Principal.NTAccount($username)
$sidTranslate = $sidObject.Translate([System.Security.Principal.SecurityIdentifier])
$sid = $sidTranslate.Value.Split('')[0]
$regPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\" + $sid
$profilePath = Get-ItemProperty $regPath | Select-Object -ExpandProperty ProfileImagePath
# Define the location of the Recycle Bin in the user's UPD, get it's current ACL, then alter it to restore the user's permissions
$rb = $profilePath + '\$RECYCLE.BIN'
$acl = Get-Acl $rb
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$user","FullControl","ContainerInherit,ObjectInherit","None","Allow")
$acl.SetAccessRule($AccessRule)
$acl | Set-Acl $rb