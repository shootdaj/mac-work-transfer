#!/bin/bash

# List manual applications that need to be installed

# Colors
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${YELLOW}Manual Applications to Install:${NC}"
echo "================================"
echo ""

apps=(
    "AltTab|https://alt-tab-macos.netlify.app|Window switcher"
    "Amphetamine|Mac App Store|Keep Mac awake"
    "Bartender 5|https://www.macbartender.com|Menu bar organization"
    "Beyond Compare|https://scootersoftware.com|File comparison"
    "ChatGPT|https://chatgpt.com/download|OpenAI ChatGPT app"
    "Claude|https://claude.ai/download|Anthropic Claude app"
    "Copilot|https://github.com/features/copilot|GitHub Copilot"
    "CotEditor|https://coteditor.com|Text editor"
    "Raycast|https://raycast.com|Productivity launcher"
    "Warp|https://warp.dev|Modern terminal"
    "Zed|https://zed.dev|Code editor"
)

for app in "${apps[@]}"; do
    IFS='|' read -r name url desc <<< "$app"
    echo -e "${BLUE}$name${NC}"
    echo "  → $desc"
    echo "  → Download: $url"
    echo ""
done

echo "================================"
echo ""
echo "Note: Install these apps manually, then run restore-app-configs.sh again"
echo "to apply their saved configurations."