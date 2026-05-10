#!/usr/bin/env bash
# Bootstrap a new Mac with my terminal/shell config.
# Idempotent: safe on a fresh machine or to re-run after editing.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

log() { printf "\033[1;34m==>\033[0m %s\n" "$*"; }

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

log "Installing Homebrew packages..."
brew bundle install --file="$DOTFILES_DIR/Brewfile"

# oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_if_missing() {
  local repo="$1" dest="$2"
  if [[ ! -d "$dest" ]]; then
    log "Cloning $repo -> $dest"
    git clone --depth=1 "$repo" "$dest"
  fi
}

clone_if_missing https://github.com/romkatv/powerlevel10k.git           "$ZSH_CUSTOM/themes/powerlevel10k"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions       "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting   "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

link() {
  local src="$1" dest="$2"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    return
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    log "Backing up $dest -> $BACKUP_DIR/"
    mv "$dest" "$BACKUP_DIR/"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  log "Linked $dest -> $src"
}

log "Linking dotfiles..."
link "$DOTFILES_DIR/.zshrc"                 "$HOME/.zshrc"
link "$DOTFILES_DIR/.p10k.zsh"              "$HOME/.p10k.zsh"
link "$DOTFILES_DIR/.gitconfig"             "$HOME/.gitconfig"
link "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"

log "Done. Open a new terminal (or run 'exec zsh') to pick up the new config."
[[ -d "$BACKUP_DIR" ]] && log "Existing files backed up to: $BACKUP_DIR"
