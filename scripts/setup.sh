#!/bin/bash

# Mac Work Transfer - Main Setup Script
# Run this script on a new Mac to restore your work environment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
    exit 1
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is for macOS only"
fi

echo "================================"
echo "Mac Work Transfer Setup Script"
echo "================================"
echo ""

# Step 1: Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -d "/opt/homebrew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    log "Homebrew already installed"
fi

# Step 2: Install packages from Brewfile.essentials
if [[ -f "Brewfile.essentials" ]]; then
    log "Installing Homebrew packages..."
    brew bundle install --file=Brewfile.essentials
else
    error "Brewfile.essentials not found!"
fi

# Step 3: Restore dotfiles
log "Restoring dotfiles..."
./scripts/restore-dotfiles.sh

# Step 4: Restore application configurations
log "Restoring application configurations..."
./scripts/restore-app-configs.sh

# Step 5: Install manual applications
log "Manual applications to install:"
./scripts/list-manual-apps.sh

# Step 6: System preferences
log "Setting up system preferences..."
./scripts/setup-system-prefs.sh

echo ""
echo "================================"
echo "Setup Complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Install manual applications listed above"
echo "2. Sign into accounts (GitHub, browsers, etc.)"
echo "3. Restart your Mac for all changes to take effect"