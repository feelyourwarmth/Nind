#!/bin/bash

set -e

if [ "$EUID" -eq 0 ]; then
    echo "Não rode este script como root (não use sudo ./install.sh)."
    echo "O script já usa sudo internamente quando precisa."
    exit 1
fi

sudo -v
( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTS_DIR"

trap 'echo ""; echo "Erro na linha $LINENO. Instalação interrompida."; echo "Nada além do que já foi executado até aqui foi alterado."' ERR

require_path() {
    if [ ! -e "$1" ]; then
        echo ""
        echo "ERRO: caminho não encontrado: $1"
        echo "Verifique se a estrutura de pastas do repositório está correta."
        exit 1
    fi
}

echo """
███▄    █  ██▓ ███▄    █ ▓█████▄
██ ▀█   █ ▓██▒ ██ ▀█   █ ▒██▀ ██▌
▓██  ▀█ ██▒▒██▒▓██  ▀█ ██▒░██   █▌
▓██▒  ▐▌██▒░██░▓██▒  ▐▌██▒░▓█▄   ▌
▒██░   ▓██░░██░▒██░   ▓██░░▒████▓
░ ▒░   ▒ ▒ ░▓  ░ ▒░   ▒ ▒  ▒▒▓  ▒
░ ░░   ░ ▒░ ▒ ░░ ░░   ░ ▒░ ░ ▒  ▒
  ░   ░ ░  ▒ ░   ░   ░ ░  ░ ░  ░
        ░  ░           ░    ░
                          ░
"""


echo "[1/12] Verificando repositório multilib..."

if ! grep -qE "^\[multilib\]" /etc/pacman.conf; then
    echo "Multilib desabilitado. Habilitando..."

    sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf

    if ! grep -qE "^\[multilib\]" /etc/pacman.conf; then
        echo ""
        echo "Não foi possível habilitar o multilib automaticamente."
        echo "Edite /etc/pacman.conf manualmente (descomente a seção [multilib])"
        echo "e rode o script novamente."
        exit 1
    fi

    sudo pacman -Sy --noconfirm
else
    echo "Multilib já habilitado."
fi

echo ""
echo "[2/12] Atualizando sistema..."

sudo pacman -Syu --noconfirm


echo ""
echo "[3/12] Verificando yay..."

if ! command -v yay &>/dev/null; then
    echo "Instalando yay..."

    sudo pacman -S --needed --noconfirm git base-devel

    rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay

    (
        cd /tmp/yay
        makepkg -si --needed --noconfirm --noprogressbar
    )

    rm -rf /tmp/yay
else
    echo "yay já instalado."
fi


echo ""
echo "[4/12] Instalando dependências base..."

sudo pacman -S --needed --noconfirm \
    base-devel \
    dkms \
    curl \
    jq \
    git \
    github-cli \
    mousepad \
    imv \
    kitty \
    fish \
    yazi \
    ffmpegthumbnailer \
    tumbler \
    eza \
    zoxide \
    neovim \
    lua \
    luarocks \
    vlc \
    ffmpeg \
    unzip \
    7zip \
    nautilus \
    nano \
    qt6ct \
    nwg-look \
    starship \
    fastfetch \
    sddm \
    pipewire \
    pipewire-pulse \
    wireplumber \
    linux-headers \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji

sudo pacman -S --needed --noconfirm \
    niri \
    xwayland-satellite \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    matugen \
    cava \
    qt6-multimedia-ffmpeg

yay --sudoloop -S --needed --noconfirm zen-browser-bin noctalia-git gopac-bin nirimod-git


echo ""
echo "[5/12] Configuração da GPU"

echo ""
echo "GPU detectada:"
lspci | grep -E "VGA|3D" || true

echo ""

echo "Escolha sua GPU:"
echo "1) NVIDIA"
echo "2) AMD"
echo "3) Intel"

read -rp "Opção: " GPU


case $GPU in

1)

    echo ""
    echo "NVIDIA selecionada"

    echo ""
    echo "Escolha o driver NVIDIA conforme a geração da sua GPU:"
    echo "1) Turing ou mais nova (RTX 20xx+, GTX 16xx+) -> driver open oficial"
    echo "2) Maxwell / Pascal (GTX 900 / GTX 10xx) -> driver legacy 580xx (AUR)"
    echo "3) Mais antiga que isso (pré-Maxwell) -> drivers legacy antigos (AUR)"

    read -rp "Opção: " NVIDIA_TYPE


    case $NVIDIA_TYPE in

    1)

        echo "Instalando NVIDIA (driver open oficial)..."

        sudo pacman -S --needed --noconfirm \
            nvidia-open \
            nvidia-utils \
            lib32-nvidia-utils \
            nvidia-settings \
            egl-wayland

        ;;


    2)

        echo "Instalando NVIDIA Legacy 580xx (Maxwell/Pascal)..."


        if ! yay --sudoloop -S --needed --noconfirm \
            nvidia-580xx-dkms \
            nvidia-580xx-utils \
            lib32-nvidia-580xx-utils; then

            echo ""
            echo "Não foi possível instalar o nvidia-580xx-dkms via AUR."
            echo "O nome desse pacote pode ter mudado. Verifique manualmente em:"
            echo "https://aur.archlinux.org/packages?O=0&K=nvidia (procure pela sua geração)"
            exit 1
        fi

        ;;


    3)

        echo ""
        echo "AVISO: drivers legacy têm suporte fraco/nenhum a Wayland."
        echo "Niri pode não funcionar. Considere X11."
        echo ""
        echo "1) nvidia-390xx-dkms"
        echo "2) nvidia-340xx-dkms"

        read -rp "Opção: " NVIDIA_OLD

        case $NVIDIA_OLD in

        1)
            yay --sudoloop -S --needed --noconfirm \
                nvidia-390xx-dkms \
                nvidia-390xx-utils \
                lib32-nvidia-390xx-utils
            ;;

        2)
            yay --sudoloop -S --needed --noconfirm \
                nvidia-340xx-dkms \
                nvidia-340xx-utils \
                lib32-nvidia-340xx-utils
            ;;

        *)
            echo "Opção inválida"
            exit 1
            ;;

        esac

        ;;

    *)

        echo "Opção inválida"
        exit 1

        ;;

    esac


    echo "Configurando NVIDIA DRM..."

    sudo mkdir -p /etc/modprobe.d

    echo -e "options nvidia_drm modeset=1\noptions nvidia_drm fbdev=1" | \
        sudo tee /etc/modprobe.d/nvidia.conf >/dev/null

    echo "Regenerando initramfs..."

    sudo mkinitcpio -P

    ;;


2)

    echo "Instalando AMD..."

    sudo pacman -S --needed --noconfirm \
        mesa \
        lib32-mesa \
        vulkan-radeon \
        lib32-vulkan-radeon

    ;;


3)

    echo "Instalando Intel..."

    sudo pacman -S --needed --noconfirm \
        mesa \
        lib32-mesa \
        vulkan-intel \
        lib32-vulkan-intel

    ;;


*)

    echo "Opção inválida"
    exit 1

    ;;

esac


echo ""
echo "[6/12] Criando backup..."

BACKUP_DIR=~/dots-backup-$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP_DIR/.config" "$BACKUP_DIR/.local"

if [ -d ~/.config ]; then
    cp -a ~/.config/. "$BACKUP_DIR/.config/"
fi

if [ -d ~/.local ]; then
    cp -a ~/.local/. "$BACKUP_DIR/.local/"
fi

echo "Backup salvo em: $BACKUP_DIR"


echo ""
echo "[7/12] Aplicando configurações..."

require_path "$DOTS_DIR/.config"
require_path "$DOTS_DIR/.local"

mkdir -p ~/.config
mkdir -p ~/.local


cp -a \
    "$DOTS_DIR/.config/." \
    ~/.config/


cp -a \
    "$DOTS_DIR/.local/." \
    ~/.local/


echo ""
echo "[8/12] Instalando SDDM..."

sudo systemctl disable gdm 2>/dev/null || true
sudo systemctl disable lightdm 2>/dev/null || true
sudo systemctl disable ly 2>/dev/null || true
sudo systemctl disable greetd 2>/dev/null || true


echo "Preparando tema SDDM..."

sudo mkdir -p /usr/share/sddm/themes

sudo mkdir -p /etc/sddm.conf.d

echo "Instalando tema SDDM..."

yay --sudoloop -S --needed --noconfirm sddm-silent-theme

echo "Aplicando tema SDDM..."

cat <<EOF | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
[Theme]
Current=silent
EOF


echo ""
echo "[9/12] Ativando serviços..."

sudo systemctl enable sddm
sudo systemctl enable NetworkManager
sudo systemctl set-default graphical.target

sudo usermod -aG video,render "$USER"

systemctl --user daemon-reload || true

systemctl --user enable --now \
    pipewire \
    pipewire-pulse \
    wireplumber || true


echo ""
echo ""
echo ""
echo "[10/12] Extras (opcional)"

echo ""
echo "Escolha pacotes que deseja instalar:"
echo "Digite os números separados por espaço e dê ENTER. (ex: 1 3 5 6 7 10 12 13)"
echo ""
echo "Caso queira pular está etapa, apenas dê ENTER sem digitar nada."
echo ""

APPS=(
    "Easyeffects" # 1
    "VSCode" # 2
    "Zed" # 3
    "GIMP" # 4
    "LACT" # 5
    "Steam" # 6
    "Discord" # 7
    "LibreOffice" # 8
    "Thunderbird" # 9
    "CoolerControl" # 10
    "Flatpak" # 11
    "OpenRGB" # 12
    "OBS-Studio" # 13
)

for i in "${!APPS[@]}"; do
    echo "$((i+1))) ${APPS[$i]}"
done

echo ""

read -rp "Opções: " SELECTED_APPS

SELECTED_APPS=$(echo "$SELECTED_APPS" | tr ' ' '\n' | sort -un | tr '\n' ' ')

INSTALL_PACMAN=()
INSTALL_YAY=()


if [ -z "$SELECTED_APPS" ]; then
    echo "Nenhum aplicativo selecionado. Pulando..."
else
    for APP in $SELECTED_APPS; do
        if ! [[ "$APP" =~ ^[0-9]+$ ]]; then
            echo "Entrada inválida: $APP"
            continue
        fi

        case $APP in
        1)
            INSTALL_PACMAN+=(
                easyeffects
                lsp-plugins
            )
            INSTALL_YAY+=(
                deepfilternet-plus-bin
            )
            ;;
        2)
            INSTALL_YAY+=(
                visual-studio-code-bin
            )
            ;;
        3)
            INSTALL_PACMAN+=(
                zed
            )
            ;;
        4)
            INSTALL_PACMAN+=(
                gimp
            )
            ;;
        5)
            INSTALL_PACMAN+=(
                lact
            )
            ;;
        6)
            INSTALL_PACMAN+=(
                steam
            )

            echo ""
            read -rp "Deseja instalar SLSsteam também? (s/N): " INSTALL_SLS

            if [[ "$INSTALL_SLS" =~ ^[sS]$ ]]; then
                INSTALL_PACMAN+=(
                    make
                    gcc
                    pkgconf
                )

                INSTALL_SLSSTEAM=true
            fi
            ;;
        7)
            INSTALL_PACMAN+=(
                discord
            )
            ;;
        8)
            INSTALL_PACMAN+=(
                libreoffice-fresh
            )
            ;;
        9)
            INSTALL_PACMAN+=(
                thunderbird
            )
            ;;
        10)
            INSTALL_YAY+=(
                coolercontrold-bin
                coolercontrol-bin
            )

            echo ""
            read -rp "Deseja instalar o NCT6687 também? (S/n): " INSTALL_NCT

            if [[ "$INSTALL_NCT" =~ ^[sS]$ ]]; then
                INSTALL_YAY+=(
                    nct6687d-dkms-git
                )

                INSTALL_NCT6687=true
            fi
            ;;
        11)
            INSTALL_PACMAN+=(
                flatpak
            )
            ;;
        12)
            INSTALL_PACMAN+=(
                openrgb
                i2c-tools
            )
            sudo modprobe i2c-dev
            sudo modprobe i2c-i801
            sudo modprobe i2c-piix4
            sudo i2cdetect -l
            ;;
        13)
            INSTALL_PACMAN+=(
                obs-studio
            )
            INSTALL_YAY+=(
                gobs-cli-bin
            )
            ;;
        *)
            echo "Opção inválida: $APP"
            ;;
        esac
    done
fi

if [ ${#INSTALL_PACMAN[@]} -gt 0 ]; then
    echo ""
    echo "Instalando pacotes oficiais:"
    printf '%s\n' "${INSTALL_PACMAN[@]}"

    sudo pacman -S --needed --noconfirm \
        "${INSTALL_PACMAN[@]}"
fi

if [ ${#INSTALL_YAY[@]} -gt 0 ]; then
    echo ""
    echo "Instalando pacotes AUR:"
    printf '%s\n' "${INSTALL_YAY[@]}"

    yay --sudoloop -S --needed --noconfirm \
        "${INSTALL_YAY[@]}"
fi

if [[ "${INSTALL_SLSSTEAM:-false}" == true ]]; then
    echo ""
    echo "Instalando SLSsteam..."

    SLS_DIR="$HOME/Downloads/SLSsteam"

    (
        cd "$HOME/Downloads"

        if [ -d "$SLS_DIR" ]; then
            echo "Removendo instalação antiga do SLSsteam..."
            rm -rf "$SLS_DIR"
        fi

        git clone "https://github.com/AceSLS/SLSsteam" "$SLS_DIR"
        cd "$SLS_DIR"
        make
        chmod +x setup.sh
        ./setup.sh install
    )

    echo "Removendo arquivos temporários do SLSsteam..."
    rm -rf "$SLS_DIR"

    echo "SLSsteam instalado!"
fi

if [[ "${INSTALL_NCT6687:-false}" == true ]]; then
    echo ""
    echo "Instalando NCT6687..."

    echo nct6687 | sudo tee /etc/modules-load.d/nct.conf
    sudo sensors-detect --auto
    sudo sed -i 's/^HWMON_MODULES=.*/HWMON_MODULES="nct6687"/' /etc/conf.d/lm_sensors
    sudo systemctl enable --now coolercontrold

    echo "NCT6687 instalado!"
fi

echo ""
echo "Apps extras finalizado!"


echo ""
echo "[11/12] Instalando Vicinae..."

if ! command -v vicinae &>/dev/null; then
    curl -fsSL https://vicinae.com/install -o /tmp/vicinae-install.sh
    sed -i 's#< /dev/tty##' /tmp/vicinae-install.sh
    yes | bash /tmp/vicinae-install.sh
    rm -f /tmp/vicinae-install.sh
else
    echo "Vicinae já instalado."
fi


echo ""
echo "[12/12] Finalizando..."

fc-cache -f

xdg-user-dirs-update

if [ "$SHELL" != "/usr/bin/fish" ] && [ "$SHELL" != "/bin/fish" ]; then
    echo "Definindo fish como shell padrão..."

    FISH_PATH="$(command -v fish)"

    if ! grep -qx "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi

    sudo usermod -s "$FISH_PATH" "$USER"
fi

gsettings set org.gnome.desktop.interface icon-theme "int_clay"

COUNTDOWN=5
COMMAND="sudo reboot"

echo ""
echo "================================="
echo ""
echo "    Instalação concluída!"
echo ""
echo "================================="
echo ""
echo "Para aplicar as configurações, o computador deve reiniciar..."
echo "Pressione CTRL + C para cancelar."
echo ""

for ((i=COUNTDOWN; i>0; i--)); do
    echo -ne "Reiniciando em $i segundos... \r"
    sleep 1
done

echo -e "\nReiniciando!"
eval "$COMMAND"
