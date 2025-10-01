#!/bin/bash

# Mac Work Transfer - Improved Setup Script with Better Error Handling
# Run this script on a new Mac to restore your work environment

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track failures
FAILURES=()

# Helper functions
log() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
    FAILURES+=("$1")
}

info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script is for macOS only"
    exit 1
fi

echo "================================"
echo "Mac Work Transfer Setup Script"
echo "================================"
echo ""

# Phase 1: Install Homebrew
info "Phase 1: Core Tools Installation"
if ! command -v brew &> /dev/null; then
    log "Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -d "/opt/homebrew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        log "Homebrew installed successfully"
    else
        error "Homebrew installation failed - continue manually"
    fi
else
    log "Homebrew already installed"
fi

# Phase 2: Install Homebrew packages
info "Phase 2: Installing Homebrew Packages"
if [[ -f "Brewfile.essentials" ]]; then
    if brew bundle install --file=Brewfile.essentials --verbose; then
        log "Homebrew packages installed"
    else
        warn "Some Homebrew packages failed to install"
        warn "Run 'brew bundle install --file=Brewfile.essentials --verbose' to retry"
    fi
else
    error "Brewfile.essentials not found!"
fi

# Phase 3: Restore dotfiles FIRST (before apps need them)
info "Phase 3: Restoring Dotfiles"
if [[ -x "./scripts/restore-dotfiles.sh" ]]; then
    if ./scripts/restore-dotfiles.sh; then
        log "Dotfiles restored"
    else
        error "Dotfiles restoration failed"
    fi
else
    error "restore-dotfiles.sh not found or not executable"
fi

# Phase 4: Show manual apps to install
info "Phase 4: Manual Application Installation Required"
echo ""
warn "IMPORTANT: Install these apps NOW before continuing:"
if [[ -x "./scripts/list-manual-apps.sh" ]]; then
    ./scripts/list-manual-apps.sh
else
    error "list-manual-apps.sh not found"
fi

echo ""
read -p "Press ENTER after installing manual apps to continue..."

# Phase 5: Restore app configs AFTER apps are installed
info "Phase 5: Restoring Application Configurations"
if [[ -x "./scripts/restore-app-configs.sh" ]]; then
    if ./scripts/restore-app-configs.sh; then
        log "App configurations restored"
    else
        warn "Some app configurations failed - check output above"
    fi
else
    error "restore-app-configs.sh not found or not executable"
fi

# Phase 6: VS Code Extensions (if VS Code installed)
info "Phase 6: VS Code Extensions"
if command -v code &> /dev/null; then
    log "Installing VS Code extensions..."
    while IFS= read -r line; do
        if [[ $line == vscode* ]]; then
            ext=$(echo $line | awk '{print $2}' | tr -d '"')
            code --install-extension "$ext" 2>/dev/null && \
                echo "  → Installed $ext" || \
                warn "  Failed: $ext"
        fi
    done < Brewfile.essentials
else
    warn "VS Code not found - install manually then run:"
    warn "grep '^vscode' Brewfile.essentials | awk '{print \$2}' | xargs -I {} code --install-extension {}"
fi

# Phase 7: System preferences
info "Phase 7: System Preferences"
read -p "Apply system preferences? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ -x "./scripts/setup-system-prefs.sh" ]]; then
        ./scripts/setup-system-prefs.sh
    else
        error "setup-system-prefs.sh not found"
    fi
fi

# Summary
echo ""
echo "================================"
if [ ${#FAILURES[@]} -eq 0 ]; then
    echo -e "${GREEN}Setup Complete!${NC}"
else
    echo -e "${YELLOW}Setup Complete with Issues${NC}"
    echo ""
    echo "Failed steps:"
    for failure in "${FAILURES[@]}"; do
        echo "  - $failure"
    done
    echo ""
    echo "See MANUAL_RECOVERY.md for manual steps"
fi
echo "================================"
echo ""
echo "Next steps:"
echo "1. Restart applications for configs to take effect"
echo "2. Open Karabiner-Elements to load keyboard config"
echo "3. Sign into accounts (GitHub, browsers, etc.)"
echo "4. Generate new SSH keys if needed"
echo "5. Restart Mac for all system preferences to apply"