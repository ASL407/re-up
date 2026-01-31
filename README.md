Run this script on new images of Kali to quickly download several tools and make some minor configuration adjustments.

## What It Does

**System Configuration:**
- Auto-sizes VMware display resolution
- Creates `/home/kali/transfers` directory for tools
- Updates package repositories

**Wordlists:**
- Installs SecLists
- Unzips RockYou wordlist

**Utilities:**
- Installs KeePass2 for reading `.kdbx` databases

**Active Directory Tools:**
- BloodHound + Neo4j
- bloodhound-python
- PowerView.ps1
- Mimikatz (x64)
- Seatbelt.exe
- SharpUp.exe

**Privilege Escalation Tools:**
- WinPEASany.exe (Windows enumeration)
- LinPEAS.sh (Linux enumeration)
- lse.sh (Linux Smart Enumeration)
- PowerUp.ps1
- JuicyPotato.exe
- JuicyPotatoNG.exe
- GodPotato.exe
- SigmaPotato.exe
- PrintSpoofer64.exe
- accesschk.exe (old version with `/accepteula`)
- accesschk-ng.exe (newer version)

**Pivoting/Tunneling:**
- Ligolo-ng (proxy, agent, agent.exe)
- Chisel (Linux and Windows)
- plink.exe

**All tools downloaded to:** `/home/kali/transfers`

## Usage
```bash
chmod +x setup.sh
sudo ./setup.sh
```
