#!/bin/bash

# macOS Settings Restoration Script
# This script restores macOS system settings from exported preference files
# 
# IMPORTANT: 
# - Run this script on the target macOS system
# - Close all applications before running
# - Some settings require logout/login to take effect
# - Privacy permissions must be manually granted

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_DIR="$SCRIPT_DIR"

echo "🍎 macOS Settings Restoration Script"
echo "======================================"
echo ""
echo "⚠️  IMPORTANT WARNINGS:"
echo "   - This will overwrite existing system preferences"
echo "   - Close all applications before continuing"
echo "   - Some settings require logout/login to take effect"
echo "   - Privacy permissions must be manually granted"
echo ""

read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Restoration cancelled."
    exit 1
fi

echo ""
echo "🔧 Starting restoration process..."

# Function to restore plist if it exists and has content
restore_plist() {
    local source_file="$1"
    local domain="$2"
    local description="$3"
    
    if [[ -f "$source_file" && -s "$source_file" ]]; then
        echo "   📝 Restoring $description..."
        defaults import "$domain" "$source_file" 2>/dev/null || {
            echo "      ⚠️  Warning: Could not import $description (may require admin privileges)"
        }
    else
        echo "   ⏭️  Skipping $description (file not found or empty)"
    fi
}

# Function to kill processes safely
kill_process() {
    local process_name="$1"
    if pgrep "$process_name" > /dev/null; then
        echo "   🔄 Restarting $process_name..."
        killall "$process_name" 2>/dev/null || true
        sleep 1
    fi
}

echo ""
echo "1️⃣ Restoring Core System Settings..."

# Global preferences
restore_plist "$SETTINGS_DIR/system-preferences/global-preferences.plist" ".GlobalPreferences" "Global System Preferences"

# Dock settings
restore_plist "$SETTINGS_DIR/dock/dock.plist" "com.apple.dock" "Dock Configuration"

# Finder settings
restore_plist "$SETTINGS_DIR/finder/finder.plist" "com.apple.finder" "Finder Preferences"

# Restart Dock and Finder
kill_process "Dock"
kill_process "Finder"

echo ""
echo "2️⃣ Restoring Input Device Settings..."

# Trackpad and mouse
restore_plist "$SETTINGS_DIR/trackpad-mouse/trackpad.plist" "com.apple.AppleMultitouchTrackpad" "Trackpad Settings"
restore_plist "$SETTINGS_DIR/trackpad-mouse/mouse.plist" "com.apple.AppleMultitouchMouse" "Mouse Settings"
restore_plist "$SETTINGS_DIR/trackpad-mouse/bluetooth-trackpad.plist" "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Bluetooth Trackpad"
restore_plist "$SETTINGS_DIR/trackpad-mouse/bluetooth-mouse.plist" "com.apple.driver.AppleBluetoothMultitouch.mouse" "Bluetooth Mouse"

# Keyboard and shortcuts
restore_plist "$SETTINGS_DIR/keyboard/hitoolbox.plist" "com.apple.HIToolbox" "Keyboard Settings"
restore_plist "$SETTINGS_DIR/keyboard/symbolic-hotkeys.plist" "com.apple.symbolichotkeys" "Keyboard Shortcuts"

echo ""
echo "3️⃣ Restoring Interface Settings..."

# Notifications
restore_plist "$SETTINGS_DIR/notifications/notification-center.plist" "com.apple.ncprefs" "Notification Center"

# Accessibility
restore_plist "$SETTINGS_DIR/accessibility/accessibility.plist" "com.apple.Accessibility" "Accessibility Settings"
restore_plist "$SETTINGS_DIR/accessibility/universal-access.plist" "com.apple.universalaccess" "Universal Access"

# Sound and control center
restore_plist "$SETTINGS_DIR/sound/control-center.plist" "com.apple.controlcenter" "Control Center"
restore_plist "$SETTINGS_DIR/sound/bezel-services.plist" "com.apple.BezelServices" "Sound Bezel Services"

echo ""
echo "4️⃣ Restoring System Services..."

# Spotlight
restore_plist "$SETTINGS_DIR/spotlight/spotlight.plist" "com.apple.Spotlight" "Spotlight Search"

# Sharing
restore_plist "$SETTINGS_DIR/sharing/sharing.plist" "com.apple.sharingd" "Sharing Services"

# Login window
restore_plist "$SETTINGS_DIR/users-groups/loginwindow.plist" "com.apple.loginwindow" "Login Window"

# Desktop and screensaver
restore_plist "$SETTINGS_DIR/desktop-screensaver/wallpaper.plist" "com.apple.wallpaper" "Wallpaper Settings"
restore_plist "$SETTINGS_DIR/desktop-screensaver/screensaver.plist" "com.apple.screensaver" "Screensaver Settings"

# Date and time
restore_plist "$SETTINGS_DIR/date-time/menu-clock.plist" "com.apple.menuextra.clock" "Menu Clock"

# Language and region
restore_plist "$SETTINGS_DIR/language-region/languages.plist" ".GlobalPreferences" "Language Preferences"
restore_plist "$SETTINGS_DIR/language-region/locale.plist" ".GlobalPreferences" "Regional Settings"

echo ""
echo "5️⃣ Restoring Application Settings..."

# Productivity apps
echo "   📱 Productivity Applications..."
restore_plist "$SETTINGS_DIR/additional-settings/productivity/bettertouchtool.plist" "com.hegenberg.BetterTouchTool" "BetterTouchTool"
restore_plist "$SETTINGS_DIR/additional-settings/productivity/raycast.plist" "com.raycast.macos" "Raycast"
restore_plist "$SETTINGS_DIR/additional-settings/productivity/alt-tab.plist" "com.lwouis.alt-tab-macos" "AltTab"
restore_plist "$SETTINGS_DIR/additional-settings/productivity/rectangle.plist" "com.knollsoft.Rectangle" "Rectangle"

# Utilities
echo "   🛠️  System Utilities..."
restore_plist "$SETTINGS_DIR/additional-settings/utilities/bartender.plist" "com.surteesstudios.Bartender" "Bartender"
restore_plist "$SETTINGS_DIR/additional-settings/utilities/stats.plist" "eu.exelban.Stats" "Stats"
restore_plist "$SETTINGS_DIR/additional-settings/utilities/amphetamine.plist" "com.if.Amphetamine" "Amphetamine"

# Development tools
echo "   💻 Development Tools..."
restore_plist "$SETTINGS_DIR/additional-settings/development/datagrip.plist" "com.jetbrains.datagrip" "DataGrip"
restore_plist "$SETTINGS_DIR/additional-settings/development/dataspell.plist" "com.jetbrains.dataspell" "DataSpell"
restore_plist "$SETTINGS_DIR/additional-settings/development/rider.plist" "com.jetbrains.rider" "Rider"
restore_plist "$SETTINGS_DIR/additional-settings/development/gitkraken.plist" "com.axosoft.gitkraken" "GitKraken"
restore_plist "$SETTINGS_DIR/additional-settings/development/github-client.plist" "com.github.GitHubClient" "GitHub Desktop"

# Browsers
echo "   🌐 Web Browsers..."
restore_plist "$SETTINGS_DIR/additional-settings/browsers/chrome.plist" "com.google.Chrome" "Google Chrome"
restore_plist "$SETTINGS_DIR/additional-settings/browsers/brave.plist" "com.brave.Browser" "Brave Browser"
restore_plist "$SETTINGS_DIR/additional-settings/browsers/firefox.plist" "org.mozilla.firefox" "Firefox"
restore_plist "$SETTINGS_DIR/additional-settings/browsers/vivaldi.plist" "com.vivaldi.Vivaldi" "Vivaldi"

# Multimedia apps
echo "   🎵 Multimedia Applications..."
restore_plist "$SETTINGS_DIR/additional-settings/multimedia/vlc.plist" "org.videolan.vlc" "VLC Media Player"
restore_plist "$SETTINGS_DIR/additional-settings/multimedia/iina.plist" "com.colliderli.iina" "IINA"
restore_plist "$SETTINGS_DIR/additional-settings/multimedia/spotify.plist" "com.spotify.client" "Spotify"

echo ""
echo "6️⃣ Applying Computer Name Settings..."

if [[ -f "$SETTINGS_DIR/sharing/computer-name.txt" && -s "$SETTINGS_DIR/sharing/computer-name.txt" ]]; then
    COMPUTER_NAME=$(cat "$SETTINGS_DIR/sharing/computer-name.txt")
    echo "   🖥️  Setting computer name to: $COMPUTER_NAME"
    sudo scutil --set ComputerName "$COMPUTER_NAME" 2>/dev/null || echo "      ⚠️  Could not set computer name (requires admin)"
fi

if [[ -f "$SETTINGS_DIR/sharing/local-hostname.txt" && -s "$SETTINGS_DIR/sharing/local-hostname.txt" ]]; then
    LOCAL_HOSTNAME=$(cat "$SETTINGS_DIR/sharing/local-hostname.txt")
    echo "   🔗 Setting local hostname to: $LOCAL_HOSTNAME"
    sudo scutil --set LocalHostName "$LOCAL_HOSTNAME" 2>/dev/null || echo "      ⚠️  Could not set local hostname (requires admin)"
fi

# Set timezone if available
if [[ -f "$SETTINGS_DIR/date-time/timezone.txt" && -s "$SETTINGS_DIR/date-time/timezone.txt" ]]; then
    TIMEZONE=$(cat "$SETTINGS_DIR/date-time/timezone.txt" | sed 's/Time Zone: //')
    echo "   🕐 Setting timezone to: $TIMEZONE"
    sudo systemsetup -settimezone "$TIMEZONE" 2>/dev/null || echo "      ⚠️  Could not set timezone (requires admin)"
fi

echo ""
echo "7️⃣ Refreshing System Services..."

# Restart system UI components
kill_process "SystemUIServer"
kill_process "NotificationCenter"

# Clear preference caches
echo "   🧹 Clearing preference caches..."
killall cfprefsd 2>/dev/null || true

echo ""
echo "✅ Settings restoration completed!"
echo ""
echo "📋 Next Steps:"
echo "   1. 🔓 Grant app permissions in System Settings > Privacy & Security"
echo "   2. 🔐 Import keychains and certificates manually"
echo "   3. 🌐 Reconfigure network settings (WiFi, VPN)"
echo "   4. 🔄 Log out and log back in for all changes to take effect"
echo "   5. 🚀 Launch applications to verify their settings"
echo ""
echo "⚠️  Note: Some applications may need to be restarted to pick up new settings."

read -p "Press Enter to continue..."