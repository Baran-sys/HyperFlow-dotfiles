#!/usr/bin/env bash
set -e

TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || whoami)}"
if [ "$TARGET_USER" = "root" ] && [ -n "$USER" ] && [ "$USER" != "root" ]; then
    TARGET_USER="$USER"
fi

echo "================================================================="
echo "  SDDM Otomatik Giriş (Autologin) Yapılandırması"
echo "================================================================="
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "Sistem yapılandırma dosyalarını düzenlemek için root yetkisi gerekiyor."
    echo "Lütfen sudo şifrenizi girin:"
    exec sudo bash "$0" "$@"
fi

echo "[1/3] /etc/sddm.conf.d/ dizini kontrol ediliyor..."
mkdir -p /etc/sddm.conf.d

echo "[2/3] Mevcut SDDM yapılandırmasındaki çakışan ayarlar temizleniyor..."
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

echo "[3/3] autologin.conf ve zz-autologin.conf ayarlanıyor..."
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
echo "  [OK] SDDM Otomatik Giriş Başarıyla Ayarlandı!"
echo "  Kullanıcı : ${TARGET_USER}"
echo "  Oturum    : hyprland.desktop"
echo "================================================================="
echo ""
read -p "Tamamlandı! Kapatmak için Enter tuşuna basın..."
