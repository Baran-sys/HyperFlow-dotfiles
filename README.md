# 🌸 Catppuccin Mocha Hyprland Dotfiles & Material 3 Applets

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

Modern, akıcı ve yüksek performanslı **Hyprland** masaüstü yapılandırması. **Waybar**, **Dunst**, **Kitty**, **Tofi**, **Rofi** ve Python/GTK3 ile sıfırdan geliştirilmiş **Material 3 / macOS Popover** tarzı bağımsız sistem araçlarını içerir.

---

## ✨ Öne Çıkan Özellikler

### 1. 🎵 Material 3 MPRIS Medya Oynatıcı (`media-player`)
- **Material Design 3 Expressive Tuş Hiyerarşisi:**
  - Vurgulu **FAB Oynat/Duraklat** butonu (`52px` daire, Catppuccin Mocha Mavi, yüksek kontrast).
  - Dairesel **Tonal Atlama** butonları (`40px` daire, önceki/sonraki parça).
  - **Karışık Çalma (Shuffle)** ve **Tekrar (Loop/Repeat)** modları (aktif/pasif renk geçişleri, şarkı/liste döngüsü).
- **Cairo Yuvarlatılmış Albüm Kapağı:** Gerçek zamanlı şarkı kapağı önbellekleme ve `cairo` ile yumuşatılmış köşe maskelemesi.
- **Etkileşimli Zaman Çubuğu (Seek Bar):** Şarkının istenilen yerine anında atlama ve uçlarda biçimlendirilmiş zaman etiketleri.
- **Hızlı Ses Kontrolü:** Alt durum çubuğunda fare tekerleğiyle (`scroll`) anında ses açma/kısma.
- **Hızlı Tek Örnek Denetimi (Single-Instance):** Waybar üzerinden tıklandığında <5ms içinde açılır/kapanır; Escape veya odak kaybında otomatik gizlenir.

### 2. ⚡ Canlı Görev Yöneticisi & Kaynak İzleyici (`task-manager`)
- **İşlemci Sıcaklığı:** Donanım sensörlerinden (`coretemp` / `Package id 0`) canlı CPU sıcaklığı takibi (`%11.0 (42°C)`).
- **3'lü Kart Özeti:** CPU, RAM ve Çift GPU (NVIDIA RTX 4060 + Intel UHD) anlık kullanım grafikleri.
- **Akıllı GPU İşlem Algılama:** İşlemlerin NVIDIA mı, Intel mi yoksa Hibrit mi kullandığını `/proc/fdinfo` ve `nvidia-smi` üzerinden gerçek zamanlı belirler.
- **Arama ve Süreç Sonlandırma:** PID, işlem adı veya GPU adına göre anlık filtreleme ve `SIGTERM` ile güvenli kapatma.

### 3. 🖥️ macOS Tarzı Popover Sistem Araçları (Waybar Applets)
- 📶 **WiFi Yöneticisi (`wifi-manager`):** Çevredeki ağları listeleme, sinyal kalitesi ve bağlantı yönetimi.
- 󰂯 **Bluetooth Yöneticisi (`bluetooth-manager`):** Eşleşmiş cihazları bağlama ve yeni cihaz tarama.
- 🔊 **Ses Mikseri (`audio-mixer`):** Çıkış/giriş aygıtları ve akış bazlı ses düzeyleri.
- 📅 **Takvim (`calendar-app`):** Sade ve hızlı tarih/ay görünümü.
- 🔋 **Güç ve Oturum Menüsü (`power-menu`, `power-session`):** Pil sağlığı, Kafein modu (uyku önleyici) ve oturum kapatma/yeniden başlatma.
- 🔍 **Spotlight & Pano Menüsü (`spotlight-menu`, `clipboard-menu`):** macOS Spotlight benzeri hızlı başlatıcı ve pano geçmişi.

---

## 🚀 Kurulum

### Otomatik Kurulum (Tek Komut)

```bash
git clone https://github.com/Baran-sys/hyprland-dotfiles.git ~/hyprland-dotfiles
cd ~/hyprland-dotfiles
chmod +x install.sh
./install.sh
```

### Kurulum Betiğinin Yaptıkları:
1. Gerekli Arch/CachyOS paketlerini kontrol eder ve eksikleri yükler (`paru`, `yay` veya `pacman`).
2. Mevcut yapılandırmalarınızı `~/.config/hyprland-backup-TARIH/` altına güvenle yedekler.
3. `.config` dosyalarını (`hypr`, `waybar`, `assets`, `dunst`, `kitty`, `tofi`, `rofi`, `wlogout`) yerleştirir.
4. Özel Python appletlerini ve yardımcı araçları `~/.local/bin/` içine kopyalar ve çalıştırma izni verir.
5. Paylaşılan kütüphaneleri (`libspotify-notray.so`) ve `.desktop` dosyalarını kurar.
6. Aktif Hyprland oturumunu ve Waybar'ı anında yeniler.

---

## ⌨️ Temel Kısayollar

| Kısayol | İşlev |
|---|---|
| `Super + Q` | Terminali Aç (Kitty) |
| `Super + C` | Aktif Pencereyi Kapat |
| `Super + E` | Dosya Yöneticisi (Dolphin) |
| `Super + Space` | Spotlight Uygulama Başlatıcı |
| `Super + V` | Pano Geçmişi (Clipboard Manager) |
| `Super + L` | Ekranı Kilitle (Hyprlock) |
| `Super + M` | Medya Oynatıcıyı Aç/Kapat |
| `Super + Shift + S` | Ekran Görüntüsü Al (Grimblast) |

---

## 📂 Dizin Yapısı

```text
hyprland-dotfiles/
├── .config/
│   ├── hypr/               # Hyprland, Hyprlock, Hypridle, Hyprpaper
│   ├── waybar/             # Waybar şablonu ve CSS stilleri
│   ├── assets/             # Duvar kağıtları ve wlogout simgeleri
│   ├── dunst/              # Bildirim yöneticisi
│   ├── kitty/              # Terminal yapılandırması
│   ├── rofi/               # Spotlight ve Pano temaları
│   ├── tofi/               # Minimal menü yapılandırması
│   ├── wlogout/            # Çıkış ekranı düzeni ve stilleri
│   └── spotify-flags.conf  # Spotify şifre sormama bayrakları
├── .local/
│   ├── bin/                # Material 3 & Popover Python GTK3 Appletleri
│   ├── lib/                # libspotify-notray.so kütüphanesi
│   └── share/applications/ # Özelleştirilmiş spotify.desktop
├── install.sh              # Otomatik yedeklemeli kurulum betiği
└── README.md
```

---

## 📜 Lisans
MIT License. Dilediğiniz gibi kullanabilir, özelleştirebilir ve paylaşabilirsiniz.
