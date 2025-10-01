#!/bin/bash

# Configure macOS system preferences for productivity

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}  →${NC} $1"
}

warn() {
    echo -e "${YELLOW}  ⚠${NC} $1"
}

echo "Configuring system preferences..."

# Dock settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock show-recents -bool false
log "Configured Dock settings"

# Finder settings
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"  # Search current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
log "Configured Finder settings"

# Keyboard settings
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
log "Configured keyboard settings"

# Trackpad settings
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
log "Configured trackpad settings"

# Mission Control
defaults write com.apple.dock mru-spaces -bool false  # Don't rearrange spaces
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool false
log "Configured Mission Control"

# Screenshots
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
log "Configured screenshot settings"

# Safari Developer menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
log "Enabled Safari Developer menu"

# TextEdit plain text default
defaults write com.apple.TextEdit RichText -int 0
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
log "Set TextEdit to plain text mode"

# Disable smart quotes and dashes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
log "Disabled smart quotes and dashes"

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true
log "Enabled showing hidden files"

# Restart affected applications
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo ""
log "System preferences configured!"
warn "Some changes require a logout/restart to take full effect"