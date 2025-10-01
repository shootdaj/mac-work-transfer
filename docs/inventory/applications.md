# Essential Applications Configuration

## BetterTouchTool
**Location**: `~/Library/Application Support/BetterTouchTool/`
**Export Method**: 
```bash
# Export settings
cp -r "~/Library/Application Support/BetterTouchTool/" ./docs/configs/bettertouchtool/
```

**Key Settings to Document:**
- Touch Bar customizations
- Trackpad gestures
- Keyboard shortcuts
- Window snapping rules

## Karabiner-Elements
**Location**: `~/.config/karabiner/`
**Export Method**:
```bash
# Export configuration
cp -r ~/.config/karabiner/ ./docs/configs/karabiner/
```

**Key Files:**
- `karabiner.json` - Main configuration
- Custom complex modifications

## Cursor (AI Code Editor)
**Location**: `~/Library/Application Support/Cursor/`
**Settings Location**: `~/Library/Application Support/Cursor/User/`
**Export Method**:
```bash
# Export user settings
cp -r "~/Library/Application Support/Cursor/User/" ./docs/configs/cursor/
```

**Key Files:**
- `settings.json` - Editor preferences
- `keybindings.json` - Custom shortcuts
- Extensions list (already captured in Brewfile.essentials)

## GitKraken
**Location**: `~/.gitkraken/`
**Export Method**:
```bash
# Export profiles and settings
cp -r ~/.gitkraken/ ./docs/configs/gitkraken/
```

## Itsycal
**Preferences**: System Preferences integration
**Export Method**: Manual documentation of settings

## DaisyDisk
**Preferences**: Built-in preferences
**Export Method**: Manual documentation

## VLC Nightly
**Location**: `~/Library/Preferences/org.videolan.vlc/`
**Export Method**:
```bash
# Export preferences
cp -r "~/Library/Preferences/org.videolan.vlc/" ./docs/configs/vlc/
```

## GPT4All
**Location**: `~/Library/Application Support/nomic.ai/GPT4All/`
**Models Location**: Check app for model storage path

## LM Studio
**Location**: `~/.cache/lm-studio/` or similar
**Models**: Document model storage locations

## SuperWhisper
**Preferences**: App-specific settings
**Export Method**: Manual documentation

## Browsers Configuration

### Brave Browser
**Location**: `~/Library/Application Support/BraveSoftware/Brave-Browser/`
**Export Method**: Manual export of bookmarks, extensions

### Firefox
**Location**: `~/Library/Application Support/Firefox/Profiles/`
**Export Method**:
```bash
# Export Firefox profile
cp -r "~/Library/Application Support/Firefox/Profiles/" ./docs/configs/firefox/
```

## Development Tools

### .NET SDK
**Verify Installation**:
```bash
dotnet --version
dotnet --list-sdks
```

### Far2l
**Configuration**: `~/.config/far2l/`

### NotepadNext
**Settings**: App-specific preferences