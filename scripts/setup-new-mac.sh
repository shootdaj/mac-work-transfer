#!/bin/bash

# 🚀 Complete Mac Work Transfer Setup
# Automated setup script for new Mac

set -e  # Exit on any error

echo "🍎 Starting Mac Work Transfer Setup..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "\n${BLUE}📋 Step $1: $2${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

print_step "1" "Installing Homebrew"
if command -v brew >/dev/null 2>&1; then
    print_success "Homebrew already installed"
else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    print_success "Homebrew installed"
fi

print_step "2" "Installing Essential Packages"
if [[ -f "$REPO_DIR/Brewfile.essentials" ]]; then
    echo "Installing packages from Brewfile.essentials..."
    brew bundle install --file="$REPO_DIR/Brewfile.essentials"
    print_success "Essential packages installed"
else
    print_error "Brewfile.essentials not found"
    exit 1
fi

print_step "3" "Setting up Development Environment"

# Install NVM
if [[ ! -d "$HOME/.nvm" ]]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    print_success "NVM installed"
else
    print_success "NVM already installed"
fi

# Source NVM and install Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if command -v nvm >/dev/null 2>&1; then
    echo "Installing Node.js v24.2.0..."
    nvm install 24.2.0
    nvm use 24.2.0
    nvm alias default 24.2.0
    print_success "Node.js v24.2.0 installed"
fi

print_step "4" "Restoring Dotfiles"
if [[ -d "$REPO_DIR/docs/configs/dotfiles" ]]; then
    echo "Copying dotfiles..."
    cp "$REPO_DIR/docs/configs/dotfiles/.zshrc" ~/
    cp "$REPO_DIR/docs/configs/dotfiles/.gitconfig" ~/
    cp "$REPO_DIR/docs/configs/dotfiles/.zprofile" ~/
    
    # Create .config directory if it doesn't exist
    mkdir -p ~/.config
    cp -r "$REPO_DIR/docs/configs/dotfiles/gh" ~/.config/ 2>/dev/null || true
    
    print_success "Dotfiles restored"
else
    print_warning "Dotfiles backup not found"
fi

print_step "5" "Restoring Application Configurations"
if [[ -d "$REPO_DIR/docs/configs" ]]; then
    echo "Restoring app configurations..."
    
    # BetterTouchTool
    if [[ -d "$REPO_DIR/docs/configs/bettertouchtool" ]]; then
        mkdir -p ~/Library/Application\ Support/BetterTouchTool
        cp -r "$REPO_DIR/docs/configs/bettertouchtool/"* ~/Library/Application\ Support/BetterTouchTool/
        print_success "BetterTouchTool config restored"
    fi
    
    # Karabiner-Elements
    if [[ -d "$REPO_DIR/docs/configs/karabiner" ]]; then
        mkdir -p ~/.config/karabiner
        cp -r "$REPO_DIR/docs/configs/karabiner/"* ~/.config/karabiner/
        print_success "Karabiner config restored"
    fi
    
    # Cursor
    if [[ -d "$REPO_DIR/docs/configs/cursor" ]]; then
        mkdir -p ~/Library/Application\ Support/Cursor/User
        cp -r "$REPO_DIR/docs/configs/cursor/"* ~/Library/Application\ Support/Cursor/User/
        print_success "Cursor config restored"
    fi

    # Bartender
    if [[ -d "$REPO_DIR/docs/configs/bartender" ]]; then
        mkdir -p ~/Library/Application\ Support/Bartender
        cp -r "$REPO_DIR/docs/configs/bartender/"* ~/Library/Application\ Support/Bartender/
        print_success "Bartender config restored"
    fi
    
else
    print_warning "App configurations backup not found"
fi

print_step "6" "Applying macOS System Preferences"
if [[ -f "$REPO_DIR/docs/configs/macos-settings/restore-macos-settings.sh" ]]; then
    echo "Applying system preferences..."
    bash "$REPO_DIR/docs/configs/macos-settings/restore-macos-settings.sh"
    print_success "System preferences applied"
else
    print_warning "macOS settings restore script not found"
fi

print_step "7" "Final Steps"
echo
print_success "🎉 Automated setup complete!"
echo
echo "📋 Manual steps remaining:"
echo "1. 🔐 Install manual apps:"
echo "   • AltTab, Amphetamine, Bartender 5"
echo "   • Beyond Compare, ChatGPT, Claude, Copilot"
echo "   • CotEditor, Raycast, Warp"
echo
echo "2. 🔑 Set up authentication:"
echo "   • Generate SSH key: ssh-keygen -t ed25519 -C 'shootdaj@gmail.com'"
echo "   • Add to GitHub: gh ssh-key add ~/.ssh/id_ed25519.pub"
echo "   • Sign into apps (GitHub, browsers, etc.)"
echo
echo "3. 🔒 Configure security & privacy:"
echo "   • Grant app permissions in System Settings"
echo "   • Set up Touch ID/Face ID"
echo "   • Configure FileVault"
echo
echo "4. 🌐 Network setup:"
echo "   • Connect to WiFi networks"
echo "   • Set up VPN configurations"
echo
echo "5. 🔄 Restart required:"
echo "   • Log out and log back in to apply all settings"
echo "   • Some app configurations may need app restarts"
echo
print_warning "Don't forget to restart your Mac to apply all changes!"
echo
echo "🚀 Your new Mac should now be ~75% configured to match your old setup!"