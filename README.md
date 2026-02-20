Run this script on new images of Kali for an OSCP-friendly set of configurations and tools.
---

## Complete List of Everything This Script Does:

**System Configuration:**
- Auto-sizes VMware display resolution
- Makes display auto-resize persistent (adds to ~/.profile)
- Enables and starts SSH service
- Sets timezone to America/Los_Angeles
- Enables NTP time synchronization
- Creates /home/kali/transfers directory
- Updates package repositories

**Wordlists:**
- Installs SecLists
- Unzips RockYou wordlist

**Utilities:**
- Installs KeePass2
- Installs and configures SNMP MIBs (downloads and enables them)

**Active Directory Tools:**
- BloodHound + Neo4j
- bloodhound-python (via pipx or pip)
- PowerView.ps1
- Mimikatz (x64)
- Seatbelt.exe
- SharpUp.exe
- SharpHound.exe

**Privilege Escalation Tools:**
- WinPEASx64 (copied from system or downloaded)
- LinPEAS.sh
- lse.sh (Linux Smart Enumeration)
- pspy64
- pspy64s
- PowerUp.ps1
- JuicyPotato.exe
- JuicyPotatoNG.exe
- GodPotato.exe
- SigmaPotato.exe
- PrintSpoofer64.exe
- accesschk.exe (old version with /accepteula)
- accesschk-ng.exe (newer version)

**Pivoting/Tunneling:**
- Ligolo-ng (proxy, agent, agent.exe)
- Chisel (Linux and Windows)
- plink.exe

**Terminal Logging:**
- Adds automatic terminal session logging to ~/.zshrc
- Creates ~/logs directory
- Logs all terminal output with timestamps

**All tools downloaded to:** /home/kali/transfers

**Cleanup:**
- Removes unnecessary files (README, LICENSE, .txt files, etc.)
