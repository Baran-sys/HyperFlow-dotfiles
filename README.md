# Catppuccin Hyprland Dotfiles

> [!NOTE]
> Bu yapılandırma [gaurav23b/simple-hyprland](https://github.com/gaurav23b/simple-hyprland) reposundan fork edilerek geliştirilmiştir. Dinamik açık/koyu tema motoru, Material 3 medya oynatıcı, CPU sıcaklık takipli görev yöneticisi, macOS popover tarzı sistem araçları ve performans optimizasyonları eklenmiştir.

Hyprland için modern, sade ve akıcı masaüstü yapılandırması. Waybar, Dunst, Kitty, Rofi ve Python/GTK3 ile geliştirilmiş bağımsız sistem appletlerini içerir.

---

## Öne Çıkan Özellikler

### Dinamik Açık / Koyu Tema (Catppuccin Mocha & Latte)
- Waybar üzerindeki parlaklık modülüne tıklandığında (veya sağ tıklandığında) sistem teması anında değişir.
- Duvar kağıdı tema ile senkronize olarak değişir:
  - Koyu Mod: Koyu mor Catppuccin yaprakları (`cat_leaves.png`)
  - Açık Mod: Açık gri/beyaz Catppuccin yaprakları (`cat_leaves_light.png`)
- Waybar, GTK 3/4, QT/Kvantum, Rofi, Kitty, Dunst ve kilit ekranı (Hyprlock) tek tıklamayla anında güncellenir.
- Waybar v0.15.0 XDG Desktop Portal desteği sayesinde arayüz titreşimi olmadan dinamik CSS geçişi sağlanır.

### Material 3 MPRIS Medya Oynatıcı (`media-player`)
- Oynat/Duraklat, önceki/sonraki parça, karışık çalma (shuffle) ve tekrar (loop) kontrolleri.
- Cairo ile yumuşatılmış köşelere sahip albüm kapağı gösterimi.
- Tıklanabilir ve sürüklenebilir şarkı ilerleme çubuğu (seek bar).
- Fare tekerleği ile ses düzeyi kontrolü.
- Hızlı açılış ve odak kaybında otomatik kapanma.

### Canlı Görev Yöneticisi ve Kaynak İzleyici (`task-manager`)
- Donanım sensörlerinden canlı CPU sıcaklığı ve kullanım takibi.
- CPU, RAM ve Çift GPU (NVIDIA + Intel) anlık durum kartları.
- İşlemlerin hangi GPU'yu kullandığını tespit eden akıllı süreç izleme.
- Süreç filtreleme, arama ve güvenli sonlandırma (SIGTERM).

### Popover Sistem Araçları (Waybar Appletleri)
- Wi-Fi Yöneticisi (`wifi-manager`): Ağ tarama, sinyal durumu ve bağlantı yönetimi.
- Bluetooth Yöneticisi (`bluetooth-manager`): Cihaz eşleştirme, bağlantı ve tarama.
- Ses Mikseri (`audio-mixer`): Giriş/çıkış cihazları ve uygulama bazlı ses denetimi.
- Takvim (`calendar-app`): Hızlı ay ve tarih görünümü.
- Güç ve Oturum Menüsü (`power-menu`, `power-session`): Pil sağlığı, Kafein (uyku önleyici) modu ve oturum seçenekleri.
- Spotlight ve Pano (`spotlight-menu`, `clipboard-menu`): Uygulama başlatıcı ve pano geçmişi.

---

## Kurulum

### Otomatik Kurulum

```bash
git clone https://github.com/Baran-sys/hyprland-dotfiles.git ~/hyprland-dotfiles
cd ~/hyprland-dotfiles
chmod +x install.sh
./install.sh
```

Kurulum betiği eksik paketleri denetler, mevcut yapılandırmalarınızı `~/.config/hyprland-backup-[TARIH]/` dizinine yedekler ve yeni dosyaları yerleştirir.

---

## Temel Kısayollar

| Kısayol | İşlev |
|---|---|
| Super + T | Terminal (Kitty) |
| Super + Q | Aktif Pencereyi Kapat |
| Super + E | Dosya Yöneticisi (Dolphin) |
| Super + A | Spotlight Başlatıcı |
| Super + V | Pano Geçmişi (Clipboard Manager) |
| Super + L | Ekran Kilidi (Hyprlock) |
| PrintScreen | Ekran Görüntüsü (Grimblast) |

---

## Dizin Yapısı

```text
hyprland-dotfiles/
├── .config/
│   ├── assets/             # Duvar kağıtları ve arayüz görselleri
│   ├── dunst/              # Bildirim temaları (açık / koyu)
│   ├── gtk-3.0/            # GTK 3 tema ayarları ve stilleri
│   ├── hypr/               # Hyprland, Hyprlock, Hypridle, Hyprpaper
│   ├── kitty/              # Terminal yapılandırması
│   ├── rofi/               # Spotlight ve Pano temaları (açık / koyu)
│   ├── tofi/               # Minimal başlatıcı yapılandırması
│   ├── waybar/             # Waybar şablonu, style-dark.css ve style-light.css
│   ├── wlogout/            # Oturum kapatma menüsü stilleri
│   └── xsettingsd/         # XSettingsD yapılandırması
├── .local/
│   ├── bin/                # Python GTK3 Appletleri ve yardımcı betikler
│   ├── lib/                # libspotify-notray.so kütüphanesi
│   └── share/applications/ # Masaüstü kısayolları
├── install.sh              # Otomatik kurulum ve yedekleme betiği
└── README.md
```

---

## Teşekkür ve Referanslar

- Temel Yapı: [gaurav23b/simple-hyprland](https://github.com/gaurav23b/simple-hyprland)
- Renk Paletleri: [Catppuccin Mocha & Latte](https://github.com/catppuccin/catppuccin)
- Tasarım Dili: Material Design 3 Expressive ve macOS Popover

## Lisans

MIT License
