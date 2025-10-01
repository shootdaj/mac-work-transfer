# Manual Recovery Guide

## If Automation Fails - Step-by-Step Manual Process

### Phase 1: Core Tools
```bash
# 1. Install Homebrew manually
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. For Apple Silicon Macs, add to PATH:
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Install essentials
brew bundle install --file=Brewfile.essentials --verbose
```

### Phase 2: Manual App Downloads
**Install these BEFORE restoring configs:**

1. **Raycast** - https://raycast.com
2. **Warp** - https://warp.dev  
3. **Zed** - https://zed.dev
4. **Bartender 5** - https://www.macbartender.com
5. **AltTab** - https://alt-tab-macos.netlify.app
6. **Beyond Compare** - https://scootersoftware.com
7. **ChatGPT** - https://chatgpt.com/download
8. **Claude** - https://claude.ai/download
9. **CotEditor** - https://coteditor.com
10. **Amphetamine** - Mac App Store

### Phase 3: Restore Dotfiles Manually
```bash
# Backup existing
mkdir ~/dotfiles-backup-$(date +%Y%m%d)
cp ~/.zshrc ~/.zprofile ~/.gitconfig ~/dotfiles-backup-$(date +%Y%m%d)/ 2>/dev/null

# Restore
cp docs/configs/dotfiles/.zshrc ~/.zshrc
cp docs/configs/dotfiles/.zprofile ~/.zprofile
cp docs/configs/dotfiles/.gitconfig ~/.gitconfig

# Config directories
cp -r docs/configs/dotfiles/gh ~/.config/
cp -r docs/configs/dotfiles/NotepadNext ~/.config/
cp -r docs/configs/karabiner ~/.config/
cp -r docs/configs/far2l ~/.config/
```

### Phase 4: App Configs (AFTER apps installed)

#### Karabiner-Elements
1. Open Karabiner-Elements app
2. Go to Misc > Configuration folder > Open
3. Replace contents with `docs/configs/karabiner/*`
4. Restart Karabiner-Elements

#### BetterTouchTool
1. Open BetterTouchTool
2. Preferences > Presets > Import
3. Navigate to `docs/configs/bettertouchtool/`
4. Import preset files

#### Cursor
```bash
cp -r docs/configs/cursor/* "~/Library/Application Support/Cursor/User/"
```

#### Raycast
1. Open Raycast
2. Settings > Advanced > Import/Export
3. Import from `docs/configs/raycast/`

#### Warp
```bash
cp -r docs/configs/warp/* "~/Library/Application Support/dev.warp.Warp-Stable/"
```

#### Zed
```bash
cp -r docs/configs/zed/* "~/Library/Application Support/Zed/"
```

#### AltTab
```bash
defaults import com.lwouis.alt-tab-macos docs/configs/altTab/alttab.plist
# Then restart AltTab
```

#### Bartender
```bash
cp docs/configs/bartender/com.surteesstudios.Bartender.plist ~/Library/Preferences/
# Then restart Bartender
```

### Phase 5: VS Code Extensions
**Install VS Code first**, then:
```bash
code --install-extension anthropic.claude-code
code --install-extension anysphere.cursorpyright
code --install-extension bierner.markdown-preview-github-styles
code --install-extension esbenp.prettier-vscode
code --install-extension mechatroner.rainbow-csv
code --install-extension ms-azuretools.vscode-containers
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-python.debugpy
code --install-extension ms-python.python
code --install-extension sourcegraph.amp
code --install-extension yzhang.markdown-all-in-one
code --install-extension zaaack.markdown-editor
```

### Phase 6: System Preferences
```bash
# Run each command individually to identify failures
defaults write com.apple.dock autohide -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write NSGlobalDomain KeyRepeat -int 2
# ... etc (see setup-system-prefs.sh)

# Restart services
killall Dock
killall Finder
```

## Common Issues & Fixes

### "Permission denied" errors
```bash
chmod +x scripts/*.sh
sudo xattr -cr scripts/  # Clear quarantine
```

### Homebrew fails on M1/M2 Mac
```bash
# Ensure Rosetta 2 installed
softwareupdate --install-rosetta --agree-to-license
```

### Config not loading
- Most apps need restart after config restore
- Some apps need manual import through UI
- Check app is running correct version

### SSH Keys
**NOT backed up for security**. Regenerate:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# Add to GitHub/GitLab manually
```

## Verification Checklist
- [ ] Homebrew packages installed (`brew list`)
- [ ] Manual apps downloaded and installed
- [ ] Karabiner config loaded (test a shortcut)
- [ ] BetterTouchTool gestures working
- [ ] Git config correct (`git config --list`)
- [ ] Shell aliases working (`alias`)
- [ ] VS Code extensions installed
- [ ] System preferences applied (Dock hidden, etc.)