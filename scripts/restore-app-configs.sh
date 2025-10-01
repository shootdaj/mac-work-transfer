#!/bin/bash

# Restore application configurations

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

echo "Restoring application configurations..."

# BetterTouchTool
if [[ -d "docs/configs/bettertouchtool" ]]; then
    TARGET="$HOME/Library/Application Support/BetterTouchTool"
    mkdir -p "$TARGET"
    cp -r docs/configs/bettertouchtool/* "$TARGET/" 2>/dev/null && \
        log "Restored BetterTouchTool config" || \
        warn "BetterTouchTool config restore failed (app may need to be installed first)"
fi

# Cursor
if [[ -d "docs/configs/cursor" ]]; then
    TARGET="$HOME/Library/Application Support/Cursor/User"
    mkdir -p "$(dirname "$TARGET")"
    cp -r docs/configs/cursor "$TARGET" 2>/dev/null && \
        log "Restored Cursor config" || \
        warn "Cursor config restore failed (app may need to be installed first)"
fi

# GitKraken
if [[ -d "docs/configs/gitkraken" ]]; then
    cp -r docs/configs/gitkraken "$HOME/.gitkraken" 2>/dev/null && \
        log "Restored GitKraken config" || \
        warn "GitKraken config restore failed"
fi

# VLC
if [[ -d "docs/configs/vlc" ]]; then
    TARGET="$HOME/Library/Preferences"
    mkdir -p "$TARGET"
    cp -r docs/configs/vlc "$TARGET/org.videolan.vlc" 2>/dev/null && \
        log "Restored VLC config" || \
        warn "VLC config restore failed"
fi

# Firefox
if [[ -d "docs/configs/firefox" ]]; then
    TARGET="$HOME/Library/Application Support/Firefox/Profiles"
    mkdir -p "$(dirname "$TARGET")"
    cp -r docs/configs/firefox "$TARGET" 2>/dev/null && \
        log "Restored Firefox profiles" || \
        warn "Firefox profiles restore failed (app may need to be installed first)"
fi

# Raycast
if [[ -d "docs/configs/raycast" ]]; then
    TARGET="$HOME/Library/Group Containers/SY64MV22J9.com.raycast.macos.shared"
    mkdir -p "$(dirname "$TARGET")"
    cp -r docs/configs/raycast "$TARGET" 2>/dev/null && \
        log "Restored Raycast config" || \
        warn "Raycast config restore failed (app may need to be installed first)"
fi

# Warp
if [[ -d "docs/configs/warp" ]]; then
    TARGET="$HOME/Library/Application Support/dev.warp.Warp-Stable"
    mkdir -p "$TARGET"
    cp -r docs/configs/warp/* "$TARGET/" 2>/dev/null && \
        log "Restored Warp config" || \
        warn "Warp config restore failed (app may need to be installed first)"
fi

# Zed
if [[ -d "docs/configs/zed" ]]; then
    TARGET="$HOME/Library/Application Support/Zed"
    mkdir -p "$TARGET"
    cp -r docs/configs/zed/* "$TARGET/" 2>/dev/null && \
        log "Restored Zed config" || \
        warn "Zed config restore failed (app may need to be installed first)"
fi

# Bartender
if [[ -f "docs/configs/bartender/com.surteesstudios.Bartender.plist" ]]; then
    TARGET="$HOME/Library/Preferences"
    cp docs/configs/bartender/com.surteesstudios.Bartender.plist "$TARGET/" 2>/dev/null && \
        log "Restored Bartender preferences" || \
        warn "Bartender preferences restore failed"
fi

# AltTab
if [[ -f "docs/configs/altTab/alttab.plist" ]]; then
    defaults import com.lwouis.alt-tab-macos docs/configs/altTab/alttab.plist 2>/dev/null && \
        log "Restored AltTab preferences" || \
        warn "AltTab preferences restore failed"
fi

echo ""
log "Application configurations restored!"
warn "Some apps may need to be installed before configs take effect"