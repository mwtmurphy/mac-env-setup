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

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi
    print_success "Running on macOS"
}

# Collect user information
collect_user_info() {
    print_info "Setting up Mac environment - let's collect some information first"
    echo
    
    read -r -p "Enter your full name for Git: " USERNAME
    read -r -p "Enter your email address: " EMAIL
    echo
    
    read -p "Install work tools (1Password, Slack, Zoom, etc.)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_WORK_TOOLS=true
    fi
    
    echo
    print_info "Configuration:"
    echo "  Name: $USERNAME"
    echo "  Email: $EMAIL"
    echo "  Work tools: $INSTALL_WORK_TOOLS"
    echo
    
    read -p "Continue with setup? [Y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Setup cancelled"
        exit 0
    fi
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    print_info "Installing Xcode Command Line Tools..."
    
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
    print_info "Installing Homebrew..."
    
    if command -v brew &> /dev/null; then
        print_success "Homebrew already installed"
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        
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
    print_info "Installing core development tools..."
    
    # Install applications
    brew install --cask iterm2 font-source-code-pro visual-studio-code
    brew install zsh git hugo pyenv xz
    
    print_success "Core development tools installed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    print_info "Installing Oh My Zsh..."
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh already installed"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    fi
}

# Configure shell
configure_shell() {
    print_info "Configuring shell..."
    
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
    print_info "Installing core applications..."
    
    brew install --cask adobe-acrobat-reader google-chrome google-drive lastpass logi-options-plus obsidian spotify
    
    print_success "Core applications installed"
}

# Setup Python environment
setup_python() {
    print_info "Setting up Python environment..."
    
    # Install Python 3.10.12
    if pyenv versions | grep -q "3.10.12"; then
        print_success "Python 3.10.12 already installed"
    else
        pyenv install 3.10.12
        print_success "Python 3.10.12 installed"
    fi
    
    pyenv global 3.10.12
    
    # Install Poetry
    if command -v poetry &> /dev/null; then
        print_success "Poetry already installed"
    else
        curl -sSL https://install.python-poetry.org | python3 -
        print_success "Poetry installed"
    fi
}

# Configure Git and SSH
configure_git_ssh() {
    print_info "Configuring Git and SSH..."
    
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
    print_info "Installing VS Code extensions..."
    
    code --install-extension ms-python.python
    code --install-extension GitHub.vscode-pull-request-github
    code --install-extension shd101wyy.markdown-preview-enhanced
    code --install-extension vscode-icons-team.vscode-icons
    code --install-extension GoogleCloudTools.cloudcode
    
    print_success "VS Code extensions installed"
}

# Install work tools (optional)
install_work_tools() {
    if [ "$INSTALL_WORK_TOOLS" = true ]; then
        print_info "Installing work tools..."
        
        brew install --cask 1password google-cloud-sdk loom notion slack zoom
        
        # Add Google Cloud SDK to shell
        if [ -f "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc" ]; then
            cat >> ~/.zshrc << 'EOF'

# Google Cloud SDK
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
EOF
        fi
        
        print_success "Work tools installed"
        print_warning "Run 'gcloud auth application-default login' after setup to authenticate Google Cloud"
    else
        print_info "Skipping work tools installation"
    fi
}

# Display manual setup reminders
show_manual_steps() {
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
    echo "• Pin to dock: VSCode, Spotify, Chrome, Obsidian"
    if [ "$INSTALL_WORK_TOOLS" = true ]; then
        echo "• Pin to dock: Notion, Slack, Zoom"
    fi
    echo "• Sign in to: LastPass, Chrome, Spotify, Google Drive"
    if [ "$INSTALL_WORK_TOOLS" = true ]; then
        echo "• Sign in to: 1Password, Loom, Notion, Slack, Zoom"
    fi
    echo "• Logi+ > Setup mouse and keyboard"
    echo "• Obsidian > Load commonplace vault from Google Drive"
    echo
    echo "Development:"
    echo "• Add SSH key to GitHub account (already copied to clipboard)"
    echo "• VS Code > Settings > Rulers at 70 and 100"
    echo "• VS Code > Set vscode-icons as file icon theme"
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
    install_oh_my_zsh
    configure_shell
    install_core_apps
    setup_python
    configure_git_ssh
    install_vscode_extensions
    install_work_tools
    
    echo
    print_success "Automated setup completed!"
    echo
    
    show_manual_steps
}

# Run the script
main