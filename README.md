# 🥞 PancakeScanner v3.2 (PowerShell)

**PancakeScanner** is a fast, lightweight, and completely open-source Windows security scanner built with PowerShell. It scans your system in less than 3 seconds to detect hidden registry startup traps, adware shortcuts, high-CPU miners, and malicious services that standard antiviruses often miss.

---

## 🚀 Key Features (10-Point Defense System):
* **IFEO Injection Scan:** Detects hidden Image File Execution Options registry traps used by malware to hijack system apps.
* **Winlogon Shell Integrity:** Checks if core system shells (`explorer.exe` and `userinit.exe`) have been modified or replaced.
* **Suspicious Services Audit:** Automatically scans user-writable directories (`AppData`, `Temp`, `Users`) for active malicious background services.
* **Smart Task Scheduler Filter:** Hides hundreds of native Microsoft tasks to display only third-party custom tasks (malware persistence, network bypass utilities like Zapret, etc.).
* **Windows Defender Exclusions Check:** Reveals if any directory has been secretly whitelisted by a trojan.
* **HOSTS File Analysis:** Scans for unauthorized redirection loops or anti-malware website blockades.
* **Browser & Game Shortcuts Adware Scan:** Inspects Desktop `.lnk` shortcuts to find appended hidden advertising links (like adware bundle leftovers).
* **Crypto-Miner Detection:** Monitors background activity to instantly highlight processes consuming more than 50% CPU power.
* **Miner Process Audit:** Scans all active system processes in real-time to find hidden crypto-miners hiding from Task Manager.
* **Classic Startup Registry Scan:** Audits key `Run` paths in both HKLM and HKCU registry hives with smart ignore-lists for trusted apps like Roblox and OneDrive.

---

## 🛠️ How to Download and Run (The Easiest Way):

To easily launch the scanner with full Administrator privileges and bypass Windows security flags without opening the terminal manually, follow these 4 simple steps:

1. Download and extract the **PancakeScanner** ZIP archive from the **Releases** section to your computer.
2. Right-click on your **Desktop** -> select **New** -> **Shortcut**.
3. In the location field, copy and paste the following command and click **Next**:

```powershell
powershell.exe -NoExit -ExecutionPolicy Bypass -File "\$HOME\Downloads\PancakeScanner-3.2\PancakeScanner-3.2\SuperScanner.ps1"
```

4. Name the shortcut `PancakeScanner`, click **Finish**, then right-click your new shortcut -> choose **Properties** -> click the **Advanced...** button -> check **Run as administrator** and click **OK**.

🎉 **That's it!** Now you can simply double-click this Desktop shortcut anytime you want to audit your PC. The scan will complete in 3 seconds, and the window will stay open for you to read the clean green logs!

---
*Powered by Pancake Power. The source code is entirely open for audit and completely safe to use.*
