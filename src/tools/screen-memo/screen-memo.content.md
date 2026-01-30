# 🖥️ GNU Screen Command Cheatsheet

GNU Screen is a terminal multiplexer that lets you run multiple shell sessions inside a single terminal window, detach them, and reattach later.

## 📦 Starting & Managing Screen Sessions

- **Start a new session**
  ```bash
  screen
  ```
- **Start with a session name**
  ```bash
  screen -S session_name
  ```
- **List running sessions**
  ```bash
  screen -ls
  ```
- **Attach to a session**
  ```bash
  screen -r session_name
  ```
- **Attach to the last detached session**
  ```bash
  screen -r
  ```
- **Kill a session**
  ```bash
  screen -X -S session_name quit
  ```

## ⌨️ Essential Key Bindings

> Default prefix key: `Ctrl-a` (press before other keys)

| Key Binding | Action |
|-|--|
| `Ctrl-a c`  | Create new window |
| `Ctrl-a n`  | Next window |
| `Ctrl-a p`  | Previous window |
| `Ctrl-a "`  | List all windows |
| `Ctrl-a 0..9` | Switch to window by number |
| `Ctrl-a A`  | Rename current window |
| `Ctrl-a d`  | Detach session |
| `Ctrl-a ?`  | Help (show key bindings) |
| `Ctrl-a k`  | Kill current window |
| `Ctrl-a \`  | Kill all windows & exit screen |
| `Ctrl-a x`  | Lock screen |
| `Ctrl-a S`  | Split screen horizontally |
| `Ctrl-a |`  | Split screen vertically |
| `Ctrl-a tab` | Switch focus between regions |
| `Ctrl-a Q`  | Close all regions except current |

## 🔀 Window & Region Management

- **Split horizontally**
  ```bash
  Ctrl-a S
  ```
- **Split vertically**
  ```bash
  Ctrl-a |
  ```
- **Switch region focus**
  ```bash
  Ctrl-a tab
  ```
- **Remove all splits except current**
  ```bash
  Ctrl-a Q
  ```

## 📂 Session Persistence

- **Detach session (keep running in background)**
  ```bash
  Ctrl-a d
  ```
- **Reattach session**
  ```bash
  screen -r session_name
  ```

## ⚙️ Configuration

- **Default config file:** `~/.screenrc`
- Example `.screenrc`:
  ```bash
  # Start with a named session
  startup_message off
  defscrollback 5000
  hardstatus alwayslastline
  hardstatus string '%{= kG}[%H] %{= kw}%?%-Lw%?%{= kR}%n*%f %t%?(%u)%?%{= kw}%?%+Lw%? %{= kG}[%H]'
  ```

## 🛠️ Useful Options

- **Scrollback buffer size**
  ```bash
  screen -h 5000
  ```
- **Execute command in new screen**
  ```bash
  screen -dmS session_name command
  ```
- **Log output**
  ```bash
  Ctrl-a H
  ```
  (toggle logging in current window)

## 🚪 Exiting Screen

- **Kill current window**
  ```bash
  Ctrl-a k
  ```
- **Kill all windows & quit**
  ```bash
  Ctrl-a \
  ```
- **Exit normally**
  - Close all programs in the window, then type `exit`.

## 🧠 Tips

- Use **named sessions** (`screen -S`) to avoid confusion.
- Combine with **SSH** to keep remote jobs running after disconnect.
- Use `.screenrc` to customize behavior and status line.