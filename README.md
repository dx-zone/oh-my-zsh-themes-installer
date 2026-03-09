# 🎨 Oh My Zsh Themes Installer

<p align="center"> <img src="https://img.shields.io/badge/zsh-Oh%20My%20Zsh-green?style=for-the-badge"> <img src="https://img.shields.io/badge/shell-bash-blue?style=for-the-badge"> <img src="https://img.shields.io/badge/license-MIT-lightgrey?style=for-the-badge"> </p>

A simple, practical toolkit to **manage and install custom Oh My Zsh themes quickly and safely**.

This project contains:

- ✨ A collection of **customized Oh My Zsh themes**
- ⚙️ A **bootstrap installer script** to manage them
- 🧰 Utilities to **install, delete, preview, and activate themes**

Instead of manually copying files and editing `.zshrc`, this tool provides a **clean workflow to manage your shell themes safely and quickly**.

---

# 🎬 Demo

*(Placeholder — add GIF later)*

```bash
[ GIF PLACEHOLDER ]

Example demo:
• listing themes
• installing themes
• activating a theme
• switching themes
```

Example execution:

```bash
./install-oh-my-zsh-themes.sh --list-themes
./install-oh-my-zsh-themes.sh --set-theme mint-dx
exec zsh
```

------

# 📦 Installation

Clone the repository:

```bash
git clone https://github.com/dx-zone/oh-my-zsh-themes.git
cd oh-my-zsh-themes
```

Install the themes:

```bash
./install-oh-my-zsh-themes.sh
```

Activate one:

```bash
./install-oh-my-zsh-themes.sh --set-theme mint-dx
```

Reload shell:

```bash
exec zsh
```

------

# 📁 Repository Layout

```bash
.
├── install-oh-my-zsh-themes.sh   # ⚙️ Theme manager
└── oh-my-zsh-themes              # 🎨 Theme collection
    ├── fino-dx.zsh-theme
    └── mint-dx.zsh-theme
```

Add new themes to:

```bash
oh-my-zsh-themes/
```

Then run the installer.

------

# 🎨 Included Themes

| Theme       | Description                                           |
| ----------- | ----------------------------------------------------- |
| **mint-dx** | Clean Mint-inspired prompt customized for readability |
| **fino-dx** | Refined Fino-based prompt with improved structure     |

Both themes are **customized derivatives** of existing Oh My Zsh themes.

------

# ⚙️ Script Flags Reference

| Flag | Long Flag           | Description                               |
| ---- | ------------------- | ----------------------------------------- |
| `-y` | `--yes`             | Run without confirmation prompts          |
| `-n` | `--dry-run`         | Preview actions without making changes    |
| —    | `--no-backup`       | Disable automatic backup before overwrite |
| `-t` | `--theme-dir DIR`   | Custom Oh My Zsh theme directory          |
| `-z` | `--zshrc FILE`      | Use alternate `.zshrc` file               |
| `-d` | `--delete`          | Remove installed themes                   |
| `-L` | `--list-themes`     | Show available repository themes          |
| `-s` | `--set-theme THEME` | Update `ZSH_THEME="..."` in `.zshrc`      |
| `-c` | `--clean-up`        | Remove repo theme files and installer     |
| `-h` | `--help`            | Show help information                     |

------

# 🧠 Quick Usage Examples

Install themes interactively:

```bash
./install-oh-my-zsh-themes.sh
```

Preview actions safely:

```bash
./install-oh-my-zsh-themes.sh --dry-run
```

List available themes:

```bash
./install-oh-my-zsh-themes.sh --list-themes
```

Activate a theme:

```bash
./install-oh-my-zsh-themes.sh --set-theme mint-dx
```

Remove installed themes:

```bash
./install-oh-my-zsh-themes.sh --delete
```

------

# 🔒 Safe Workflow

Recommended process:

```bash
./install-oh-my-zsh-themes.sh --dry-run
./install-oh-my-zsh-themes.sh --set-theme mint-dx
exec zsh
```

This ensures changes are **verified before applying them**.

------

# 🧰 Requirements

- `zsh`
- [Oh My Zsh](https://ohmyz.sh/)
- A terminal font with icon support (recommended)

Good font options:

- JetBrainsMono Nerd Font
- MesloLGS NF
- FiraCode Nerd Font

------

# 🛠 Custom Themes

To add your own theme:

1️⃣ drop it into

```bash
oh-my-zsh-themes/
```

2️⃣ run installer

```bash
./install-oh-my-zsh-themes.sh
```

------

# 🤝 Contributing

Contributions are welcome.

Possible improvements:

- new themes
- prompt improvements
- installer features
- documentation improvements

------

# 👨‍💻 Maintainer

**DX**

GitHub
 https://github.com/dx-zone

------

# 📜 License

This project is licensed under the MIT License — see the LICENSE file for details.

------

## ⭐ Tip

If this repo helps you build a cleaner terminal environment, consider starring it.
