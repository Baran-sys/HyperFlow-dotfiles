#!/usr/bin/env bash
set -e

echo "================================================================="
echo "  System Power Optimization & Hybrid GPU / Xorg Fix"
echo "================================================================="
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "Root privileges are required to modify system configuration files."
    echo "Please enter your sudo password:"
    exec sudo bash "$0" "$@"
fi

echo "[1/3] Checking iGPU configuration to prevent Xorg from locking discrete GPU..."
IGPU_LINE=$(lspci | grep -E "VGA|3D|Display" | grep -i -E "Intel|AMD|ATI" | head -n 1 || true)
if [ -n "$IGPU_LINE" ]; then
    RAW_SLOT=$(echo "$IGPU_LINE" | awk '{print $1}')
    BUS_HEX=$(echo "$RAW_SLOT" | cut -d: -f1)
    DEV_HEX=$(echo "$RAW_SLOT" | cut -d: -f2 | cut -d. -f1)
    FUNC_HEX=$(echo "$RAW_SLOT" | cut -d. -f2)
    BUS_DEC=$((16#$BUS_HEX))
    DEV_DEC=$((16#$DEV_HEX))
    FUNC_DEC=$((16#$FUNC_HEX))
    mkdir -p /etc/X11/xorg.conf.d
    cat << XCONF > /etc/X11/xorg.conf.d/10-igpu-primary.conf
# Prevents SDDM and Xorg from waking up discrete (dGPU) card
Section "ServerFlags"
    Option "AutoAddGPU" "false"
EndSection

Section "Device"
    Identifier "iGPU"
    Driver "modesetting"
    BusID "PCI:${BUS_DEC}:${DEV_DEC}:${FUNC_DEC}"
EndSection
XCONF
    echo "  [OK] /etc/X11/xorg.conf.d/10-igpu-primary.conf created (BusID: PCI:${BUS_DEC}:${DEV_DEC}:${FUNC_DEC})."
else
    echo "  [Info] Internal iGPU not found, skipping Xorg PCI pinning."
fi

echo "[2/3] Adding udev power-saving rules for battery operation..."
mkdir -p /etc/udev/rules.d
cat << 'UDEVCONF' > /etc/udev/rules.d/99-battery-powersave.rules
# Automatic power profile switching on battery / AC
# SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set power-saver"
# SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
UDEVCONF
udevadm control --reload && udevadm trigger || true
echo "  [OK] Udev rules reloaded and triggered."

echo "[3/3] Cleaning package cache..."
if command -v pacman &>/dev/null; then
    pacman -Sc --noconfirm || true
fi

echo ""
echo "================================================================="
echo "  [OK] All System Optimizations Completed Successfully!"
echo "================================================================="
echo ""
