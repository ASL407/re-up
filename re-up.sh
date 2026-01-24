#!/bin/bash

set -eo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ASCII Art - Portrait of Dr. Gachet
echo -e "${BLUE}"
cat << "EOF"
                    .:--==++****++==--:.                    
                .-=+*##%%%%%%%%%%%%%%%%##*+=-.                
             :=*#%%%%%%%%%%%%%%%%%%%%%%%%%%##*=:             
          .=*#%%%%%##****+++++++++****##%%%%%%#*=.          
        :+#%%%%#*+=-.                  .-=+*#%%%%#+:        
      .+#%%%#*=.                            .=*#%%%#+.      
     =%%%%#=.        ..::--==++==--:..         .=#%%%%=     
   .+%%%#=       .-=+*##%%%%%%%%%%%%##*+-.       =*%%%+.   
  .+%%%*:      :+#%%%%%#*+======+*#%%%%%%#+:      :*%%%+.  
  +%%%*:     .+%%%%#=:.            .:=*%%%%#=.     :*%%%+  
 =%%%#:     .*%%%#:     .-+****+-.     :#%%%*.     :#%%%= 
.#%%%.     .#%%%=     :*%%%%%%%%#*:     =%%%#.     .%%%#.
=%%%+      +%%%=     =%%%#+=--=+#%%%=    .#%%%+      +%%%= 
*%%#.     :%%%#     +%%%+.      .+%%%+    #%%%:     .#%%*
#%%*      *%%#.    :%%%#   :==:   #%%%:   .#%%*      *%%#
#%%+     .%%%+     +%%%:   +%%+   :%%%+    +%%%:     +%%#
#%%=     :%%%:     *%%#.   =%%=   .#%%*    :%%%:     =%%#
#%%=     :%%%:     +%%%:   :==:   :%%%+    :%%%:     =%%#
*%%#.     *%%#.    .#%%%:        :%%%#.    #%%*     .#%%*
=%%%+     .#%%%.    .*%%%+:    :+%%%*.    #%%%:     +%%%= 
.#%%%.     =%%%#.    .+%%%%#**#%%%%+.    +%%%=     .%%%#.
 =%%%#:     +%%%#:     :+#%%%%%%#+:     :#%%%+     :#%%%= 
  +%%%*:     =%%%%+.      .-==-.      .+%%%%=     :*%%%+  
  .+%%%*:     :*%%%%*-.            .-*%%%%*:     :*%%%+.  
   .+%%%#=      .=*%%%%#*+====++*#%%%%#=.      =*%%%+.   
     =%%%%#=.      .-+#%%%%%%%%%#+=-.       .=#%%%%=     
      .+#%%%#*=.         .....          .=*#%%%#+.      
        :+#%%%%#*+=-.              .-=+*#%%%%#+:        
          .=*#%%%%%##****++++++****##%%%%%#*=.          
             :=*#%%%%%%%%%%%%%%%%%%%%%%%%%%*=:             
                .-=+*##%%%%%%%%%%%%%%##*+=-.                
                    .:--==++****++==--:.                    

           Portrait of Dr. Gachet - Vincent van Gogh (1890)
EOF
echo -e "${NC}\n"

echo -e "${GREEN}[*] Starting Kali Linux environment setup...${NC}\n"

# Create transfers directory
echo -e "${YELLOW}[+] Creating /home/kali/transfers directory...${NC}"
mkdir -p /home/kali/transfers
cd /home/kali/transfers

# Download SecLists
echo -e "${YELLOW}[+] Installing SecLists...${NC}"
sudo apt update
sudo apt install -y seclists

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

# Download PEASS-ng (WinPEAS & LinPEAS)
echo -e "${YELLOW}[+] Downloading WinPEAS and LinPEAS...${NC}"
wget -q https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASx64.exe -O /home/kali/transfers/winPEASx64.exe
wget -q https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh -O /home/kali/transfers/linpeas.sh
chmod +x /home/kali/transfers/linpeas.sh
echo -e "${GREEN}[✓] PEASS-ng tools downloaded${NC}"

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

echo -e "\n${GREEN}[✓] Setup complete!${NC}"
echo -e "${GREEN}[*] All tools have been downloaded to /home/kali/transfers${NC}"

# Cleanup any unnecessary files
echo -e "${YELLOW}[*] Cleaning up unnecessary files...${NC}"
cd /home/kali/transfers
rm -f kiwi_passwords.yar mimicom.idl JuicyPotatoNG.zip 2>/dev/null || true
echo -e "${GREEN}[✓] Cleanup complete${NC}"

echo -e "${YELLOW}[*] Remember to start neo4j before using BloodHound: sudo neo4j start${NC}"
echo -e "${YELLOW}[*] Default neo4j credentials are neo4j:neo4j (you'll be prompted to change on first login)${NC}\n"
