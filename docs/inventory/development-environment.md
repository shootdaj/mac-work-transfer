# Development Environment Setup

## Core Development Tools

### Runtime Environments
- **Node.js**: v24.2.0 (via system/Homebrew)
- **npm**: v11.3.0
- **Python**: 3.9.6 (system default)
- **Git**: 2.49.0

### Containerization
- **Docker**: 28.1.1, build 4eba377
  - Location: `/usr/local/bin/docker`
  - Likely Docker Desktop installation

### Package Managers
- **Homebrew**: Configured in `.zprofile`
- **NVM**: Configured in `.zshrc` (Node Version Manager)
- **pip**: Aliased to `python3 -m pip` in `.zshrc`

## Code Editors & IDEs (from Brewfile.essentials)

### Primary Editor
- **Cursor**: AI-powered code editor (backed up configs)

### Development Tools
- **GitKraken**: Git GUI client (backed up configs)
- **GitHub CLI**: Command-line Git operations

## Additional Development Apps (Manual Install)

### AI Development Tools
- **Copilot**: GitHub Copilot app
- **ChatGPT**: OpenAI development assistant  
- **Claude**: Anthropic development assistant

### Text Editors
- **CotEditor**: Lightweight text editor

## Language-Specific Setup

### .NET Development
- **dotnet-sdk**: Included in Brewfile.essentials
- Check version with: `dotnet --version`

### JavaScript/Node.js
- **NVM**: For managing Node.js versions
- **Current Node**: v24.2.0
- **Global packages**: Need to document with `npm list -g --depth=0`

### Python Development
- **System Python**: 3.9.6
- **pip**: Configured with alias
- **Virtual environments**: Need to check for pyenv/virtualenv

## Container Development

### Docker Setup
- **Docker Desktop**: Installed and running
- **Kubernetes**: Likely available through Docker Desktop
- **Container configs**: Check for docker-compose files

## Development Workflow Tools

### Version Control
- **Git**: 2.49.0 with LFS support
- **GitHub CLI**: Authenticated and configured
- **GitKraken**: GUI for complex Git operations

### File Management  
- **far2l**: Terminal file manager with custom aliases

## Missing/TODO Items

### Need to Document
1. **Global npm packages**: `npm list -g --depth=0`
2. **Python virtual environments**: Check for pyenv, conda, venv
3. **Docker containers/images**: `docker images` and `docker ps`
4. **SSH keys**: Generate/transfer for Git authentication
5. **Environment variables**: Check for API keys, paths
6. **IDE extensions**: Cursor extensions (already backed up)

### Development Dependencies
- **Build tools**: Xcode Command Line Tools
- **Compilers**: GCC, Clang status
- **Database tools**: Local databases, GUI clients

## Restore Process on New Mac

### 1. Install Core Tools (via Homebrew)
```bash
# Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install from Brewfile.essentials
brew bundle install --file=Brewfile.essentials
```

### 2. Setup Runtime Environments
```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install Node.js version
nvm install 24.2.0
nvm use 24.2.0
```

### 3. Docker Setup
- Install Docker Desktop manually
- Sign in to Docker Hub account
- Configure resource limits

### 4. Authentication Setup
```bash
# GitHub authentication
gh auth login

# Generate SSH key for Git
ssh-keygen -t ed25519 -C "shootdaj@gmail.com"
ssh-add ~/.ssh/id_ed25519
gh ssh-key add ~/.ssh/id_ed25519.pub
```

### 5. Restore Configurations
```bash
# Restore dotfiles
source ~/.zprofile
source ~/.zshrc

# Verify tools
node --version
docker --version
git --version
```

## Security Notes
- **SSH keys**: Need separate secure backup
- **API keys**: Check environment variables and config files
- **Docker credentials**: Need to re-authenticate
- **Git credentials**: May need to re-authenticate after SSH key setup