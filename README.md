# Mac Environment Setup

This repository contains an automated setup script for configuring a new Mac development environment. Run `./setup.sh` to automatically install and configure most development tools, then follow the manual steps below.

## Quick Start

1. **Run the automated setup script:**
   ```bash
   git clone https://github.com/mwtmurphy/mac-env-setup.git
   cd mac-env-setup
   ./setup.sh
   ```

2. **Follow the manual configuration steps** listed at the bottom of this README

## What Gets Automated

The `setup.sh` script will automatically:
- Install Xcode Command Line Tools and Homebrew
- Install core development tools (iTerm2, VS Code, Git, Python, GitHub CLI, etc.)
- Install Claude Code CLI for AI-powered development
- Configure Claude Code with development templates and settings
- Configure your shell with Oh My Zsh, productivity plugins, and custom settings
- Install essential applications via Homebrew
- Set up Python environment with pyenv and Poetry (interactive version selection)
- Configure Git with your name/email and generate SSH keys
- Install VS Code extensions
- Optionally install work tools (1Password, Slack, Zoom, etc.)

## Automated Installation Details

### Core Development Tools Installation
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/{user}/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install core applications
brew install --cask iterm2 font-source-code-pro visual-studio-code
brew install zsh git hugo pyenv xz node gh tree

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

### Claude Code CLI Installation
```bash
# Install Claude Code CLI via npm
npm install -g @anthropic-ai/claude-code
```

### Claude Code Configuration
```bash
# Create configuration directory
mkdir -p ~/.claude

# Create user settings with development-friendly defaults
# Uses template file: templates/claude-settings-template.json
cp templates/claude-settings-template.json ~/.claude/settings.json

# Create project template for CLAUDE.md files
cp CLAUDE_PROJECT_TEMPLATE.md ~/CLAUDE_PROJECT_TEMPLATE.md
```

The setup script uses the included `templates/claude-settings-template.json` file which provides:
- Comprehensive tool permissions for development tasks
- Proper hooks configuration for Claude Code validation
- Python/SQL development focus matching the project template

### Zsh Plugins Installation
```bash
# Install zsh-autosuggestions (command completion based on history)
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting (real-time command syntax validation)
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

### Shell Configuration
```bash
# Add to ~/.zshrc
export HOMEBREW_NO_ENV_HINTS=true

# Set Oh My Zsh theme
ZSH_THEME="essembeh"

# Oh My Zsh plugins for enhanced shell experience
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Add pyenv initialization
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Add Poetry to PATH
export PATH="$HOME/.local/bin:$PATH"
```

### Core Applications
```bash
brew install --cask adobe-acrobat-reader google-chrome google-drive lastpass logi-options-plus obsidian spotify
```

### Python Environment Setup
```bash
# Install your selected Python version (default: 3.13.6)
pyenv install {selected_version}
pyenv global {selected_version}

# Install Poetry package manager with retry mechanism
# The script automatically retries up to 3 times with exponential backoff
curl -sSL --connect-timeout 30 --max-time 300 https://install.python-poetry.org | python3 -
export PATH="$HOME/.local/bin:$PATH"  # Update PATH for current session
poetry --version  # Verify installation
```

**Available Python Versions:**
- Python 3.13.6 (recommended - active development) 
- Python 3.12.11 (stable - security fixes only)
- Python 3.11.13 (stable - security fixes only) 
- Python 3.10.18 (stable - security fixes only)
- Python 3.9.22 (stable - security fixes only)
- Custom version (enter manually during setup)

**Python Version Selection Process:**
During the setup, you'll be prompted to choose your preferred Python version:
1. **Interactive Mode**: Choose from 5 predefined versions or enter a custom version
2. **Non-Interactive Mode**: Defaults to Python 3.13.6 (recommended) unless `--python-version` is specified
3. **Command Line Override**: Use `--python-version=X.Y.Z` to specify any version directly

Examples:
```bash
./setup.sh --python-version=3.11.13          # Use specific version
./setup.sh --non-interactive                 # Use default (3.13.6)
./setup.sh                                   # Interactive selection menu
```

### Git and SSH Configuration
```bash
git config --global user.name "{username}"
git config --global user.email "{email}"
ssh-keygen -t ed25519 -C "{email}"
eval "$(ssh-agent -s)"

# Create SSH config
cat >> ~/.ssh/config << EOF
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF

# Copy SSH key to clipboard
pbcopy < ~/.ssh/id_ed25519.pub
```

### VS Code Extensions
```bash
code --install-extension ms-python.python
code --install-extension GitHub.vscode-pull-request-github
code --install-extension shd101wyy.markdown-preview-enhanced
code --install-extension vscode-icons-team.vscode-icons
code --install-extension GoogleCloudTools.cloudcode
```

### Optional Work Tools
```bash
brew install --cask 1password google-cloud-sdk loom notion slack zoom
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
```

### Google Cloud Setup
```bash
gcloud auth application-default login
gcloud auth application-default set-quota-project
```

---

## What to Do After Running the Setup Script

After `./setup.sh` completes successfully, you'll need to manually configure the following:

### 1. Application Setup
- **Pin to Dock**: VS Code, Spotify, Chrome, Obsidian (+ Notion, Slack, Zoom if work tools installed)
- **Sign in** to all applications:
  - LastPass (install Rosetta 2 if prompted)
  - Google Chrome
  - Spotify
  - Google Drive (set `commonplace` folder as available offline)
  - 1Password, Loom, Notion, Slack, Zoom (if work tools were installed)
- **Logitech Options+** → Configure mouse and keyboard settings for Mac and Chrome
- **Obsidian** → Load your commonplace vault from Google Drive

### 2. System Settings
- **User & Groups** → Set your user profile image
- **Displays** → Night Shift → Set to "Sunset to Sunrise"
- **Bluetooth** → Connect your keyboard, mouse, and headphones
- **Desktop & Dock** → Configure:
  - Position on screen: Left
  - Minimize windows into application icon: Enable
  - Automatically hide and show the Dock: Disable
- **Privacy & Security** → App Management → Add iTerm2 for app management permissions

### 3. iTerm2 Configuration
- Open **iTerm2** → Preferences → Profiles → Default
- **Text** tab → Set font to "Source Code Pro", size 12
- **Colors** tab → Import and select `3024_night.itermcolors` color preset
- **Colors** tab → Set cursor and cursor text colors to yellow

### 4. Development Setup
- **GitHub** → Add the SSH key to your GitHub account:
  - The setup script automatically copies your SSH key to the clipboard
  - If clipboard method failed, manually copy with: `pbcopy < ~/.ssh/id_ed25519.pub`
  - Go to GitHub → Settings → SSH and GPG keys → New SSH key
  - Paste the key and give it a descriptive title
  - Test connection: `ssh -T git@github.com`
- **Claude Code** → Complete authentication and GitHub integration:
  - Run `claude login` to authenticate with your Anthropic account
  - For GitHub integration: `claude /install-github-app` (optional but recommended)
  - This enables Claude to respond to @mentions in GitHub PRs and issues
  - Configure repository secrets with your Anthropic API key if using GitHub Actions
  - Copy `~/CLAUDE_PROJECT_TEMPLATE.md` to your project root as `CLAUDE.md` and customize
- **VS Code** → Automatically configured by the setup script with Claude Code optimizations and development settings
- **Google Cloud** (if work tools installed) → Run: `gcloud auth application-default login`

### 5. Optional Customization
- **Wallpaper** → Set desktop background to `mac_dynamic_background.heic`
- **Video Call Backgrounds** → Set virtual background to `video_call_background.png`:
  - **Zoom** → Settings → Background & Effects → Virtual Backgrounds → Add Image
  - **Google Meet** → Settings → Video → Background → Upload Image

### 6. Final Step
**Restart your terminal** to ensure all shell configuration changes take effect.

---

## Troubleshooting

### Common Issues and Solutions

#### Script fails to run
**Problem**: `./setup.sh: Permission denied`  
**Solution**: Make the script executable with `chmod +x setup.sh`

#### Homebrew installation fails
**Problem**: Network connection issues or permission problems  
**Solutions**:
- Check your internet connection
- Try running the Homebrew installation manually: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Ensure you have admin privileges on your Mac

#### Individual app installations fail
**Problem**: Specific brew cask installations fail  
**Solutions**:
- Update Homebrew: `brew update`
- Try installing individual apps manually: `brew install --cask <app-name>`
- Some apps might not be available in your region or have licensing restrictions

#### Python installation via pyenv fails
**Problem**: pyenv install fails with compilation errors  
**Solutions**:
- Install required dependencies: `brew install openssl readline sqlite3 xz zlib`
- Try a different Python version (older versions like 3.11.x often have fewer compilation issues)
- For Apple Silicon Macs, ensure you're using compatible Python versions
- Check [pyenv common build problems](https://github.com/pyenv/pyenv/wiki/Common-build-problems)
- Re-run the script and select a different version from the interactive menu

#### Poetry installation fails
**Problem**: Poetry installation fails during setup or times out  
**Solutions**:
- The script automatically retries 3 times with increasing delays (5s, 10s, 15s)
- Check your internet connection and try again
- Verify you can reach https://install.python-poetry.org in your browser
- For corporate networks, check if proxy settings are required:
  ```bash
  export https_proxy=your_proxy_url
  export http_proxy=your_proxy_url
  ```
- Manual installation if script continues to fail:
  ```bash
  curl -sSL https://install.python-poetry.org | python3 -
  export PATH="$HOME/.local/bin:$PATH"
  poetry --version  # Verify installation
  ```
- If PATH issues persist, add to your shell configuration:
  ```bash
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
  ```

#### Oh My Zsh installation fails
**Problem**: Network issues or existing zsh configuration conflicts  
**Solutions**:
- Check internet connection
- Try manual installation: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- Remove existing `.oh-my-zsh` directory if corrupted: `rm -rf ~/.oh-my-zsh`

#### SSH key not working with GitHub
**Problem**: Git operations still prompt for password  
**Solutions**:
- Ensure SSH key was added to GitHub account
- Test SSH connection: `ssh -T git@github.com`
- Check SSH agent is running: `ssh-add -l`
- Re-add key to SSH agent: `ssh-add ~/.ssh/id_ed25519`

#### VS Code extensions fail to install
**Problem**: Extensions don't install automatically  
**Solutions**:
- Install manually through VS Code Extensions marketplace
- Check VS Code command line tool is available: `code --version`
- Restart VS Code and try again

#### Terminal settings not applied
**Problem**: Shell configuration changes don't take effect  
**Solutions**:
- Restart your terminal application completely
- Source the configuration manually: `source ~/.zshrc`
- Check for syntax errors in `.zshrc`: `zsh -n ~/.zshrc`

### Getting Help

If you encounter issues not covered here:
1. **Check the script output** - Error messages usually indicate the specific problem
2. **Try dry-run mode** - Run `./setup.sh` and choose dry-run to preview what would be installed
3. **Run individual steps manually** - You can execute specific brew commands or installations manually
4. **Check system requirements** - Ensure you're running a supported version of macOS
5. **Report issues** - Create an issue in this repository with your error messages and system details

---

## Links
- [Sourabh Bajaj macOS setup](https://sourabhbajaj.com/mac-setup/) (last accessed 2023-11-28)
- [Hypermodern Python](https://cjolowicz.github.io/posts/hypermodern-python-01-setup/) (last accessed 2023-11-29)