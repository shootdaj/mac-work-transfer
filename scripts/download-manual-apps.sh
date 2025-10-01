#!/bin/bash

# Download Manual Apps - Automated Fetcher
# Downloads all manual apps that can be automated

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }

# Create downloads directory
DOWNLOAD_DIR="$HOME/Downloads/MacTransferApps"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

info "Downloading manual apps to: $DOWNLOAD_DIR"
echo ""

# Apps we can auto-download
declare -A apps=(
    ["AltTab"]="https://github.com/lwouis/alt-tab-macos/releases/latest/download/AltTab-6.72.0.zip"
    ["Warp"]="https://releases.warp.dev/stable/v0.2025.08.27.08.11.stable_04/Warp.dmg"
    ["Zed"]="https://zed.dev/api/releases/stable/latest/Zed.dmg"
)

# Download each app
for app in "${!apps[@]}"; do
    url="${apps[$app]}"
    filename=$(basename "$url")
    
    if [[ -f "$filename" ]]; then
        warn "$app already downloaded"
        continue
    fi
    
    info "Downloading $app..."
    if curl -L -o "$filename" "$url" 2>/dev/null; then
        log "$app downloaded successfully"
    else
        warn "$app download failed - get manually from:"
        echo "  → ${url%/*}"
    fi
done

# Apps requiring manual download
echo ""
info "Still need manual download:"
echo ""
echo "Open these URLs in browser:"
echo "• Raycast: https://raycast.com"
echo "• Bartender 5: https://www.macbartender.com"
echo "• Beyond Compare: https://scootersoftware.com"
echo "• ChatGPT: https://chatgpt.com/download"
echo "• Claude: https://claude.ai/download"
echo "• CotEditor: https://coteditor.com"
echo ""
echo "App Store apps:"
echo "• Amphetamine (search in App Store)"
echo ""

# Auto-open downloads folder
open "$DOWNLOAD_DIR"
log "Downloads folder opened"

echo ""
info "Install downloaded apps, then return to setup script"