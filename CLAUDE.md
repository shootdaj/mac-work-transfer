# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose
This is a **Mac work transfer repository** for migrating setups, apps, configs, and automations between Mac machines. Complete backup system with 27 essential packages and 14 app configurations.

## Communication Style (Per AGENT_PLAN.md)
- Keep responses **brief and direct** unless details are explicitly requested
- Ask for clarification when ambiguous - provide exact details (formal names, paths, terminology)
- Focus on **actionable output** - files, code, commands, checklists
- Provide **step-by-step guides** with exact file paths and copy-paste-ready code

## Technical Context
- **Primary OS**: macOS (Sequoia)
- **Key Tools**: Raycast, BetterTouchTool, Karabiner-Elements, Cursor, Warp, GitKraken
- **Development**: Cursor (not VS Code), Docker/Kubernetes, zsh dotfiles
- **Preferences**: OSS/free software, modern concise approaches, automation and customization

## When User Asks to Run Mac Setup

**USE THIS SCRIPT**: `./scripts/setup-claude-driven.sh`

### Your Role as Driver
1. **Execute the script** and interpret its JSON output
2. **Guide the user** through any manual steps needed
3. **Troubleshoot failures** using the detailed task results
4. **Make decisions** about what to retry or skip
5. **Verify completeness** and guide next steps

### Script Behavior
- **Deterministic tasks**: Handled automatically (file ops, package installs, configs)
- **JSON output**: Machine-readable results for each task
- **Real-time feedback**: Progress updates via stderr
- **Comprehensive logging**: Full technical log in /tmp/
- **No user interaction**: Script runs silently, you handle the communication

### Key Manual Steps (Script Will Detect, You Handle)
1. **Manual app installation**: Check script output for missing apps, guide user to install them
2. **SSH key generation**: Not automated for security - guide user through `ssh-keygen`
3. **Account sign-ins**: GitHub, browsers, development tools
4. **App restarts**: Some apps need restart for configs to load

### Troubleshooting Approach
1. **Read the JSON report** - shows exactly what succeeded/failed
2. **Check the log file** - technical details for debugging
3. **Use MANUAL_RECOVERY.md** - step-by-step fixes for common issues
4. **Run individual scripts** if needed - restore-dotfiles.sh, restore-app-configs.sh

### Success Criteria
- Homebrew packages installed
- Dotfiles restored (.zshrc, .gitconfig, etc.)
- App configs applied (Raycast, BetterTouchTool, Karabiner, Cursor, etc.)
- Manual apps installed and verified
- System preferences optimized
- User knows what to do next

## Repository Structure
```
├── Brewfile.essentials          # 27 curated packages
├── docs/configs/               # 14 backed up app configurations
├── scripts/setup-claude-driven.sh  # ⭐ RUN THIS SCRIPT
├── MANUAL_RECOVERY.md          # Troubleshooting guide
└── AGENT_PLAN.md              # User's AI interaction preferences
```

## Commands to Know
- **Run setup**: `./scripts/setup-claude-driven.sh`
- **Manual recovery**: See `MANUAL_RECOVERY.md`
- **Check installed apps**: `ls /Applications/ | grep -E "(Raycast|Warp|Zed|AltTab|Bartender)"`
- **Verify Homebrew**: `brew list | wc -l` (should be ~20+ packages)