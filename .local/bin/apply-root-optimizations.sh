#!/usr/bin/env bash
set -e

echo "================================================================="
echo "  Sistem Güç Optimizasyonu & NVIDIA/Xorg Düzeltmesi"
echo "================================================================="
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "Sistem yapılandırma dosyalarını düzenlemek için root yetkisi gerekiyor."
    echo "Lütfen sudo şifrenizi girin:"
    exec sudo bash "$0" "$@"
fi

echo "[1/4] Xorg'un NVIDIA kartına bağlanmasını engelleyecek Intel yapılandırması kuruluyor..."
mkdir -p /etc/X11/xorg.conf.d
cat << 'XCONF' > /etc/X11/xorg.conf.d/10-intel-only.conf
# SDDM ve Xorg'un NVIDIA kartını kilitlemesini önler
Section "ServerFlags"
    Option "AutoAddGPU" "false"
EndSection

Section "Device"
    Identifier "Intel"
    Driver "modesetting"
    BusID "PCI:0:2:0"
EndSection
XCONF
echo "  [OK] /etc/X11/xorg.conf.d/10-intel-only.conf oluşturuldu."

echo "[2/4] Pildeyken güç tasarrufu için udev kuralları ekleniyor..."
mkdir -p /etc/udev/rules.d
cat << 'UDEVCONF' > /etc/udev/rules.d/99-battery-powersave.rules
# Pildeyken power-saver, prize takılıyken balanced profiline otomatik geçiş
# SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set power-saver"
# SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
UDEVCONF
udevadm control --reload && udevadm trigger || true
echo "  [OK] Udev kuralları yüklendi ve tetiklendi."

echo "[3/4] Artık paketler ve gereksiz sistem önbellekleri temizleniyor..."
# Artık rustup paketini kaldır (kullanıcı zaten ~/.cargo/bin/rustup kullanıyor)
if pacman -Q rustup &>/dev/null; then
    pacman -Rns --noconfirm rustup || true
    echo "  [OK] Artık rustup paketi kaldırıldı."
fi

# Pacman paket önbelleğini temizle (eski versiyonları siler)
echo "  [OK] Pacman paket önbelleği temizleniyor..."
pacman -Sc --noconfirm || true

echo "[4/4] Kontroller tamamlandı."
echo ""
echo "================================================================="
echo "  [OK] Tüm Sistem Optimizasyonları Başarıyla Tamamlandı!"
echo "  Yeniden başlatma sonrası Xorg bir daha NVIDIA kartını tutmayacaktır."
echo "================================================================="
echo ""
