#!/bin/bash

#
# ███╗   ███╗ █████╗  ██████╗     ███████╗███████╗████████╗██╗   ██╗██████╗ 
# ████╗ ████║██╔══██╗██╔════╝     ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
# ██╔████╔██║███████║██║  ███╗    ███████╗█████╗     ██║   ██║   ██║██████╔╝
# ██║╚██╔╝██║██╔══██║██║   ██║    ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
# ██║ ╚═╝ ██║██║  ██║╚██████╔╝    ███████║███████╗   ██║   ╚██████╔╝██║     
# ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝     ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
#                                                                          

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

# Animation functions
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep -w $pid)" ]; do
    local temp=${spinstr#?}
    printf "${YELLOW}[%c]${RESET} " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

progress_bar() {
  local title=$1
  echo -e "${CYAN}$title${RESET}"
  for i in {1..30}; do
    echo -ne "${GREEN}█${RESET}"
    sleep 0.03
  done
  echo -e " ${GREEN}Done!${RESET}"
}

# Section headers
print_section() {
  echo ""
  echo -e "${PURPLE}╔═════════════════════════════════════════════════════╗${RESET}"
  echo -e "${PURPLE}║${RESET} ${BOLD}${CYAN}$1${RESET}${PURPLE} ${RESET}"
  echo -e "${PURPLE}╚═════════════════════════════════════════════════════╝${RESET}"
}

# Success and error messages
success() {
  echo -e "${GREEN}✓ $1${RESET}"
}

info() {
  echo -e "${CYAN}ℹ $1${RESET}"
}

warn() {
  echo -e "${YELLOW}⚠ $1${RESET}"
}

error() {
  echo -e "${RED}✗ $1${RESET}"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to handle errors
handle_error() {
  error "$1"
  exit 1
}

# Welcome message
clear
echo -e "${BLUE}${BOLD}"
echo -e "Welcome to your macOS setup script!"
echo -e "${RESET}"
sleep 1
progress_bar "Initializing..."

# This is a script to install all the necessary tools for my macos machine

# Install Oh My Zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || handle_error "Failed to install Oh My Zsh"
  # Note: Oh My Zsh installation script may change the shell, we'll continue with our script
else
  echo "Oh My Zsh is already installed."
fi

# Install Homebrew if not installed
if ! command_exists brew; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || handle_error "Failed to install Homebrew"

  # Add Homebrew to PATH if not already configured
  if ! grep -q "brew shellenv" ~/.zprofile; then
    echo "Adding Homebrew to PATH in ~/.zprofile..."
    echo >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  fi
  
  eval "$(/opt/homebrew/bin/brew shellenv)"
  
  # We don't source ~/.zshrc here as it might not work in non-interactive shells
  # Instead, we'll export any needed variables directly
else
  echo "Homebrew is already installed."
fi

# Install fnm (Fast Node Manager)
if ! command_exists fnm; then
  echo "Installing fnm..."
  curl -fsSL https://fnm.vercel.app/install | bash || handle_error "Failed to install fnm"

  # Add fnm configuration to .zshrc
  if ! grep -q "fnm env --use-on-cd" ~/.zshrc; then
    echo 'eval "$(fnm env --use-on-cd --shell zsh)"' >> ~/.zshrc
    echo "Added fnm configuration to .zshrc"
  fi

  # Instead of sourcing .zshrc, use the env command directly for this session
  eval "$(fnm env --use-on-cd --shell zsh)" 2>/dev/null || true
  fnm install --lts || echo "Note: fnm is installed but couldn't install Node.js LTS. Please run 'fnm install --lts' manually after script completion."
else
  echo "fnm is already installed."
fi

#
# Development Tools
#

# Install Cursor (Code Editor)
if ! command_exists cursor; then
  echo "Installing Cursor..."
  brew install --cask cursor || handle_error "Failed to install Cursor"
else
  echo "Cursor is already installed."
fi

# Install Windsurf
if ! command_exists windsurf; then
  echo "Installing Windsurf..."
  brew install --cask windsurf || handle_error "Failed to install Windsurf"
else
  echo "Windsurf is already installed."
fi

# Install Docker
if ! command_exists docker; then
  echo "Installing Docker..."
  brew install --cask docker || handle_error "Failed to install Docker"
else
  echo "Docker is already installed."
fi

# Install Google Chrome
if [ ! -d "/Applications/Google Chrome.app" ]; then
  echo "Installing Google Chrome..."
  brew install --cask google-chrome || handle_error "Failed to install Google Chrome"
else
  echo "Google Chrome is already installed."
fi

# Install Python for AI Engineering
if command_exists python3; then
  PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
  echo "Python $PYTHON_VERSION is already installed."
else
  echo "Installing Python..."
  brew install python || handle_error "Failed to install Python"
fi


echo "Python setup complete. To create and use a virtual environment:"
echo "  python3 -m venv myproject"
echo "  source myproject/bin/activate"
echo "  pip install numpy pandas matplotlib scikit-learn torch tensorflow"

# Install Postman
if [ ! -d "/Applications/Postman.app" ]; then
  echo "Installing Postman..."
  brew install --cask postman || handle_error "Failed to install Postman"
else
  echo "Postman is already installed."
fi

# Install GitKraken
if [ ! -d "/Applications/GitKraken.app" ]; then
  echo "Installing GitKraken..."
  brew install --cask gitkraken || handle_error "Failed to install GitKraken"
else
  echo "GitKraken is already installed."
fi

# Create a command-line alias for GitKraken if desired
if [ ! -f "/usr/local/bin/gitkraken" ] && [ -d "/Applications/GitKraken.app" ]; then
  echo "Creating gitkraken command-line alias..."
  sudo ln -sf "/Applications/GitKraken.app/Contents/MacOS/GitKraken" "/usr/local/bin/gitkraken" || echo "Note: Could not create gitkraken command. You may need to run the command manually with sudo."
fi

# Install Notion
if [ ! -d "/Applications/Notion.app" ]; then
  echo "Installing Notion..."
  brew install --cask notion || handle_error "Failed to install Notion"
else
  echo "Notion is already installed."
fi

# Install Claude
if [ ! -d "/Applications/Claude.app" ]; then
  echo "Installing Claude..."
  brew install --cask claude || handle_error "Failed to install Claude"
else
  echo "Claude is already installed."
fi

# Install ChatGPT
if [ ! -d "/Applications/ChatGPT.app" ]; then
  echo "Installing ChatGPT..."
  brew install --cask chatgpt || handle_error "Failed to install ChatGPT"
else
  echo "ChatGPT is already installed."
fi

# Install Superwhisper
if [ ! -d "/Applications/Superwhisper.app" ]; then
  echo "Installing Superwhisper..."
  brew install --cask superwhisper || handle_error "Failed to install Superwhisper"
else
  echo "Superwhisper is already installed."
fi

# Install TablePlus
if [ ! -d "/Applications/TablePlus.app" ]; then
  echo "Installing TablePlus..."
  brew install --cask tableplus || handle_error "Failed to install TablePlus"
else
  echo "TablePlus is already installed."
fi

#
# Terminal and Utilities
#

# Install Warp terminal
if [ ! -d "/Applications/Warp.app" ]; then
  echo "Installing Warp Terminal..."
  brew install --cask warp || handle_error "Failed to install Warp"
else
  echo "Warp Terminal is already installed."
fi

# Install CleanShot
if [ ! -d "/Applications/CleanShot X.app" ]; then
  echo "Installing CleanShot..."
  brew install --cask cleanshot || handle_error "Failed to install CleanShot"
else
  echo "CleanShot is already installed."
fi

# Install App Store apps using mas-cli
if ! command_exists mas; then
  echo "Installing mas-cli for App Store installations..."
  brew install mas || handle_error "Failed to install mas-cli"
else
  echo "mas-cli is already installed."
fi

# Check if mas can list apps (a good indicator if you're signed in)
echo "Checking App Store access..."
if mas list &>/dev/null; then
  echo "Installing apps from App Store..."
  
  # Example apps - replace IDs with the ones you want
  # To find an app's ID, use: mas search "App Name"
  
  # Perplexity
  PERPLEXITY_ID="6714467650"
  if ! mas list | grep -q "$PERPLEXITY_ID"; then
    echo "Installing Perplexity..."
    mas install "$PERPLEXITY_ID" || echo "Failed to install Perplexity"
  else
    echo "Perplexity is already installed."
  fi
  
  # Canva
  CANVA_ID="897446215"
  if ! mas list | grep -q "$CANVA_ID"; then
    echo "Installing Canva..."
    mas install "$CANVA_ID" || echo "Failed to install Canva"
  else
    echo "Canva is already installed."
  fi
  
  # Gifski
  GIFSKI_ID="1351639930"
  if ! mas list | grep -q "$GIFSKI_ID"; then
    echo "Installing Gifski..."
    mas install "$GIFSKI_ID" || echo "Failed to install Gifski"
  else
    echo "Gifski is already installed."
  fi
  
  # Add more App Store apps as needed by ID
  # mas install APP_ID
  
else
  echo "Unable to access App Store properly. Please make sure you're signed in to the App Store app manually."
  echo "Note: Some macOS versions have restrictions that prevent mas-cli from checking login status."
fi

echo "Setup complete!"
echo "Note: You may need to restart your terminal or run 'source ~/.zshrc' to use all installed tools."

