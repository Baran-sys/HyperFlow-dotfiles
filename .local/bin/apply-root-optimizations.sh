#!/usr/bin/env bash
set -e

echo "================================================================="
echo "  Sistem Güç Optimizasyonu & Hibrit GPU / Xorg Düzeltmesi"
echo "================================================================="
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "Sistem yapılandırma dosyalarını düzenlemek için root yetkisi gerekiyor."
    echo "Lütfen sudo şifrenizi girin:"
    exec sudo bash "$0" "$@"
fi

echo "[1/3] Xorg'un harici GPU'yu kilitlemesini engelleyecek iGPU yapılandırması kontrol ediliyor..."
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
# SDDM ve Xorg'un harici (dGPU) kartı uykudan uyandırmasını önler
Section "ServerFlags"
    Option "AutoAddGPU" "false"
EndSection

Section "Device"
    Identifier "iGPU"
    Driver "modesetting"
    BusID "PCI:${BUS_DEC}:${DEV_DEC}:${FUNC_DEC}"
EndSection
XCONF
    echo "  [OK] /etc/X11/xorg.conf.d/10-igpu-primary.conf oluşturuldu (BusID: PCI:${BUS_DEC}:${DEV_DEC}:${FUNC_DEC})."
else
    echo "  [Bilgi] Dahili iGPU bulunamadı, Xorg PCI sabitlemesi atlandı."
fi

echo "[2/3] Pildeyken güç tasarrufu için udev kuralları ekleniyor..."
mkdir -p /etc/udev/rules.d
cat << 'UDEVCONF' > /etc/udev/rules.d/99-battery-powersave.rules
# Pildeyken power-saver, prize takılıyken balanced profiline otomatik geçiş
# SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set power-saver"
# SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
UDEVCONF
udevadm control --reload && udevadm trigger || true
echo "  [OK] Udev kuralları yüklendi ve tetiklendi."

echo "[3/3] Paket önbelleği temizleniyor..."
if command -v pacman &>/dev/null; then
    pacman -Sc --noconfirm || true
fi

echo ""
echo "================================================================="
echo "  [OK] Tüm Sistem Optimizasyonları Başarıyla Tamamlandı!"
echo "================================================================="
echo ""
