# Define registry path and value (obfuscated variable names)
$rp = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\USBTracker"
$rv = "UsageCount"
$gh = "https://github.com/2MuchLag4you/rds-test/blob/main/"

# Create registry key/value if missing
if (-not (Test-Path $rp)) {
    New-Item -Path $rp -Force | Out-Null
    New-ItemProperty -Path $rp -Name $rv -Value 0 -PropertyType DWORD -Force | Out-Null
}

# Read and increment counter
$uc = (Get-ItemProperty -Path $rp -Name $rv).$rv
$uc++
Set-ItemProperty -Path $rp -Name $rv -Value $uc

# Lock system on first insert (asynchronously after showing message)
if ($uc -eq 1) {
    # Lock system using rundll32 with a delayed background job (more stealthy and native)
    Start-Job { Start-Sleep -Seconds 1; Start-Process "rundll32.exe" -ArgumentList "user32.dll,LockWorkStation" -WindowStyle Hidden } | Out-Null

    # Create message box informing the user that he or she didn't lock the system
    Add-Type -AssemblyName System.Windows.Forms
    $msg = "Please lock your system when you leave your desk. This is a reminder to help you remember to do so."
    $title = "Lock your system"
    $icon = [System.Windows.Forms.MessageBoxIcon]::Warning
    $button = [System.Windows.Forms.MessageBoxButtons]::OK
    [System.Windows.Forms.MessageBox]::Show($msg, $title, $button, $icon) | Out-Null
}
# After 5 inserts, download and show image
elseif ($uc -gt 5) {
    $ip = "$env:TEMP\" + "Mon" + "key-full-HD.jpg"
    try {
        $dl = New-Object Net.WebClient
        $dl.DownloadFile($gh + "Monkey-full-HD.jpg?raw=true", $ip)
        Start-Process "explorer.exe" -ArgumentList "`"$ip`""
    } catch {}
}

# Silent otherwise
