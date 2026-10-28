#!/usr/bin/env bash
set -e

TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || whoami)}"
if [ "$TARGET_USER" = "root" ] && [ -n "$USER" ] && [ "$USER" != "root" ]; then
    TARGET_USER="$USER"
fi

echo "================================================================="
echo "  SDDM Autologin Configuration"
echo "================================================================="
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "Root privileges are required to modify system configuration files."
    echo "Please enter your sudo password:"
    exec sudo bash "$0" "$@"
fi

echo "[1/3] Checking /etc/sddm.conf.d/ directory..."
mkdir -p /etc/sddm.conf.d

echo "[2/3] Cleaning conflicting settings in existing SDDM configuration..."
if [ -f /etc/sddm.conf.d/the_hyde_project.conf ]; then
    cp -a /etc/sddm.conf.d/the_hyde_project.conf /etc/sddm.conf.d/the_hyde_project.conf.bak
    python3 - "$TARGET_USER" << 'PYEOF' 2>/dev/null || true
import re, sys
user = sys.argv[1]
with open('/etc/sddm.conf.d/the_hyde_project.conf', 'r') as f:
    text = f.read()
text = re.sub(
    r'\[Autologin\]\s*Relogin=[^\n]*\s*Session=[^\n]*\s*User=[^\n]*',
    f'[Autologin]\nRelogin=false\nSession=hyprland.desktop\nUser={user}',
    text
)
with open('/etc/sddm.conf.d/the_hyde_project.conf', 'w') as f:
    f.write(text)
PYEOF
fi

echo "[3/3] Configuring autologin.conf and zz-autologin.conf..."
cat << AUTOCONF > /etc/sddm.conf.d/autologin.conf
[Autologin]
User=${TARGET_USER}
Session=hyprland.desktop
Relogin=false
AUTOCONF

cat << AUTOCONF > /etc/sddm.conf.d/zz-autologin.conf
[Autologin]
User=${TARGET_USER}
Session=hyprland.desktop
Relogin=false
AUTOCONF

echo ""
echo "================================================================="
echo "  [OK] SDDM Autologin Configured Successfully!"
echo "  User    : ${TARGET_USER}"
echo "  Session : hyprland.desktop"
echo "================================================================="
echo ""
read -p "Tamamlandı! Kapatmak için Enter tuşuna basın..."
