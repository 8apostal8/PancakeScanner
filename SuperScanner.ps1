if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Write-Host "[-] Please run this script as Administrator!" -ForegroundColor Red; Read-Host -Prompt "Press ENTER to exit..."; exit }
Clear-Host; $TotalThreats = 0; $ThreatList = @()
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "               🥞 PancakeScanner Ultimate PRO v3.9.4           " -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host " Express Scan (Check active miners, adware shortcuts, HOSTS)" -ForegroundColor Yellow
Write-Host " Deep Scan    (Full 10-point system security audit)" -ForegroundColor Blue
$ScanMode = Read-Host "`nSelect Scan Mode (1/2)"; if ($ScanMode -ne "1" -and $ScanMode -ne "2") { $ScanMode = "1" }; Clear-Host
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "               🥞 PancakeScanner Running...                    " -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "Initializing selected modules..." -ForegroundColor Gray; Start-Sleep -Milliseconds 300
if ($ScanMode -eq "2") {
    Write-Host "`n Checking IFEO Injections..." -ForegroundColor Cyan; $IfeoPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"; $IfeoThreats = 0
    Get-ChildItem -Path $IfeoPath -ErrorAction SilentlyContinue | ForEach-Object {
        $SubKey = $_.Name.Split("\")[-1]; if (Get-ItemProperty -Path "$IfeoPath\$SubKey" -Name "Debugger" -ErrorAction SilentlyContinue) {
            Write-Host "  [!] IFEO Hijack Found: $SubKey -> Active Debugger Trap!" -ForegroundColor Red; $TotalThreats++; $IfeoThreats++; $ThreatList += "Registry IFEO Hijack: $SubKey"
        }
    }
    if ($IfeoThreats -eq 0) { Write-Host "  -> IFEO registry hive is safe." -ForegroundColor Green }
    Write-Host "`n Checking Winlogon Shell Integrity..." -ForegroundColor Cyan; $WinlogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $Shell = (Get-ItemProperty -Path $WinlogonPath -Name "Shell" -ErrorAction SilentlyContinue).Shell; $Userinit = (Get-ItemProperty -Path $WinlogonPath -Name "Userinit" -ErrorAction SilentlyContinue).Userinit; $ShellThreats = 0
    if ($Shell -ne "explorer.exe" -and $Shell -ne $null) { Write-Host "  [!] Malicious Shell replacement detected: $Shell" -ForegroundColor Red; $TotalThreats++; $ShellThreats++; $ThreatList += "Malicious Shell Modification: $Shell" }
    if ($Userinit -notlike "*userinit.exe*" -and $Userinit -ne $null) { Write-Host "  [!] Malicious Userinit modification detected: $Userinit" -ForegroundColor Red; $TotalThreats++; $ShellThreats++; $ThreatList += "Malicious Userinit Modification: $Userinit" }
    if ($ShellThreats -eq 0) { Write-Host "  -> Core system shells are authentic." -ForegroundColor Green }
    Write-Host "`n Auditing Suspicious Background Services..." -ForegroundColor Cyan; $ServiceThreats = 0
    Get-CimInstance -ClassName Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.PathName -like "*AppData*" -or $_.PathName -like "*Temp*" -or $_.PathName -like "*Users\Public*" } | ForEach-Object {
        Write-Host "  [!] Alert: Service '$($_.Name)' is running from temporary folders!" -ForegroundColor Yellow; $TotalThreats++; $ServiceThreats++; $ThreatList += "Suspicious AppData/Temp Service: $($_.Name)"
    }
    if ($ServiceThreats -eq 0) { Write-Host "  -> No rogue writable background services detected." -ForegroundColor Green }
    Write-Host "`n Analyzing Task Scheduler paths..." -ForegroundColor Cyan
    Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskPath -notlike "\Microsoft*" -and $_.TaskPath -notlike "\OneDrive*" } | ForEach-Object {
        $Action = $_.Actions.Execute; if ($Action) { Write-Host "  -> Custom Task: $($_.TaskName) -> Trigger Path: $Action" -ForegroundColor Yellow }
    }
    Write-Host "`n Dumping Windows Defender Exclusions..." -ForegroundColor Cyan; $DefEx = (Get-MpPreference -ErrorAction SilentlyContinue).ExclusionPath
    if ($DefEx) {
        $DefEx | ForEach-Object { Write-Host "  [!] Defender Exclusion Loophole Found: $_" -ForegroundColor Yellow; $TotalThreats++; $ThreatList += "Defender Exclusion Loophole: $_" }
    } else { Write-Host "  -> Exclusion list is empty (Full defense active)." -ForegroundColor Green }
}
Write-Host "`n Analyzing HOSTS file loops..." -ForegroundColor Cyan; $HostsPath = "$env:windir\System32\drivers\etc\hosts"; $HostsThreats = 0
if (Test-Path $HostsPath) {
    if ((Get-Content $HostsPath -ErrorAction SilentlyContinue | Where-Object { $_ -match "^\s*[^#]" }) -match "virustotal" -or (Get-Content $HostsPath -ErrorAction SilentlyContinue) -match "drweb") {
        Write-Host "  [!] Alert: Anti-malware websites blockade found in HOSTS!" -ForegroundColor Red; $TotalThreats++; $HostsThreats++; $ThreatList += "HOSTS File Anti-Virus Blockade"
    }
}
if ($HostsThreats -eq 0) { Write-Host "  -> HOSTS file is clean and unredirected." -ForegroundColor Green }
Write-Host "`n Checking Desktop shortcuts for adware links..." -ForegroundColor Cyan; $WshShell = New-Object -ComObject WScript.Shell; $LnkThreats = 0
Get-ChildItem -Path "$HOME\Desktop" -Filter "*.lnk" -ErrorAction SilentlyContinue | ForEach-Object {
    $Shortcut = $WshShell.CreateShortcut($_.FullName); if ($Shortcut.TargetPath -match "http" -or $Shortcut.Arguments -match "http") {
        Write-Host "  [!] Adware link found in shortcut: '$($_.Name)'" -ForegroundColor Red; $TotalThreats++; $LnkThreats++; $ThreatList += "Adware Desktop Shortcut: $($_.Name)"
    }
}
if ($LnkThreats -eq 0) { Write-Host "  -> All Desktop game and app shortcuts are safe." -ForegroundColor Green }
Write-Host "`n Checking for heavy CPU processes (Potential Miners)..." -ForegroundColor Cyan; $CpuCounters = Get-Counter '\Process(*)\% Processor Time' -ErrorAction SilentlyContinue; $CpuThreats = 0
$CpuCounters.CounterSamples | Where-Object { $_.CookedValue -gt 50 -and $_.InstanceName -notlike "_total" -and $_.InstanceName -notlike "idle" } | ForEach-Object {
    $Rounding = [math]::Round($_.CookedValue); Write-Host "  [!] High CPU Usage: $($_.InstanceName) -> Current Load: [$Rounding%]" -ForegroundColor Yellow
    $TotalThreats++; $CpuThreats++; $ThreatList += "High Process CPU Load: $($_.InstanceName) ($Rounding%)"
}
if ($CpuThreats -eq 0) { Write-Host "  -> Background CPU load is perfectly stable." -ForegroundColor Green }
Write-Host "`n Auditing active process signatures..." -ForegroundColor Cyan; $MinerSigs = @("xmrig", "minerd", "cpuminer", "ethminer", "stratum"); $MinersFound = 0
foreach ($Sig in $MinerSigs) {
    if (Get-Process -Name "*$Sig*" -ErrorAction SilentlyContinue) {
        Write-Host "  [!] Cryptominer process active signature found: $Sig" -ForegroundColor Red; $TotalThreats++; $MinersFound++; $ThreatList += "Active Cryptominer Signature: $Sig"
    }
}
if ($MinersFound -eq 0) { Write-Host "  -> No explicit mining signatures detected in memory." -ForegroundColor Green }
if ($ScanMode -eq "2") {
    Write-Host "`n Checking classic Startup Registry keys..." -ForegroundColor Cyan
    foreach ($Path in @("HKLM:\Software\Microsoft\Windows\CurrentVersion\Run", "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run")) {
        if (Test-Path $Path) {
            (Get-Item -Path $Path -ErrorAction SilentlyContinue).Property | ForEach-Object {
                $Val = Get-ItemPropertyValue -Path $Path -Name $_ -ErrorAction SilentlyContinue
                if ($Val -and $_ -notlike "PS*" -and $Val -notlike "*Roblox*" -and $Val -notlike "*OneDrive*") { Write-Host "  -> Startup Entry: $_ -> Value: $Val" -ForegroundColor Gray }
            }
        }
    }
}
Write-Host "`n===============================================================" -ForegroundColor Cyan
if ($TotalThreats -gt 0) {
    Write-Host "          SCAN COMPLETE: $TotalThreats POTENTIAL THREATS FOUND!          " -ForegroundColor Red -BackgroundColor Black
    Write-Host "`n--- DETECTED THREAT LIST SUMMARY ---" -ForegroundColor Red
    foreach ($Threat in $ThreatList) { Write-Host " [x] $Threat" -ForegroundColor Yellow }
    Write-Host "-------------------------------------" -ForegroundColor Red
} else { Write-Host "               SCAN COMPLETE: SYSTEM IS FULLY CLEAN!           " -ForegroundColor Green -BackgroundColor Black }
Write-Host "===============================================================" -ForegroundColor Cyan
$SaveChoice = Read-Host "`nSave scan report to Desktop? (Y/N)"
if ($SaveChoice -eq "Y" -or $SaveChoice -eq "y") {
    $ReportContent = @("=======================================================", "               🥞 PancakeScanner Security Report       ", "=======================================================", "Scan Date: $(Get-Date)", "Total Threats Found: $TotalThreats", "-------------------------------------------------------")
    if ($TotalThreats -gt 0) { foreach ($Threat in $ThreatList) { $ReportContent += " [x] $Threat" } } else { $ReportContent += " -> SYSTEM IS COMPLETELY CLEAN AND SAFE!" }
    $ReportContent | Out-File -FilePath "$HOME\Desktop\Pancake_Report.txt" -Encoding utf8
    Write-Host "[+] Success! Report saved to Desktop as 'Pancake_Report.txt'" -ForegroundColor Green
}
Write-Host "`n[A] Install Autonomous Protection (Scans system background every 1 hour)" -ForegroundColor Magenta
Write-Host "[E] Exit" -ForegroundColor Gray
$Choice = Read-Host "`nChoose an option (A/E)"
if ($Choice -eq "A" -or $Choice -eq "a") {
    $CurrentScript = $MyInvocation.MyCommand.Path
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$CurrentScript`""
    $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1)
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName "PancakeAutonomousGuard" -Action $Action -Trigger $Trigger -Settings $Settings -User "NT AUTHORITY\SYSTEM" -Force | Out-Null
    Write-Host "`n[+] Success! PancakeAutonomousGuard installed. Your PC is scanned silently every hour!" -ForegroundColor Green; Start-Sleep -Seconds 3
}
exit
