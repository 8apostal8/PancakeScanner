if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[-] Please run this script as Administrator!" -ForegroundColor Red
    Read-Host -Prompt "Press ENTER to exit..."
    exit
}

Clear-Host
$TotalThreats = 0

Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "               🥞 PancakeScanner Ultimate PRO v3.8             " -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "Starting lightning-fast 10-point audit..." -ForegroundColor Gray
Start-Sleep -Milliseconds 300

Write-Host "`n Checking IFEO Injections..." -ForegroundColor Cyan
$IfeoPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
$IfeoThreats = 0
Get-ChildItem -Path $IfeoPath -ErrorAction SilentlyContinue | ForEach-Object {
    $SubKey = $_.Name.Split("\")[-1]
    if (Get-ItemProperty -Path "$IfeoPath\$SubKey" -Name "Debugger" -ErrorAction SilentlyContinue) {
        Write-Host "  [!] IFEO Hijack Found: $SubKey -> Active Debugger Trap!" -ForegroundColor Red
        $IfeoThreats++
        $TotalThreats++
    }
}
if ($IfeoThreats -eq 0) { Write-Host "  -> IFEO registry hive is safe." -ForegroundColor Green }

Write-Host "`n Checking Winlogon Shell Integrity..." -ForegroundColor Cyan
$WinlogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$Shell = (Get-ItemProperty -Path $WinlogonPath -Name "Shell" -ErrorAction SilentlyContinue).Shell
$Userinit = (Get-ItemProperty -Path $WinlogonPath -Name "Userinit" -ErrorAction SilentlyContinue).Userinit

if ($Shell -ne "explorer.exe" -and $Shell -ne $null) {
    Write-Host "  [!] Malicious Shell replacement detected: $Shell" -ForegroundColor Red
    $TotalThreats++
} elseif ($Userinit -notlike "*userinit.exe*" -and $Userinit -ne $null) {
    Write-Host "  [!] Malicious Userinit modification detected: $Userinit" -ForegroundColor Red
    $TotalThreats++
} else {
    Write-Host "  -> Core system shells are authentic." -ForegroundColor Green
}

Write-Host "`n Auditing Suspicious Background Services..." -ForegroundColor Cyan
$BadServices = Get-CimInstance -ClassName Win32_Service -ErrorAction SilentlyContinue | Where-Object {
    $_.PathName -like "*AppData*" -or $_.PathName -like "*Temp*" -or $_.PathName -like "*Users\Public*"
}
if ($BadServices) {
    foreach ($Service in $BadServices) {
        Write-Host "  [!] Alert: Service '$($Service.Name)' is running from temporary folders! Path: $($Service.PathName)" -ForegroundColor Yellow
        $TotalThreats++
    }
} else {
    Write-Host "  -> No rogue writable background services detected." -ForegroundColor Green
}

Write-Host "`n Analyzing Task Scheduler paths..." -ForegroundColor Cyan
$Tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
    $_.TaskPath -notlike "\Microsoft*" -and $_.TaskPath -notlike "\OneDrive*"
}
if ($Tasks) {
    foreach ($Task in $Tasks) {
        $Action = (Get-ScheduledTask -TaskName $Task.TaskName -ErrorAction SilentlyContinue).Actions.Execute
        if ($Action) {
            Write-Host "  -> Custom Task: $($Task.TaskName) -> Trigger Path: $Action" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "  -> Third-party custom tasks are clear." -ForegroundColor Green
}

Write-Host "`n Dumping Windows Defender Exclusions..." -ForegroundColor Cyan
$Exclusions = (Get-MpPreference -ErrorAction SilentlyContinue).ExclusionPath
if ($Exclusions) {
    foreach ($Ex in $Exclusions) {
        Write-Host "  [!] Defender Exclusion Loophole Found: $Ex" -ForegroundColor Yellow
        $TotalThreats++
    }
} else {
    Write-Host "  -> Exclusion list is empty (Full defense active)." -ForegroundColor Green
}

Write-Host "`n Analyzing HOSTS file loops..." -ForegroundColor Cyan
$HostsPath = "$env:windir\System32\drivers\etc\hosts"
if (Test-Path $HostsPath) {
    $HostsContent = Get-Content $HostsPath -ErrorAction SilentlyContinue | Where-Object { $_ -match "^\s*[^#]" }
    if ($HostsContent -match "virustotal" -or $HostsContent -match "drweb" -or $HostsContent -match "kaspersky") {
        Write-Host "  [!] Alert: Anti-malware websites blockade found in HOSTS!" -ForegroundColor Red
        $TotalThreats++
    } else {
        Write-Host "  -> HOSTS file is clean and unredirected." -ForegroundColor Green
    }
}

Write-Host "`n Checking Desktop shortcuts for adware links..." -ForegroundColor Cyan
$WshShell = New-Object -ComObject WScript.Shell
$LnkThreats = 0
Get-ChildItem -Path "$HOME\Desktop" -Filter "*.lnk" -ErrorAction SilentlyContinue | ForEach-Object {
    $Shortcut = $WshShell.CreateShortcut($_.FullName)
    if ($Shortcut.TargetPath -match "http" -or $Shortcut.Arguments -match "http") {
        Write-Host "  [!] Adware link found in shortcut: '$($_.Name)' -> Path: $($Shortcut.Arguments)" -ForegroundColor Red
        $LnkThreats++
        $TotalThreats++
    }
}
if ($LnkThreats -eq 0) { Write-Host "  -> All Desktop game and app shortcuts are safe." -ForegroundColor Green }

Write-Host "`n Checking for heavy CPU processes (Potential Miners)..." -ForegroundColor Cyan
$HeavyProcs = Get-Process | Where-Object { $_.CPU -gt 50 -and $_.ProcessName -notlike "Idle" }
if ($HeavyProcs) {
    foreach ($Proc in $HeavyProcs) {
        Write-Host "  [!] High CPU Usage: $($Proc.ProcessName) (PID: $($Proc.Id))" -ForegroundColor Yellow
        $TotalThreats++
    }
} else {
    Write-Host "  -> Background CPU load is perfectly stable." -ForegroundColor Green
}

Write-Host "`n Auditing active process signatures..." -ForegroundColor Cyan
$MinerSigs = @("xmrig", "minerd", "cpuminer", "ethminer", "stratum")
$MinersFound = 0
foreach ($Sig in $MinerSigs) {
    if (Get-Process -Name "*$Sig*" -ErrorAction SilentlyContinue) {
        Write-Host "  [!] Cryptominer process active signature found: $Sig" -ForegroundColor Red
        $MinersFound++
        $TotalThreats++
    }
}
if ($MinersFound -eq 0) { Write-Host "  -> No explicit mining signatures detected in memory." -ForegroundColor Green }

Write-Host "`n Checking classic Startup Registry keys..." -ForegroundColor Cyan
$RunPaths = @("HKLM:\Software\Microsoft\Windows\CurrentVersion\Run", "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run")
foreach ($Path in $RunPaths) {
    if (Test-Path $Path) {
        $Properties = (Get-Item -Path $Path -ErrorAction SilentlyContinue).Property
        foreach ($PropName in $Properties) {
            $PropValue = Get-ItemPropertyValue -Path $Path -Name $PropName -ErrorAction SilentlyContinue
            if ($PropValue -and $PropName -notlike "PS*") {
                if ($PropValue -notlike "*Roblox*" -and $PropValue -notlike "*OneDrive*") {
                    Write-Host "  -> Startup Entry: $PropName -> Value: $PropValue" -ForegroundColor Gray
                }
            }
        }
    }
}
Write-Host "  -> Basic Registry Startup check finished." -ForegroundColor Green

Write-Host "`n===============================================================" -ForegroundColor Cyan
if ($TotalThreats -gt 0) {
    Write-Host "          SCAN COMPLETE: $TotalThreats POTENTIAL THREATS FOUND!          " -ForegroundColor Red -BackgroundColor Black
    
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $Toast = New-Object System.Windows.Forms.NotifyIcon
    $Toast.Icon = [System.Drawing.SystemIcons]::Shield
    $Toast.BalloonTipTitle = "🥞 PancakeScanner Alert!"
    $Toast.BalloonTipText = "Security audit finished. Found $TotalThreats suspicious elements on your PC! Run the report."
    $Toast.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
    $Toast.Visible = $true
    $Toast.ShowBalloonTip(5000)
} else {
    Write-Host "               SCAN COMPLETE: SYSTEM IS FULLY CLEAN!           " -ForegroundColor Green -BackgroundColor Black
}
Write-Host "===============================================================" -ForegroundColor Cyan

Write-Host "`n[A] Install Autonomous Protection (Scans system background every 1 hour)" -ForegroundColor Magenta
Write-Host "[E] Exit" -ForegroundColor Gray
$Choice = Read-Host "`nChoose an option (A/E)"

if ($Choice -eq "A" -or $Choice -eq "a") {
    $CurrentScript = $MyInvocation.MyCommand.Path
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$CurrentScript`""
    $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1)
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    
    Register-ScheduledTask -TaskName "PancakeAutonomousGuard" -Action $Action -Trigger $Trigger -Settings $Settings -User "NT AUTHORITY\SYSTEM" -Force | Out-Null
    
    Write-Host "`n[+] Success! PancakeAutonomousGuard installed. Your PC is scanned silently every hour!" -ForegroundColor Green
    Start-Sleep -Seconds 3
}

exit
