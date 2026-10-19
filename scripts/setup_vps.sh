#!/usr/bin/env bash
# ==============================================================================
# Setup VPS for SonarQube Server (Production 2026)
# Automates: Kernel Limits (sysctl), Ulimits, Docker Engine, UFW Firewall
# Compatible with: Ubuntu 22.04/24.04 LTS & Debian 12
# ==============================================================================

set -euo pipefail

# Text formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}   SonarQube VPS Bootstrap & Tuning Script (2026)    ${NC}"
echo -e "${BLUE}=====================================================${NC}"

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] This script must be run as root (use sudo).${NC}"
   exit 1
fi

echo -e "\n${YELLOW}>>> [1/5] Applying Mandatory Linux Kernel Limits for Elasticsearch...${NC}"

SYSCTL_CONF="/etc/sysctl.d/99-sonarqube.conf"
cat << 'EOF' > "$SYSCTL_CONF"
# SonarQube & Elasticsearch memory map limits
vm.max_map_count=524288
fs.file-max=131072
vm.swappiness=1
EOF

sysctl --system > /dev/null
echo -e "${GREEN}✓ Kernel parameters updated: vm.max_map_count=$(sysctl -n vm.max_map_count)${NC}"

echo -e "\n${YELLOW}>>> [2/5] Configuring File Descriptors and Thread Limits (ulimits)...${NC}"
LIMITS_CONF="/etc/security/limits.d/99-sonarqube.conf"
cat << 'EOF' > "$LIMITS_CONF"
* soft nofile 131072
* hard nofile 131072
* soft nproc 8192
* hard nproc 8192
EOF
echo -e "${GREEN}✓ File limits applied in $LIMITS_CONF${NC}"

echo -e "\n${YELLOW}>>> [3/5] Checking and Installing Docker & Docker Compose...${NC}"
if ! command -v docker &> /dev/null; then
    echo "Installing Docker Engine and dependencies..."
    apt-get update -qq
    apt-get install -y -qq ca-certificates curl gnupg lsb-release ufw

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc || \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    OS_ID=$(. /etc/os-release && echo "$ID")
    VERSION_CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$OS_ID $VERSION_CODENAME stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable --now docker
    echo -e "${GREEN}✓ Docker successfully installed.${NC}"
else
    echo -e "${GREEN}✓ Docker is already installed: $(docker --version)${NC}"
fi

echo -e "\n${YELLOW}>>> [4/5] Configuring UFW Firewall...${NC}"
if command -v ufw &> /dev/null; then
    ufw default deny incoming > /dev/null
    ufw default allow outgoing > /dev/null
    ufw allow 22/tcp comment 'SSH' > /dev/null
    ufw allow 80/tcp comment 'HTTP (Caddy SSL)' > /dev/null
    ufw allow 443/tcp comment 'HTTPS (SonarQube)' > /dev/null
    ufw --force enable > /dev/null
    echo -e "${GREEN}✓ Firewall configured: Ports 22, 80, 443 are open.${NC}"
fi

echo -e "\n${YELLOW}>>> [5/5] Final Instructions...${NC}"
echo -e "${GREEN}VPS bootstrap completed successfully!${NC}"
echo -e "Next steps:"
echo -e " 1. Navigate to the docker folder: ${BLUE}cd docker${NC}"
echo -e " 2. Copy the environment file:   ${BLUE}cp .env.example .env${NC}"
echo -e " 3. Edit your domain & secrets:   ${BLUE}nano .env${NC}"
echo -e " 4. Start SonarQube with Caddy:   ${BLUE}docker compose up -d${NC}"
echo -e "${BLUE}=====================================================${NC}"
