#!/usr/bin/env bash
# ==============================================================================
# Catppuccin Mocha Hyprland & Custom Applets Installer (Forked from simple-hyprland)
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
BACKUP_DIR="${HOME}/.config/hyprland-backup-$(date +%Y%m%d_%H%M%S)"

echo -e "${CYAN}${BOLD}"
echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo -e "${NC}"
echo -e "${BOLD}Catppuccin Mocha Hyprland & Custom Applets Installer (Forked from simple-hyprland)${NC}\n"

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
    grim
    slurp
    wl-clipboard
    playerctl
    pamixer
    brightnessctl
    networkmanager
    bluez
    bluez-utils
    python
    python-gobject
    gtk3
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

    CONFIGS_TO_BACKUP=(hypr waybar assets dunst kitty tofi rofi wlogout gtk-3.0 xsettingsd)
    for cfg in "${CONFIGS_TO_BACKUP[@]}"; do
        if [ -e "${HOME}/.config/${cfg}" ]; then
            cp -ra "${HOME}/.config/${cfg}" "${BACKUP_DIR}/"
            echo -e "  ✓ ~/.config/${cfg} ➔ ${BACKUP_DIR}/"
        fi
    done

    echo -e "${GREEN}Yedekleme tamamlandı: ${BACKUP_DIR}${NC}"
}

# ------------------------------------------------------------------------------
# 3. Copy Config Files
# ------------------------------------------------------------------------------
copy_dotfiles() {
    echo -e "\n${BLUE}[3/5] Yapılandırma dosyaları ~/.config dizinine kopyalanıyor...${NC}"
    mkdir -p "${HOME}/.config"

    cp -ra "${SCRIPT_DIR}/.config/"* "${HOME}/.config/"
    echo -e "${GREEN}✓ ~/.config dosyaları başarıyla yerleştirildi.${NC}"
}

# ------------------------------------------------------------------------------
# 4. Copy Scripts, Libraries & Desktop Entries
# ------------------------------------------------------------------------------
install_scripts_and_apps() {
    echo -e "\n${BLUE}[4/5] Özel appletler ve betikler ~/.local dizinine yükleniyor...${NC}"
    mkdir -p "${HOME}/.local/bin"
    mkdir -p "${HOME}/.local/lib"
    mkdir -p "${HOME}/.local/share/applications"

    # Copy scripts
    if [ -d "${SCRIPT_DIR}/.local/bin" ]; then
        cp -ra "${SCRIPT_DIR}/.local/bin/"* "${HOME}/.local/bin/"
        chmod +x "${HOME}/.local/bin/"*
        echo -e "  ✓ Betikler ve appletler ~/.local/bin/ içine yüklendi (chmod +x uygulandı)."
    fi

    # Copy shared libraries (e.g. libspotify-notray.so)
    if [ -d "${SCRIPT_DIR}/.local/lib" ]; then
        cp -ra "${SCRIPT_DIR}/.local/lib/"* "${HOME}/.local/lib/"
        echo -e "  ✓ Kütüphaneler ~/.local/lib/ içine yüklendi."
    fi

    # Copy desktop applications
    if [ -d "${SCRIPT_DIR}/.local/share/applications" ]; then
        cp -ra "${SCRIPT_DIR}/.local/share/applications/"* "${HOME}/.local/share/applications/"
        echo -e "  ✓ Masaüstü girişleri ~/.local/share/applications/ içine yüklendi."
        if command -v update-desktop-database &>/dev/null; then
            update-desktop-database "${HOME}/.local/share/applications" &>/dev/null || true
        fi
    fi

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
        killall -SIGUSR2 waybar &>/dev/null || true
        echo -e "${GREEN}✓ Hyprland & Waybar yenilendi.${NC}"
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
