param (
    [string]$FilePath
)

# Check if the file exists
if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
    Write-Host "File not found: $FilePath"
    exit 1
}

# Read the list of service names from the input file
$ServiceNames = Get-Content -Path $FilePath

# Iterate through the service names and query their binary path names
foreach ($ServiceName in $ServiceNames) {
    try {
        # Run sc.exe qc command and capture the output
        $scOutput = sc.exe qc $ServiceName 2>&1

        # Use regex to find the BINARY_PATH_NAME
        $binaryPath = $scOutput | Select-String -Pattern 'BINARY_PATH_NAME\s+:\s+(.+)'

        # Check if a binary path was found
        if ($binaryPath) {
            # Extract the binary path value
            $binaryPath = $binaryPath.Matches.Groups[1].Value
            # Remove surrounding double quotes if present
            $binaryPath = $binaryPath -replace '^"|"$'
            # Remove any text after ".exe"
            $binaryPath = $binaryPath -replace '\.exe.*', '.exe'
            
            # Run Get-Acl for the binary path
            $acl = Get-Acl -Path $binaryPath
            
            # Display the service name in green
            Write-Host -ForegroundColor Green "Service Name: $ServiceName"
            
            # Display the binary path
            Write-Host "Binary Path Name: $binaryPath"
            
            # Display the ACL information
            $acl | Format-List
        } else {
            Write-Host "Service not found or no Binary Path Name found for: $ServiceName"
        }
    } catch {
        Write-Host "Service not found or error retrieving information for: $ServiceName"
    }
}
