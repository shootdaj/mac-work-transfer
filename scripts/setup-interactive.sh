#!/bin/bash

# Mac Work Transfer - Interactive Pair Programming Setup
# Your AI pair programmer that drives automation but asks for help when needed

# Advanced terminal formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# Unicode symbols for pretty output
CHECKMARK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
PACKAGE="📦"
FOLDER="📁"
COMPUTER="💻"
HOURGLASS="⏳"
SPARKLES="✨"

# Session tracking
START_TIME=$(date +%s)
SESSION_ID="mac-transfer-$(date +%Y%m%d-%H%M%S)"
REPORT_FILE="$HOME/Desktop/Mac-Transfer-Report-$SESSION_ID.html"
LOG_FILE="/tmp/mac-transfer-$SESSION_ID.log"

# Comprehensive tracking
declare -A TASK_STATUS=()
declare -A TASK_DETAILS=()
declare -A TASK_TIMES=()
TOTAL_TASKS=0
COMPLETED_TASKS=0
FAILED_TASKS=0
MANUAL_TASKS=0

# Beautiful UI functions
print_header() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  ${ROCKET} ${WHITE}Mac Work Transfer - Interactive Setup${NC}              ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}  ${COMPUTER} Your AI pair programmer is driving this session      ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    local title="$1"
    local emoji="$2"
    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${emoji} ${WHITE}${title}${NC}$(printf "%*s" $((53 - ${#title})) "")${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# Live progress bar with task info
show_live_progress() {
    local current="$1"
    local total="$2"
    local task_name="$3"
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    # Clear previous line and show progress
    printf "\r\033[K"
    printf "${BLUE}Progress: ${NC}["
    printf "${GREEN}%*s${NC}" $filled | tr ' ' '█'
    printf "%*s" $((width - filled)) | tr ' ' '░'
    printf "] ${WHITE}%d%%${NC} ${GRAY}(%d/%d)${NC}\n" $percentage $current $total
    printf "${YELLOW}${HOURGLASS} Currently: ${NC}%s\n" "$task_name"
    printf "\033[1A"  # Move cursor up to overwrite on next update
}

# Smart task executor with real-time feedback
execute_task() {
    local task_id="$1"
    local task_name="$2"
    local task_cmd="$3"
    local manual_fallback="$4"
    
    TOTAL_TASKS=$((TOTAL_TASKS + 1))
    local start_time=$(date +%s)
    
    echo -e "\n${BLUE}${GEAR} Starting:${NC} $task_name"
    echo "Command: $task_cmd" >> "$LOG_FILE"
    
    # Show live progress while task runs
    show_live_progress $COMPLETED_TASKS $TOTAL_TASKS "$task_name"
    
    # Execute with timeout and progress indication
    if timeout 300 bash -c "$task_cmd" >> "$LOG_FILE" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        TASK_STATUS["$task_id"]="SUCCESS"
        TASK_DETAILS["$task_id"]="Completed successfully in ${duration}s"
        TASK_TIMES["$task_id"]="$duration"
        COMPLETED_TASKS=$((COMPLETED_TASKS + 1))
        
        printf "\r\033[K${GREEN}${CHECKMARK} Completed:${NC} $task_name ${GRAY}(${duration}s)${NC}\n"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        FAILED_TASKS=$((FAILED_TASKS + 1))
        printf "\r\033[K${RED}${CROSS} Failed:${NC} $task_name ${GRAY}(${duration}s)${NC}\n"
        
        # Offer manual intervention if available
        if [[ -n "$manual_fallback" ]]; then
            echo -e "${YELLOW}${WARNING} I need your help here!${NC}"
            echo -e "${WHITE}Manual step required:${NC} $manual_fallback"
            echo ""
            read -p "Press ENTER after completing this step manually, or 's' to skip: " -r
            
            if [[ $REPLY != "s" ]]; then
                TASK_STATUS["$task_id"]="MANUAL_SUCCESS"
                TASK_DETAILS["$task_id"]="Completed manually by user"
                MANUAL_TASKS=$((MANUAL_TASKS + 1))
                echo -e "${GREEN}${CHECKMARK} Manual completion confirmed${NC}"
                return 0
            else
                TASK_STATUS["$task_id"]="SKIPPED"
                TASK_DETAILS["$task_id"]="Skipped by user"
                echo -e "${YELLOW}${WARNING} Task skipped${NC}"
                return 1
            fi
        else
            TASK_STATUS["$task_id"]="FAILED"
            TASK_DETAILS["$task_id"]="Failed after ${duration}s - see log for details"
            return 1
        fi
    fi
}

# Interactive manual intervention during automation
request_manual_help() {
    local task_name="$1"
    local instructions="$2"
    local verification_cmd="$3"
    
    echo -e "\n${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC} ${HOURGLASS} ${YELLOW}MANUAL INTERVENTION NEEDED${NC}                           ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Task:${NC} $task_name"
    echo -e "${WHITE}What I need you to do:${NC}"
    echo "$instructions" | fold -w 60 | sed 's/^/  /'
    echo ""
    
    while true; do
        read -p "Ready to continue? (y/n/help): " -r
        case $REPLY in
            [Yy])
                if [[ -n "$verification_cmd" ]]; then
                    echo -e "\n${BLUE}${INFO} Verifying completion...${NC}"
                    if eval "$verification_cmd" >/dev/null 2>&1; then
                        echo -e "${GREEN}${CHECKMARK} Verification successful!${NC}"
                        MANUAL_TASKS=$((MANUAL_TASKS + 1))
                        return 0
                    else
                        echo -e "${YELLOW}${WARNING} Verification failed. Please try again.${NC}"
                        continue
                    fi
                else
                    MANUAL_TASKS=$((MANUAL_TASKS + 1))
                    return 0
                fi
                ;;
            [Nn])
                echo -e "${YELLOW}${WARNING} Skipping this step. Added to final report.${NC}"
                return 1
                ;;
            "help")
                echo -e "\n${BLUE}${INFO} Additional help:${NC}"
                echo "This step requires manual intervention because automation"
                echo "might not work reliably. I'll wait here until you're done."
                echo ""
                ;;
            *)
                echo -e "${YELLOW}Please answer y/n/help${NC}"
                ;;
        esac
    done
}

# Generate beautiful HTML report
generate_report() {
    local end_time=$(date +%s)
    local total_duration=$((end_time - START_TIME))
    
    cat > "$REPORT_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mac Transfer Report - $SESSION_ID</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 20px rgba(0,0,0,0.1); }
        .header { text-align: center; color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 20px; margin-bottom: 30px; }
        .summary { display: flex; justify-content: space-around; margin: 30px 0; }
        .stat { text-align: center; padding: 20px; border-radius: 8px; margin: 0 10px; flex: 1; }
        .success { background: #d4edda; color: #155724; }
        .failed { background: #f8d7da; color: #721c24; }
        .manual { background: #fff3cd; color: #856404; }
        .task { margin: 15px 0; padding: 15px; border-radius: 5px; border-left: 4px solid #ddd; }
        .task.success { border-left-color: #28a745; background: #f8fff9; }
        .task.failed { border-left-color: #dc3545; background: #fff8f8; }
        .task.manual { border-left-color: #ffc107; background: #fffef7; }
        .task.skipped { border-left-color: #6c757d; background: #f8f9fa; }
        .next-steps { background: #e7f3ff; padding: 20px; border-radius: 8px; margin-top: 30px; }
        .timestamp { color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Mac Work Transfer Report</h1>
            <p>Session: $SESSION_ID</p>
            <p class="timestamp">Completed: $(date)</p>
            <p class="timestamp">Duration: $((total_duration / 60))m $((total_duration % 60))s</p>
        </div>
        
        <div class="summary">
            <div class="stat success">
                <h3>✅ Automated</h3>
                <p style="font-size: 24px; margin: 0;">$COMPLETED_TASKS</p>
            </div>
            <div class="stat manual">
                <h3>👤 Manual</h3>
                <p style="font-size: 24px; margin: 0;">$MANUAL_TASKS</p>
            </div>
            <div class="stat failed">
                <h3>❌ Failed</h3>
                <p style="font-size: 24px; margin: 0;">$FAILED_TASKS</p>
            </div>
        </div>
        
        <h2>📋 Detailed Results</h2>
EOF

    # Add task details
    for task_id in "${!TASK_STATUS[@]}"; do
        local status="${TASK_STATUS[$task_id]}"
        local details="${TASK_DETAILS[$task_id]}"
        local css_class=""
        local icon=""
        
        case $status in
            "SUCCESS") css_class="success"; icon="✅" ;;
            "MANUAL_SUCCESS") css_class="manual"; icon="👤" ;;
            "FAILED") css_class="failed"; icon="❌" ;;
            "SKIPPED") css_class="skipped"; icon="⏭️" ;;
        esac
        
        cat >> "$REPORT_FILE" << EOF
        <div class="task $css_class">
            <strong>$icon $task_id</strong><br>
            <small>$details</small>
        </div>
EOF
    done
    
    # Add next steps
    cat >> "$REPORT_FILE" << EOF
        
        <div class="next-steps">
            <h3>🎯 What You Still Need To Do</h3>
            <ol>
EOF

    # Generate specific next steps based on what failed/was skipped
    if [[ $FAILED_TASKS -gt 0 ]]; then
        echo "                <li><strong>Address Failed Tasks:</strong> See MANUAL_RECOVERY.md for step-by-step fixes</li>" >> "$REPORT_FILE"
    fi
    
    cat >> "$REPORT_FILE" << EOF
                <li><strong>Generate SSH Keys:</strong> <code>ssh-keygen -t ed25519 -C "your_email@example.com"</code></li>
                <li><strong>Open Karabiner-Elements:</strong> Load your custom keyboard configurations</li>
                <li><strong>Sign Into Accounts:</strong> GitHub, browsers, development tools</li>
                <li><strong>Restart Applications:</strong> BetterTouchTool, Bartender, AltTab for configs to load</li>
                <li><strong>System Restart:</strong> For all system preferences to take full effect</li>
            </ol>
            
            <p><strong>🔗 Useful Links:</strong></p>
            <ul>
                <li>Log file: <code>$LOG_FILE</code></li>
                <li>Manual recovery guide: <code>MANUAL_RECOVERY.md</code></li>
                <li>Config backups: <code>docs/configs/</code></li>
            </ul>
        </div>
        
        <p style="text-align: center; margin-top: 30px; color: #666;">
            Generated by Mac Work Transfer Interactive Setup<br>
            <small>Your AI pair programmer session</small>
        </p>
    </div>
</body>
</html>
EOF
}

# Main execution flow
main() {
    print_header
    
    echo -e "${WHITE}Welcome! I'm your AI pair programmer for this Mac setup.${NC}"
    echo -e "${GRAY}I'll drive the automation and ask for your help when I need it.${NC}"
    echo ""
    read -p "Ready to begin? Press ENTER..."
    
    print_section "Phase 1: System Prerequisites" $COMPUTER
    
    # macOS check
    execute_task "macos_check" "Verify macOS system" \
        '[[ "$OSTYPE" == "darwin"* ]]' \
        ""
    
    print_section "Phase 2: Core Tools Installation" $PACKAGE
    
    # Homebrew installation
    execute_task "homebrew_install" "Install Homebrew package manager" \
        'command -v brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' \
        "Go to https://brew.sh and follow installation instructions manually"
    
    # Path setup for Homebrew
    if [[ -d "/opt/homebrew" ]] && ! echo "$PATH" | grep -q "/opt/homebrew/bin"; then
        request_manual_help "Homebrew Path Setup" \
            "I need to add Homebrew to your PATH. Please run this command in your terminal:
            echo 'eval \$(/opt/homebrew/bin/brew shellenv)' >> ~/.zprofile
            eval \$(/opt/homebrew/bin/brew shellenv)" \
            "command -v brew >/dev/null 2>&1"
    fi
    
    print_section "Phase 3: Essential Package Installation" $PACKAGE
    
    # Homebrew packages
    execute_task "homebrew_packages" "Install essential Homebrew packages" \
        'brew bundle install --file=Brewfile.essentials --no-lock' \
        "Run: brew bundle install --file=Brewfile.essentials --verbose
        If individual packages fail, install them one by one with: brew install <package>"
    
    print_section "Phase 4: Manual Applications" $FOLDER
    
    # This is where we pause for manual app installation
    request_manual_help "Install Manual Applications" \
        "Please install these applications now. I'll wait:
        
        • Raycast: https://raycast.com
        • Warp Terminal: https://warp.dev  
        • Zed Editor: https://zed.dev
        • AltTab: https://alt-tab-macos.netlify.app
        • Bartender 5: https://www.macbartender.com
        • Claude: https://claude.ai/download
        • ChatGPT: https://chatgpt.com/download
        
        Download and install them all before continuing." \
        "ls /Applications/ | grep -E '(Raycast|Warp|Zed|AltTab|Bartender|Claude|ChatGPT)' | wc -l | xargs test 4 -le"
    
    print_section "Phase 5: Configuration Restore" $GEAR
    
    # Dotfiles
    execute_task "dotfiles_restore" "Restore shell and development configs" \
        './scripts/restore-dotfiles.sh' \
        "Manually copy configs from docs/configs/dotfiles/ to your home directory"
    
    # App configurations
    execute_task "app_configs_restore" "Restore application configurations" \
        './scripts/restore-app-configs.sh' \
        "Follow the individual app config steps in MANUAL_RECOVERY.md"
    
    print_section "Phase 6: System Preferences" $COMPUTER
    
    # System preferences
    request_manual_help "System Preferences Setup" \
        "I can apply optimized system preferences for productivity.
        This includes: faster dock, better finder settings, improved keyboard response.
        
        Should I apply these now?" \
        ""
    
    if [[ $? -eq 0 ]]; then
        execute_task "system_prefs" "Apply productivity system preferences" \
            './scripts/setup-system-prefs.sh' \
            "Run individual defaults commands from setup-system-prefs.sh manually"
    fi
    
    # Generate final report
    print_section "Session Complete" $SPARKLES
    generate_report
    
    echo -e "${GREEN}${CHECKMARK} Setup session completed!${NC}"
    echo -e "${BLUE}${INFO} Detailed report saved to:${NC} $REPORT_FILE"
    echo -e "${GRAY}Opening report now...${NC}"
    
    open "$REPORT_FILE"
    
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC} ${SPARKLES} ${WHITE}Your Mac transfer session is complete!${NC}               ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}   Check the detailed report for next steps                   ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Cleanup on exit
trap 'echo -e "\n${YELLOW}Session interrupted. Partial report saved to $REPORT_FILE${NC}"; generate_report; exit 1' INT TERM

# Execute main function
main "$@"