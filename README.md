# 🥞 PancakeScanner v3.7 (PowerShell)

**PancakeScanner** is a fast, lightweight, and completely open-source Windows security scanner built with PowerShell. It scans your system in less than 3 seconds to detect hidden registry startup traps, adware shortcuts, high-CPU miners, and malicious services that standard antiviruses often miss.

---

## 🚀 Key Features (10-Point Defense System):
* **IFEO Injection Scan:** Detects hidden Image File Execution Options registry traps used by malware to hijack system apps.
* **Winlogon Shell Integrity:** Checks if core system shells (`explorer.exe` and `userinit.exe`) have been modified or replaced.
* **Suspicious Services Audit:** Automatically scans user-writable directories (`AppData`, `Temp`, `Users`) for active malicious background services.
* **Smart Task Scheduler Filter:** Hides hundreds of native Microsoft tasks to display only third-party custom tasks.
* **Windows Defender Exclusions Check:** Reveals if any directory has been secretly whitelisted by a trojan.
* **HOSTS File Analysis:** Scans for unauthorized redirection loops or anti-malware website blockades.
* **Browser & Game Shortcuts Adware Scan:** Inspects Desktop `.lnk` shortcuts to find appended hidden advertising links.
* **Crypto-Miner Detection:** Monitors background activity to instantly highlight processes consuming more than 50% CPU power.
* **Miner Process Audit:** Scans all active system processes in real-time to find hidden crypto-miners hiding from Task Manager.
* **Classic Startup Registry Scan:** Audits key `Run` paths in both HKLM and HKCU registry hives with smart ignore-lists for trusted apps like Roblox and OneDrive.

---

## 🛠️ How to Run:

1. Download and extract the **PancakeScanner** ZIP archive from the **Releases** section to your computer.
2. Press **Win + X** on your keyboard and launch **Terminal (Admin)** or **PowerShell (Admin)**.
3. Copy, paste the following command into the terminal, and hit **ENTER**:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process -Force; Unblock-File -Path "$HOME\Downloads\PancakeScanner-3.7\PancakeScanner-3.7\SuperScanner.ps1"; cd "$HOME\Downloads\PancakeScanner-3.7\PancakeScanner-3.7"; .\SuperScanner.ps1
```

---
*Powered by Pancake Power. The source code is entirely open for audit and completely safe to use.*

