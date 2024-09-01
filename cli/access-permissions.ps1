# Apply access permissions

# Check if the required files and directories exist
if (-Not (Test-Path './constants.php') -or -Not (Test-Path './cli/')) {
    Write-Error '⛔ It does not look like a FreshRSS directory; exiting!'
    exit 2
}

# Check if the script is running as an administrator
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error '⛔ Applying access permissions requires running as an administrator!'
    exit 3
}

# Based on group access
Get-ChildItem -Recurse | ForEach-Object { 
    $acl = Get-Acl $_.FullName
    $acl.SetAccessRuleProtection($true, $false)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\IIS_IUSRS", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl $_.FullName $acl
}

# Read files, and directory traversal
Get-ChildItem -Recurse | ForEach-Object { 
    $acl = Get-Acl $_.FullName
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\IIS_IUSRS", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl $_.FullName $acl
}

# Write access
New-Item -ItemType Directory -Force -Path './data/users/_/'
Get-ChildItem -Recurse './data/' | ForEach-Object { 
    $acl = Get-Acl $_.FullName
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\IIS_IUSRS", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl $_.FullName $acl
}
