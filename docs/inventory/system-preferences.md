# macOS System Preferences Documentation

## Current Settings Captured

### ⌨️ Keyboard
- **Key Repeat Rate**: 2 (Fast)
- **Initial Key Repeat Delay**: 15 (Short)
- **Press and Hold for Accents**: Disabled

### 🖥️ Display & Accessibility
- **Increase Contrast**: Off (0)
- **Font Smoothing**: Light (1)
- **Reduce Motion**: Off
- **Differentiate Without Color**: Off

### 📁 Finder
- **Show Path Bar**: Yes
- **Show Status Bar**: Yes
- **Show All File Extensions**: Yes
- **Search Scope**: Current Folder
- **Hidden Files**: Not shown by default

### 🚢 Dock
- **Auto-hide**: No
- **Icon Size**: 48px
- **Minimize to App Icon**: Yes
- **Show Recent Apps**: No

### 🚀 Mission Control
- **Rearrange Spaces Automatically**: No
- **Switch to Space on App Activation**: No

### ✍️ Text Input
- **Auto-capitalization**: Off
- **Smart Dashes**: Off
- **Period with Double-Space**: Off
- **Smart Quotes**: Off
- **Auto Spelling Correction**: Off

### 🔲 Hot Corners
- **Bottom Right**: Show Desktop

### 📸 Screenshots
- **Location**: Desktop
- **Format**: PNG
- **Shadow**: Disabled

## Files Created

1. **`scripts/macos-preferences.sh`** - Executable script to apply all settings
2. **`docs/configs/macos-settings/NSGlobalDomain.plist`** - Full global preferences backup

## How to Apply on New Machine

```bash
# Run the preferences script
./scripts/macos-preferences.sh

# Some settings require restart
sudo shutdown -r now
```

## Manual Settings Required

These can't be automated and need manual configuration:

1. **Security & Privacy**
   - FileVault
   - Firewall settings
   - Privacy permissions for apps

2. **Energy Saver**
   - Display sleep timing
   - Power adapter settings

3. **Network**
   - WiFi networks
   - VPN configurations

4. **Bluetooth**
   - Paired devices

5. **Touch ID / Face ID**
   - Fingerprint setup