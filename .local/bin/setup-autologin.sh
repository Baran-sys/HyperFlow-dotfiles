#!/usr/bin/env bash
set -e

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

echo "[2/3] the_hyde_project.conf içindeki çakışan ayarlar temizleniyor..."
if [ -f /etc/sddm.conf.d/the_hyde_project.conf ]; then
    cp -a /etc/sddm.conf.d/the_hyde_project.conf /etc/sddm.conf.d/the_hyde_project.conf.bak
    # the_hyde_project.conf içindeki boş Autologin kısmını User=bren yap
    python3 -c "
with open('/etc/sddm.conf.d/the_hyde_project.conf', 'r') as f:
    text = f.read()

import re
text = re.sub(r'\[Autologin\]\s*Relogin=[^\n]*\s*Session=[^\n]*\s*User=[^\n]*', '[Autologin]\nRelogin=false\nSession=hyprland.desktop\nUser=bren', text)
with open('/etc/sddm.conf.d/the_hyde_project.conf', 'w') as f:
    f.write(text)
" 2>/dev/null || true
fi

echo "[3/3] autologin.conf ve zz-autologin.conf ayarlanıyor..."
cat << 'AUTOCONF' > /etc/sddm.conf.d/autologin.conf
[Autologin]
User=bren
Session=hyprland.desktop
Relogin=false
AUTOCONF

cat << 'AUTOCONF' > /etc/sddm.conf.d/zz-autologin.conf
[Autologin]
User=bren
Session=hyprland.desktop
Relogin=false
AUTOCONF

echo ""
echo "================================================================="
echo "  [OK] SDDM Otomatik Giriş Başarıyla Ayarlandı!"
echo "  Kullanıcı : bren"
echo "  Oturum    : hyprland.desktop"
echo "================================================================="
echo ""
read -p "Tamamlandı! Kapatmak için Enter tuşuna basın..."
