## Quick Reference — Commands & Shortcuts

[Back to top](#quick-nav)

Everything installed by this setup, in one place. Print this, bookmark it, or just ask Claude "what commands do I have?"

---

### Shell Commands (installed by Step 1)

These aliases are added to your `~/.zshrc` (or `~/.bashrc`) and available in any terminal session.

| Command | What it does |
|---------|-------------|
| `cskip` | Launch Claude Code with all permissions skipped (`claude --dangerously-skip-permissions`) |
| `cc` | Short alias for `claude` |
| `ccr` | Resume last Claude conversation (`claude --resume`) |
| `ccc` | Continue last Claude conversation (`claude --continue`) |
| `cbrain` | Launch Claude Code in your 2ndBrain vault with auto mode |
| `c2danger` | Launch Claude Code in your 2ndBrain vault with skip-permissions |
| `cbraintg` | Same as `cbrain` but with Telegram channel connected |
| `c2tgdanger` | Same as `c2danger` but with Telegram channel connected |

> **Tip:** After running any setup script, run `source ~/.zshrc` to activate new commands. The scripts do this automatically, but just in case.

---

### Terminal Hotkeys

These work in your terminal when a Claude session is active.

| Hotkey | What it does |
|--------|-------------|
| **Shift+Tab** | Toggle auto-approve permissions on/off without restarting Claude |
| **Ctrl+C** | Stop whatever is currently running / exit Claude |
| **Ctrl+U** | Clear the entire line you are typing |
| **Up Arrow** | Recall previous command from history |
| **Tab** | Auto-complete file names and commands |

---

### Claude Code Built-In Commands (inside a session)

| Command | What it does |
|---------|-------------|
| `/exit` | Quit Claude |
| `/help` | Show all available commands |
| `/permissions` | Check current permission settings |
| `/clear` | Clear the conversation |
| `/compact` | Summarize conversation to save context window |
| `/voice` | Enable voice input mode |
| `!command` | Run a shell command without leaving Claude (e.g., `!ls`) |

---

### Claude Code Skills (slash commands)

These are custom skills installed by the setup scripts. Type them inside a Claude session.

| Command | Installed in | What it does |
|---------|-------------|-------------|
| `/rswarm <task>` | Step 3 | Launch a 15-agent swarm with fixed roles for structured parallel execution |
| `/rhive <goal>` | Step 3 | Launch a queen-led autonomous hive-mind with raft consensus |
| `/pretext <request>` | Step 4 | Text measurement and layout via @chenglou/pretext |

> These are **explicit triggers** — you type the command to activate the skill. This is different from the auto-triggered tools below, which respond to natural language.

---

### Auto-Triggered Tools (natural language — no command needed)

These activate on their own when Claude detects a relevant task via natural language. You never type a command — just describe what you want and Claude picks up the right tool.

| Tool | Installed in | How it activates | Example prompt |
|------|-------------|-----------------|----------------|
| UI/UX Pro Max | Step 4 | Natural language — asks about UI, design, layouts, interfaces | "Build me a dashboard with a sidebar" |
| 21st.dev Magic | Step 4 | Natural language — building components, pulls from 21st.dev library | "Create a hero section with a CTA" |
| Context Hub | Step 3 | Natural language — Claude writes code that calls external APIs | "Use the Stripe API to create a checkout" |
| Remotion | Step 5 | Natural language — video, animation, motion graphics | "Make a 30-second intro video" |
| Memory Hook | Step 2 | Automatic on session end — saves context from the conversation | (no prompt needed — runs automatically) |

> **Key distinction:** Slash commands (`/rswarm`, `/rhive`, `/pretext`) require you to type the command. Everything in this table works by just talking to Claude naturally.

---

### Status Line Indicators

When these tools are active, you may see indicators in your Claude session:

| Indicator | Meaning |
|-----------|---------|
| 🧠 2ndBrain | Working inside your Obsidian vault |
| ⚡ Ruflo | Ruflo MCP server is connected |
| 🎨 UIPro | Design skill is loaded (always on after Step 4) |
| 🐝 Swarm | Swarm is active (after `/rswarm`) — number shows agent count |
| 🍯 Hive | Hive-mind is active (after `/rhive`) |

---

### Ruflo Commands (Step 3)

These are available in your terminal after Step 3 installs the Ruflo CLI.

| Command | What it does |
|---------|-------------|
| `npx @claude-flow/cli@latest doctor --fix` | Diagnose and fix Ruflo installation issues |
| `npx @claude-flow/cli@latest daemon start` | Start the Ruflo background daemon |
| `npx @claude-flow/cli@latest swarm status` | Check the status of any running swarm |
| `npx @claude-flow/cli@latest memory search --query "..."` | Search your agent memory for past context |
| `npx @claude-flow/cli@latest memory list` | List all stored memory entries |

---

### Update & Maintenance

| Command | What it does |
|---------|-------------|
| `curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-setup/main/update.sh \| bash` | Re-run all steps, skip what is installed, pick up anything new |
| `source ~/.zshrc` | Reload shell config to activate new aliases |
| `claude update` | Update Claude Code itself to the latest version |
| `brew update && brew upgrade` | Update Homebrew and all installed packages (macOS) |

---

### Quick Troubleshooting

| Problem | Fix |
|---------|-----|
| `cskip` not recognized | Run `source ~/.zshrc` to reload your shell config |
| Claude asks for login | Run `claude` once normally and complete the browser login flow |
| Shift+Tab does nothing | Make sure you are inside an active Claude session, not at a normal shell prompt |
| Swarm not responding | Run `npx @claude-flow/cli@latest doctor --fix` to diagnose |
| MCP tools not connecting | Exit Claude, run `claude mcp list` to check connections, then relaunch |
| Obsidian vault not found | Tell Claude the full path to your vault (e.g., `~/Desktop/2ndBrain`) |

---

### Tips

- Say "yes" when Claude asks for permission, or use the `!` prefix to run commands directly without leaving the session.
- Voice commands work in Claude Code — use `/voice` to enable microphone input.
- If Claude seems confused or slow, run `/compact` to summarize the conversation and free up context.
- You can drag and drop files into your terminal to paste their full file path.
- Press **Up Arrow** to recall and re-run previous commands without retyping them.
