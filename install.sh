#!/usr/bin/env bash
# ==============================================================================
# HyprFlow — Hyprland Desktop Environment & Custom Applets Installer
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.config/hyprflow-backup-$(date +%Y%m%d_%H%M%S)"

echo -e "${CYAN}${BOLD}"
echo "  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ███████╗██╗      ██████╗ ██╗    ██╗"
echo "  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██║     ██╔═══██╗██║    ██║"
echo "  ███████║ ╚████╔╝ ██████╔╝██████╔╝█████╗  ██║     ██║   ██║██║ █╗ ██║"
echo "  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██╔══╝  ██║     ██║   ██║██║███╗██║"
echo "  ██║  ██║   ██║   ██║     ██║  ██║██║     ███████╗╚██████╔╝╚███╔███╔╝"
echo "  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝ "
echo -e "${NC}"
echo -e "${BOLD}HyprFlow — Hyprland Desktop Environment & Custom Applets Installer${NC}\n"

# ------------------------------------------------------------------------------
# 1. Package Installation
# ------------------------------------------------------------------------------
REQUIRED_PACKAGES=(
    hyprland
    waybar
    dunst
    kitty
    tofi
    rofi-wayland
    wlogout
    hypridle
    hyprlock
    hyprpaper
    hyprpolkitagent
    hyprpicker
    dolphin
    gnome-text-editor
    cliphist
    jq
    libnotify
    xdg-utils
    xdg-user-dirs
    power-profiles-daemon
    kvantum
    qt5ct
    qt6ct
    ttf-jetbrains-mono-nerd
    grim
    slurp
    wl-clipboard
    playerctl
    pamixer
    brightnessctl
    networkmanager
    network-manager-applet
    bluez
    bluez-utils
    blueman
    pavucontrol
    python
    python-gobject
    gtk3
    gtk-layer-shell
    python-psutil
    python-cairo
    cairo
)

install_dependencies() {
    echo -e "${BLUE}[1/5] Bağımlılıklar kontrol ediliyor...${NC}"

    PKG_MANAGER=""
    if command -v paru &>/dev/null; then
        PKG_MANAGER="paru"
    elif command -v yay &>/dev/null; then
        PKG_MANAGER="yay"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="sudo pacman"
    fi

    if [ -n "$PKG_MANAGER" ]; then
        echo -e "Paket yöneticisi tespit edildi: ${GREEN}${PKG_MANAGER}${NC}"
        read -p "Eksik paketleri otomatik yüklemek istiyor musunuz? [E/h]: " -r install_choice
        install_choice=${install_choice:-E}
        if [[ $install_choice =~ ^[Ee]$ ]]; then
            echo -e "${YELLOW}Gerekli paketler yükleniyor...${NC}"
            $PKG_MANAGER -S --needed --noconfirm "${REQUIRED_PACKAGES[@]}" || {
                echo -e "${RED}Bazı paketler yüklenemedi. Devam ediliyor...${NC}"
            }
        else
            echo -e "${YELLOW}Paket kurulumu atlandı.${NC}"
        fi
    else
        echo -e "${YELLOW}Desteklenen bir Arch paket yöneticisi bulunamadı. Lütfen gerekli paketleri manuel kurun:${NC}"
        echo "${REQUIRED_PACKAGES[*]}"
    fi
}

# ------------------------------------------------------------------------------
# 2. Backup Existing Configs
# ------------------------------------------------------------------------------
backup_configs() {
    echo -e "\n${BLUE}[2/5] Mevcut yapılandırmalar yedekleniyor...${NC}"
    mkdir -p "$BACKUP_DIR"

    CONFIGS_TO_BACKUP=(hypr waybar assets dunst kitty tofi rofi wlogout gtk-3.0 xsettingsd Kvantum qt5ct qt6ct kdeglobals mimeapps.list)
    for cfg in "${CONFIGS_TO_BACKUP[@]}"; do
        if [ -e "${HOME}/.config/${cfg}" ]; then
            cp -ra "${HOME}/.config/${cfg}" "${BACKUP_DIR}/"
            echo -e "  ✓ ~/.config/${cfg} ➔ ${BACKUP_DIR}/"
        fi
    done

    echo -e "${GREEN}Yedekleme tamamlandı: ${BACKUP_DIR}${NC}"
}

# ------------------------------------------------------------------------------
# 3. Copy Config Files & Normalize User Paths
# ------------------------------------------------------------------------------
copy_dotfiles() {
    echo -e "\n${BLUE}[3/5] Yapılandırma dosyaları ~/.config dizinine kopyalanıyor...${NC}"
    mkdir -p "${HOME}/.config"

    cp -ra "${SCRIPT_DIR}/.config/"* "${HOME}/.config/"

    # Normalize hardcoded user home paths if installing on another username
    if [ "${HOME}" != "/home/bren" ]; then
        find "${HOME}/.config/hypr" "${HOME}/.config/waybar" "${HOME}/.config/dunst" "${HOME}/.config/rofi" \
            -type f -exec sed -i "s|/home/bren|${HOME}|g" {} + 2>/dev/null || true
    fi

    echo -e "${GREEN}✓ ~/.config dosyaları başarıyla yerleştirildi.${NC}"
}

# ------------------------------------------------------------------------------
# 4. Copy Scripts, Libraries, Desktop Entries & Default MIME Associations
# ------------------------------------------------------------------------------
install_scripts_and_apps() {
    echo -e "\n${BLUE}[4/5] Özel appletler ve betikler ~/.local dizinine yükleniyor...${NC}"
    mkdir -p "${HOME}/.local/bin"
    mkdir -p "${HOME}/.local/lib"
    mkdir -p "${HOME}/.local/share/applications"

    # Copy scripts
    if [ -d "${SCRIPT_DIR}/.local/bin" ]; then
        cp -ra "${SCRIPT_DIR}/.local/bin/"* "${HOME}/.local/bin/"
        if [ "${HOME}" != "/home/bren" ]; then
            find "${HOME}/.local/bin" -maxdepth 1 -type f -exec sed -i "s|/home/bren|${HOME}|g" {} + 2>/dev/null || true
        fi
        chmod +x "${HOME}/.local/bin/"*
        echo -e "  ✓ Betikler ve appletler ~/.local/bin/ içine yüklendi (chmod +x uygulandı)."
    fi

    # Copy shared libraries (e.g. libspotify-notray.so)
    if [ -d "${SCRIPT_DIR}/.local/lib" ]; then
        cp -ra "${SCRIPT_DIR}/.local/lib/"* "${HOME}/.local/lib/"
        echo -e "  ✓ Kütüphaneler ~/.local/lib/ içine yüklendi."
    fi

    # Copy desktop applications (with NoDisplay=true on Waybar applets so Spotlight stays clean)
    if [ -d "${SCRIPT_DIR}/.local/share/applications" ]; then
        cp -ra "${SCRIPT_DIR}/.local/share/applications/"* "${HOME}/.local/share/applications/"
        if [ "${HOME}" != "/home/bren" ]; then
            find "${HOME}/.local/share/applications" -maxdepth 1 -name "*.desktop" -exec sed -i "s|/home/bren|${HOME}|g" {} + 2>/dev/null || true
        fi
        echo -e "  ✓ Masaüstü girişleri ~/.local/share/applications/ içine yüklendi."
        if command -v update-desktop-database &>/dev/null; then
            update-desktop-database "${HOME}/.local/share/applications" &>/dev/null || true
        fi
    fi

    # Configure default MIME associations for text and empty files (fixes Firefox opening empty .txt files)
    if command -v xdg-mime &>/dev/null; then
        if [ -f "/usr/share/applications/org.gnome.TextEditor.desktop" ]; then
            xdg-mime default org.gnome.TextEditor.desktop text/plain inode/x-empty application/x-zerosize 2>/dev/null || true
        fi
        if [ -f "/usr/share/applications/org.kde.dolphin.desktop" ]; then
            xdg-mime default org.kde.dolphin.desktop inode/directory 2>/dev/null || true
        fi
        echo -e "  ✓ Varsayılan MIME dosya ilişkilendirmeleri (text/plain, inode/x-empty, inode/directory) yapılandırıldı."
    fi

    # Ensure Desktop folder exists
    mkdir -p "${HOME}/Masaüstü" 2>/dev/null || true

    # Verify ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":${HOME}/.local/bin:"* ]]; then
        echo -e "${YELLOW}UYARI: ~/.local/bin dizini PATH ortam değişkeninizde görünmüyor.${NC}"
        echo -e "Kabuk ayar dosyanıza (örn: ~/.zshrc veya ~/.bashrc) şu satırı ekleyin:"
        echo -e "    ${BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    fi
}

# ------------------------------------------------------------------------------
# 5. Reload Hyprland
# ------------------------------------------------------------------------------
reload_environment() {
    echo -e "\n${BLUE}[5/5] Ortam yenileniyor...${NC}"
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        echo -e "Hyprland oturumu tespit edildi, yapılandırma yeniden yükleniyor..."
        hyprctl reload &>/dev/null || true
        killall waybar &>/dev/null || true
        hyprctl dispatch exec waybar &>/dev/null || true
        pkill -f "desktop-manager" &>/dev/null || true
        hyprctl dispatch exec "${HOME}/.local/bin/desktop-manager" &>/dev/null || true
        echo -e "${GREEN}✓ Hyprland, Waybar ve Masaüstü Yöneticisi (desktop-manager) yenilendi.${NC}"
    else
        echo -e "${YELLOW}Aktif Hyprland oturumu bulunamadı. Yeni bir oturum başlattığınızda ayarlar aktif olacaktır.${NC}"
    fi
}

# Main Execution Flow
install_dependencies
backup_configs
copy_dotfiles
install_scripts_and_apps
reload_environment

echo -e "\n${GREEN}${BOLD}================================================================="
echo "  ✓ Kurulum Başarıyla Tamamlandı!"
echo "=================================================================${NC}"
echo -e "Yedekleriniz: ${CYAN}${BACKUP_DIR}${NC}\n"
