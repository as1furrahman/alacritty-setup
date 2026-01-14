# 🖥️ Alacritty Terminal Setup

A minimal, aesthetic, keyboard-centric terminal configuration optimized for Python/AI/ML development.
Inspired by [Axenide's dotfiles](https://github.com/Axenide/Dotfiles).

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Mellifluous Theme** | Warm, muted colors for reduced eye strain |
| **Cascadia Code** | Nerd Font with programming ligatures |
| **Minimal Prompt** | Red `»` character, clean two-line layout |
| **Vi Mode** | Full terminal navigation from keyboard |
| **100K Scrollback** | Large buffer for ML training logs |

### Included Tools

| Tool | Description |
|------|-------------|
| **zoxide** | Smart `cd` that learns your habits (`z` command) |
| **thefuck** | Auto-correct previous command (`fuck` or `fix`) |
| **yazi** | Modern file manager with image preview (`y` command) |
| **nitch** | Minimal system info (Axenide style) |
| **btop** | Beautiful resource monitor |
| **LazyVim** | Pre-configured Neovim setup |

## 🚀 Quick Install

```bash
git clone <repo-url> ~/Documents/alacritty
cd ~/Documents/alacritty
./install.sh
```

This automatically:
- ✅ Detects distro (Arch, Debian, Ubuntu, Fedora)
- ✅ Installs all dependencies
- ✅ Installs Starship, Nerd Font, LazyVim
- ✅ Configures all tools
- ✅ Changes shell to zsh

### Options

```bash
./install.sh              # Full install
./install.sh --deps-only  # Only dependencies
./install.sh --no-deps    # Only configs
```

## ⌨️ Keyboard Shortcuts

### Alacritty

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+Space` | Toggle Vi mode |
| `Ctrl+Shift+Q` | Quit |
| `Ctrl+Shift+F` | Search |
| `Ctrl+Shift+C/V` | Copy/Paste |
| `Ctrl++/-/0` | Font size |
| `F11` | Fullscreen |

### Shell Commands

| Command | Action |
|---------|--------|
| `z <dir>` | Smart cd (zoxide) |
| `fuck` | Fix last command (thefuck) |
| `y` | Open file manager (yazi) |
| `nitch` | Show system info |
| `btop` | Resource monitor |

## 🎨 Prompt Style

```
 5:30pm  󰅐 1 hour, 30 minutes   ubuntu in ~
~/Documents/alacritty 
» 
```

## 📁 File Structure

```
~/Documents/alacritty/
├── alacritty.toml     # Terminal config
├── starship.toml      # Minimal prompt
├── zshrc              # Zsh config
├── yazi.toml          # File manager config
├── install.sh         # Auto-installer
└── README.md
```

## 📝 License

MIT
