# Mac Environment Setup

This repository contains an automated setup script for configuring a new Mac development environment. Run `./setup.sh` to automatically install and configure most development tools, then follow the manual steps below.

## Quick Start

1. **Run the automated setup script:**
   ```bash
   git clone <this-repo>
   cd mac-env-setup
   ./setup.sh
   ```

2. **Follow the manual configuration steps** listed at the bottom of this README

## What Gets Automated

The `setup.sh` script will automatically:
- Install Xcode Command Line Tools and Homebrew
- Install core development tools (iTerm2, VS Code, Git, Python, etc.)
- Configure your shell with Oh My Zsh and custom settings
- Install essential applications via Homebrew
- Set up Python environment with pyenv and Poetry
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
brew install zsh git hugo pyenv xz

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

### Shell Configuration
```bash
# Add to ~/.zshrc
export HOMEBREW_NO_ENV_HINTS=true

# Set Oh My Zsh theme
ZSH_THEME="essembeh"

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
pyenv install 3.10.12
pyenv global 3.10.12
curl -sSL https://install.python-poetry.org | python3 -
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

## Manual Steps (Require user interaction)

### System Settings
1. **User & Groups** > Set user image
2. **Displays** > Night shift > Sunset to sunrise
3. **Bluetooth** > Connect keyboard, mouse and headphones
4. **Desktop & Dock**
   - Position on screen > Left
   - Minimise into application > True
   - Automatically hide and show the dock > False
5. **Privacy & Security** > App Management > Add iTerm for app management

### iTerm2 Configuration
1. **iTerm2** > Settings > Profiles
   - **Text** > Set font to `Source Code Pro` size 12
   - **Colors** > Set colour preset to `3024_night.itermcolors`
   - **Colors** > Set cursor and cursor text colour to yellow

### Application Setup and Sign-ins
1. **Finder** > Applications > Uninstall apps which can be managed through Homebrew
2. **Pin to dock**: VSCode, Spotify, Chrome, Obsidian (+ Notion, Slack, Zoom if installed)
3. **Sign in to applications**:
   - LastPass (Install Rosetta when prompted)
   - Chrome
   - Spotify
   - Google Drive > Set `commonplace` folder as offline ready
   - 1Password, Loom, Notion, Slack, Zoom (if work tools installed)
4. **Logi+** > Setup mouse and keyboard for Mac and Chrome
5. **Obsidian** > Load commonplace vault from Google Drive

### GitHub SSH Key
1. Add SSH key to GitHub account (key already copied to clipboard)

### VS Code Settings
1. **Settings** > Set rulers at 70 (comments) and 100 (code)
2. Open `vscode-icons` extension and set file icon theme

### Backgrounds
1. **System Settings** > Wallpaper > Set to `mac_background.heic`
2. **Zoom** > Settings > Background > Set to `zoom_background.png` (if Zoom installed)

---

## What to Do After Running the Setup Script

After `./setup.sh` completes successfully, you'll need to manually configure the following:

### 1. System Settings
- **User & Groups** → Set your user profile image
- **Displays** → Night Shift → Set to "Sunset to Sunrise"
- **Bluetooth** → Connect your keyboard, mouse, and headphones
- **Desktop & Dock** → Configure:
  - Position on screen: Left
  - Minimize windows into application icon: Enable
  - Automatically hide and show the Dock: Disable
- **Privacy & Security** → App Management → Add iTerm2 for app management permissions

### 2. iTerm2 Configuration
- Open **iTerm2** → Preferences → Profiles → Default
- **Text** tab → Set font to "Source Code Pro", size 12
- **Colors** tab → Import and select `3024_night.itermcolors` color preset
- **Colors** tab → Set cursor and cursor text colors to yellow

### 3. Application Setup
- **Pin to Dock**: VS Code, Spotify, Chrome, Obsidian (+ Notion, Slack, Zoom if work tools installed)
- **Sign in** to all applications:
  - LastPass (install Rosetta 2 if prompted)
  - Google Chrome
  - Spotify
  - Google Drive (set `commonplace` folder as available offline)
  - 1Password, Loom, Notion, Slack, Zoom (if work tools were installed)
- **Logitech Options+** → Configure mouse and keyboard settings for Mac and Chrome
- **Obsidian** → Load your commonplace vault from Google Drive

### 4. Development Setup
- **GitHub** → Add the SSH key to your GitHub account (already copied to clipboard by the script)
- **VS Code** → Settings:
  - Set rulers at columns 70 (comments) and 100 (code)
  - Open vscode-icons extension and set as file icon theme
- **Google Cloud** (if work tools installed) → Run: `gcloud auth application-default login`

### 5. Optional Customization
- **Wallpaper** → Set desktop background to `mac_background.heic`
- **Zoom Background** → Set virtual background to `zoom_background.png` (if Zoom installed)

### 6. Final Step
**Restart your terminal** to ensure all shell configuration changes take effect.

---

## Links
[Sourabh Bajaj macOS setup](https://sourabhbajaj.com/mac-setup/) (last accessed 2023-11-28)
[Hypermodern Python](https://cjolowicz.github.io/posts/hypermodern-python-01-setup/) (last accessed 2023-11-29)