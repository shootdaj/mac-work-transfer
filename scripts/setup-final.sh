#!/bin/bash

# Mac Work Transfer - Ultra-Robust Setup Script
# Designed for maximum reliability and graceful degradation

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Progress tracking
SUCCESS_COUNT=0
FAILURE_COUNT=0
SKIPPED_COUNT=0
FAILURES=()
SUCCESSES=()

# Logging functions
log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    SUCCESSES+=("$1")
    ((SUCCESS_COUNT++))
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    FAILURES+=("$1")
    ((FAILURE_COUNT++))
}

log_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

log_skip() {
    echo -e "${CYAN}[→]${NC} $1"
    ((SKIPPED_COUNT++))
}

# Progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    printf "\r${CYAN}Progress: ["
    printf "%*s" $filled | tr ' ' '='
    printf "%*s" $((width - filled)) | tr ' ' '-'
    printf "] %d%% (%d/%d)${NC}" $percentage $current $total
}

# Check prerequisites
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script requires macOS"
        exit 1
    fi
    log_success "macOS detected"
}

# Safe command runner with retry
safe_run() {
    local cmd="$1"
    local desc="$2"
    local retries=${3:-1}
    
    for ((i=1; i<=retries; i++)); do
        if eval "$cmd" >/dev/null 2>&1; then
            log_success "$desc"
            return 0
        elif [[ $i -lt $retries ]]; then
            log_warning "$desc failed, retrying ($((i+1))/$retries)..."
            sleep 2
        fi
    done
    
    log_error "$desc failed after $retries attempts"
    return 1
}

# Install Homebrew with robust error handling
install_homebrew() {
    log_info "Checking Homebrew installation..."
    
    if command -v brew >/dev/null 2>&1; then
        log_success "Homebrew already installed"
        return 0
    fi
    
    log_info "Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null; then
        # Handle path setup for both Intel and Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        log_success "Homebrew installed successfully"
        return 0
    else
        log_error "Homebrew installation failed"
        return 1
    fi
}

# Install Homebrew packages with graceful failure handling
install_homebrew_packages() {
    log_info "Installing Homebrew packages..."
    
    if [[ ! -f "Brewfile.essentials" ]]; then
        log_error "Brewfile.essentials not found"
        return 1
    fi
    
    # First try batch install
    if brew bundle install --file=Brewfile.essentials --no-lock 2>/dev/null; then
        log_success "All Homebrew packages installed successfully"
        return 0
    fi
    
    # If batch fails, install individually
    log_warning "Batch install failed, trying individual packages..."
    local success=0
    local total=0
    
    while IFS= read -r line; do
        [[ $line =~ ^(brew|cask)\ \"([^\"]+)\" ]] || continue
        local type="${BASH_REMATCH[1]}"
        local package="${BASH_REMATCH[2]}"
        ((total++))
        
        if [[ $type == "brew" ]]; then
            if brew install "$package" 2>/dev/null; then
                log_success "Installed: $package"
                ((success++))
            else
                log_error "Failed: $package"
            fi
        elif [[ $type == "cask" ]]; then
            if brew install --cask "$package" 2>/dev/null; then
                log_success "Installed: $package"
                ((success++))
            else
                log_error "Failed: $package"
            fi
        fi
    done < "Brewfile.essentials"
    
    log_info "Homebrew packages: $success/$total successful"
    [[ $success -gt 0 ]] && return 0 || return 1
}

# Restore dotfiles with backup
restore_dotfiles() {
    log_info "Restoring dotfiles..."
    
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Define dotfile mappings
    local -A dotfiles=(
        ["docs/configs/dotfiles/.zshrc"]="$HOME/.zshrc"
        ["docs/configs/dotfiles/.zprofile"]="$HOME/.zprofile" 
        ["docs/configs/dotfiles/.gitconfig"]="$HOME/.gitconfig"
    )
    
    for src in "${!dotfiles[@]}"; do
        local dst="${dotfiles[$src]}"
        local filename=$(basename "$dst")
        
        if [[ -f "$src" ]]; then
            [[ -f "$dst" ]] && cp "$dst" "$backup_dir/$filename" 2>/dev/null
            if cp "$src" "$dst" 2>/dev/null; then
                log_success "Restored $filename"
            else
                log_error "Failed to restore $filename"
            fi
        else
            log_skip "$filename (source not found)"
        fi
    done
    
    # Config directories
    local -A config_dirs=(
        ["docs/configs/dotfiles/gh"]="$HOME/.config/gh"
        ["docs/configs/dotfiles/NotepadNext"]="$HOME/.config/NotepadNext"
        ["docs/configs/karabiner"]="$HOME/.config/karabiner"
        ["docs/configs/far2l"]="$HOME/.config/far2l"
    )
    
    mkdir -p "$HOME/.config"
    
    for src in "${!config_dirs[@]}"; do
        local dst="${config_dirs[$src]}"
        local dirname=$(basename "$dst")
        
        if [[ -d "$src" ]]; then
            [[ -d "$dst" ]] && cp -r "$dst" "$backup_dir/$dirname-backup" 2>/dev/null
            if cp -r "$src" "$dst" 2>/dev/null; then
                log_success "Restored $dirname config"
            else
                log_error "Failed to restore $dirname config"
            fi
        else
            log_skip "$dirname config (source not found)"
        fi
    done
    
    log_info "Backups saved to: $backup_dir"
}

# Show manual apps with download links
show_manual_apps() {
    log_info "Manual applications to install:"
    echo ""
    
    local apps=(
        "AltTab|https://alt-tab-macos.netlify.app|Window switcher"
        "Amphetamine|Mac App Store|Keep Mac awake"
        "Bartender 5|https://www.macbartender.com|Menu bar organization"
        "Beyond Compare|https://scootersoftware.com|File comparison"
        "ChatGPT|https://chatgpt.com/download|OpenAI ChatGPT app"
        "Claude|https://claude.ai/download|Anthropic Claude app"
        "Copilot|https://github.com/features/copilot|GitHub Copilot"
        "CotEditor|https://coteditor.com|Text editor"
        "Raycast|https://raycast.com|Productivity launcher"
        "Warp|https://warp.dev|Modern terminal"
        "Zed|https://zed.dev|Code editor"
    )
    
    for app in "${apps[@]}"; do
        IFS='|' read -r name url desc <<< "$app"
        echo -e "${BLUE}$name${NC} - $desc"
        echo "  → Download: $url"
        echo ""
    done
}

# Restore app configs after apps are installed
restore_app_configs() {
    log_info "Restoring application configurations..."
    
    # App config mappings with error handling
    local -A app_configs=(
        ["BetterTouchTool"]="docs/configs/bettertouchtool:$HOME/Library/Application Support/BetterTouchTool"
        ["Cursor"]="docs/configs/cursor:$HOME/Library/Application Support/Cursor/User"
        ["GitKraken"]="docs/configs/gitkraken:$HOME/.gitkraken"
        ["VLC"]="docs/configs/vlc:$HOME/Library/Preferences/org.videolan.vlc"
        ["Firefox"]="docs/configs/firefox:$HOME/Library/Application Support/Firefox/Profiles"
        ["Raycast"]="docs/configs/raycast:$HOME/Library/Group Containers/SY64MV22J9.com.raycast.macos.shared"
        ["Warp"]="docs/configs/warp:$HOME/Library/Application Support/dev.warp.Warp-Stable"
        ["Zed"]="docs/configs/zed:$HOME/Library/Application Support/Zed"
    )
    
    for app in "${!app_configs[@]}"; do
        IFS=':' read -r src dst <<< "${app_configs[$app]}"
        
        if [[ -d "$src" ]]; then
            mkdir -p "$(dirname "$dst")" 2>/dev/null
            if cp -r "$src"/* "$dst/" 2>/dev/null; then
                log_success "$app config restored"
            else
                log_warning "$app config failed (app may need to be installed first)"
            fi
        else
            log_skip "$app config (source not found)"
        fi
    done
    
    # Handle preference files
    if [[ -f "docs/configs/bartender/com.surteesstudios.Bartender.plist" ]]; then
        if cp "docs/configs/bartender/com.surteesstudios.Bartender.plist" "$HOME/Library/Preferences/" 2>/dev/null; then
            log_success "Bartender preferences restored"
        else
            log_warning "Bartender preferences failed"
        fi
    fi
    
    if [[ -f "docs/configs/altTab/alttab.plist" ]]; then
        if defaults import com.lwouis.alt-tab-macos "docs/configs/altTab/alttab.plist" 2>/dev/null; then
            log_success "AltTab preferences restored"
        else
            log_warning "AltTab preferences failed"
        fi
    fi
}

# Apply system preferences with user confirmation
setup_system_preferences() {
    echo ""
    read -p "Apply macOS system preferences? (y/n) " -n 1 -r
    echo
    
    [[ ! $REPLY =~ ^[Yy]$ ]] && { log_skip "System preferences"; return 0; }
    
    log_info "Applying system preferences..."
    
    # Safe preference setters
    local -A prefs=(
        ["Hide Dock automatically"]="defaults write com.apple.dock autohide -bool true"
        ["Faster Dock animation"]="defaults write com.apple.dock autohide-time-modifier -float 0.5"
        ["Show Finder path bar"]="defaults write com.apple.finder ShowPathbar -bool true"
        ["Show file extensions"]="defaults write NSGlobalDomain AppleShowAllExtensions -bool true"
        ["Faster key repeat"]="defaults write NSGlobalDomain KeyRepeat -int 2"
        ["Enable tap to click"]="defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true"
        ["Don't rearrange spaces"]="defaults write com.apple.dock mru-spaces -bool false"
        ["Show hidden files"]="defaults write com.apple.finder AppleShowAllFiles -bool true"
    )
    
    for desc in "${!prefs[@]}"; do
        if eval "${prefs[$desc]}" 2>/dev/null; then
            log_success "$desc"
        else
            log_warning "$desc failed"
        fi
    done
    
    # Restart UI services
    killall Dock 2>/dev/null && log_success "Dock restarted" || log_warning "Dock restart failed"
    killall Finder 2>/dev/null && log_success "Finder restarted" || log_warning "Finder restart failed"
}

# Main execution
main() {
    clear
    echo "=================================="
    echo "Mac Work Transfer - Ultra Setup"
    echo "=================================="
    echo ""
    
    # Phase execution with progress tracking
    local phases=(
        "check_macos:macOS Check"
        "install_homebrew:Homebrew Setup"
        "install_homebrew_packages:Package Installation"
        "restore_dotfiles:Dotfiles Restore"
    )
    
    local current_phase=0
    for phase_info in "${phases[@]}"; do
        IFS=':' read -r phase_func phase_name <<< "$phase_info"
        ((current_phase++))
        
        echo ""
        log_info "Phase $current_phase: $phase_name"
        show_progress $current_phase ${#phases[@]}
        echo ""
        
        if ! $phase_func; then
            log_warning "Phase $current_phase completed with issues"
        fi
    done
    
    echo ""
    echo ""
    
    # Manual apps phase
    log_info "Phase 5: Manual Application Installation"
    show_manual_apps
    
    echo "=================================="
    log_warning "STOP: Install the manual apps above before continuing"
    echo "=================================="
    echo ""
    read -p "Press ENTER after installing manual apps..."
    
    # Config restore phase
    echo ""
    log_info "Phase 6: Application Configuration Restore"
    restore_app_configs
    
    # System preferences phase
    log_info "Phase 7: System Preferences"
    setup_system_preferences
    
    # Final summary
    echo ""
    echo "=================================="
    echo "Setup Complete!"
    echo "=================================="
    echo ""
    echo -e "Results: ${GREEN}$SUCCESS_COUNT success${NC}, ${RED}$FAILURE_COUNT failed${NC}, ${CYAN}$SKIPPED_COUNT skipped${NC}"
    
    if [[ $FAILURE_COUNT -gt 0 ]]; then
        echo ""
        echo "Failed items (see MANUAL_RECOVERY.md for fixes):"
        printf '  • %s\n' "${FAILURES[@]}"
    fi
    
    echo ""
    echo "Next steps:"
    echo "1. Open Karabiner-Elements to load keyboard config"
    echo "2. Restart applications for configs to take effect"
    echo "3. Generate SSH keys: ssh-keygen -t ed25519 -C \"your_email\""
    echo "4. Sign into accounts (GitHub, browsers, etc.)"
    echo "5. Restart Mac for all system changes to apply"
}

# Run main function
main "$@"