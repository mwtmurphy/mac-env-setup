#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
USERNAME=""
EMAIL=""
INSTALL_WORK_TOOLS=false
DRY_RUN=false
PYTHON_VERSION=""
NON_INTERACTIVE=false
# Latest stable versions as of 2025
PYTHON_313="3.13.6"
PYTHON_312="3.12.11"  
PYTHON_311="3.11.13"
PYTHON_310="3.10.18"
PYTHON_39="3.9.22"
CURRENT_STEP=0
TOTAL_STEPS=13

# Print colored output
print_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

print_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

# Print step progress
print_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "${BLUE}[${CURRENT_STEP}/${TOTAL_STEPS}]${NC} $1"
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi
    print_success "Running on macOS"
}

# Validate email format
validate_email() {
    local email="$1"
    if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --python-version=*)
                PYTHON_VERSION="${1#*=}"
                shift
                ;;
            --work-tools)
                INSTALL_WORK_TOOLS=true
                shift
                ;;
            --no-work-tools)
                INSTALL_WORK_TOOLS=false
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --non-interactive)
                NON_INTERACTIVE=true
                shift
                ;;
            --name=*)
                USERNAME="${1#*=}"
                shift
                ;;
            --email=*)
                EMAIL="${1#*=}"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help information
show_help() {
    echo "Mac Environment Setup Script"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --python-version=VERSION    Specify Python version (e.g., 3.13.6)"
    echo "  --work-tools                Install work tools (1Password, Slack, etc.)"
    echo "  --no-work-tools            Skip work tools installation"
    echo "  --dry-run                  Show what would be installed without executing"
    echo "  --non-interactive          Use defaults, no prompts (requires --name and --email)"
    echo "  --name=NAME                Full name for Git configuration"
    echo "  --email=EMAIL              Email address for Git configuration"
    echo "  -h, --help                 Show this help message"
    echo
    echo "Examples:"
    echo "  $0                                    # Interactive mode"
    echo "  $0 --dry-run                         # Preview what would be installed"
    echo "  $0 --python-version=3.12.11         # Use specific Python version"
    echo "  $0 --work-tools --python-version=3.13.6  # Install work tools with Python 3.13"
    echo "  $0 --non-interactive --name=\"John Doe\" --email=\"john@example.com\" --work-tools"
    echo
}

# Display Python version selection menu
select_python_version() {
    echo
    print_info "Select Python version to install:"
    echo "  1) Python $PYTHON_313 (recommended - active development)"
    echo "  2) Python $PYTHON_312 (stable - security fixes only)"
    echo "  3) Python $PYTHON_311 (stable - security fixes only)"
    echo "  4) Python $PYTHON_310 (stable - security fixes only)"
    echo "  5) Python $PYTHON_39 (stable - security fixes only)"
    echo "  6) Custom version (enter manually)"
    echo
    
    while true; do
        read -r -p "Choose option [1-6]: " choice
        case $choice in
            1) PYTHON_VERSION="$PYTHON_313"; break ;;
            2) PYTHON_VERSION="$PYTHON_312"; break ;;
            3) PYTHON_VERSION="$PYTHON_311"; break ;;
            4) PYTHON_VERSION="$PYTHON_310"; break ;;
            5) PYTHON_VERSION="$PYTHON_39"; break ;;
            6) 
                read -r -p "Enter Python version (e.g., 3.11.5): " custom_version
                if [[ -n "$custom_version" ]]; then
                    PYTHON_VERSION="$custom_version"
                    break
                else
                    print_error "Version cannot be empty"
                fi
                ;;
            *) print_error "Invalid choice. Please select 1-6." ;;
        esac
    done
    
    print_success "Selected Python $PYTHON_VERSION"
}

# Collect user information
collect_user_info() {
    if [[ "$NON_INTERACTIVE" == "true" ]]; then
        # Validate required parameters for non-interactive mode
        if [[ -z "$USERNAME" || -z "$EMAIL" ]]; then
            print_error "Non-interactive mode requires --name and --email parameters"
            exit 1
        fi
        
        if ! validate_email "$EMAIL"; then
            print_error "Invalid email format: $EMAIL"
            exit 1
        fi
        
        # Set default Python version if not specified
        if [[ -z "$PYTHON_VERSION" ]]; then
            PYTHON_VERSION="$PYTHON_313"
        fi
        
        print_info "Non-interactive mode - using provided configuration"
    else
        print_info "Setting up Mac environment - let's collect some information first"
        echo
        
        # Collect and validate name if not provided
        while [[ -z "$USERNAME" ]]; do
            read -r -p "Enter your full name for Git: " USERNAME
            if [[ -z "$USERNAME" ]]; then
                print_error "Name cannot be empty. Please try again."
            fi
        done
        
        # Collect and validate email if not provided
        while [[ -z "$EMAIL" ]] || ! validate_email "$EMAIL"; do
            read -r -p "Enter your email address: " EMAIL
            if [[ -z "$EMAIL" ]]; then
                print_error "Email cannot be empty. Please try again."
            elif ! validate_email "$EMAIL"; then
                print_error "Invalid email format. Please enter a valid email address."
                EMAIL=""
            fi
        done
        
        # Python version selection if not provided
        if [[ -z "$PYTHON_VERSION" ]]; then
            select_python_version
        else
            print_info "Using specified Python version: $PYTHON_VERSION"
        fi
        
        echo
        if [[ "$INSTALL_WORK_TOOLS" == "false" ]]; then
            read -p "Install work tools (1Password, Slack, Zoom, etc.)? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                INSTALL_WORK_TOOLS=true
            fi
        fi
        
        if [[ "$DRY_RUN" == "false" ]]; then
            read -p "Dry run mode (show what would be installed without executing)? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                DRY_RUN=true
                print_warning "DRY RUN MODE: No actual installations will be performed"
            fi
        fi
        
        echo
        read -p "Continue with setup? [Y/n]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_info "Setup cancelled"
            exit 0
        fi
    fi
    
    echo
    print_info "Configuration:"
    echo "  Name: $USERNAME"
    echo "  Email: $EMAIL"
    echo "  Python version: $PYTHON_VERSION"
    echo "  Work tools: $INSTALL_WORK_TOOLS"
    echo "  Dry run: $DRY_RUN"
    echo "  Non-interactive: $NON_INTERACTIVE"
    echo
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    print_step "Installing Xcode Command Line Tools"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would install Xcode Command Line Tools"
        return 0
    fi
    
    if xcode-select -p &> /dev/null; then
        print_success "Xcode Command Line Tools already installed"
    else
        xcode-select --install
        print_warning "Please complete the Xcode installation in the popup window"
        read -r -p "Press Enter once Xcode installation is complete..."
        print_success "Xcode Command Line Tools installed"
    fi
}

# Install and setup Homebrew
install_homebrew() {
    print_step "Installing and configuring Homebrew"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would install Homebrew package manager"
        return 0
    fi
    
    if command -v brew &> /dev/null; then
        print_success "Homebrew already installed"
    else
        print_info "Downloading and installing Homebrew..."
        if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"; then
            print_error "Failed to install Homebrew. Please check your internet connection and try again."
            exit 1
        fi
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            (echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installed and configured"
    fi
}

# Install core development tools
install_core_tools() {
    print_step "Installing core development tools"
    
    local cask_apps=("iterm2" "font-source-code-pro" "visual-studio-code")
    local cli_tools=("zsh" "git" "hugo" "pyenv" "xz" "dockutil" "node")
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would install cask applications: ${cask_apps[*]}"
        print_info "[DRY RUN] Would install CLI tools: ${cli_tools[*]}"
        return 0
    fi
    
    # Install cask applications
    for app in "${cask_apps[@]}"; do
        if ! brew install --cask "$app"; then
            print_warning "Failed to install $app, continuing with other applications..."
        else
            print_success "Installed $app"
        fi
    done
    
    # Install command line tools
    for tool in "${cli_tools[@]}"; do
        if ! brew install "$tool"; then
            print_warning "Failed to install $tool, continuing with other tools..."
        else
            print_success "Installed $tool"
        fi
    done
    
    print_success "Core development tools installation completed"
}

# Install Claude Code CLI
install_claude_code() {
    print_step "Installing Claude Code CLI"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would install Claude Code CLI via npm"
        return 0
    fi
    
    if command -v claude &> /dev/null; then
        print_success "Claude Code already installed"
    else
        if ! npm install -g @anthropic-ai/claude-code; then
            print_error "Failed to install Claude Code CLI"
            print_warning "Continuing without Claude Code. You can install it manually later with: npm install -g @anthropic-ai/claude-code"
            return 1
        fi
        print_success "Claude Code CLI installed"
    fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
    print_step "Installing Oh My Zsh shell framework"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would install Oh My Zsh shell framework"
        return 0
    fi
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh already installed"
    else
        if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended; then
            print_error "Failed to install Oh My Zsh. Please check your internet connection."
            print_warning "Continuing without Oh My Zsh installation..."
            return 1
        fi
        print_success "Oh My Zsh installed"
    fi
}

# Configure shell
configure_shell() {
    print_step "Configuring shell environment"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would configure shell with Oh My Zsh theme and environment variables"
        return 0
    fi
    
    # Backup existing .zshrc if it exists
    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.backup."$(date +%Y%m%d_%H%M%S)"
        print_info "Backed up existing .zshrc"
    fi
    
    # Create/update .zshrc
    cat >> ~/.zshrc << 'EOF'

# Homebrew
export HOMEBREW_NO_ENV_HINTS=true

# Oh My Zsh theme
ZSH_THEME="essembeh"

# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Poetry
export PATH="$HOME/.local/bin:$PATH"
EOF
    
    print_success "Shell configured"
}

# Install core applications
install_core_apps() {
    print_step "Installing core applications"
    
    local core_apps=("adobe-acrobat-reader" "google-chrome" "google-drive" "lastpass" "logi-options-plus" "obsidian" "spotify")
    local failed_apps=()
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would install core applications: ${core_apps[*]}"
        return 0
    fi
    
    for app in "${core_apps[@]}"; do
        if ! brew install --cask "$app"; then
            print_warning "Failed to install $app"
            failed_apps+=("$app")
        else
            print_success "Installed $app"
        fi
    done
    
    if [ ${#failed_apps[@]} -eq 0 ]; then
        print_success "All core applications installed successfully"
    else
        print_warning "Some applications failed to install: ${failed_apps[*]}"
        print_info "You can try installing them manually later with: brew install --cask <app-name>"
    fi
}

# Setup Python environment
setup_python() {
    print_step "Setting up Python $PYTHON_VERSION environment"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would install Python $PYTHON_VERSION via pyenv"
        print_info "[DRY RUN] Would install Poetry package manager"
        return 0
    fi
    
    # Install specified Python version
    if pyenv versions | grep -q "$PYTHON_VERSION"; then
        print_success "Python $PYTHON_VERSION already installed"
    else
        if ! pyenv install "$PYTHON_VERSION"; then
            print_error "Failed to install Python $PYTHON_VERSION"
            print_warning "Continuing without Python setup. You may need to install Python manually."
            return 1
        fi
        print_success "Python $PYTHON_VERSION installed"
    fi
    
    if ! pyenv global "$PYTHON_VERSION"; then
        print_warning "Failed to set Python $PYTHON_VERSION as global version"
    fi
    
    # Install Poetry
    if command -v poetry &> /dev/null; then
        print_success "Poetry already installed"
    else
        if ! curl -sSL https://install.python-poetry.org | python3 -; then
            print_error "Failed to install Poetry"
            print_warning "Continuing without Poetry. You can install it manually later."
            return 1
        fi
        print_success "Poetry installed"
    fi
}

# Configure Git and SSH
configure_git_ssh() {
    print_step "Configuring Git and SSH keys"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would configure Git with name: $USERNAME, email: $EMAIL"
        print_info "[DRY RUN] Would generate SSH key for GitHub authentication"
        return 0
    fi
    
    # Configure Git
    git config --global user.name "$USERNAME"
    git config --global user.email "$EMAIL"
    print_success "Git configured with name: $USERNAME, email: $EMAIL"
    
    # Generate SSH key if it doesn't exist
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519 -N ""
        print_success "SSH key generated"
    else
        print_success "SSH key already exists"
    fi
    
    # Start SSH agent and add key
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    
    # Create SSH config
    mkdir -p ~/.ssh
    cat >> ~/.ssh/config << EOF
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
    
    # Copy SSH key to clipboard
    pbcopy < ~/.ssh/id_ed25519.pub
    print_success "SSH key copied to clipboard"
    print_warning "Don't forget to add this SSH key to your GitHub account!"
}

# Install VS Code extensions
install_vscode_extensions() {
    print_step "Installing VS Code extensions"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would install VS Code extensions: Python, GitHub, Markdown, Icons, Cloud Code"
        return 0
    fi
    
    code --install-extension ms-python.python
    code --install-extension GitHub.vscode-pull-request-github
    code --install-extension shd101wyy.markdown-preview-enhanced
    code --install-extension vscode-icons-team.vscode-icons
    code --install-extension GoogleCloudTools.cloudcode
    
    print_success "VS Code extensions installed"
}

# Configure VS Code settings
configure_vscode_settings() {
    print_step "Configuring VS Code settings"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would configure VS Code with rulers, themes, and Python settings"
        return 0
    fi
    
    # Create VS Code user settings directory
    local vscode_dir="$HOME/Library/Application Support/Code/User"
    mkdir -p "$vscode_dir"
    
    # Backup existing settings if they exist
    if [ -f "$vscode_dir/settings.json" ]; then
        cp "$vscode_dir/settings.json" "$vscode_dir/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backed up existing VS Code settings"
    fi
    
    # Create settings.json with common preferences
    cat > "$vscode_dir/settings.json" << EOF
{
    "editor.rulers": [70, 100],
    "workbench.iconTheme": "vscode-icons",
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "editor.detectIndentation": true,
    "editor.trimAutoWhitespace": true,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "files.trimFinalNewlines": true,
    "editor.formatOnSave": true,
    "editor.wordWrap": "bounded",
    "editor.wordWrapColumn": 100,
    "python.defaultInterpreterPath": "~/.pyenv/shims/python",
    "python.terminal.activateEnvironment": true,
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "git.autofetch": true,
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.fontSize": 12,
    "workbench.startupEditor": "welcomePage",
    "explorer.confirmDelete": false,
    "explorer.confirmDragAndDrop": false,
    "markdown.preview.fontSize": 14,
    "editor.minimap.enabled": true,
    "editor.lineNumbers": "on",
    "editor.renderWhitespace": "boundary",
    "workbench.colorTheme": "Default Dark Modern"
}
EOF
    
    print_success "VS Code settings configured"
}

# Install work tools (optional)
install_work_tools() {
    if [ "$INSTALL_WORK_TOOLS" = true ]; then
        print_step "Installing work tools"
        
        local work_apps=("1password" "google-cloud-sdk" "loom" "notion" "slack" "zoom")
        local failed_work_apps=()
        
        if [[ "$DRY_RUN" == "true" ]]; then
            print_info "[DRY RUN] Would install work applications: ${work_apps[*]}"
            return 0
        fi
        
        for app in "${work_apps[@]}"; do
            if ! brew install --cask "$app"; then
                print_warning "Failed to install $app"
                failed_work_apps+=("$app")
            else
                print_success "Installed $app"
            fi
        done
        
        # Add Google Cloud SDK to shell if it was installed successfully
        if [ -f "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc" ]; then
            cat >> ~/.zshrc << 'EOF'

# Google Cloud SDK
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
EOF
            print_success "Google Cloud SDK added to shell configuration"
        fi
        
        if [ ${#failed_work_apps[@]} -eq 0 ]; then
            print_success "All work tools installed successfully"
        else
            print_warning "Some work tools failed to install: ${failed_work_apps[*]}"
            print_info "You can try installing them manually later with: brew install --cask <app-name>"
        fi
        
        print_warning "Run 'gcloud auth application-default login' after setup to authenticate Google Cloud"
    else
        print_step "Skipping work tools installation"
    fi
}

# Configure dock with dockutil
configure_dock() {
    print_step "Configuring dock layout"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would configure dock with pinned applications"
        return 0
    fi
    
    if ! command -v dockutil &> /dev/null; then
        print_warning "dockutil not found, skipping dock configuration"
        return 1
    fi
    
    # Remove default dock items that aren't needed
    local default_apps=("Launchpad" "Safari" "Mail" "FaceTime" "Messages" "Maps" "Photos" "Contacts" "Calendar" "Reminders" "Notes" "Freeform" "TV" "Music" "Podcasts" "News" "App Store")
    
    for app in "${default_apps[@]}"; do
        if dockutil --list | grep -q "$app"; then
            dockutil --remove "$app" --no-restart 2>/dev/null || true
        fi
    done
    
    # Add our preferred applications in order
    local dock_apps=("Visual Studio Code" "Google Chrome" "Spotify" "Obsidian")
    
    # Add work tools to dock if they were installed
    if [ "$INSTALL_WORK_TOOLS" = true ]; then
        dock_apps+=("Slack" "Zoom" "Notion")
    fi
    
    # Remove existing instances and add in correct order
    for app in "${dock_apps[@]}"; do
        # Remove if it exists
        dockutil --remove "$app" --no-restart 2>/dev/null || true
        
        # Add to dock if application exists
        local app_path="/Applications/${app}.app"
        if [ -d "$app_path" ]; then
            dockutil --add "$app_path" --no-restart 2>/dev/null || print_warning "Could not add $app to dock"
        fi
    done
    
    # Restart dock to apply changes
    killall Dock 2>/dev/null || true
    
    print_success "Dock configured with pinned applications"
}

# Display manual setup reminders
show_manual_steps() {
    print_step "Displaying manual setup instructions"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Setup preview completed!"
        print_warning "Run the script without dry-run mode to perform actual installations"
        return 0
    fi
    
    print_info "Setup complete! Here are the manual steps you still need to do:"
    echo
    echo "System Settings:"
    echo "• User & Groups > Set user image"
    echo "• Displays > Night shift > Sunset to sunrise"
    echo "• Bluetooth > Connect keyboard, mouse and headphones"
    echo "• Desktop & Dock > Position: Left, Minimise into app: True, Auto-hide: False"
    echo "• Privacy & Security > App Management > Add iTerm"
    echo
    echo "iTerm2 Configuration:"
    echo "• Settings > Profiles > Text > Font: Source Code Pro, size 12"
    echo "• Settings > Profiles > Colors > Preset: 3024_night.itermcolors"
    echo "• Settings > Profiles > Colors > Cursor colors: Yellow"
    echo
    echo "Application Setup:"
    echo "• Dock has been automatically configured with essential applications"
    echo "• Sign in to: LastPass, Chrome, Spotify, Google Drive"
    if [ "$INSTALL_WORK_TOOLS" = true ]; then
        echo "• Sign in to: 1Password, Loom, Notion, Slack, Zoom"
    fi
    echo "• Logi+ > Setup mouse and keyboard"
    echo "• Obsidian > Load commonplace vault from Google Drive"
    echo
    echo "Development:"
    echo "• Add SSH key to GitHub account (already copied to clipboard)"
    echo "• VS Code has been automatically configured with rulers, themes, and settings"
    if [ "$INSTALL_WORK_TOOLS" = true ]; then
        echo "• Run: gcloud auth application-default login"
    fi
    echo
    echo "Optional:"
    echo "• System Settings > Wallpaper > Set to mac_background.heic"
    if [ "$INSTALL_WORK_TOOLS" = true ]; then
        echo "• Zoom > Settings > Background > Set to zoom_background.png"
    fi
    echo
    print_success "Restart your terminal to apply all shell changes!"
}

# Main execution
main() {
    # Parse command line arguments first
    parse_arguments "$@"
    
    echo "============================================"
    echo "     Mac Environment Setup Script"
    echo "============================================"
    echo
    
    check_macos
    collect_user_info
    
    echo
    print_info "Starting automated setup..."
    echo
    
    install_xcode_tools
    install_homebrew
    install_core_tools
    install_claude_code
    install_oh_my_zsh
    configure_shell
    install_core_apps
    setup_python
    configure_git_ssh
    install_vscode_extensions
    configure_vscode_settings
    install_work_tools
    configure_dock
    
    echo
    print_success "Automated setup completed!"
    echo
    
    show_manual_steps
}

# Run the script
main "$@"