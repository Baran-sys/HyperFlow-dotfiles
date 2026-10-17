#!/usr/bin/env bash
set -e

echo "================================================================="
echo "  Limine Bootloader: Hash Doğrulama Hatası Kalıcı Düzeltme"
echo "================================================================="
echo ""

# Sudo kontrolü
if [ "$EUID" -ne 0 ]; then
    echo "Sistem ve önyükleyici dosyalarını düzenlemek için root yetkisi gerekiyor."
    echo "Lütfen sudo şifrenizi girin:"
    exec sudo bash "$0" "$@"
fi

echo "[1/4] /etc/default/limine yapılandırması güncelleniyor..."
if grep -q "ENABLE_VERIFICATION" /etc/default/limine; then
    sed -i 's/^ENABLE_VERIFICATION=.*/ENABLE_VERIFICATION=no/' /etc/default/limine
else
    echo "ENABLE_VERIFICATION=no" >> /etc/default/limine
fi

echo "[2/4] /etc/limine-entry-tool.conf yapılandırması güncelleniyor..."
if [ -f /etc/limine-entry-tool.conf ]; then
    sed -i 's/^ENABLE_VERIFICATION=yes/ENABLE_VERIFICATION=no/' /etc/limine-entry-tool.conf
fi

echo "[3/4] /boot altındaki limine.conf dosyaları temizleniyor..."
FOUND=0
for conf in /boot/limine.conf /boot/limine/limine.conf /boot/EFI/limine/limine.conf /boot/efi/EFI/limine/limine.conf /boot/efi/limine.conf; do
    if [ -f "$conf" ]; then
        FOUND=1
        echo "   -> Bulundu: $conf"
        cp -a "$conf" "${conf}.bak"
        # Hash (#blake2b) eklerini yoldan temizle
        sed -i -E 's/#[a-f0-9]{32,}//g' "$conf"
        
        # hash_mismatch_panic: no ekle (olası panikleri önlemek için)
        if ! grep -q "hash_mismatch_panic" "$conf"; then
            sed -i '1i hash_mismatch_panic: no' "$conf"
        fi
        echo "   -> $conf temizlendi ve yedeklendi (${conf}.bak)."
    fi
done

if [ "$FOUND" -eq 0 ]; then
    echo "   (Doğrudan yol bulunamadı, find ile taranıyor...)"
    while IFS= read -r conf; do
        echo "   -> Bulundu: $conf"
        cp -a "$conf" "${conf}.bak"
        sed -i -E 's/#[a-f0-9]{32,}//g' "$conf"
        if ! grep -q "hash_mismatch_panic" "$conf"; then
            sed -i '1i hash_mismatch_panic: no' "$conf"
        fi
    done < <(find /boot -name "limine.conf" 2>/dev/null || true)
fi

echo "[4/4] Limine önyükleyici girdileri güncelleniyor..."
if command -v limine-update &>/dev/null; then
    limine-update || true
elif command -v limine-entry-tool &>/dev/null; then
    limine-entry-tool || true
fi

# Güncelleme sonrası limine.conf kontrolü ve temizliği
for conf in /boot/limine.conf /boot/limine/limine.conf /boot/EFI/limine/limine.conf /boot/efi/EFI/limine/limine.conf /boot/efi/limine.conf; do
    if [ -f "$conf" ]; then
        sed -i -E 's/#[a-f0-9]{32,}//g' "$conf"
        if ! grep -q "hash_mismatch_panic" "$conf"; then
            sed -i '1i hash_mismatch_panic: no' "$conf"
        fi
    fi
done

echo ""
echo "================================================================="
echo "  [OK] İŞLEM BAŞARIYLA TAMAMLANDI!"
echo "  Limine hash doğrulaması (ENABLE_VERIFICATION=no) kapatıldı."
echo "  Artık başlangıçta hashleri elle silmenize gerek kalmadan sistem açılacak."
echo "================================================================="
echo ""
read -p "Pencereyi kapatmak için Enter tuşuna basın..."
