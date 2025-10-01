# Setup Context for New Mac

This document provides complete context for debugging and fixing issues during Mac setup.

## What Was Built

A comprehensive Mac work transfer system that automates ~75% of new Mac setup.

### Repository Structure
```
mac-work-transfer/
├── Brewfile.essentials          # 27 curated packages
├── scripts/setup-new-mac.sh     # Main automation script
├── docs/
│   ├── configs/                 # 8 app configurations (8.8MB)
│   │   ├── bettertouchtool/     # 6.9MB - gestures/automations
│   │   ├── karabiner/           # 112KB - keyboard customizations (main config only)
│   │   ├── cursor/              # 12KB - settings + keybindings only
│   │   ├── bartender/           # 840KB - menu bar organization
│   │   ├── macos-settings/      # 556KB - 44 system preference files
│   │   ├── altTab/              # 8KB - window switcher
│   │   ├── vlc/                 # 88KB - player config
│   │   └── dotfiles/            # 24KB - .zshrc, .gitconfig, .zprofile
│   └── inventory/               # Documentation of current setup
├── AGENT_PLAN.md               # User's AI interaction preferences
├── CLAUDE.md                   # AI assistant instructions
└── README.md                   # Main documentation
```

## Setup Process Overview

### Automated (15-20 minutes)
1. **Homebrew Installation** - Package manager
2. **Package Installation** - 27 essential packages from Brewfile.essentials
3. **NVM + Node.js** - v24.2.0 installation
4. **Dotfiles Restoration** - Shell configs, Git identity
5. **App Config Restoration** - 8 apps configured
6. **System Preferences** - macOS settings applied

### Manual (~2 hours)
1. **Install 10 apps** not in Homebrew
2. **SSH key generation** and GitHub authentication
3. **Sign into accounts** (browsers, dev tools)
4. **Grant privacy permissions** when prompted
5. **Network setup** (WiFi, VPN)

## Key Decisions Made

### Apps Excluded (Manual Install Required)
- AltTab
- Amphetamine
- Bartender 5
- Beyond Compare
- ChatGPT
- Claude
- Copilot
- CotEditor
- Raycast
- Warp

### Configs Deliberately Excluded
- **GitKraken** - Embedded git repo caused issues, UI preferences not critical
- **Warp** - 666MB of app bundles/cache, no portable configs
- **Raycast** - 303MB of cache/analytics, settings encrypted in SQLite
- **Firefox** - 414MB of browser cache/history, not needed
- **Far2l** - User preference
- **Zed** - Not transferring this editor

### Configs Optimized
- **Cursor** - Kept only settings.json, keybindings.json, syncLocalSettings.json (12KB vs 269MB)
- **Karabiner** - Kept only main karabiner.json (112KB vs 51MB with backups)

## Important Technical Details

### macOS System Settings Captured
- **Keyboard**: Fast repeat (2), short delay (15), no press-and-hold
- **Dock**: Auto-hide enabled, 0 delay, 0.35s animation, 48px icons
- **Trackpad**: Tap to click enabled
- **Finder**: Path bar, status bar, all extensions visible
- **Notifications**: Per-app rules (1,652 lines)
- **BetterTouchTool**: 2,579 lines of custom gestures

### Development Environment
- **Node.js**: v24.2.0 via NVM
- **npm**: v11.3.0
- **Python**: 3.9.6 (system)
- **Git**: 2.49.0 with LFS
- **Docker**: 28.1.1 (Docker Desktop)

### Shell Configuration
```bash
# LM Studio CLI
export PATH="$PATH:/Users/anshul/.lmstudio/bin"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Aliases
alias pip="python3 -m pip"
alias cls='clear'
alias far="/Applications/far2l.app/Contents/MacOS/far2l --tty"
```

## Troubleshooting Guide

### If Homebrew Installation Fails
```bash
# Check if Xcode Command Line Tools installed
xcode-select --install

# Manual Homebrew install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### If Package Installation Fails
```bash
# Update Homebrew
brew update

# Install packages one by one to isolate failures
brew install fd
brew install ffmpeg
# ... etc

# Check failed casks
brew info <cask-name>
```

### If NVM Installation Fails
```bash
# Manual NVM install
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload shell
source ~/.zprofile
source ~/.zshrc

# Install Node
nvm install 24.2.0
nvm use 24.2.0
nvm alias default 24.2.0
```

### If Config Restoration Fails
Configs are in `docs/configs/`. Manually copy if needed:

```bash
# BetterTouchTool
cp -r docs/configs/bettertouchtool/* ~/Library/Application\ Support/BetterTouchTool/

# Karabiner
cp -r docs/configs/karabiner/* ~/.config/karabiner/

# Cursor
cp -r docs/configs/cursor/* ~/Library/Application\ Support/Cursor/User/

# Bartender
cp -r docs/configs/bartender/* ~/Library/Application\ Support/Bartender/

# Dotfiles
cp docs/configs/dotfiles/.zshrc ~/
cp docs/configs/dotfiles/.gitconfig ~/
cp docs/configs/dotfiles/.zprofile ~/
cp -r docs/configs/dotfiles/gh ~/.config/
```

### If System Preferences Don't Apply
```bash
# Run restore script manually
cd docs/configs/macos-settings/
./restore-macos-settings.sh

# Check specific settings
defaults read com.apple.dock
defaults read NSGlobalDomain

# Restart affected services
killall Dock
killall Finder
killall SystemUIServer
```

### If Apps Don't Recognize Configs
Some apps need to be launched first before configs work:
1. Launch the app once
2. Quit the app
3. Copy configs to the right location
4. Launch app again

### SSH Key Setup
```bash
# Generate key
ssh-keygen -t ed25519 -C "shootdaj@gmail.com"

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add key
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub | pbcopy

# Add to GitHub
gh ssh-key add ~/.ssh/id_ed25519.pub

# Test
ssh -T git@github.com
```

## Known Issues & Workarounds

### Issue: "Permission Denied" for App Configs
**Solution**: Some apps create their config directories with restricted permissions. Launch the app first, then copy configs.

### Issue: System Settings Require Restart
**Solution**: Log out and log back in, or restart the Mac after running the setup script.

### Issue: Homebrew Casks Need Manual Approval
**Solution**: Some casks require clicking "Open" in System Settings → Privacy & Security after installation.

### Issue: Node/npm Commands Not Found
**Solution**: Reload shell or manually source NVM:
```bash
source ~/.zprofile
source ~/.zshrc
```

### Issue: Git Push Requires Authentication
**Solution**: Set up SSH keys (see above) or use GitHub CLI:
```bash
gh auth login
```

## Verification Checklist

After setup completes, verify:

```bash
# Homebrew
brew --version
brew list | wc -l  # Should be ~27

# Development tools
node --version     # Should be v24.2.0
npm --version      # Should be v11.3.0
python3 --version  # Should be 3.9.6+
git --version      # Should be 2.49.0+
docker --version   # Should be 28.1.1+

# Shell config
cat ~/.zshrc | grep -i nvm     # Should see NVM config
cat ~/.gitconfig               # Should see user info

# Apps installed
ls /Applications/ | grep -E "(BetterTouchTool|Karabiner|Cursor|Bartender)"

# System settings
defaults read com.apple.dock autohide              # Should be 1
defaults read com.apple.dock autohide-delay        # Should be 0
defaults read NSGlobalDomain KeyRepeat             # Should be 2
```

## File Locations Reference

### Application Support
- Cursor: `~/Library/Application Support/Cursor/User/`
- BetterTouchTool: `~/Library/Application Support/BetterTouchTool/`
- Bartender: `~/Library/Application Support/Bartender/`

### Config Files
- Karabiner: `~/.config/karabiner/`
- GitHub CLI: `~/.config/gh/`
- Shell: `~/.zshrc`, `~/.zprofile`, `~/.gitconfig`

### System Preferences
- All stored in: `~/Library/Preferences/`
- Applied via: `defaults write` commands

## Contact & Resources

- **Repository**: https://github.com/shootdaj/mac-work-transfer
- **Commit**: 47178c5
- **Total Size**: 8.8MB configs
- **Setup Time**: ~2.5 hours total (20 min automated + 2h manual)

## Tips for Debugging

1. **Check logs**: Setup script outputs detailed progress
2. **Run step by step**: Can run individual restore scripts in `scripts/`
3. **Verify file permissions**: Use `ls -la` to check config directories
4. **Test incrementally**: Don't install everything at once
5. **Use MANUAL_RECOVERY.md**: Step-by-step manual instructions available

## What to Expect

**Immediate after script runs:**
- Terminal commands work (git, node, npm, brew)
- Shell aliases available (pip, cls, far)
- Dotfiles in place

**After logging out/in:**
- System preferences active (keyboard, trackpad, dock)
- UI changes visible

**After launching apps:**
- BetterTouchTool gestures work
- Karabiner keyboard mods active
- Cursor looks familiar
- Bartender menu bar organized

**After manual setup:**
- All apps installed
- SSH keys working
- Signed into accounts
- Full development environment ready