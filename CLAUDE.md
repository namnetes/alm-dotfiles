# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal dotfiles managed with **GNU Stow**. Running `stow .` from this directory creates symlinks in `$HOME` pointing to all tracked files (except those listed in `.stow-local-ignore`). Files excluded from stow: `.git/`, `.gitconfig`, `.gitignore`, `system-config/`, `CLAUDE.md`, `.claudecodeignore`, `.editorconfig`, `README.md`.

## Language & Communication

- **All interactions and explanations must be in French**, unless explicitly requested otherwise.
- Code, variable names, docstrings, and git commit messages stay in **English** (industry standard).

## Deploying Changes

```bash
# From the repo root — creates/updates symlinks in $HOME
stow .

# Dry run to preview changes
stow --simulate .

# Remove symlinks
stow -D .
```

## Code Standards

### Python
- **Package manager**: `uv` exclusively — never `pip` or `poetry`
- `uv sync` to install deps; `uv run <script.py>` to execute
- `uv run ruff check . --fix` for linting; `uv run pytest` for tests
- Line length: **88 characters** max (Black/Ruff style)
- Type hints required on all function signatures
- Docstrings: Google Style (Napoleon)

### Shell (Bash)
- Line length: **80 characters** max
- Always use `set -euo pipefail` at the top of scripts
- Use `\` for multi-line commands to respect the 80-char limit

### Data (CSV)
- Delimiter: `;` (semicolon), encoding: UTF-8
- Always specify `sep=';'` in Pandas/Polars

## Git Commits

Conventional Commits format: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `chore:`

## Repository Structure

```
.bash_aliases        # Shell aliases (sourced by .bashrc)
.bash_env            # Environment variables + tool initialization
                     # (starship, fnm, uv, fzf, zoxide, eza, SDKMAN)
.bash_functions      # Shell functions (ve, jl, fkill, gsp, dlvi, etc.)
.functions/
  bin/               # Executable scripts added to PATH
                     # (change_wallpaper.sh, update_system.sh, vid2mp3.sh,
                     #  list_functions.sh, init_zed.sh, update_hostname.sh)
  lib/               # Library scripts sourced at shell init
                     # (git_aliases.sh, clean_path.sh)
  tools/             # Python tools called by bash functions
                     # (rename_images.py, check_csv.py, manage_kvm.py,
                     #  encrypt_gpg.py)
.config/
  starship.toml      # Starship prompt config
  kitty/             # Kitty terminal config
  yazi/              # Yazi file manager config (yazi.toml, keymap.toml,
                     #  init.lua — plugins via ya pack)
  zed/               # Zed editor config (settings.json, keymap.json,
                     #  tasks.json)
  claude/            # Claude global rules (global_rules.md → .clauderc)
  systemd/           # User systemd units
doc/
  README.md          # Architecture overview for .functions/tools/ with examples
  check_csv.md       # Per-tool detailed docs (check_csv, encrypt_gpg,
  encrypt_gpg.md     #   manage_kvm, rename_images)
  manage_kvm.md
  rename_images.md
system-config/       # System-level config (NOT stowed, applied manually)
                     # kernel tuning via sysctl.d for 128GB RAM systems
```

## Key Patterns

- `.bash_env` is the main entrypoint for tool initialization; it sources `.functions/lib/git_aliases.sh` and `.functions/lib/clean_path.sh` when those exist locally.
- Shell functions in `.bash_functions` delegate Python work to scripts in `.functions/tools/`.
- `.functions/bin/` scripts are standalone executables; `.functions/lib/` scripts are sourced (not executed directly).
- `.clauderc` is a symlink to `.config/claude/global_rules.md`.
- The `gsp` function checks git status across `~/alm-dotfiles`, `~/alm-tools`, `~/alm-technook`, `~/workspaces/devinit`, and `~/workspaces/vmforge`.
- `.config/zed/settings.json` configures ruff (88-char) and shfmt (80-char) as LSP formatters, matching the code standards above. LSPs: ruff, pyright, yaml-language-server.
- `.config/yazi/init.lua` initializes community plugins (git, full-border, starship, smart-filter). Plugins are installed via `ya pack -a yazi-rs/plugins#<name>`.
- `.config/yazi/keymap.toml` defines plugin keybindings (jump-to-char on `f`, smart-filter on `F`, lazygit on `g l`, max-preview on `T`).

## Diagrams (Mermaid.js v10+)

- `flowchart TD`: vertical workflows / decision logic
- `flowchart LR`: data pipelines / linear ETL
- `sequenceDiagram`: API interactions
- Color palette:
  - `classDef startStop fill:#e1f5fe,stroke:#01579b`
  - `classDef error fill:#ffebee,stroke:#c62828`
  - `classDef logic fill:#e8eaf6,stroke:#1a237e`
  - `classDef data fill:#fff3e0,stroke:#e65100`
