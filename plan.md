# playingwithmycumfigs

## Purpose

Ensure opencode session data is synced across machines (laptop, work PC) via Syncthing. When you chat with opencode on one machine, the `opencode.db` is synced so the same history appears on the other machine.

## What's in This Repo

| File | Purpose |
|------|---------|
| `lua/opencode_session/project.lua` | Multi-parent project detection (configurable parent dirs + `.git` fallback). Kept as a reusable utility. |
| `plan.md` | This file — documentation of the sync setup. |
| `.gitignore` | Standard ignores. |

Everything else (db.lua, session.lua, prompts.lua, prompt/, plugin/) was removed — opencode manages sessions natively and has its own SQLite database. No Neovim plugin code is needed for sync.

## How Sync Works

### Syncthing Folder Configuration
Syncthing should sync these directories across machines:

| Directory | What | Notes |
|-----------|------|-------|
| `~/.local/share/opencode/` | Opencode data (sessions, chat history, tool outputs) | This contains `opencode.db` — the main database with all session data |

### `.stignore` (at `~/.local/share/opencode/.stignore`)
Exclude SQLite transient files to avoid conflicts:

```
(?d)*.db-shm
(?d)*.db-wal
```

The `opencode.db` file itself IS synced. These are just the WAL (Write-Ahead Log) files that SQLite creates temporarily.

### What to Verify
On each machine (laptop + work PC):
1. Syncthing is running
2. `~/.local/share/opencode/` is added as a synced folder
3. The `.stignore` file exists inside that folder with the WAL exclusions
4. Both machines show the folder as "Up to Date"

Once configured, opencode's session history will sync automatically.

## Parent Project Dirs

Configured in `vim.g.opencode_opts.project.parent_dirs` (in Neovim config):

- `C:/Users/abhianu/OneDrive/Desktop/Projects` (laptop)
- `C:/Users/abhianu/OneDrive/Desktop/CODE` (laptop)
- `C:/Users/avsg/Desktop/CODE` (work PC)

## Removed Features (Historical Reference)

The following were implemented and then stripped out when the scope was simplified:
- SQLite database module (db.lua) — opencode has its own
- Session management module (session.lua) — opencode manages natively
- Prompt management module (prompts.lua) — no mode tabs needed
- Mode prompt files (prompt/) — no custom modes needed
- Plugin entry point (plugin/opencode_session.lua) — no plugin needed
- Neovim mode integration (opencode_modes.lua) — no mode switching needed
- Terminal clearing on mode switch
- Dynamic mode tabs in opencode TUI
