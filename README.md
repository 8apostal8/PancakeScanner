# 🥞 PancakeScanner v3 (PowerShell)

**PancakeScanner** is a fast, lightweight, and completely open-source Windows security scanner built with PowerShell. It scans your system in less than 3 seconds to detect hidden registry startup traps, adware shortcuts, high-CPU miners, and malicious services that standard antiviruses often miss [INDEX: 1.4.1, 14, 20].

---

## 🚀 Key Features (10-Point Defense System):
* **IFEO Injection Scan:** Detects hidden Image File Execution Options registry traps used by malware to hijack system apps [INDEX: 18].
* **Winlogon Shell Integrity:** Checks if core system shells (`explorer.exe` and `userinit.exe`) have been modified or replaced.
* **Suspicious Services Audit:** Automatically scans user-writable directories (`AppData`, `Temp`, `Users`) for active malicious background services [INDEX: 18, 24].
* **Smart Task Scheduler Filter:** Hides hundreds of native Microsoft tasks to display only third-party custom tasks (malware persistence, network bypass utilities like Zapret, etc.).
* **Windows Defender Exclusions Check:** Reveals if any directory has been secretly whitelisted by a trojan.
* **HOSTS File Analysis:** Scans for unauthorized redirection loops or anti-malware website blockades.
* **Browser & Game Shortcuts Adware Scan:** Inspects Desktop `.lnk` shortcuts to find appended hidden advertising links (like adware bundle leftovers) [INDEX: 1.3.1].
* **Crypto-Miner Detection:** Monitors background activity to instantly highlight processes consuming more than 50% CPU power.
* **Miner Process Audit:** Scans all active system processes in real-time to find hidden crypto-miners hiding from Task Manager.
* **Classic Startup Registry Scan:** Audits key `Run` paths in both HKLM and HKCU registry hives with smart ignore-lists for trusted apps like Roblox and OneDrive.

---

## 🛠️ How to Download and Run:

Since Windows blocks self-made PowerShell scripts by default for safety reasons, execute the scanner using this simple and foolproof method:

1. Download the `SuperScanner.ps1` file from the **Releases** section to your computer.
2. Press **Win + X** on your keyboard and launch **Terminal (Admin)** or **PowerShell (Admin)**.
3. Copy and paste the following short command into the terminal window to temporarily allow script execution, then hit **ENTER**:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
```

4. Now, simply **drag and drop** your downloaded `SuperScanner.ps1` file directly into that terminal window (Windows will automatically fill in the correct path) and hit **ENTER** to run the scan!

5. The scanner completes its diagnostic run in roughly 3 seconds [INDEX: 14]. Safe parameters are highlighted in **green**, while suspicious triggers turn **red/yellow**.

---
*Powered by Pancake Power. The source code is entirely open for audit and completely safe to use [INDEX: 20].*
