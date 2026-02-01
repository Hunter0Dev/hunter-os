# Hunter OS Code Editors Guide

## Available Editors

Hunter OS includes multiple code editors to suit different workflows and preferences.

---

## 🖥️ GUI Editor: Code - OSS

**What is it?**  
Code - OSS is the fully open-source version of Visual Studio Code, without Microsoft's telemetry or proprietary components.

**Launch**:
- Applications → Development → Code - OSS
- Terminal: `code`

**Features**:
- ✅ IntelliSense (code completion)
- ✅ Debugging support
- ✅ Git integration
- ✅ Extensions from Open VSX Registry
- ✅ Multi-language support
- ✅ Terminal integration
- ✅ **No telemetry** (privacy-focused)

**Quick Start**:
```bash
# Open current directory
code .

# Open specific file
code /path/to/file.py

# Open with extensions
code --install-extension ms-python.python
```

**Extensions**:
Code - OSS uses the Open VSX Registry for extensions. Most popular extensions are available:
- Python
- C/C++
- Rust
- Go
- JavaScript/TypeScript
- Markdown
- GitLens

---

## 💻 Terminal Editors

### Neovim (Recommended)
**Modern Vim with better defaults**

**Launch**: `nvim <file>`

**Features**:
- ✅ Lua configuration
- ✅ Built-in LSP support
- ✅ Better performance than Vim
- ✅ Async plugins
- ✅ Modern defaults

**Quick Commands**:
```bash
# Edit file
nvim file.py

# Edit with line number
nvim +42 file.py

# Configuration
nvim ~/.config/nvim/init.vim
```

**Basic Usage**:
- `i` - Insert mode
- `Esc` - Normal mode
- `:w` - Save
- `:q` - Quit
- `:wq` - Save and quit
- `/search` - Search
- `dd` - Delete line
- `yy` - Copy line
- `p` - Paste

---

### Vim
**Classic powerful text editor**

**Launch**: `vim <file>`

**Features**:
- ✅ Ubiquitous (available everywhere)
- ✅ Powerful editing commands
- ✅ Extensive plugin ecosystem
- ✅ Modal editing

**Quick Commands**: Same as Neovim

---

### Nano
**Beginner-friendly terminal editor**

**Launch**: `nano <file>`

**Features**:
- ✅ Easy to use
- ✅ On-screen help
- ✅ No modal editing
- ✅ Perfect for quick edits

**Quick Commands**:
- `Ctrl+O` - Save
- `Ctrl+X` - Exit
- `Ctrl+W` - Search
- `Ctrl+K` - Cut line
- `Ctrl+U` - Paste

**Best for**: Quick config file edits, beginners

---

### Emacs
**Extensible, customizable editor**

**Launch**: `emacs <file>`

**Features**:
- ✅ Highly extensible (Emacs Lisp)
- ✅ Built-in file manager
- ✅ Email client
- ✅ Org-mode for notes
- ✅ Can be a complete IDE

**Quick Commands**:
- `Ctrl+X Ctrl+S` - Save
- `Ctrl+X Ctrl+C` - Exit
- `Ctrl+X Ctrl+F` - Open file
- `Ctrl+S` - Search forward

---

## 🎯 Which Editor to Use?

### For Beginners
**Nano** - Easiest to learn, on-screen help

### For Quick Edits
**Nano** or **Vim** - Fast startup, simple changes

### For Serious Development
**Code - OSS** - Full IDE experience with debugging

### For Power Users
**Neovim** - Efficient, keyboard-driven, highly customizable

### For Scripting
**Vim/Neovim** - Fast, powerful, great for shell scripts

### For Everything
**Emacs** - Can do almost anything (if you learn it!)

---

## 🚀 Code - OSS Tips

### Recommended Extensions
```bash
# Python development
code --install-extension ms-python.python

# C/C++ development  
code --install-extension llvm-vs-code-extensions.vscode-clangd

# Rust development
code --install-extension rust-lang.rust-analyzer

# Markdown preview
code --install-extension yzhang.markdown-all-in-one

# GitLens
code --install-extension eamodio.gitlens
```

### Keyboard Shortcuts
- `Ctrl+P` - Quick file open
- `Ctrl+Shift+P` - Command palette
- `Ctrl+B` - Toggle sidebar
- `Ctrl+`` - Toggle terminal
- `Ctrl+/` - Toggle comment
- `F5` - Start debugging
- `Ctrl+Shift+F` - Search in files

### Settings
```bash
# Open settings
code --user-data-dir ~/.config/Code-OSS
```

---

## 🔧 Neovim Configuration

### Basic Config
Create `~/.config/nvim/init.vim`:
```vim
" Basic settings
set number          " Line numbers
set relativenumber  " Relative line numbers
set expandtab       " Use spaces instead of tabs
set tabstop=4       " Tab width
set shiftwidth=4    " Indent width
set smartindent     " Auto indent
set mouse=a         " Enable mouse
set clipboard=unnamedplus  " System clipboard

" Search settings
set ignorecase      " Ignore case in search
set smartcase       " Unless uppercase used
set hlsearch        " Highlight search results

" Color scheme
colorscheme desert
syntax on
```

### Plugin Manager (Optional)
Install vim-plug for plugins:
```bash
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

---

## 📝 Editor Comparison

| Feature | Code-OSS | Neovim | Vim | Nano | Emacs |
|---------|----------|--------|-----|------|-------|
| **GUI** | ✅ | ❌ | ❌ | ❌ | ✅ |
| **Mouse** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Learning Curve** | Easy | Hard | Hard | Easy | Very Hard |
| **Speed** | Medium | Fast | Fast | Fast | Medium |
| **Extensions** | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Debugging** | ✅ | ✅ | ⚠️ | ❌ | ✅ |
| **Git Integration** | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Resource Usage** | High | Low | Low | Low | Medium |
| **Best For** | Projects | Scripts | Quick edits | Configs | Everything |

---

## 🎓 Learning Resources

### Code - OSS
- Built-in tutorial: Help → Welcome
- Keyboard shortcuts: `Ctrl+K Ctrl+S`

### Neovim/Vim
- Built-in tutorial: `vimtutor`
- Help: `:help`
- Cheat sheet: https://vim.rtorr.com/

### Nano
- Help: `Ctrl+G` (while in nano)
- Commands shown at bottom of screen

### Emacs
- Built-in tutorial: `Ctrl+H t`
- Help: `Ctrl+H ?`

---

## 💡 Pro Tips

1. **Start with Code - OSS** for GUI development
2. **Learn Nano** for quick terminal edits
3. **Gradually learn Vim/Neovim** for efficiency
4. **Use the right tool** for the job
5. **Customize your editor** to your workflow

---

For more information, see `/usr/share/doc/hunter-os/README.md`
