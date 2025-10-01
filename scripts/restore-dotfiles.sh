#!/bin/bash

# Restore dotfiles and shell configurations

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

echo "Restoring dotfiles..."

# Backup existing dotfiles
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Restore zsh configs
if [[ -f "docs/configs/dotfiles/.zshrc" ]]; then
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
    cp docs/configs/dotfiles/.zshrc "$HOME/.zshrc"
    log "Restored .zshrc"
fi

if [[ -f "docs/configs/dotfiles/.zprofile" ]]; then
    [[ -f "$HOME/.zprofile" ]] && cp "$HOME/.zprofile" "$BACKUP_DIR/"
    cp docs/configs/dotfiles/.zprofile "$HOME/.zprofile"
    log "Restored .zprofile"
fi

# Restore git config
if [[ -f "docs/configs/dotfiles/.gitconfig" ]]; then
    [[ -f "$HOME/.gitconfig" ]] && cp "$HOME/.gitconfig" "$BACKUP_DIR/"
    cp docs/configs/dotfiles/.gitconfig "$HOME/.gitconfig"
    log "Restored .gitconfig"
fi

# Restore .config directory items
if [[ -d "docs/configs/dotfiles/gh" ]]; then
    mkdir -p "$HOME/.config"
    [[ -d "$HOME/.config/gh" ]] && cp -r "$HOME/.config/gh" "$BACKUP_DIR/"
    cp -r docs/configs/dotfiles/gh "$HOME/.config/"
    log "Restored GitHub CLI config"
fi

if [[ -d "docs/configs/dotfiles/NotepadNext" ]]; then
    mkdir -p "$HOME/.config"
    [[ -d "$HOME/.config/NotepadNext" ]] && cp -r "$HOME/.config/NotepadNext" "$BACKUP_DIR/"
    cp -r docs/configs/dotfiles/NotepadNext "$HOME/.config/"
    log "Restored NotepadNext config"
fi

# Restore Karabiner
if [[ -d "docs/configs/karabiner" ]]; then
    mkdir -p "$HOME/.config"
    [[ -d "$HOME/.config/karabiner" ]] && cp -r "$HOME/.config/karabiner" "$BACKUP_DIR/"
    cp -r docs/configs/karabiner "$HOME/.config/"
    log "Restored Karabiner config"
fi

# Restore Far2l
if [[ -d "docs/configs/far2l" ]]; then
    mkdir -p "$HOME/.config"
    [[ -d "$HOME/.config/far2l" ]] && cp -r "$HOME/.config/far2l" "$BACKUP_DIR/"
    cp -r docs/configs/far2l "$HOME/.config/"
    log "Restored Far2l config"
fi

echo ""
log "Dotfiles restored! Backups saved to: $BACKUP_DIR"