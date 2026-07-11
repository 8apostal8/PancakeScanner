# Принудительно включаем поддержку смайликов и красивых значков
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "               SUPER SCANNER V3 (POWERSHELL)              " -ForegroundColor Cyan -BackgroundColor DarkBlue
Write-Host "==========================================================`n" -ForegroundColor Cyan

# 1. Debugger (IFEO)
Write-Host "[1] Checking Debugger (IFEO) traps..." -ForegroundColor Yellow
$IfeoPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
$IfeoSubKeys = Get-ChildItem -Path $IfeoPath -ErrorAction SilentlyContinue
$IfeoFound = $false
foreach ($Key in $IfeoSubKeys) {
    $Val = Get-ItemProperty -Path $Key.PSPath -ErrorAction SilentlyContinue
    if ($Val.Debugger) {
        Write-Host "⚠️ TRAP DETECTED: $($Key.PSChildName) -> Debugger = $($Val.Debugger)" -ForegroundColor Red
        $IfeoFound = $true
    }
}
if (-not $IfeoFound) { Write-Host " -> IFEO is clean." -ForegroundColor Green }

# 2. Winlogon
Write-Host "`n[2] Checking Winlogon Shell & Userinit..." -ForegroundColor Yellow
$WinlogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$Winlogon = Get-ItemProperty -Path $WinlogonPath -ErrorAction SilentlyContinue
if ($Winlogon.Shell -ne "explorer.exe") { Write-Host "⚠️ BAD SHELL: $($Winlogon.Shell)" -ForegroundColor Red } 
else { Write-Host " -> Shell is OK (explorer.exe)." -ForegroundColor Green }
if ($Winlogon.Userinit -notmatch "userinit.exe") { Write-Host "⚠️ BAD USERINIT: $($Winlogon.Userinit)" -ForegroundColor Red } 
else { Write-Host " -> Userinit is OK." -ForegroundColor Green }

# 3 & 4. Services in User Folders
Write-Host "`n[3-4] Checking suspicious Services (AppData/Temp)..." -ForegroundColor Yellow
$ServicesPath = "HKLM:\SYSTEM\CurrentControlSet\Services"
$SuspiciousServices = Get-ChildItem -Path $ServicesPath | ForEach-Object { Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue } | Where-Object { $_.ImagePath -match "appdata|local|temp|users" -and $_.ImagePath -notmatch "dwscanner|drweb" }
if ($SuspiciousServices) {
    foreach ($Service in $SuspiciousServices) { Write-Host "⚠️ Suspicious service: $($Service.PSChildName) -> $($Service.ImagePath)" -ForegroundColor DarkYellow }
} else { Write-Host " -> AppData/Temp services are clean." -ForegroundColor Green }

# 5. Task Scheduler
Write-Host "`n[5] Analyzing active custom Tasks..." -ForegroundColor Yellow
$Tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskPath -notmatch "\\Microsoft\\Windows" -and $_.State -ne "Disabled" }
if ($Tasks) {
    foreach ($Task in $Tasks) {
        $Action = $Task.Actions | ForEach-Object { $_.Execute + " " + $_.Argument }
        Write-Host " -> Task: $($Task.TaskName) -> Run: $Action" -ForegroundColor Cyan
    }
} else { Write-Host " -> Custom tasks not found." -ForegroundColor Green }

# 6. Defender Exclusions
Write-Host "`n[6] Checking Defender Exclusions..." -ForegroundColor Yellow
$PathsReg = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"
$Exclusions = Get-ItemProperty -Path $PathsReg -ErrorAction SilentlyContinue
if ($Exclusions) {
    $Exclusions.psobject.properties | Where-Object { $_.Name -notmatch "PS|Name" } | ForEach-Object { Write-Host "⚠️ Excluded path: $($_.Name)" -ForegroundColor Red }
} else { Write-Host " -> Exclusion list is empty." -ForegroundColor Green }

# 7. HOSTS File
Write-Host "`n[7] Analyzing HOSTS file..." -ForegroundColor Yellow
$HostsPath = "$env:windir\System32\drivers\etc\hosts"
if (Test-Path $HostsPath) {
    $HostsContent = Get-Content $HostsPath | Where-Object { $_ -match "^\s*[^#]" }
    if ($HostsContent) {
        Write-Host "⚠️ Redirects found in HOSTS:" -ForegroundColor Magenta
        $HostsContent | ForEach-Object { Write-Host "   $_" -ForegroundColor Magenta }
    } else { Write-Host " -> HOSTS file is clean." -ForegroundColor Green }
}

# 8. Browser Shortcuts
Write-Host "`n[8] Checking Desktop shortcuts for adware links..." -ForegroundColor Yellow
$WshShell = New-Object -ComObject WScript.Shell
$DesktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$Shortcuts = Get-ChildItem -Path $DesktopPath -Filter *.lnk
$LnkFound = $false
foreach ($Shortcut in $Shortcuts) {
    $Target = $WshShell.CreateShortcut($Shortcut.FullName)
    if ($Target.Arguments -match "http|www|\.ru|\.com|\.net") {
        Write-Host "⚠️ Adware link in shortcut: '$($Shortcut.Name)' -> $($Target.Arguments)" -ForegroundColor Red
        $LnkFound = $true
    }
}
if (-not $LnkFound) { Write-Host " -> All desktop shortcuts are clean." -ForegroundColor Green }

# 9. Heavy Processes (Поиск скрытых майнеров)
Write-Host "`n[9] Checking for heavy CPU processes (Potential Miners)..." -ForegroundColor Yellow
$HeavyProcs = Get-Process | Where-Object { $_.CPU -gt 50 }
if ($HeavyProcs) {
    foreach ($Proc in $HeavyProcs) {
        Write-Host "⚠️ High CPU Usage: $($Proc.Name) (PID: $($Proc.Id))" -ForegroundColor DarkYellow
    }
} else { Write-Host " -> CPU loads are perfectly normal." -ForegroundColor Green }

# 10. Startup Registry Items
Write-Host "`n[10] Checking classic Startup Registry keys..." -ForegroundColor Yellow
$RunKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)
$RunFound = $false
foreach ($Path in $RunKeys) {
    $Items = Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue
    if ($Items) {
        $Items.psobject.properties | Where-Object { $_.Name -notmatch "PS|Name" } | ForEach-Object {
            # Белый список чистых программ, чтобы не было ложных тревог
            if ($_.Value -match "appdata|temp|local" -and $_.Value -notmatch "onedrive|utweb|customcursor|roblox") {
                Write-Host "⚠️ Suspicious Autorun Item: $($_.Name) -> $($_.Value)" -ForegroundColor Red
                $RunFound = $true
            }
        }
    }
}
if (-not $RunFound) { Write-Host " -> Basic Registry Startup is clean." -ForegroundColor Green }

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "                 SCAN COMPLETE SUCCESSFULLY!              " -ForegroundColor Green -BackgroundColor DarkGreen
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "`nPress ENTER to exit..." -ForegroundColor Gray
[void][System.Console]::ReadLine()
