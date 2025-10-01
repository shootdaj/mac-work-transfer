# Dotfiles & Shell Configuration

## Core Dotfiles Backed Up

### Shell Configuration
- **`.zshrc`** - Zsh shell configuration
  - LM Studio CLI path export
  - NVM (Node Version Manager) setup
  - Custom aliases: `pip`, `cls`, `far`
  
- **`.zprofile`** - Zsh profile (login shell)
  - Homebrew environment setup

### Git Configuration  
- **`.gitconfig`** - Git global configuration
  - User: Anshul Vishwakarma (shootdaj@gmail.com)
  - Git LFS filter configuration

### GitHub CLI
- **`gh/config.yml`** - GitHub CLI preferences
- **`gh/hosts.yml`** - GitHub host configurations

## Key Environment Setup

### Development Tools
```bash
# LM Studio CLI
export PATH="$PATH:/Users/anshul/.lmstudio/bin"

# NVM for Node.js version management
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

### Useful Aliases
```bash
alias pip="python3 -m pip"      # Use Python 3 pip explicitly
alias cls='clear'                # Windows-style clear command
alias far="open -a far2l"       # GUI far2l launcher
alias far="/Applications/far2l.app/Contents/MacOS/far2l --tty"  # Terminal far2l
```

## Missing Dotfiles (Not Found)
- **`.bashrc`** - Not present (using zsh)
- **`.vimrc`** - Not customized
- **`.tmuxrc`** - Not present
- **SSH config** - Present but not backed up (contains sensitive data)

## Additional Config Locations

### Application Configs in ~/.config/
- **`karabiner/`** - Already backed up separately
- **`zed/settings.json`** - Code editor settings (skipped - not transferring Zed)
- **`raycast/extensions/`** - Extension manifests (handled via Raycast app backup)

## Restore Process

### On New Mac:
```bash
# Copy dotfiles to home directory
cp dotfiles/.zshrc ~/
cp dotfiles/.gitconfig ~/  
cp dotfiles/.zprofile ~/
cp -r dotfiles/gh ~/.config/

# Install required tools first
# Homebrew (installs to /opt/homebrew on Apple Silicon)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# NVM for Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Source the new shell configuration
source ~/.zprofile
source ~/.zshrc
```

## Dependencies Required
1. **Homebrew** - Package manager
2. **NVM** - Node.js version manager  
3. **LM Studio** - AI model management (if using LM Studio CLI)
4. **Git LFS** - Large file support (installed with Git)
5. **GitHub CLI** - gh command

## Notes
- **SSH keys**: Need separate secure backup and restore
- **Git credentials**: May need re-authentication after restore
- **Shell history**: Not backed up (contains potentially sensitive commands)