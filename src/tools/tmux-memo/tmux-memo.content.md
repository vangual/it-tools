# 🖥️ tmux Linux Command Cheatsheet

## 🔑 Basics
- **Start new session**: `tmux`
- **Start named session**: `tmux new -s <name>`
- **List sessions**: `tmux ls`
- **Attach to last session**: `tmux attach`
- **Attach to named session**: `tmux attach -t <name>`
- **Detach from session**: `Ctrl+b d`
- **Kill session**: `tmux kill-session -t <name>`
- **Rename session**: `Ctrl+b $`

## 📂 Windows (like tabs)
- **Create new window**: `Ctrl+b c`
- **Rename window**: `Ctrl+b ,`
- **Next window**: `Ctrl+b n`
- **Previous window**: `Ctrl+b p`
- **List windows**: `Ctrl+b w`
- **Switch to window #**: `Ctrl+b <0-9>`
- **Kill current window**: `Ctrl+b &`

## 🪟 Panes (splits)
- **Split vertically**: `Ctrl+b %`
- **Split horizontally**: `Ctrl+b "`
- **Move between panes**: `Ctrl+b <arrow keys>`
- **Cycle panes**: `Ctrl+b o`
- **Toggle pane zoom**: `Ctrl+b z`
- **Kill pane**: `Ctrl+b x`
- **Swap panes**: `Ctrl+b {` (swap with previous), `Ctrl+b }` (swap with next)

## 📋 Copy Mode
- **Enter copy mode**: `Ctrl+b [`
- **Start selection**: `<Space>`
- **Copy selection**: `<Enter>`
- **Quit copy mode**: `q`
- **Paste buffer**: `Ctrl+b ]`

## ⚙️ Configuration
- **Reload config**: `tmux source-file ~/.tmux.conf`
- **Show options**: `tmux show-options -g`
- **List all shortcuts**: `Ctrl+b ?`

## 🧭 Useful Commands
- **Command prompt**: `Ctrl+b :`
- **List sessions/windows/panes**: `tmux info`
- **Kill server (all sessions)**: `tmux kill-server`

## 📝 Notes
- **Prefix key**: Default is `Ctrl+b`. Press it before any shortcut.
- **Custom prefix**: Can be changed in `~/.tmux.conf` (e.g., `set -g prefix C-a`).

### Example Workflow
1. Start a named session: `tmux new -s dev`
2. Split into panes: `Ctrl+b %` and `Ctrl+b "`
3. Create multiple windows: `Ctrl+b c`
4. Detach: `Ctrl+b d`
5. Reattach later: `tmux attach -t dev`