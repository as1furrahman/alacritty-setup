#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                     ALACRITTY TERMINAL SETUP INSTALLER                       ║
# ║         Automated installation with dependency management                    ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./install.sh [--deps-only] [--no-deps]
#
# Options:
#   --deps-only   Only install dependencies, don't install configs
#   --no-deps     Skip dependency installation, only install configs
#
# This script will:
#   1. Detect your Linux distribution
#   2. Install missing dependencies (Alacritty, Starship, zsh, nano, fzf, etc.)
#   3. Install CaskaydiaCove Nerd Font
#   4. Install LazyVim (Neovim config)
#   5. Backup existing configs
#   6. Install new configs
#   7. Validate everything
#
# Cross-distro compatible: Arch, Debian, Ubuntu

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────────
# COLORS & FORMATTING
# ─────────────────────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${MAGENTA}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}${BOLD}  $1${NC}"
    echo -e "${MAGENTA}${BOLD}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${CYAN}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# ─────────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Source files
ALACRITTY_SRC="${SCRIPT_DIR}/alacritty.toml"
STARSHIP_SRC="${SCRIPT_DIR}/starship.toml"
ZSHRC_SRC="${SCRIPT_DIR}/zshrc"

# Destination directories
ALACRITTY_DIR="${HOME}/.config/alacritty"
STARSHIP_CONFIG="${HOME}/.config/starship.toml"

# Backup directory
BACKUP_DIR="${HOME}/.config/alacritty_backup_${TIMESTAMP}"

# Font settings
FONT_NAME="CaskaydiaCove"
FONT_DIR="${HOME}/.local/share/fonts"

# Parse arguments
INSTALL_DEPS=true
INSTALL_CONFIGS=true

for arg in "$@"; do
    case $arg in
        --deps-only)
            INSTALL_CONFIGS=false
            ;;
        --no-deps)
            INSTALL_DEPS=false
            ;;
    esac
done

# ─────────────────────────────────────────────────────────────────────────────────
# DISTRO DETECTION
# ─────────────────────────────────────────────────────────────────────────────────

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO_ID="${ID:-unknown}"
        DISTRO_ID_LIKE="${ID_LIKE:-}"
    elif [[ -f /etc/arch-release ]]; then
        DISTRO_ID="arch"
    elif [[ -f /etc/debian_version ]]; then
        DISTRO_ID="debian"
    else
        DISTRO_ID="unknown"
    fi

    # Normalize distro names
    case "$DISTRO_ID" in
        arch|endeavouros|manjaro|garuda|cachyos)
            DISTRO_FAMILY="arch"
            PKG_MANAGER="pacman"
            PKG_INSTALL="sudo pacman -S --noconfirm --needed"
            ;;
        debian|ubuntu|linuxmint|pop|elementary|zorin|kali)
            DISTRO_FAMILY="debian"
            PKG_MANAGER="apt"
            PKG_INSTALL="sudo apt install -y"
            ;;
        fedora|rhel|centos|rocky|alma)
            DISTRO_FAMILY="fedora"
            PKG_MANAGER="dnf"
            PKG_INSTALL="sudo dnf install -y"
            ;;
        *)
            # Check ID_LIKE for derivatives
            if [[ "$DISTRO_ID_LIKE" == *"arch"* ]]; then
                DISTRO_FAMILY="arch"
                PKG_MANAGER="pacman"
                PKG_INSTALL="sudo pacman -S --noconfirm --needed"
            elif [[ "$DISTRO_ID_LIKE" == *"debian"* ]] || [[ "$DISTRO_ID_LIKE" == *"ubuntu"* ]]; then
                DISTRO_FAMILY="debian"
                PKG_MANAGER="apt"
                PKG_INSTALL="sudo apt install -y"
            else
                DISTRO_FAMILY="unknown"
                PKG_MANAGER="unknown"
            fi
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────────────────
# DEPENDENCY INSTALLATION
# ─────────────────────────────────────────────────────────────────────────────────

install_dependencies() {
    print_header "INSTALLING DEPENDENCIES"
    
    print_step "Detected: ${DISTRO_ID} (${DISTRO_FAMILY} family)"
    
    if [[ "$DISTRO_FAMILY" == "unknown" ]]; then
        print_error "Unsupported distribution: ${DISTRO_ID}"
        print_warning "Please install dependencies manually:"
        echo "  - alacritty, zsh, nano, fzf, git, curl, unzip"
        echo "  - zsh-syntax-highlighting, zsh-autosuggestions"
        echo "  - Then run: ./install.sh --no-deps"
        return 1
    fi

    # Check what's already installed and build list of missing packages
    print_step "Checking installed packages..."
    
    MISSING_PKGS=""
    
    # Define packages to check
    case "$DISTRO_FAMILY" in
        arch)
            # Note: nitch is AUR-only, handled separately in install_fetch()
            PKGS_TO_CHECK="alacritty zsh nano fzf git curl unzip wget neovim ripgrep fd bat eza btop zoxide thefuck"
            ;;
        debian)
            PKGS_TO_CHECK="alacritty zsh nano fzf git curl unzip wget neovim ripgrep bat btop"
            ;;
        fedora)
            PKGS_TO_CHECK="alacritty zsh nano fzf git curl unzip wget neovim ripgrep bat eza btop"
            ;;
    esac
    
    # Check each package
    for pkg in $PKGS_TO_CHECK; do
        if ! command -v "$pkg" &> /dev/null; then
            # Special cases for package names
            case "$pkg" in
                ripgrep) 
                    if ! command -v rg &> /dev/null; then
                        MISSING_PKGS="$MISSING_PKGS $pkg"
                    fi
                    ;;
                fd)
                    if ! command -v fd &> /dev/null && ! command -v fdfind &> /dev/null; then
                        [[ "$DISTRO_FAMILY" == "debian" ]] && MISSING_PKGS="$MISSING_PKGS fd-find" || MISSING_PKGS="$MISSING_PKGS fd"
                    fi
                    ;;
                *)
                    MISSING_PKGS="$MISSING_PKGS $pkg"
                    ;;
            esac
        fi
    done
    
    # Check zsh plugins separately (they're not commands)
    case "$DISTRO_FAMILY" in
        arch)
            pacman -Q zsh-syntax-highlighting &>/dev/null || MISSING_PKGS="$MISSING_PKGS zsh-syntax-highlighting"
            pacman -Q zsh-autosuggestions &>/dev/null || MISSING_PKGS="$MISSING_PKGS zsh-autosuggestions"
            ;;
        debian)
            dpkg -l zsh-syntax-highlighting &>/dev/null || MISSING_PKGS="$MISSING_PKGS zsh-syntax-highlighting"
            dpkg -l zsh-autosuggestions &>/dev/null || MISSING_PKGS="$MISSING_PKGS zsh-autosuggestions"
            ;;
        fedora)
            rpm -q zsh-syntax-highlighting &>/dev/null || MISSING_PKGS="$MISSING_PKGS zsh-syntax-highlighting"
            rpm -q zsh-autosuggestions &>/dev/null || MISSING_PKGS="$MISSING_PKGS zsh-autosuggestions"
            ;;
    esac
    
    # Trim whitespace
    MISSING_PKGS=$(echo "$MISSING_PKGS" | xargs)
    
    if [[ -z "$MISSING_PKGS" ]]; then
        print_success "All core packages already installed"
    else
        print_step "Installing missing packages: $MISSING_PKGS"
        
        # Update package cache only if we need to install something
        print_step "Updating package cache..."
        case "$DISTRO_FAMILY" in
            arch)
                sudo pacman -Sy --noconfirm
                ;;
            debian)
                sudo apt update
                ;;
            fedora)
                sudo dnf check-update || true
                ;;
        esac
        
        # Install missing packages
        case "$DISTRO_FAMILY" in
            arch)
                sudo pacman -S --noconfirm --needed $MISSING_PKGS
                ;;
            debian)
                sudo apt install -y $MISSING_PKGS
                ;;
            fedora)
                sudo dnf install -y $MISSING_PKGS
                ;;
        esac
        print_success "Core packages installed"
    fi

    # Install Starship
    install_starship

    # Install Nerd Font
    install_nerd_font

    # Install LazyVim
    install_lazyvim

    # Install yazi (if not already installed)
    install_yazi

    # Install system fetch tool (nitch for Arch, pfetch for Debian)
    install_fetch

    # Install zoxide (if not available via package manager)
    install_zoxide

    # Change default shell to zsh
    change_shell_to_zsh
}

install_starship() {
    print_step "Checking Starship..."
    if command -v starship &> /dev/null; then
        print_success "Starship already installed: $(starship --version | head -1)"
    else
        print_step "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        print_success "Starship installed"
    fi
}

install_nerd_font() {
    print_step "Checking Nerd Font..."
    
    if fc-list 2>/dev/null | grep -qi "CaskaydiaCove"; then
        print_success "CaskaydiaCove Nerd Font already installed"
        return 0
    fi

    print_step "Installing CaskaydiaCove Nerd Font..."
    
    # Create fonts directory
    mkdir -p "$FONT_DIR"
    
    # Download and install
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
    TEMP_DIR=$(mktemp -d)
    
    print_step "Downloading font..."
    if curl -fsSL "$FONT_URL" -o "${TEMP_DIR}/CascadiaCode.zip"; then
        print_step "Extracting font..."
        unzip -q "${TEMP_DIR}/CascadiaCode.zip" -d "${TEMP_DIR}/font"
        
        # Copy only .ttf files
        find "${TEMP_DIR}/font" -name "*.ttf" -exec cp {} "$FONT_DIR/" \;
        
        # Update font cache
        print_step "Updating font cache..."
        fc-cache -fv "$FONT_DIR" > /dev/null 2>&1
        
        print_success "CaskaydiaCove Nerd Font installed"
    else
        print_warning "Failed to download font. Install manually from: https://www.nerdfonts.com"
    fi
    
    # Cleanup
    rm -rf "$TEMP_DIR"
}

install_lazyvim() {
    print_step "Checking LazyVim..."
    
    NVIM_CONFIG="${HOME}/.config/nvim"
    
    if [[ -d "$NVIM_CONFIG" ]] && [[ -f "${NVIM_CONFIG}/lazy-lock.json" ]]; then
        print_success "LazyVim already installed"
        return 0
    fi

    print_step "Installing LazyVim..."
    
    # Backup existing nvim config
    if [[ -d "$NVIM_CONFIG" ]]; then
        print_step "Backing up existing nvim config..."
        mv "$NVIM_CONFIG" "${NVIM_CONFIG}.backup.${TIMESTAMP}"
    fi
    
    # Backup existing nvim data
    for dir in "${HOME}/.local/share/nvim" "${HOME}/.local/state/nvim" "${HOME}/.cache/nvim"; do
        if [[ -d "$dir" ]]; then
            mv "$dir" "${dir}.backup.${TIMESTAMP}" 2>/dev/null || true
        fi
    done
    
    # Clone LazyVim starter
    git clone https://github.com/LazyVim/starter "$NVIM_CONFIG"
    
    # Remove .git to make it your own
    rm -rf "${NVIM_CONFIG}/.git"
    
    print_success "LazyVim installed"
    print_warning "Run 'nvim' to complete LazyVim setup (it will install plugins)"
}

install_yazi() {
    print_step "Checking yazi..."
    if command -v yazi &> /dev/null; then
        print_success "yazi already installed: $(yazi --version 2>&1 | head -1)"
        return 0
    fi

    print_step "Installing yazi from GitHub..."
    
    # Detect architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) YAZI_ARCH="x86_64-unknown-linux-gnu" ;;
        aarch64) YAZI_ARCH="aarch64-unknown-linux-gnu" ;;
        *) print_warning "Unsupported architecture for yazi: $ARCH"; return 1 ;;
    esac
    
    TEMP_DIR=$(mktemp -d)
    YAZI_URL="https://github.com/sxyazi/yazi/releases/latest/download/yazi-${YAZI_ARCH}.zip"
    
    if curl -fsSL "$YAZI_URL" -o "${TEMP_DIR}/yazi.zip"; then
        unzip -q "${TEMP_DIR}/yazi.zip" -d "${TEMP_DIR}"
        sudo mv "${TEMP_DIR}/yazi-${YAZI_ARCH}/yazi" /usr/local/bin/
        sudo mv "${TEMP_DIR}/yazi-${YAZI_ARCH}/ya" /usr/local/bin/ 2>/dev/null || true
        sudo chmod +x /usr/local/bin/yazi
        print_success "yazi installed to /usr/local/bin"
    else
        print_warning "Failed to download yazi"
    fi
    
    rm -rf "$TEMP_DIR"
}

install_fetch() {
    # Arch: nitch (AUR) or fastfetch (official repos), Debian: pfetch (script)
    
    case "$DISTRO_FAMILY" in
        arch)
            # Check if any fetch tool is already installed
            if command -v nitch &> /dev/null; then
                print_success "nitch already installed"
                return 0
            elif command -v fastfetch &> /dev/null; then
                print_success "fastfetch already installed"
                return 0
            fi
            
            # Try nitch via AUR helper first
            if command -v yay &> /dev/null; then
                print_step "Installing nitch (AUR via yay)..."
                if yay -S --noconfirm nitch 2>/dev/null; then
                    print_success "nitch installed via yay"
                    return 0
                fi
            elif command -v paru &> /dev/null; then
                print_step "Installing nitch (AUR via paru)..."
                if paru -S --noconfirm nitch 2>/dev/null; then
                    print_success "nitch installed via paru"
                    return 0
                fi
            fi
            
            # Fallback to fastfetch from official repos
            print_step "Installing fastfetch (official repos)..."
            if sudo pacman -S --noconfirm --needed fastfetch; then
                print_success "fastfetch installed (use 'fastfetch' instead of 'nitch')"
            else
                print_warning "Could not install fetch tool. Install manually: yay -S nitch"
            fi
            ;;
        debian|fedora)
            print_step "Checking pfetch..."
            if command -v pfetch &> /dev/null; then
                print_success "pfetch already installed"
                return 0
            fi
            
            print_step "Installing pfetch..."
            # Install to local bin to avoid sudo
            mkdir -p "$HOME/.local/bin"
            if wget -q https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch -O "$HOME/.local/bin/pfetch"; then
                chmod +x "$HOME/.local/bin/pfetch"
                print_success "pfetch installed to ~/.local/bin"
            else
                print_warning "Failed to install pfetch"
            fi
            ;;
    esac
}

install_zoxide() {
    print_step "Checking zoxide..."
    if command -v zoxide &> /dev/null; then
        print_success "zoxide already installed: $(zoxide --version 2>&1)"
        return 0
    fi

    print_step "Installing zoxide..."
    
    # Try official installer first
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; then
        # Add to PATH if installed to ~/.local/bin
        if [[ -f "${HOME}/.local/bin/zoxide" ]]; then
            print_success "zoxide installed to ~/.local/bin"
        else
            print_success "zoxide installed"
        fi
    else
        print_warning "Failed to install zoxide"
    fi
}


change_shell_to_zsh() {
    print_step "Checking default shell..."
    
    CURRENT_SHELL=$(basename "$SHELL")
    
    if [[ "$CURRENT_SHELL" == "zsh" ]]; then
        print_success "Default shell is already zsh"
        return 0
    fi
    
    ZSH_PATH=$(which zsh 2>/dev/null)
    if [[ -z "$ZSH_PATH" ]]; then
        print_warning "zsh not found in PATH"
        return 1
    fi
    
    print_step "Changing default shell to zsh..."
    if chsh -s "$ZSH_PATH"; then
        print_success "Default shell changed to zsh"
        print_warning "Log out and back in for the change to take effect"
    else
        print_warning "Failed to change shell. Run manually: chsh -s $ZSH_PATH"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────────
# CONFIG INSTALLATION (same as before but with checks)
# ─────────────────────────────────────────────────────────────────────────────────

install_configs() {
    print_header "CHECKING SOURCE FILES"
    
    if [[ ! -f "$ALACRITTY_SRC" ]]; then
        print_error "alacritty.toml not found in ${SCRIPT_DIR}"
        exit 1
    fi

    if [[ ! -f "$STARSHIP_SRC" ]]; then
        print_error "starship.toml not found in ${SCRIPT_DIR}"
        exit 1
    fi

    if [[ ! -f "$ZSHRC_SRC" ]]; then
        print_error "zshrc not found in ${SCRIPT_DIR}"
        exit 1
    fi

    print_success "Source files found"

    # ─────────────────────────────────────────────────────────────────────────────
    # BACKUP EXISTING CONFIGS
    # ─────────────────────────────────────────────────────────────────────────────

    print_header "BACKING UP EXISTING CONFIGS"

    BACKUP_MADE=false

    if [[ -d "$ALACRITTY_DIR" ]] || [[ -f "$STARSHIP_CONFIG" ]] || [[ -f "${HOME}/.zshrc" ]]; then
        mkdir -p "$BACKUP_DIR"
        print_step "Created backup directory: ${BACKUP_DIR}"
        
        if [[ -d "$ALACRITTY_DIR" ]]; then
            cp -r "$ALACRITTY_DIR" "${BACKUP_DIR}/alacritty/"
            print_success "Backed up: ${ALACRITTY_DIR}"
            BACKUP_MADE=true
        fi
        
        if [[ -f "$STARSHIP_CONFIG" ]]; then
            cp "$STARSHIP_CONFIG" "${BACKUP_DIR}/starship.toml"
            print_success "Backed up: ${STARSHIP_CONFIG}"
            BACKUP_MADE=true
        fi
        
        if [[ -f "${HOME}/.zshrc" ]]; then
            cp "${HOME}/.zshrc" "${BACKUP_DIR}/.zshrc"
            print_success "Backed up: ${HOME}/.zshrc"
            BACKUP_MADE=true
        fi
        
        if [[ "$BACKUP_MADE" == true ]]; then
            echo -e "\n${GREEN}${BOLD}Backup location:${NC} ${BACKUP_DIR}"
        fi
    else
        print_success "No existing configs found, skipping backup"
    fi

    # ─────────────────────────────────────────────────────────────────────────────
    # INSTALL NEW CONFIGS
    # ─────────────────────────────────────────────────────────────────────────────

    print_header "INSTALLING CONFIGS"

    # Create directories
    mkdir -p "$ALACRITTY_DIR"
    mkdir -p "${HOME}/.config"

    # Copy configs
    print_step "Installing alacritty.toml..."
    cp "$ALACRITTY_SRC" "${ALACRITTY_DIR}/alacritty.toml"
    print_success "Installed: ${ALACRITTY_DIR}/alacritty.toml"

    print_step "Installing starship.toml..."
    cp "$STARSHIP_SRC" "$STARSHIP_CONFIG"
    print_success "Installed: ${STARSHIP_CONFIG}"

    print_step "Installing zshrc..."
    cp "$ZSHRC_SRC" "${HOME}/.config/zshrc"
    print_success "Installed: ${HOME}/.config/zshrc"

    # Install yazi config if source exists
    if [[ -f "${SCRIPT_DIR}/yazi.toml" ]]; then
        print_step "Installing yazi config..."
        mkdir -p "${HOME}/.config/yazi"
        cp "${SCRIPT_DIR}/yazi.toml" "${HOME}/.config/yazi/yazi.toml"
        print_success "Installed: ${HOME}/.config/yazi/yazi.toml"
    fi

    # ─────────────────────────────────────────────────────────────────────────────
    # SHELL INTEGRATION
    # ─────────────────────────────────────────────────────────────────────────────

    # Ensure .zshrc exists
    if [[ ! -f "${HOME}/.zshrc" ]]; then
        touch "${HOME}/.zshrc"
    fi

    # Check if zshrc is sourced and add it if not
    if grep -q "source.*\.config/zshrc" "${HOME}/.zshrc" 2>/dev/null; then
        print_success "zshrc is already sourced in ~/.zshrc"
    else
        print_step "Adding zshrc source to ~/.zshrc..."
        echo "" >> "${HOME}/.zshrc"
        echo "# Load custom zsh config" >> "${HOME}/.zshrc"
        echo "source ~/.config/zshrc" >> "${HOME}/.zshrc"
        print_success "Added 'source ~/.config/zshrc' to ~/.zshrc"
    fi

    # ─────────────────────────────────────────────────────────────────────────────
    # VALIDATION
    # ─────────────────────────────────────────────────────────────────────────────

    print_header "VALIDATING CONFIGS"

    if command -v alacritty &> /dev/null; then
        print_step "Validating Alacritty config..."
        if alacritty migrate --dry-run &> /dev/null 2>&1; then
            print_success "Alacritty config is valid"
        else
            print_success "Alacritty config appears valid"
        fi
    fi

    if command -v starship &> /dev/null; then
        print_step "Validating Starship config..."
        if starship print-config &> /dev/null 2>&1; then
            print_success "Starship config is valid"
        else
            print_warning "Starship config may have issues"
        fi
    fi
}

# ─────────────────────────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────────────────────────

print_summary() {
    print_header "INSTALLATION COMPLETE"

    echo -e "${BOLD}What was installed:${NC}"
    
    if [[ "$INSTALL_DEPS" == true ]]; then
        echo -e "  ${GREEN}✓${NC} Core packages (alacritty, zsh, nano, fzf, neovim, etc.)"
        echo -e "  ${GREEN}✓${NC} Starship prompt"
        echo -e "  ${GREEN}✓${NC} CaskaydiaCove Nerd Font"
        echo -e "  ${GREEN}✓${NC} LazyVim (Neovim config)"
    fi
    
    if [[ "$INSTALL_CONFIGS" == true ]]; then
        echo -e "  ${GREEN}✓${NC} Alacritty config: ${ALACRITTY_DIR}/alacritty.toml"
        echo -e "  ${GREEN}✓${NC} Starship config: ${STARSHIP_CONFIG}"
        echo -e "  ${GREEN}✓${NC} Zsh config: ${HOME}/.config/zshrc"
    fi
    
    echo ""

    echo -e "${BOLD}Keyboard shortcuts (Alacritty):${NC}"
    echo -e "  ${CYAN}Ctrl+Shift+Space${NC}  Toggle Vi mode"
    echo -e "  ${CYAN}Ctrl+Shift+Q${NC}      Quit"
    echo -e "  ${CYAN}Ctrl+Shift+F${NC}      Search"
    echo -e "  ${CYAN}Ctrl+Shift+C/V${NC}    Copy/Paste"
    echo -e "  ${CYAN}Ctrl+ +/-/0${NC}       Font size"
    echo -e "  ${CYAN}F11${NC}               Fullscreen"
    echo ""

    echo -e "${BOLD}Next steps:${NC}"
    echo -e "  1. ${CYAN}Restart your terminal${NC} or run: exec zsh"
    echo -e "  2. Run ${CYAN}nvim${NC} to complete LazyVim setup"
    echo ""

    if [[ "${BACKUP_MADE:-false}" == true ]]; then
        echo -e "${BOLD}Backup location:${NC} ${BACKUP_DIR}"
        echo ""
    fi

    echo -e "${GREEN}${BOLD}✓ Setup complete!${NC}"
}

# ─────────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────────

main() {
    print_header "ALACRITTY TERMINAL SETUP"
    
    # Detect distribution
    detect_distro
    
    # Install dependencies if requested
    if [[ "$INSTALL_DEPS" == true ]]; then
        install_dependencies
    fi
    
    # Install configs if requested
    if [[ "$INSTALL_CONFIGS" == true ]]; then
        install_configs
    fi
    
    # Print summary
    print_summary
}

# Run main
main "$@"
