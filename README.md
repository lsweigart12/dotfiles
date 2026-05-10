# dotfiles

My macOS terminal/shell setup: zsh + oh-my-zsh + powerlevel10k, fzf, zoxide, syntax highlighting, autosuggestions, Ghostty.

## Bootstrap a new Mac

```sh
xcode-select --install   # if needed for git
git clone https://github.com/lsweigart12/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Open a new terminal afterward (or `exec zsh`).

## What `install.sh` does

1. Installs Homebrew if missing.
2. `brew bundle install` — installs everything in `Brewfile` (formulae, casks, VS Code extensions, Go tools).
3. Installs oh-my-zsh, powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting.
4. Symlinks `.zshrc`, `.p10k.zsh`, `.gitconfig`, and `.config/ghostty/config` into `$HOME`. Existing files are backed up to `~/.dotfiles-backup-<timestamp>/`.

The script is idempotent — re-run it any time to pick up changes.

## Updating the repo from the live config

```sh
cp ~/.zshrc ~/dotfiles/.zshrc
cp ~/.p10k.zsh ~/dotfiles/.p10k.zsh
brew bundle dump --file=~/dotfiles/Brewfile --force
```

(Not needed if you've already symlinked — edits to the originals go straight into the repo.)
