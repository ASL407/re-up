#!/bin/bash

set -eo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}[*] Starting Kali Linux environment setup...${NC}\n"

# Fix display resolution and make it persistent
echo -e "${YELLOW}[+] Setting display to auto-size and making it persistent...${NC}"
xrandr --output Virtual-1 --auto 2>/dev/null || echo -e "${YELLOW}[!] Display auto-size not available, skipping...${NC}"
if ! grep -q "xrandr --output Virtual-1 --auto" ~/.profile 2>/dev/null; then
    echo 'xrandr --output Virtual-1 --auto 2>/dev/null' >> ~/.profile
fi
echo -e "${GREEN}[✓] Display auto-resize configured${NC}"

# Enable SSH
echo -e "${YELLOW}[+] Enabling SSH service...${NC}"
sudo systemctl enable ssh
sudo systemctl start ssh
echo -e "${GREEN}[✓] SSH enabled${NC}"

# Set timezone and NTP
echo -e "${YELLOW}[+] Configuring timezone and NTP...${NC}"
sudo timedatectl set-timezone America/Los_Angeles
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd
echo -e "${GREEN}[✓] Timezone set to America/Los_Angeles and NTP enabled${NC}"

# Create transfers directory
echo -e "${YELLOW}[+] Creating /home/kali/transfers directory...${NC}"
mkdir -p /home/kali/transfers
cd /home/kali/transfers

# Download SecLists
echo -e "${YELLOW}[+] Installing SecLists...${NC}"
sudo apt update
sudo apt install -y seclists

# Install KeePass2
echo -e "${YELLOW}[+] Installing KeePass2...${NC}"
sudo apt install -y keepass2
echo -e "${GREEN}[✓] KeePass2 installed${NC}"

# Install SNMP MIBs
echo -e "${YELLOW}[+] Installing SNMP MIBs...${NC}"
sudo apt install -y snmp-mibs-downloader
sudo download-mibs

# Configure SNMP to use MIBs
echo -e "${YELLOW}[+] Configuring SNMP to enable MIBs...${NC}"
sudo sed -i 's/^mibs :/#mibs :/' /etc/snmp/snmp.conf
echo -e "${GREEN}[✓] SNMP MIBs enabled${NC}"

# Unzip RockYou wordlist
echo -e "${YELLOW}[+] Unzipping RockYou wordlist...${NC}"
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
    sudo gunzip /usr/share/wordlists/rockyou.txt.gz
    echo -e "${GREEN}[✓] RockYou wordlist unzipped${NC}"
else
    echo -e "${YELLOW}[!] RockYou already unzipped or not found${NC}"
fi

# Download and install Ligolo-ng
echo -e "${YELLOW}[+] Downloading Ligolo-ng...${NC}"
LIGOLO_VERSION=$(curl -s https://api.github.com/repos/nicocha30/ligolo-ng/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
mkdir -p /tmp/ligolo-download
cd /tmp/ligolo-download

wget -q https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VERSION}/ligolo-ng_agent_${LIGOLO_VERSION}_linux_amd64.tar.gz -O ligolo-agent-linux.tar.gz
wget -q https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VERSION}/ligolo-ng_agent_${LIGOLO_VERSION}_windows_amd64.zip -O ligolo-agent-windows.zip
wget -q https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VERSION}/ligolo-ng_proxy_${LIGOLO_VERSION}_linux_amd64.tar.gz -O ligolo-proxy-linux.tar.gz

tar -xzf ligolo-agent-linux.tar.gz agent
unzip -q -j ligolo-agent-windows.zip agent.exe
tar -xzf ligolo-proxy-linux.tar.gz proxy

mv agent /home/kali/transfers/agent
mv agent.exe /home/kali/transfers/agent.exe
mv proxy /home/kali/transfers/proxy

cd /home/kali/transfers
rm -rf /tmp/ligolo-download
echo -e "${GREEN}[✓] Ligolo-ng downloaded${NC}"

# Install BloodHound dependencies
echo -e "${YELLOW}[+] Installing BloodHound and dependencies...${NC}"
sudo apt install -y bloodhound neo4j

# Install bloodhound-python
echo -e "${YELLOW}[+] Installing bloodhound-python...${NC}"
if command -v pipx &> /dev/null; then
    pipx install bloodhound
else
    pip3 install bloodhound --break-system-packages
fi

echo -e "${GREEN}[✓] BloodHound setup complete${NC}"

# Copy WinPEASx64 from system location to transfers
echo -e "${YELLOW}[+] Copying WinPEASx64 to transfers...${NC}"
if [ -f /usr/share/peass/winpeas/winPEASx64.exe ]; then
    cp /usr/share/peass/winpeas/winPEASx64.exe /home/kali/transfers/winPEASx64.exe
    echo -e "${GREEN}[✓] WinPEASx64 copied${NC}"
else
    echo -e "${YELLOW}[!] WinPEASx64 not found in system, downloading...${NC}"
    wget -q https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASx64.exe -O /home/kali/transfers/winPEASx64.exe
    echo -e "${GREEN}[✓] WinPEASx64 downloaded${NC}"
fi

# Download LinPEAS
echo -e "${YELLOW}[+] Downloading LinPEAS...${NC}"
wget -q https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh -O /home/kali/transfers/linpeas.sh
chmod +x /home/kali/transfers/linpeas.sh
echo -e "${GREEN}[✓] LinPEAS downloaded${NC}"

# Download PowerView
echo -e "${YELLOW}[+] Downloading PowerView.ps1...${NC}"
wget -q https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1 -O /home/kali/transfers/PowerView.ps1
echo -e "${GREEN}[✓] PowerView downloaded${NC}"

# Download PowerUp
echo -e "${YELLOW}[+] Downloading PowerUp.ps1...${NC}"
wget -q https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1 -O /home/kali/transfers/PowerUp.ps1
echo -e "${GREEN}[✓] PowerUp downloaded${NC}"

# Download Mimikatz
echo -e "${YELLOW}[+] Downloading Mimikatz (x64)...${NC}"
MIMIKATZ_VERSION=$(curl -s https://api.github.com/repos/gentilkiwi/mimikatz/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
mkdir -p /tmp/mimikatz-download
cd /tmp/mimikatz-download
wget -q https://github.com/gentilkiwi/mimikatz/releases/download/${MIMIKATZ_VERSION}/mimikatz_trunk.zip -O mimikatz.zip
unzip -q mimikatz.zip
mv x64/mimikatz.exe /home/kali/transfers/mimikatz.exe
cd /home/kali/transfers
rm -rf /tmp/mimikatz-download
echo -e "${GREEN}[✓] Mimikatz downloaded${NC}"

# Download JuicyPotatoNG
echo -e "${YELLOW}[+] Downloading JuicyPotatoNG...${NC}"
mkdir -p /tmp/juicy-download
cd /tmp/juicy-download
wget -q https://github.com/antonioCoco/JuicyPotatoNG/releases/latest/download/JuicyPotatoNG.zip -O JuicyPotatoNG.zip
unzip -q JuicyPotatoNG.zip
mv JuicyPotatoNG.exe /home/kali/transfers/JuicyPotatoNG.exe
cd /home/kali/transfers
rm -rf /tmp/juicy-download
echo -e "${GREEN}[✓] JuicyPotatoNG downloaded${NC}"

# Download JuicyPotato
echo -e "${YELLOW}[+] Downloading JuicyPotato...${NC}"
wget -q https://github.com/ohpe/juicy-potato/releases/latest/download/JuicyPotato.exe -O /home/kali/transfers/JuicyPotato.exe
echo -e "${GREEN}[✓] JuicyPotato downloaded${NC}"

# Download GodPotato
echo -e "${YELLOW}[+] Downloading GodPotato...${NC}"
wget -q https://github.com/BeichenDream/GodPotato/releases/latest/download/GodPotato-NET4.exe -O /home/kali/transfers/GodPotato.exe
echo -e "${GREEN}[✓] GodPotato downloaded${NC}"

# Download PrintSpoofer
echo -e "${YELLOW}[+] Downloading PrintSpoofer...${NC}"
wget -q https://github.com/itm4n/PrintSpoofer/releases/latest/download/PrintSpoofer64.exe -O /home/kali/transfers/PrintSpoofer64.exe
echo -e "${GREEN}[✓] PrintSpoofer downloaded${NC}"

# Download SigmaPotato
echo -e "${YELLOW}[+] Downloading SigmaPotato...${NC}"
wget -q https://github.com/tylerdotrar/SigmaPotato/releases/latest/download/SigmaPotato.exe -O /home/kali/transfers/SigmaPotato.exe 2>/dev/null || echo -e "${RED}[!] SigmaPotato download failed - manual download may be required${NC}"

# Download Seatbelt
echo -e "${YELLOW}[+] Downloading Seatbelt...${NC}"
wget -q https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Seatbelt.exe -O /home/kali/transfers/Seatbelt.exe
echo -e "${GREEN}[✓] Seatbelt downloaded${NC}"

# Download SharpUp
echo -e "${YELLOW}[+] Downloading SharpUp...${NC}"
wget -q https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/SharpUp.exe -O /home/kali/transfers/SharpUp.exe
echo -e "${GREEN}[✓] SharpUp downloaded${NC}"

# Download SharpHound
echo -e "${YELLOW}[+] Downloading SharpHound...${NC}"
wget -q https://github.com/BloodHoundAD/BloodHound/raw/master/Collectors/SharpHound.exe -O /home/kali/transfers/SharpHound.exe
echo -e "${GREEN}[✓] SharpHound downloaded${NC}"

# Download AccessChk (old version with /accepteula support)
echo -e "${YELLOW}[+] Downloading AccessChk (old version with /accepteula)...${NC}"
wget -q https://web.archive.org/web/20071007120748if_/http://download.sysinternals.com/Files/Accesschk.zip -O /tmp/accesschk-old.zip
mkdir -p /tmp/accesschk-download
unzip -q /tmp/accesschk-old.zip -d /tmp/accesschk-download
mv /tmp/accesschk-download/accesschk.exe /home/kali/transfers/accesschk.exe 2>/dev/null || mv /tmp/accesschk-download/Accesschk.exe /home/kali/transfers/accesschk.exe
rm -rf /tmp/accesschk-download /tmp/accesschk-old.zip
echo -e "${GREEN}[✓] AccessChk (old) downloaded${NC}"

# Download AccessChk (newer version)
echo -e "${YELLOW}[+] Downloading AccessChk (newer version)...${NC}"
wget -q https://download.sysinternals.com/files/AccessChk.zip -O /tmp/accesschk-new.zip
mkdir -p /tmp/accesschk-new-download
unzip -q /tmp/accesschk-new.zip -d /tmp/accesschk-new-download
mv /tmp/accesschk-new-download/accesschk.exe /home/kali/transfers/accesschk-ng.exe 2>/dev/null || mv /tmp/accesschk-new-download/accesschk64.exe /home/kali/transfers/accesschk-ng.exe 2>/dev/null || echo -e "${YELLOW}[!] Could not find newer accesschk.exe${NC}"
rm -rf /tmp/accesschk-new-download /tmp/accesschk-new.zip
echo -e "${GREEN}[✓] AccessChk (newer) downloaded${NC}"

# Download Plink
echo -e "${YELLOW}[+] Downloading Plink...${NC}"
wget -q https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe -O /home/kali/transfers/plink.exe
echo -e "${GREEN}[✓] Plink downloaded${NC}"

# Download Chisel
echo -e "${YELLOW}[+] Downloading Chisel...${NC}"
CHISEL_VERSION=$(curl -s https://api.github.com/repos/jpillora/chisel/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
mkdir -p /tmp/chisel-download
cd /tmp/chisel-download
wget -q https://github.com/jpillora/chisel/releases/download/v${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_linux_amd64.gz -O chisel-linux.gz
wget -q https://github.com/jpillora/chisel/releases/download/v${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_windows_amd64.gz -O chisel-windows.gz
gunzip chisel-linux.gz
gunzip chisel-windows.gz
mv chisel-linux /home/kali/transfers/chisel
mv chisel-windows /home/kali/transfers/chisel.exe
chmod +x /home/kali/transfers/chisel
cd /home/kali/transfers
rm -rf /tmp/chisel-download
echo -e "${GREEN}[✓] Chisel downloaded${NC}"

# Download pspy64 and pspy64s
echo -e "${YELLOW}[+] Downloading pspy64 and pspy64s...${NC}"
wget -q https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64 -O /home/kali/transfers/pspy64
wget -q https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64s -O /home/kali/transfers/pspy64s
chmod +x /home/kali/transfers/pspy64
chmod +x /home/kali/transfers/pspy64s
echo -e "${GREEN}[✓] pspy64 and pspy64s downloaded${NC}"

# Download Linux Smart Enumeration (lse.sh)
echo -e "${YELLOW}[+] Downloading Linux Smart Enumeration...${NC}"
wget -q https://raw.githubusercontent.com/diego-treitos/linux-smart-enumeration/master/lse.sh -O /home/kali/transfers/lse.sh
chmod +x /home/kali/transfers/lse.sh
echo -e "${GREEN}[✓] Linux Smart Enumeration downloaded${NC}"

# Add logging script to .zshrc
echo -e "${YELLOW}[+] Adding terminal logging to .zshrc...${NC}"
if ! grep -q "UNDER_SCRIPT" ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc << 'EOF'

# Helper script by @sechurity
# Create a log directory, a log file and start logging
if [ -z "${UNDER_SCRIPT}" ]; then
    logdir=${HOME}/logs
    logfile=${logdir}/$(date +%F.%H-%M-%S).$$.log

    mkdir -p ${logdir}
    export UNDER_SCRIPT=${logfile}
    echo "The terminal output is saving to $logfile"
    script -f -q ${logfile}

    exit
fi
EOF
    echo -e "${GREEN}[✓] Terminal logging added to .zshrc${NC}"
else
    echo -e "${YELLOW}[!] Terminal logging already configured in .zshrc${NC}"
fi

echo -e "\n${GREEN}[✓] Setup complete!${NC}"
echo -e "${GREEN}[*] All tools have been downloaded to /home/kali/transfers${NC}"

# Cleanup any unnecessary files
echo -e "${YELLOW}[*] Cleaning up unnecessary files...${NC}"
cd /home/kali/transfers
rm -f kiwi_passwords.yar mimicom.idl JuicyPotatoNG.zip *.txt README* LICENSE* Eula.txt 2>/dev/null || true
echo -e "${GREEN}[✓] Cleanup complete${NC}"

echo -e "${YELLOW}[*] Remember to start neo4j before using BloodHound: sudo neo4j start${NC}"
echo -e "${YELLOW}[*] Default neo4j credentials are neo4j:neo4j (you'll be prompted to change on first login)${NC}"
echo -e "${YELLOW}[*] BloodHound uses port 8080 by default - this may conflict with Ligolo${NC}"
echo -e "${YELLOW}[*] Terminal logging is now enabled - logs saved to ~/logs/${NC}\n"
