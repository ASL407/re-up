# Kali Linux Setup Script

Automates installation and configuration of common pentesting tools, system settings, and docker-based services for OSCP preparation.

## What It Does

**System Configuration:**
- Auto-sizes VMware display resolution (persistent on startup)
- Enables and starts SSH service
- Sets timezone to America/Los_Angeles with NTP synchronization
- Installs and configures SNMP MIBs for network enumeration
- Adds automatic terminal session logging to ~/.zshrc

**Wordlists & Utilities:**
- Installs SecLists collection
- Unzips RockYou wordlist
- Installs KeePass2 for password database management

**Active Directory & Reconnaissance:**
- BloodHound Community Edition (via Docker with default credentials)
- bloodhound-python for JSON data collection
- PowerView.ps1 for AD reconnaissance
- Seatbelt.exe for system enumeration
- SharpUp.exe for privilege escalation vectors
- SharpHound.exe for AD data collection
- SharpGPOAbuse.exe for GPO exploitation
- Rubeus.exe for Kerberos exploitation

**Privilege Escalation Tools:**
- WinPEASx64 (Windows enumeration)
- LinPEAS.sh (Linux enumeration)
- LSE (Linux Smart Enumeration)
- pspy64 & pspy64s (process monitoring)
- PowerUp.ps1 (Windows privesc)
- JuicyPotato.exe (Windows token impersonation)
- JuicyPotatoNG.exe (Windows token impersonation)
- GodPotato.exe (Windows token impersonation)
- SigmaPotato.exe (Windows token impersonation)
- PrintSpoofer64.exe (Windows print spooler exploit)
- accesschk.exe (old version with /accepteula support)
- accesschk-ng.exe (newer version)
- Mimikatz (x64)

**Pivoting & Tunneling:**
- Ligolo-ng (proxy, agent, agent.exe)
- Chisel (Linux and Windows versions)
- plink.exe (SSH tunneling)

**Output:**
- All tools downloaded to `/home/kali/transfers`
- BloodHound credentials saved to `/home/kali/bloodhound_credentials.txt`
- Terminal session logs saved to `~/logs/`
- Unnecessary files automatically cleaned up

## Usage

```bash
chmod +x setup.sh
sudo ./setup.sh
```

## Notes

- BloodHound runs via Docker on port 8080 (may conflict with Ligolo)
- Default BloodHound credentials: `admin` / `BloodHoundCommunity123!`
- Change default password on first BloodHound login
- Terminal logging enabled by default
- Docker engine required for BloodHound
