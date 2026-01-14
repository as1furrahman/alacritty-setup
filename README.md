# 🖥️ Alacritty Terminal Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Shell: Zsh](https://img.shields.io/badge/Shell-Zsh-green.svg)](https://www.zsh.org/)
[![Prompt: Starship](https://img.shields.io/badge/Prompt-Starship-purple.svg)](https://starship.rs/)

A minimal, aesthetic terminal configuration for Arch, Debian, Ubuntu & Fedora.

![Prompt Preview](https://img.shields.io/badge/Style-Bubble%20Prompt-success)

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Mellifluous Theme** | Warm, muted colors for reduced eye strain |
| **Cascadia Code** | Nerd Font with ligatures |
| **Bubble Prompt** | Pill-style modules: `[ 0s] [ ~/path]` |
| **Dynamic OS Logo** | Arch/Debian/Ubuntu icon in prompt |
| **Vi Mode** | Terminal navigation via keyboard |

## 🚀 Quick Install

```bash
git clone https://github.com/<username>/alacritty-setup ~/Documents/alacritty
cd ~/Documents/alacritty
chmod +x install.sh && ./install.sh
```

**What it does:**
- Detects your distro
- Installs dependencies (Starship, Nerd Font, zsh plugins)
- Configures Alacritty, Starship & Zsh
- Sets zsh as default shell

## 📦 Included Tools

| Tool | Command | Description |
|------|---------|-------------|
| zoxide | `z <dir>` | Smart cd |
| thefuck | `fuck` | Fix last command |
| yazi | `y` | File manager |
| btop | `btop` | Resource monitor |
| LazyVim | `nvim` | Neovim config |

## ⌨️ Shortcuts

| Key | Action |
|-----|--------|
| `Ctrl+Shift+Space` | Vi mode |
| `Ctrl+Shift+F` | Search |
| `Ctrl+Shift+C/V` | Copy/Paste |
| `F11` | Fullscreen |

## 📁 Structure

```
├── alacritty.toml   # Terminal config
├── starship.toml    # Prompt config
├── zshrc            # Shell config
├── yazi.toml        # File manager
└── install.sh       # Auto-installer
```

## 📝 License

[MIT](LICENSE)
