# Define registry path and value
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\USBTracker"
$regName = "UsageCount"
$githubWorkspace = "https://github.com/2MuchLag4you/rds-test/blob/main/"

# Create key/value if missing
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    New-ItemProperty -Path $regPath -Name $regName -Value 0 -PropertyType DWORD -Force | Out-Null
}

# Read and increment the counter
$count = (Get-ItemProperty -Path $regPath -Name $regName).$regName
$count++
Set-ItemProperty -Path $regPath -Name $regName -Value $count

# --- Actions based on insert count ---
if ($count -eq 1) {
    # First insert: lock system using rundll32 for stealth
    Start-Process "rundll32.exe" -ArgumentList "user32.dll,LockWorkStation"
}
elseif ($count -gt 5) {
    # Sixth+ insert: show image using WebClient and explorer for stealth
    $imagePath = "$env:TEMP\Monkey-full-HD.jpg"
    try {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile("$($githubWorkspace)Monkey-full-HD.jpg?raw=true", $imagePath)
        Start-Process "explorer.exe" -ArgumentList "`"$imagePath`""
    } catch {
        # Silently ignore errors
    }
}

# Silent otherwise
