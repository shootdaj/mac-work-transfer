#!/bin/bash

# Critical: Check if we're running on modern bash (4.0+) required for associative arrays
# macOS Sequoia ships with bash 3.2 which doesn't support associative arrays
if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
    echo "CRITICAL: This script requires bash 4.0+ but found bash $BASH_VERSION" >&2
    echo "" >&2
    echo "macOS Sequoia ships with bash 3.2. To fix this:" >&2
    echo "1. Install Homebrew (if not already installed):" >&2
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" >&2
    echo "" >&2
    echo "2. Install modern bash:" >&2
    echo "   brew install bash" >&2
    echo "" >&2
    echo "3. Run this script with the new bash:" >&2
    echo "   /opt/homebrew/bin/bash \"\$0\" \"\$@\"" >&2
    echo "" >&2
    echo "4. Or add to PATH and re-run:" >&2
    echo "   export PATH=\"/opt/homebrew/bin:\$PATH\"" >&2
    echo "   bash \"\$0\" \"\$@\"" >&2
    echo "" >&2
    
    # Try to auto-fix if modern bash is available but not in PATH
    if [[ -x "/opt/homebrew/bin/bash" ]]; then
        echo "Found modern bash at /opt/homebrew/bin/bash - attempting auto-restart..." >&2
        exec /opt/homebrew/bin/bash "$0" "$@"
    elif [[ -x "/usr/local/bin/bash" ]]; then
        echo "Found modern bash at /usr/local/bin/bash - attempting auto-restart..." >&2
        exec /usr/local/bin/bash "$0" "$@"
    fi
    
    exit 1
fi

# Mac Work Transfer - Claude-Driven Setup with Pretty Output
# Designed to be executed by Claude Code with dual output:
# - Pretty terminal UI for user to watch
# - JSON output for Claude to interpret

set -euo pipefail

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# Unicode symbols
CHECKMARK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
PACKAGE="📦"
COMPUTER="💻"
HOURGLASS="⏳"
SPARKLES="✨"

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SESSION_ID="mac-transfer-$(date +%Y%m%d-%H%M%S)"

# Ensure Desktop directory exists, fallback to HOME
REPORT_DIR="$HOME/Desktop"
[[ ! -d "$REPORT_DIR" ]] && REPORT_DIR="$HOME"

REPORT_JSON="$REPORT_DIR/Mac-Transfer-Report-$SESSION_ID.json"
REPORT_HTML="$REPORT_DIR/Mac-Transfer-Report-$SESSION_ID.html"
LOG_FILE="/tmp/mac-transfer-$SESSION_ID.log"
START_TIME=$(date +%s)

# Task tracking
declare -A RESULTS=()
TASK_COUNT=0
SUCCESS_COUNT=0
FAILED_COUNT=0

# Pretty UI functions
print_header() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  ${ROCKET} ${WHITE}Mac Work Transfer - Claude-Driven Setup${NC}           ${PURPLE}║${NC}"
    local padding=$((40 - ${#SESSION_ID}))
    [[ $padding -lt 0 ]] && padding=0
    echo -e "${PURPLE}║${NC}  ${COMPUTER} Session: $SESSION_ID${NC}$(printf "%*s" $padding "")${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_phase() {
    local title="$1"
    local emoji="$2"
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${NC}"
    local title_padding=$((53 - ${#title}))
    [[ $title_padding -lt 0 ]] && title_padding=0
    echo -e "${CYAN}│${NC} ${emoji} ${WHITE}${title}${NC}$(printf "%*s" $title_padding "")${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# Dual output logging
log_result() {
    local task_id="$1"
    local status="$2"
    local details="$3"
    local duration="${4:-0}"
    
    # Store for JSON report
    RESULTS["$task_id"]=$(cat << EOF
{
  "status": "$status",
  "details": "$details",
  "duration": $duration,
  "timestamp": "$(date -Iseconds)"
}
EOF
    )
    ((TASK_COUNT++))
    
    # Pretty terminal output for user
    case $status in
        "SUCCESS")
            echo -e "${GREEN}${CHECKMARK} ${NC}$details ${GRAY}(${duration}s)${NC}"
            ((SUCCESS_COUNT++))
            ;;
        "FAILED")
            echo -e "${RED}${CROSS} ${NC}$details ${GRAY}(${duration}s)${NC}"
            ((FAILED_COUNT++))
            ;;
        "INSTALLED"|"MISSING")
            local icon="${CHECKMARK}"
            [[ $status == "MISSING" ]] && icon="${WARNING}"
            echo -e "${BLUE}${icon} ${NC}$details"
            ;;
        "INFO")
            echo -e "${CYAN}${INFO} ${NC}$details"
            ;;
    esac
    
    # JSON output for Claude (via stderr)
    echo "TASK_RESULT: $task_id = $status ($details)" >&2
}

# Safe command executor with pretty output
safe_execute() {
    local task_id="$1"
    local description="$2"
    local command="$3"
    local timeout="${4:-300}"
    
    # Pretty output for user
    echo -e "${BLUE}${HOURGLASS} ${NC}Starting: $description"
    
    # Claude feedback
    echo "EXECUTING: $task_id - $description" >&2
    local start_time=$(date +%s)
    
    # Implement timeout functionality since macOS doesn't have timeout command
    (
        bash -c "$command" >> "$LOG_FILE" 2>&1 &
        local cmd_pid=$!
        
        # Wait for timeout period, checking every second if process is done
        local elapsed=0
        local exit_code=0
        
        while [[ $elapsed -lt $timeout ]]; do
            if ! kill -0 "$cmd_pid" 2>/dev/null; then
                # Process finished, get exit code
                wait "$cmd_pid"
                exit_code=$?
                exit $exit_code
            fi
            sleep 1
            ((elapsed++))
        done
        
        # Timeout reached, try to kill the process
        kill "$cmd_pid" 2>/dev/null
        # Give the process a moment to die gracefully
        sleep 0.1
        # Force kill if still running
        kill -9 "$cmd_pid" 2>/dev/null
        # Wait for the process to be fully reaped
        wait "$cmd_pid" 2>/dev/null
        exit 124  # Standard timeout exit code
    )
    local cmd_exit_code=$?
    
    if [[ $cmd_exit_code -eq 0 ]]; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_result "$task_id" "SUCCESS" "$description" "$duration"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        if [[ $cmd_exit_code -eq 124 ]]; then
            log_result "$task_id" "FAILED" "$description (timed out after ${timeout}s)" "$duration"
        else
            log_result "$task_id" "FAILED" "$description (exit code: $cmd_exit_code)" "$duration"
        fi
        return $cmd_exit_code
    fi
}

# System verification
verify_system() {
    print_phase "System Verification" "$COMPUTER"
    echo "PHASE: System Verification" >&2
    
    safe_execute "macos_check" "Verify macOS system" \
        '[[ "$OSTYPE" == "darwin"* ]]'
    
    # Apple Silicon specific checks
    local arch=$(uname -m)
    if [[ "$arch" == "arm64" ]]; then
        log_result "apple_silicon_detected" "SUCCESS" "Apple Silicon (M1/M2/M3) detected"
        
        # Check if Rosetta 2 is available for Intel app compatibility  
        if pgrep -f oahd >/dev/null 2>&1; then
            log_result "rosetta_check" "INFO" "Rosetta 2 available for Intel app compatibility"
        else
            log_result "rosetta_check" "INFO" "Rosetta 2 not installed (not required for essential packages)"
        fi
    else
        log_result "intel_mac_detected" "SUCCESS" "Intel Mac detected"
    fi
    
    safe_execute "directory_check" "Verify project structure" \
        '[[ -f "'"$PROJECT_DIR"'/Brewfile.essentials" ]]'
    
    safe_execute "permissions_check" "Check required scripts exist and are executable" \
        '[[ -x "'"$SCRIPT_DIR"'/restore-dotfiles.sh" && -x "'"$SCRIPT_DIR"'/restore-app-configs.sh" ]]'
    
    # Test log file creation
    safe_execute "log_file_check" "Verify log file can be created" \
        'touch "'"$LOG_FILE"'" && echo "test" >> "'"$LOG_FILE"'"'
    
    # Test report directory is writable
    safe_execute "report_dir_check" "Verify reports can be written to $REPORT_DIR" \
        'touch "'"$REPORT_DIR"'/test-write-$$" && rm -f "'"$REPORT_DIR"'/test-write-$$"'
}

# Homebrew installation and setup
setup_homebrew() {
    print_phase "Homebrew Package Manager" "$PACKAGE"
    echo "PHASE: Homebrew Setup" >&2
    
    # Check if already installed
    if command -v brew >/dev/null 2>&1; then
        log_result "homebrew_check" "SUCCESS" "Homebrew already installed"
    else
        safe_execute "homebrew_install" "Install Homebrew package manager" \
            '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' \
            600
    fi
    
    # Path setup - deterministic based on system type
    if [[ -d "/opt/homebrew" ]] && ! echo "$PATH" | grep -q "/opt/homebrew/bin"; then
        safe_execute "homebrew_path_apple" "Configure Homebrew PATH for Apple Silicon" \
            'echo '\''eval "$(/opt/homebrew/bin/brew shellenv)"'\'' >> ~/.zprofile && eval "$(/opt/homebrew/bin/brew shellenv)"'
    elif [[ -x "/usr/local/bin/brew" ]] && ! echo "$PATH" | grep -q "/usr/local/bin"; then
        safe_execute "homebrew_path_intel" "Configure Homebrew PATH for Intel" \
            'echo '\''eval "$(/usr/local/bin/brew shellenv)"'\'' >> ~/.zprofile && eval "$(/usr/local/bin/brew shellenv)"'
    fi
    
    # Verify Homebrew is working
    safe_execute "homebrew_verify" "Verify Homebrew installation" \
        'command -v brew >/dev/null 2>&1 && brew --version'
}

# Install packages with granular reporting
install_packages() {
    print_phase "Essential Package Installation" "$PACKAGE"
    echo "PHASE: Package Installation" >&2
    
    if ! cd "$PROJECT_DIR"; then
        echo "ERROR: Cannot access project directory: $PROJECT_DIR" >&2
        return 1
    fi
    
    # First try batch install
    if safe_execute "packages_batch" "Install all packages via bundle" \
        'brew bundle install --file=Brewfile.essentials --no-lock --verbose'; then
        return 0
    fi
    
    # If batch fails, install individually for better reporting
    echo "BATCH_INSTALL_FAILED: Installing packages individually" >&2
    
    local success_count=0
    local total_count=0
    
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ $line =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # Parse brew/cask lines using string operations (more reliable than regex)
        if [[ $line == *"brew \""* ]] || [[ $line == *"cask \""* ]]; then
            local type="${line%% \"*}"
            type="${type##* }"  # Get last word (brew or cask)
            local package=$(echo "$line" | sed -n 's/.*"\([^"]*\)".*/\1/p')
            [[ -n "$type" && -n "$package" ]] || continue
        else
            continue
        fi
        ((total_count++))
        
        # Sanitize package name for task_id (replace special chars with underscore)
        local safe_package=$(echo "$package" | sed 's/[^a-zA-Z0-9]/_/g')
        
        if [[ $type == "brew" ]]; then
            if safe_execute "brew_$safe_package" "Install brew package: $package" \
                "brew install '$package'"; then
                ((success_count++))
            fi
        elif [[ $type == "cask" ]]; then
            if safe_execute "cask_$safe_package" "Install cask: $package" \
                "brew install --cask '$package'"; then
                ((success_count++))
            fi
        fi
    done < "Brewfile.essentials" 2>/dev/null || {
        echo "ERROR: Cannot read Brewfile.essentials" >&2
        return 1
    }
    
    log_result "packages_summary" "INFO" "Packages installed: $success_count/$total_count"
}

# Restore configurations
restore_configs() {
    print_phase "Configuration Restore" "$GEAR"
    echo "PHASE: Configuration Restore" >&2
    
    if ! cd "$PROJECT_DIR"; then
        echo "ERROR: Cannot access project directory: $PROJECT_DIR" >&2
        return 1
    fi
    
    # Dotfiles restoration
    safe_execute "dotfiles_restore" "Restore shell and development configs" \
        './scripts/restore-dotfiles.sh'
    
    # App configurations restoration  
    safe_execute "app_configs_restore" "Restore application configurations" \
        './scripts/restore-app-configs.sh'
}

# Generate app installation status
check_manual_apps() {
    print_phase "Manual App Detection" "$COMPUTER"
    echo "PHASE: Manual App Detection" >&2
    
    local apps=(
        "AltTab.app:com.lwouis.alt-tab-macos"
        "Raycast.app:com.raycast.macos"
        "Warp.app:dev.warp.Warp-Stable"
        "Zed.app:dev.zed.Zed"
        "Bartender 5.app:com.surteesstudios.Bartender"
        "Claude.app:com.anthropic.claude"
        "ChatGPT.app:com.openai.chat"
    )
    
    local installed_count=0
    local total_count=${#apps[@]}
    
    for app_info in "${apps[@]}"; do
        IFS=':' read -r app_name bundle_id <<< "$app_info"
        
        # Sanitize app name for task_id (replace spaces and special chars)
        local safe_app_name=$(echo "${app_name%.*}" | sed 's/[^a-zA-Z0-9]/_/g')
        
        if [[ -d "/Applications/$app_name" ]] || [[ -n "$(mdfind "kMDItemCFBundleIdentifier == \"$bundle_id\"" 2>/dev/null)" ]]; then
            log_result "manual_app_$safe_app_name" "INSTALLED" "$app_name found"
            ((installed_count++))
        else
            log_result "manual_app_$safe_app_name" "MISSING" "$app_name not found"
        fi
    done
    
    log_result "manual_apps_summary" "INFO" "Manual apps installed: $installed_count/$total_count"
}

# Apply system preferences (deterministic settings)
apply_system_prefs() {
    print_phase "System Preferences" "$GEAR"
    echo "PHASE: System Preferences" >&2
    
    # Core productivity settings (no user interaction needed)
    local -A prefs=(
        ["dock_autohide"]="defaults write com.apple.dock autohide -bool true"
        ["dock_animation"]="defaults write com.apple.dock autohide-time-modifier -float 0.5"
        ["finder_pathbar"]="defaults write com.apple.finder ShowPathbar -bool true"
        ["finder_extensions"]="defaults write NSGlobalDomain AppleShowAllExtensions -bool true"
        ["keyboard_repeat"]="defaults write NSGlobalDomain KeyRepeat -int 2"
        ["keyboard_delay"]="defaults write NSGlobalDomain InitialKeyRepeat -int 15"
        ["trackpad_tap"]="defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true"
        ["spaces_fixed"]="defaults write com.apple.dock mru-spaces -bool false"
    )
    
    for pref_id in "${!prefs[@]}"; do
        safe_execute "syspref_$pref_id" "Set system preference: $pref_id" \
            "${prefs[$pref_id]}"
    done
    
    # Restart UI services
    safe_execute "ui_restart" "Restart UI services" \
        'killall Dock 2>/dev/null; killall Finder 2>/dev/null; killall SystemUIServer 2>/dev/null'
}

# Generate dual reports (JSON + HTML)
generate_reports() {
    local end_time=$(date +%s)
    local total_duration=$((end_time - START_TIME))
    
    # Generate JSON report for Claude
    if ! cat > "$REPORT_JSON" << EOF
{
  "session_id": "$SESSION_ID",
  "timestamp": "$(date -Iseconds)",
  "duration_seconds": $total_duration,
  "task_count": $TASK_COUNT,
  "success_count": $SUCCESS_COUNT,
  "failed_count": $FAILED_COUNT,
  "results": {
EOF
    then
        echo "ERROR: Cannot write JSON report to $REPORT_JSON" >&2
        return 1
    fi

    local first=true
    if [[ ${#RESULTS[@]} -gt 0 ]]; then
        for task_id in "${!RESULTS[@]}"; do
            [[ $first == true ]] && first=false || echo "," >> "$REPORT_JSON"
            echo "    \"$task_id\": ${RESULTS[$task_id]}" >> "$REPORT_JSON"
        done
    fi

    if ! cat >> "$REPORT_JSON" << EOF
  },
  "log_file": "$LOG_FILE",
  "project_directory": "$PROJECT_DIR"
}
EOF
    then
        echo "ERROR: Cannot complete JSON report" >&2
        return 1
    fi

    # Generate HTML report for user
    generate_html_report "$total_duration"
    
    echo "REPORT_GENERATED: JSON=$REPORT_JSON HTML=$REPORT_HTML" >&2
}

# Beautiful HTML report generation
generate_html_report() {
    local total_duration="$1"
    
    if ! cat > "$REPORT_HTML" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mac Transfer Report - $SESSION_ID</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 20px rgba(0,0,0,0.1); }
        .header { text-align: center; color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 20px; margin-bottom: 30px; }
        .summary { display: flex; justify-content: space-around; margin: 30px 0; }
        .stat { text-align: center; padding: 20px; border-radius: 8px; margin: 0 10px; flex: 1; }
        .success { background: #d4edda; color: #155724; }
        .failed { background: #f8d7da; color: #721c24; }
        .info { background: #d1ecf1; color: #0c5460; }
        .task { margin: 15px 0; padding: 15px; border-radius: 5px; border-left: 4px solid #ddd; }
        .task.success { border-left-color: #28a745; background: #f8fff9; }
        .task.failed { border-left-color: #dc3545; background: #fff8f8; }
        .task.installed { border-left-color: #17a2b8; background: #f0f9ff; }
        .task.missing { border-left-color: #ffc107; background: #fffef7; }
        .task.info { border-left-color: #17a2b8; background: #f0f9ff; }
        .next-steps { background: #e7f3ff; padding: 20px; border-radius: 8px; margin-top: 30px; }
        .timestamp { color: #666; font-size: 14px; }
        .phase { color: #2c3e50; font-weight: bold; margin-top: 25px; padding: 10px 0; border-bottom: 2px solid #ecf0f1; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Mac Work Transfer Report</h1>
            <h2>Claude-Driven Setup Session</h2>
            <p>Session: $SESSION_ID</p>
            <p class="timestamp">Completed: $(date)</p>
            <p class="timestamp">Duration: $((total_duration / 60))m $((total_duration % 60))s</p>
        </div>
        
        <div class="summary">
            <div class="stat success">
                <h3>✅ Successful</h3>
                <p style="font-size: 24px; margin: 0;">$SUCCESS_COUNT</p>
            </div>
            <div class="stat failed">
                <h3>❌ Failed</h3>
                <p style="font-size: 24px; margin: 0;">$FAILED_COUNT</p>
            </div>
            <div class="stat info">
                <h3>📊 Total Tasks</h3>
                <p style="font-size: 24px; margin: 0;">$TASK_COUNT</p>
            </div>
        </div>
        
        <h2>📋 Detailed Results</h2>
EOF

    # Group tasks by phase for better organization
    local current_phase=""
    for task_id in "${!RESULTS[@]}"; do
        local result_json="${RESULTS[$task_id]}"
        local status=$(echo "$result_json" | grep -o '"status": "[^"]*"' | cut -d'"' -f4)
        local details=$(echo "$result_json" | grep -o '"details": "[^"]*"' | cut -d'"' -f4)
        local duration=$(echo "$result_json" | grep -o '"duration": [^,}]*' | cut -d':' -f2 | tr -d ' ')
        
        # Determine phase from task_id
        local phase="System"
        [[ $task_id =~ homebrew ]] && phase="Homebrew"
        [[ $task_id =~ (brew_|cask_|packages) ]] && phase="Packages"
        [[ $task_id =~ (dotfiles|app_configs) ]] && phase="Configuration"
        [[ $task_id =~ manual_app ]] && phase="Manual Apps"
        [[ $task_id =~ syspref ]] && phase="System Preferences"
        
        if [[ "$phase" != "$current_phase" ]]; then
            echo "        <div class=\"phase\">$phase</div>" >> "$REPORT_HTML"
            current_phase="$phase"
        fi
        
        local css_class="info"
        local icon="ℹ️"
        
        case $status in
            "SUCCESS") css_class="success"; icon="✅" ;;
            "FAILED") css_class="failed"; icon="❌" ;;
            "INSTALLED") css_class="installed"; icon="✅" ;;
            "MISSING") css_class="missing"; icon="⚠️" ;;
        esac
        
        cat >> "$REPORT_HTML" << EOF
        <div class="task $css_class">
            <strong>$icon $details</strong>
            $([ -n "$duration" ] && [ "$duration" != "0" ] && echo "<span style=\"float: right; color: #666;\">${duration}s</span>")
        </div>
EOF
    done
    
    # Add next steps
    cat >> "$REPORT_HTML" << EOF
        
        <div class="next-steps">
            <h3>🎯 What Claude Should Guide You Through Next</h3>
            <ol>
                <li><strong>Install Missing Manual Apps:</strong> Check the "Manual Apps" section above for missing applications</li>
                <li><strong>Generate SSH Keys:</strong> <code>ssh-keygen -t ed25519 -C "your_email@example.com"</code></li>
                <li><strong>Open Key Apps:</strong> Launch Karabiner-Elements, BetterTouchTool for configs to load</li>
                <li><strong>Sign Into Accounts:</strong> GitHub, browsers, development tools</li>
                <li><strong>Restart Applications:</strong> Some apps need restart for configs to take effect</li>
                <li><strong>System Restart:</strong> For all system preferences to apply fully</li>
            </ol>
            
            <p><strong>🔗 Resources:</strong></p>
            <ul>
                <li>JSON Report: <code>$REPORT_JSON</code></li>
                <li>Technical Log: <code>$LOG_FILE</code></li>
                <li>Manual Recovery: <code>$PROJECT_DIR/MANUAL_RECOVERY.md</code></li>
                <li>Config Backups: <code>$PROJECT_DIR/docs/configs/</code></li>
            </ul>
        </div>
        
        <p style="text-align: center; margin-top: 30px; color: #666;">
            Generated by Mac Work Transfer Claude-Driven Setup<br>
            <small>Session driven by Claude Code with dual output for optimal experience</small>
        </p>
    </div>
</body>
</html>
EOF
    then
        echo "ERROR: Cannot write HTML report to $REPORT_HTML" >&2
        return 1
    fi
}

# Main execution
main() {
    # Initialize session
    print_header
    
    echo "SESSION_START: $SESSION_ID" >&2
    echo "LOG_FILE: $LOG_FILE" >&2
    
    # Execute phases with pretty output for user, JSON for Claude
    verify_system
    setup_homebrew
    install_packages
    check_manual_apps
    restore_configs
    apply_system_prefs
    
    # Generate dual reports
    print_phase "Generating Reports" "$SPARKLES"
    generate_reports
    
    # Pretty completion summary for user
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  ${SPARKLES} ${WHITE}Setup Session Complete!${NC}                            ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}${CHECKMARK} Results: $SUCCESS_COUNT successful, $FAILED_COUNT failed, $TASK_COUNT total${NC}"
    echo -e "${BLUE}${INFO} HTML Report: $REPORT_HTML${NC}"
    echo -e "${BLUE}${INFO} JSON Report: $REPORT_JSON${NC}"
    echo ""
    
    # Claude session info
    echo "SESSION_COMPLETE: $SESSION_ID" >&2
    echo "REPORT_LOCATIONS: JSON=$REPORT_JSON HTML=$REPORT_HTML" >&2
    
    # Auto-open HTML report for user
    if command -v open >/dev/null 2>&1; then
        open "$REPORT_HTML"
        echo -e "${GRAY}Opening HTML report...${NC}"
    fi
    
    # Output JSON for Claude to parse
    echo ""
    echo -e "${GRAY}JSON Report for Claude:${NC}"
    if [[ -r "$REPORT_JSON" ]]; then
        cat "$REPORT_JSON"
    else
        echo '{"error": "Report generation failed", "session_id": "'"$SESSION_ID"'"}' >&2
    fi
}

# Cleanup on exit
trap 'generate_reports || echo "ERROR: Report generation failed during cleanup" >&2; echo "SESSION_INTERRUPTED: Partial results saved" >&2' INT TERM

# Execute
main "$@"