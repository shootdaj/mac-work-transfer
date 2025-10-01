# macOS System Settings Export

This directory contains a comprehensive export of all macOS system settings and customizations for work transfer purposes.

## Directory Structure

```
macos-settings/
├── all-domains.txt                    # Complete list of all defaults domains
├── system-preferences/                # Core system preference files
├── accessibility/                     # Accessibility and Universal Access settings
├── desktop-screensaver/              # Desktop background and screensaver settings
├── sound/                            # Audio and sound settings
├── notifications/                    # Notification Center settings
├── spotlight/                        # Spotlight search settings
├── privacy-security/                 # Privacy and security settings (limited access)
├── sharing/                          # Sharing services and computer naming
├── users-groups/                     # Login window and user settings
├── date-time/                        # Date, time, and timezone settings
├── language-region/                  # Language and regional settings
├── dock/                            # Dock configuration
├── finder/                          # Finder preferences
├── trackpad-mouse/                  # Trackpad and mouse settings
├── keyboard/                        # Keyboard and hotkey settings
└── additional-settings/             # Third-party application settings
    ├── browsers/                    # Browser configurations
    ├── development/                 # Development tool settings
    ├── productivity/                # Productivity app settings
    ├── multimedia/                  # Media player settings
    └── utilities/                   # System utility settings
```

## Export Summary

### System Settings (macOS Built-in)

#### ✅ Successfully Exported Settings

1. **Global Preferences** (97 lines)
   - Location: `system-preferences/global-preferences.plist`
   - Contains: System-wide appearance, behavior, and regional settings

2. **Dock Configuration** (609 lines)
   - Location: `dock/dock.plist`
   - Contains: Dock size, position, animations, persistent apps

3. **Finder Settings** (1,723 lines)
   - Location: `finder/finder.plist`
   - Contains: View preferences, sidebar items, search settings

4. **Notification Center** (1,652 lines)
   - Location: `notifications/notification-center.plist`
   - Contains: Per-app notification settings, Do Not Disturb rules

5. **Accessibility Settings** (298 lines)
   - Location: `accessibility/accessibility.plist`
   - Contains: Display, audio, and interaction accessibility options

6. **Universal Access** (314 lines)
   - Location: `accessibility/universal-access.plist`
   - Contains: VoiceOver, zoom, contrast, and other accessibility features

7. **Keyboard & Hotkeys** (392 lines)
   - Location: `keyboard/symbolic-hotkeys.plist`
   - Contains: Keyboard shortcuts, function key behavior

8. **Trackpad & Mouse** (69 lines total)
   - Locations: `trackpad-mouse/trackpad.plist`, `trackpad-mouse/mouse.plist`
   - Contains: Gesture settings, tracking speed, click behavior

9. **Desktop & Screensaver** (8 lines)
   - Locations: `desktop-screensaver/wallpaper.plist`, `desktop-screensaver/screensaver.plist`
   - Contains: Wallpaper and screensaver preferences

10. **Sound & Control Center** (42 lines)
    - Locations: `sound/control-center.plist`, `sound/bezel-services.plist`
    - Contains: Sound effects, menu bar settings

11. **Spotlight Search** (14 lines)
    - Location: `spotlight/spotlight.plist`
    - Contains: Search categories and indexing preferences

12. **Sharing Services** (15 lines)
    - Location: `sharing/sharing.plist`
    - Contains: File sharing, screen sharing, remote login settings

13. **Login & Users** (6 lines)
    - Location: `users-groups/loginwindow.plist`
    - Contains: Login window behavior, fast user switching

14. **Date & Time** (8 lines)
    - Location: `date-time/menu-clock.plist`
    - Contains: Clock display format in menu bar

15. **Language & Region** (4 lines)
    - Locations: `language-region/languages.plist`, `language-region/locale.plist`
    - Contains: Preferred languages and regional format

### Application Settings (Third-party)

#### ✅ Productivity Apps

1. **BetterTouchTool** (2,579 lines)
   - Location: `additional-settings/productivity/bettertouchtool.plist`
   - Contains: Gestures, keyboard shortcuts, window management

2. **Raycast** (94 lines)
   - Location: `additional-settings/productivity/raycast.plist`
   - Contains: Extensions, hotkeys, preferences

3. **AltTab** (30 lines)
   - Location: `additional-settings/productivity/alt-tab.plist`
   - Contains: Window switching behavior and appearance

4. **Rectangle** (24 lines)
   - Location: `additional-settings/productivity/rectangle.plist`
   - Contains: Window management shortcuts and behavior

#### ✅ System Utilities

1. **Bartender** (200 lines)
   - Location: `additional-settings/utilities/bartender.plist`
   - Contains: Menu bar organization and hidden items

2. **Stats** (39 lines)
   - Location: `additional-settings/utilities/stats.plist`
   - Contains: System monitoring widgets and preferences

3. **Amphetamine** (95 lines)
   - Location: `additional-settings/utilities/amphetamine.plist`
   - Contains: Sleep prevention settings and triggers

#### ✅ Development Tools

1. **JetBrains Tools** (30 lines total)
   - Locations: `additional-settings/development/datagrip.plist`, `dataspell.plist`, `rider.plist`
   - Contains: IDE preferences and configurations

2. **GitKraken** (9 lines)
   - Location: `additional-settings/development/gitkraken.plist`
   - Contains: Git client preferences

3. **GitHub Desktop** (10 lines)
   - Location: `additional-settings/development/github-client.plist`
   - Contains: GitHub client settings

#### ✅ Browsers

1. **Google Chrome** (10 lines)
   - Location: `additional-settings/browsers/chrome.plist`
   - Contains: Browser preferences and settings

2. **Brave Browser** (15 lines)
   - Location: `additional-settings/browsers/brave.plist`
   - Contains: Privacy and ad-blocking settings

3. **Firefox** (4 lines)
   - Location: `additional-settings/browsers/firefox.plist`
   - Contains: Basic Firefox preferences

4. **Vivaldi** (10 lines)
   - Location: `additional-settings/browsers/vivaldi.plist`
   - Contains: Vivaldi browser customizations

#### ✅ Multimedia

1. **VLC Media Player** (97 lines)
   - Location: `additional-settings/multimedia/vlc.plist`
   - Contains: Playback preferences, interface settings

2. **IINA** (70 lines)
   - Location: `additional-settings/multimedia/iina.plist`
   - Contains: Video player preferences and shortcuts

3. **Spotify** (6 lines)
   - Location: `additional-settings/multimedia/spotify.plist`
   - Contains: Music streaming preferences

#### ❌ Limited Access Settings

1. **Privacy & Security (TCC Database)**
   - Reason: System protection prevents reading privacy permissions
   - Manual restore required: Review app permissions in System Settings

2. **FileVault & Security**
   - Reason: Security-sensitive settings not accessible via defaults
   - Manual setup required: Enable FileVault, configure security settings

## Restoration Instructions

### Automated Restoration

Use the provided restore script:
```bash
./restore-macos-settings.sh
```

### Manual Restoration Steps

1. **Core System Settings:**
   ```bash
   defaults write com.apple.dock -dict-add "$(cat dock/dock.plist)"
   defaults write com.apple.finder -dict-add "$(cat finder/finder.plist)"
   killall Dock
   killall Finder
   ```

2. **Application Settings:**
   ```bash
   # Close applications first
   defaults write com.hegenberg.BetterTouchTool -dict-add "$(cat additional-settings/productivity/bettertouchtool.plist)"
   defaults write com.raycast.macos -dict-add "$(cat additional-settings/productivity/raycast.plist)"
   ```

3. **Manual Configuration Required:**
   - System Settings > Privacy & Security > Grant app permissions
   - System Settings > Displays > Arrange displays
   - System Settings > Network > WiFi networks and VPN configurations
   - Keychain Access > Import certificates and keychains

### Important Notes

- Restart applications after importing settings
- Some settings require logout/login to take effect
- Privacy permissions must be manually granted on new system
- Network configurations are not included for security reasons
- Keychain items require separate export/import

## Security Considerations

- No passwords, certificates, or keychain items are included
- Network configurations excluded for privacy
- App-specific login tokens and credentials not exported
- Manual review recommended before applying all settings

## Total Settings Captured

- **42 configuration files** with substantive content
- **Over 8,000 lines** of configuration data
- **15 system preference domains**
- **15 third-party applications**
- **All major customizable system areas covered**

This export captures the vast majority of your macOS customizations and will significantly reduce setup time on a new system.