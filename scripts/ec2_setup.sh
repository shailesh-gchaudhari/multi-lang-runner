#!/usr/bin/env bash
# ec2_setup.sh
# Run this ONCE on a fresh Ubuntu 22.04 / Amazon Linux 2023 EC2 instance
# to install all required dependencies.
#
# Usage:
#   chmod +x ec2_setup.sh
#   ./ec2_setup.sh
#
set -euo pipefail

echo "========================================"
echo "  EC2 Setup — Multi-Language Runner"
echo "  $(date)"
echo "========================================"

# ── Detect distro ─────────────────────────────────────────────────
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID"
else
    DISTRO="unknown"
fi
echo "[INFO] Detected distro: $DISTRO"

# ── Package installation helpers ──────────────────────────────────
install_packages_debian() {
    sudo apt-get update -y
    sudo apt-get install -y \
        git \
        python3 python3-pip \
        default-jdk \
        curl wget unzip \
        jq
}

install_packages_amzn() {
    sudo yum update -y
    sudo yum install -y \
        git \
        python3 python3-pip \
        java-17-amazon-corretto-devel \
        curl wget unzip \
        jq
}

case "$DISTRO" in
    ubuntu|debian) install_packages_debian ;;
    amzn|rhel|centos) install_packages_amzn ;;
    *) echo "[WARN] Unknown distro; trying apt-get..."; install_packages_debian ;;
esac

# ── Verify installations ──────────────────────────────────────────
echo ""
echo "=== Runtime Versions ==="
git       --version
python3   --version
java      -version
javac     -version

# ── Create log directory ──────────────────────────────────────────
mkdir -p "$HOME/multi-lang-runner/logs"

# ── Add authorized public key (GitHub Actions runner key) ─────────
# Paste your GitHub Actions public key below (generated in the
# "Generate SSH key pair" step of the setup guide).
#
# AUTHORIZED_KEY="ssh-ed25519 AAAA... github-actions-runner"
# mkdir -p ~/.ssh && chmod 700 ~/.ssh
# echo "$AUTHORIZED_KEY" >> ~/.ssh/authorized_keys
# chmod 600 ~/.ssh/authorized_keys
# echo "[INFO] Authorized key added."
#
# (Uncomment the lines above and replace the placeholder key.)

echo ""
echo "========================================"
echo "  EC2 setup complete!"
echo "  Next steps:"
echo "  1. Add your GitHub Actions SSH public key"
echo "     to ~/.ssh/authorized_keys (see above)."
echo "  2. Open port 22 in your EC2 Security Group."
echo "  3. Add EC2_HOST, EC2_USER, EC2_SSH_KEY"
echo "     as GitHub repository secrets."
echo "========================================"
