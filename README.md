# nvim-config

Personal Neovim configuration for DevOps / infrastructure work: Kubernetes,
Kafka, Terraform, Helm, bash scripting, Jenkins/ArgoCD pipelines, and
Python/Ansible. Built on [lazy.nvim](https://github.com/folke/lazy.nvim),
targeting Neovim 0.12+.

## Prerequisites (fresh Ubuntu 24.04)

Ubuntu 24.04's `apt` packages for Neovim and Node.js are both too old/broken
for this config (nvim-treesitter's `main` branch and several LSP tools need
recent versions), so install those two manually.

### Neovim (official tarball, not apt)

```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo mv /opt/nvim-linux-x86_64 /opt/nvim
echo 'export PATH="/opt/nvim/bin:$PATH"' >> ~/.zshrc
```

### Node.js via nvm (not apt)

Ubuntu 24's `nodejs`/`npm` apt packages are incomplete/broken. Use
[nvm](https://github.com/nvm-sh/nvm) instead:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# restart shell, then:
nvm install --lts
```

### System packages

```bash
sudo apt update
sudo apt install -y ripgrep fd-find build-essential git curl unzip
# Ubuntu packages fd as "fdfind" - symlink it so nvim-tree/telescope find it as "fd"
mkdir -p ~/.local/bin
ln -s "$(which fdfind)" ~/.local/bin/fd
```

### tree-sitter CLI

Required by nvim-treesitter's `main` branch (the config uses the new
`require("nvim-treesitter").install(...)` API, not the old
`nvim-treesitter.configs` setup):

```bash
npm install -g tree-sitter-cli
```

### lazygit

Binary install from GitHub releases (not apt - Ubuntu's version lags):

```bash
LAZYGIT_VERSION="$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[^"]*')"
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
```

### kubeconform

Binary install from GitHub releases - **not available via Mason**, so it
has to be installed separately:

```bash
curl -Lo kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64.tar.gz
tar xf kubeconform.tar.gz kubeconform
sudo install kubeconform /usr/local/bin
```

Add a shell alias for validating manifests against upstream K8s schemas
(see [Kubernetes-specific notes](#kubernetes-specific-notes) below for why
this replaces in-editor schema validation):

```bash
echo "alias kval='kubeconform -summary -verbose'" >> ~/.zshrc
```

### pipx

Needed because Mason installs Python-based tools (`black`, `isort`) into
isolated environments via pipx:

```bash
sudo apt install -y pipx
pipx ensurepath
```

### Nerd Font

Install a [Nerd Font](https://www.nerdfonts.com/) — this config was set up
with **MesloLGS Nerd Font Mono**. Install it on your **client/terminal**
machine (e.g. your laptop's terminal emulator), not on the server, if
you're connecting over SSH — the font renders glyphs client-side.

### Optional but recommended shell setup

```bash
# ~/.zshrc
alias vim="nvim"
alias vi="nvim"
export EDITOR="nvim"
export VISUAL="nvim"
```

For non-interactive contexts (scripts, tools that shell out to `$EDITOR`
without going through your interactive zsh aliases), also symlink:

```bash
mkdir -p ~/.local/bin
ln -s /opt/nvim/bin/nvim ~/.local/bin/vim
```

For editing root-owned files, use `sudoedit` (not `sudo nvim`) so you get
your own user's full plugin/LSP setup instead of root's bare config:

```bash
sudoedit /etc/some-root-file
```

`sudoedit` only passes `$EDITOR` through if sudo is configured to keep it.
Run `sudo visudo` and add:

```
Defaults env_keep += "EDITOR VISUAL"
```

## Installing this config

```bash
git clone <this-repo-url> ~/.config/nvim
```

(Or clone elsewhere and symlink it to `~/.config/nvim` if you keep other
dotfiles in a single repo.)

## First launch

```bash
nvim
```

lazy.nvim bootstraps itself on first run and installs every plugin pinned
in `lazy-lock.json`. Once it finishes, run:

```
:Mason
```

and confirm every LSP server, formatter, and linter listed below shows as
installed. If anything is missing, press `i` on it inside the Mason UI.

## What's included

### Core editor

- **catppuccin/nvim** (mocha flavour) — colorscheme, with integrations for
  cmp, gitsigns, nvim-tree, telescope, treesitter, which-key, mason, and
  native LSP diagnostics.
- **nvim-tree.lua** — file explorer.
- **telescope.nvim** (+ fzf-native, web-devicons) — fuzzy finder for files,
  recent files, live grep, and grep-under-cursor.
- **nvim-treesitter** (`main` branch) — syntax highlighting/indent via the
  new installer API; parsers for json, yaml, html, css, markdown, bash,
  lua, vim, dockerfile, gitignore, query, vimdoc, terraform, hcl, helm,
  python, go, sql. Includes `nvim-ts-autotag`.
- **which-key.nvim** — keymap hints popup.
- **nvim-cmp** (+ cmp-nvim-lsp, cmp-buffer, cmp-path, LuaSnip,
  friendly-snippets, lspkind) — completion.
- **gitsigns.nvim** — git change signs in the gutter, hunk staging/preview,
  blame.
- **lazygit.nvim** — terminal UI for git inside Neovim.

### LSP stack

Configured in `lua/ahmed/plugins/lsp/lspconfig.lua` using the current
`vim.lsp.config()` / `vim.lsp.enable()` API (see
[gotchas](#known-quirks--gotchas)). Servers installed/managed via Mason:

| Server | Purpose |
|---|---|
| `yamlls` | YAML — K8s manifests, Helm values, CI pipelines |
| `bashls` | bash/sh scripting |
| `dockerls` | Dockerfile |
| `terraformls` | Terraform/HCL |
| `jsonls` | JSON |
| `lua_ls` | Lua (for editing this config itself) |
| `pyright` | Python (Ansible, scripts) |

### Formatting & linting

`lua/ahmed/plugins/formatting.lua` (conform.nvim) and
`lua/ahmed/plugins/linting.lua` (nvim-lint), with all underlying binaries
installed by `mason-tool-installer` in `lsp/mason.lua`:

| Filetype | Formatter | Linter |
|---|---|---|
| Lua | stylua | — |
| Python | isort, black | — |
| sh / bash | shfmt | shellcheck |
| JSON | prettier | — |
| Markdown | prettier | — |
| YAML | yamlfmt | yamllint |
| Dockerfile | — | hadolint |

Format-on-save is enabled (falls back to LSP formatting if no conform
formatter matches); linting runs on `BufEnter`, `BufWritePost`, and
`InsertLeave`. Manual format: `<leader>mp`.

### Git integration

- **gitsigns.nvim** for inline hunk signs, staging, and blame (see
  [keymaps](#keymap-reference) below).
- **lazygit.nvim** for a full git TUI (`<leader>lg`).

### Kubernetes-specific notes

Live YAML schema validation via `yamlls` is **intentionally not enabled**
for Kubernetes manifests. `lspconfig.lua` opts `yamlls` into only a small
whitelist of schemastore.nvim catalog entries (`GitHub Workflow`,
`GitHub Action`, `docker-compose.yml`) instead of loading the full
schemastore catalog.

Reason: the schemastore catalog contains many schemas whose `fileMatch` is
a bare directory-name glob — e.g. Ansible's Tasks File schema matches
`**/tasks/*.yaml` and `**/vars/*.yaml`. Any YAML file that happens to live
in a directory literally named `tasks/` or `vars/` gets validated against
that schema regardless of whether the project is actually Ansible,
producing false-positive "Property X is not allowed" diagnostics. This is
a real bug class in the catalog, not a hypothetical — it was hit and
confirmed on a plain `~/tasks/*.yaml` file with no `$schema` and no special
meaning.

For actual Kubernetes manifest validation, use **kubeconform** from the
terminal instead:

```bash
kval my-manifest.yaml
# (kval is the alias set up above: kubeconform -summary -verbose)
```

`core/autocmds.lua` still auto-inserts a `# yaml-language-server: $schema=...`
modeline (pointing at the upstream `kubernetes-json-schema` catalog) into
new files created under a `k8s/`, `kubernetes/`, or `manifests/` directory
— that opts a specific file back into live schema validation deliberately,
on a per-file basis, without re-enabling the catalog-wide false positives.

## Keymap reference

Leader is `<Space>`.

### LSP (`lsp/lspconfig.lua`, on `LspAttach`)

| Keymap | Action |
|---|---|
| `gR` | Show LSP references (Telescope) |
| `gD` | Go to declaration |
| `gd` | Show LSP definitions (Telescope) |
| `gi` | Show LSP implementations (Telescope) |
| `gt` | Show LSP type definitions (Telescope) |
| `K` | Hover documentation |
| `<leader>ca` | Code actions (normal + visual) |
| `<leader>rn` | Smart rename |
| `<leader>D` | Buffer diagnostics (Telescope) |
| `<leader>d` | Line diagnostics (float) |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>rs` | Restart LSP |

### Telescope

| Keymap | Action |
|---|---|
| `<leader>ff` | Find files in cwd |
| `<leader>fr` | Recent files |
| `<leader>fs` | Live grep in cwd |
| `<leader>fc` | Grep string under cursor |

### Git (`gitsigns.lua`, on attach)

| Keymap | Action |
|---|---|
| `]h` / `[h` | Next / previous hunk |
| `<leader>hs` | Stage hunk (normal + visual range) |
| `<leader>hr` | Reset hunk (normal + visual range) |
| `<leader>hS` | Stage buffer |
| `<leader>hR` | Reset buffer |
| `<leader>hu` | Undo stage hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line (full) |
| `<leader>hB` | Toggle current line blame |
| `<leader>hd` | Diff this |
| `<leader>hD` | Diff this (against `~`) |
| `ih` (operator/visual) | Select hunk (text object) |
| `<leader>lg` | Open LazyGit |

### File explorer (`nvim-tree.lua`)

| Keymap | Action |
|---|---|
| `<leader>ee` | Toggle file explorer |
| `<leader>ef` | Toggle explorer on current file |
| `<leader>ec` | Collapse explorer |
| `<leader>er` | Refresh explorer |

### Window / split / tab (`core/keymaps.lua`)

| Keymap | Action |
|---|---|
| `jk` (insert mode) | Exit insert mode |
| `<leader>nh` | Clear search highlights |
| `<leader>+` / `<leader>-` | Increment / decrement number |
| `<leader>sv` / `<leader>sh` | Split vertically / horizontally |
| `<leader>se` | Equalize split sizes |
| `<leader>sx` | Close current split |
| `<leader>to` / `<leader>tx` | Open / close tab |
| `<leader>tn` / `<leader>tp` | Next / previous tab |

### Formatting/linting

| Keymap | Action |
|---|---|
| `<leader>mp` | Format file (or range in visual mode) |

## Known quirks / gotchas

- **nvim-treesitter `main` branch**: this config tracks the `main` branch
  rewrite, not `master`. It requires the `tree-sitter` CLI (installed via
  npm above) and uses a different config API
  (`require("nvim-treesitter").install(...)` + manual `FileType` autocmd
  calling `vim.treesitter.start()`) than most older tutorials/blog posts
  show, which target the `master` branch's `nvim-treesitter.configs.setup`.
  If you copy snippets from older guides they likely won't apply here.
- **`vim.lsp.config` / `vim.lsp.enable`**: LSP servers are set up with
  Neovim's newer built-in API, not the deprecated
  `require('lspconfig').setup{}` pattern still shown in a lot of
  nvim-lspconfig documentation/tutorials.
- **`rocks.enabled = false`** in `lazy.lua`: required to stop lazy.nvim's
  Luarocks integration from pulling in a stale `nvim-treesitter` as a
  transitive dependency via telescope's rockspec, which conflicts with the
  `main`-branch treesitter above.
- **yamlls schema validation is deliberately limited** — see
  [Kubernetes-specific notes](#kubernetes-specific-notes). If you add a new
  project type that needs a schemastore entry, add it to the `select` list
  in `lspconfig.lua` by name rather than re-enabling the full catalog.
- **`fd` vs `fdfind`**: Ubuntu's `fd-find` package installs the binary as
  `fdfind`, not `fd`. Telescope/nvim-tree expect `fd` on `PATH` — the
  symlink step above is required, not optional.
- **kubeconform is not in Mason** — it has to be installed manually (see
  prerequisites) and used from the terminal (`kval`), it isn't wired into
  any in-editor linting.
