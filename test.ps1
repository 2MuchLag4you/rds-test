# Load .NET assembly for MessageBox and LockWorkStation
Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class LockWork {
    [DllImport("user32.dll")]
    public static extern void LockWorkStation();
}
"@

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
    # First insert: show warning and lock system
    [System.Windows.Forms.MessageBox]::Show("You forgot to lock your laptop. It will now be locked.", "Security Alert", 'OK', 'Warning')
    [LockWork]::LockWorkStation()
}
elseif ($count -gt 5) {
    # Sixth+ insert: show image
    $imagePath = "$env:TEMP\Monkey-full-HD.jpg"
    try {
        Invoke-WebRequest -Uri "$($githubWorkspace)Monkey-full-HD.jpg?raw=true" -OutFile $imagePath -ErrorAction Stop
        Start-Process $imagePath
    } catch {
        # Silently ignore errors
    }
}

# Silent otherwise
