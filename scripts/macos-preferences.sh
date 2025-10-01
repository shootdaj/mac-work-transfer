#!/bin/bash

# macOS System Preferences Setup
# Captured from your current Mac setup

echo "🔧 Applying macOS System Preferences..."

# Keyboard Settings
echo "⌨️ Keyboard preferences..."
defaults write NSGlobalDomain KeyRepeat -int 2                      # Fast key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15              # Short delay until repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false  # Disable press-and-hold for accents

# Trackpad Settings
echo "🖱️ Trackpad preferences..."
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1    # Tap to click

# Display Settings
echo "🖥️ Display preferences..."
defaults write NSGlobalDomain AppleFontSmoothing -int 1             # Light font smoothing
defaults write com.apple.accessibility ReduceMotionEnabled -int 0   # Keep animations
defaults write com.apple.accessibility DifferentiateWithoutColor -int 0

# Finder Settings
echo "📁 Finder preferences..."
defaults write com.apple.finder ShowPathbar -bool true              # Show path bar
defaults write com.apple.finder ShowStatusBar -bool true            # Show status bar
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # Search current folder by default
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true     # Show all file extensions
defaults write com.apple.finder AppleShowAllFiles -bool false       # Don't show hidden files by default

# Dock Settings
echo "🚢 Dock preferences..."
defaults write com.apple.dock autohide -bool false                  # Keep dock visible
defaults write com.apple.dock minimize-to-application -bool true    # Minimize to app icon
defaults write com.apple.dock show-recents -bool false              # Don't show recent apps
defaults write com.apple.dock tilesize -int 48                      # Icon size

# Mission Control
echo "🚀 Mission Control preferences..."
defaults write com.apple.dock mru-spaces -bool false                # Don't rearrange spaces
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool false

# Screenshots
echo "📸 Screenshot preferences..."
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Sound
echo "🔊 Sound preferences..."
defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool false
defaults write com.apple.sound.beep.volume -float 0.0

# Menu Bar
echo "📊 Menu bar preferences..."
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm a"
defaults write com.apple.menuextra.battery ShowPercent -bool true

# Text Input
echo "✍️ Text input preferences..."
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Hot Corners
echo "🔲 Hot corners..."
# Bottom right corner → Show desktop
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0

echo "✅ System preferences applied!"
echo "⚠️  Some changes require logout/restart to take effect"
echo ""
echo "Additional manual settings to configure:"
echo "  • System Preferences → Accessibility → Display → Increase contrast (if desired)"
echo "  • System Preferences → Accessibility → Pointer Control → Trackpad Options"
echo "  • System Preferences → Security & Privacy settings"
echo "  • Energy Saver preferences"