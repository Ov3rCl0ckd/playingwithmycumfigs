# opencode_session.nvim

## Overview

A Neovim plugin that extends the official [opencode.nvim](https://github.com/nickjvandyke/opencode.nvim) with:

- **Project-aware mode management**: Dynamically shows/hides custom mode tabs in the opencode TUI based on whether you're inside a project folder
- **Session persistence**: Resumes the last active session per project across Neovim restarts
- **Chat history storage**: Saves/loads conversation history to a local SQLite database (via snacks.nvim's bundled sqlite3)
- **Multi-parent project detection**: Recognizes any folder under configured parent directories (e.g., `~/Projects/`, `~/CODE/`) as a project root, falling back to `.git` detection

## Architecture

```
playingwithmycumfigs/
├── lua/opencode_session/
│   ├── project.lua      # Project root detection (parent dirs + .git fallback)
│   ├── db.lua           # SQLite database operations (via snacks picker util db)
│   ├── session.lua      # Session lifecycle (start, resume, save, load history)
│   └── prompts.lua      # Manage prompt .md files in ~/.config/opencode/modes/
├── plugin/
│   └── opencode_session.lua  # Plugin entry point: setup, autocmds, user commands
├── prompt/
│   ├── Tutor.md         # Socratic Code Tutor
│   ├── docs.md          # Documentation Hunter
│   ├── review.md        # Code Reviewer
│   ├── cop.md           # Security Auditor
│   └── rabbit.md        # ADHD Rabbit Hole Blocker
└── plan.md              # This file
```

External config files (in `~/.config/nvim/lua/`):
- `utils/opencode_modes.lua` — Mode definitions, server interaction, terminal clearing
- `plugins/opencode.lua` — Official opencode.nvim config + custom mode keybindings
- `plugins/opencode_session.lua` — lazy.nvim spec for this plugin

## What's Implemented

### Core Plugin (lua/opencode_session/)
- [x] **project.lua**: Multi-parent project detection (configurable via `vim.g.opencode_opts.project.parent_dirs`), with `.git` fallback
- [x] **db.lua**: SQLite3 database via snacks.nvim's bundled `sqlite3.dll`. Tables: `chat_history`, `active_sessions`
- [x] **session.lua**: Start/resume sessions, save/load messages, persistence across restarts
- [x] **prompts.lua**: Copy prompt `.md` files to `~/.config/opencode/modes/` inside projects, remove them outside

### Neovim Config Integration
- [x] **opencode_modes.lua**: 5 modes (tutor, docs, review, security, rabbit) reading from `.md` files
- [x] Project-scope check: modes only work inside project folders
- [x] Terminal clearing on mode switch (sends form feed to opencode terminal buffer)
- [x] Keybindings: `<Leader>ot`/`od`/`or`/`oc`/`ob` for each mode
- [x] DB notification only appears on first database creation

### OpenCode Server
- [x] Dynamic mode tabs in opencode TUI (appear inside projects, only plan/build outside)
- [x] Prompts sourced from `~/.config/opencode/modes/*.md`

## Remaining Work

### Bugs - Fixed
- [x] ~~**BU-001: `copy()` error in prompts.lua** — `vim.fn.copy()` is for Vim dicts, not files. Replaced with `vim.fn.readfile` + `vim.fn.writefile`.~~ ✅

### Features - Complete
- [x] ~~**Clear chat history on mode switch** — No dedicated clear/purge API exists in opencode.nvim. Using `session.new` instead: each mode switch creates a fresh session (equivalent to Option B).~~ ✅

### Future / Not Implemented
- `DELETE /session/{id}` endpoint — the opencode.nvim Neovim plugin does not expose any API to delete/purge/clear a session's messages. The server's REST API might have one (not explored), but the plugin has none. Current solution: create a new session each time.
- Add `:Session` commands documentation
- Auto-start opencode server inside projects
- Mode-specific session history (not just project-level)

## User Decisions Made

| Decision | Choice |
|----------|--------|
| Mode tabs visibility | Dynamic — only show custom tabs (tutor, docs, review, security, rabbit) inside project folders; only built-in plan/build outside |
| Terminal on mode switch | Cleared via form feed (`\f`) sent to terminal channel |
| Session history on mode switch | **Option A**: `session.new` creates a fresh session each time (Option B impossible — no clear/purge API exists in opencode.nvim) |
| Prompt source | Only `.md` instruction files, no inline Lua prompts |
| Session across restarts | Resume last active session per project |
| nvim config path | `~/.config/nvim/` (Windows: `C:\Users\abhianu\.config\nvim\`) |
| Parent project dirs | `C:\Users\abhianu\OneDrive\Desktop\Projects`, `C:\Users\abhianu\OneDrive\Desktop\CODE`, `C:\Users\avsg\Desktop\CODE` |
