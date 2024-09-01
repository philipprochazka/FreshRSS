# Strips sensitive passwords from (Apache) logs

# Function to replace sensitive data in logs
function Strip-SensitiveData {
    param (
        [string]$logFile
    )

    # Check if the log file exists
    if (-Not (Test-Path $logFile)) {
        Write-Error "Log file not found: $logFile"
        return
    }

    # Read the log file and replace sensitive data
    Get-Content $logFile | ForEach-Object {
        $_ -replace '([?&])(Passwd|token)=[^& \t]+', '$1$2=redacted'
    } | Set-Content $logFile
}

# Example usage
Strip-SensitiveData -logFile "path\to\your\logfile.log"
