<a id="top"></a>

# CLI Maxxing

**Everything you need to start working with AI-powered development tools; one command per step.**

> [!NOTE]
> **Heads up — this was fidgetcoded.** I'm no expert, but I tried — nominally — my best. Getting this stack running end-to-end on a clean machine took a lot of trial and error, and it still might not be perfect.
>
> <hr>
>
> **fidg·et·cod·ing** \ ˈfij-ət-ˌkō-diŋ \   *verb*   ·   **fidgetcoded**; **fidgetcode**<br>
> **1** : to code as self-regulation — the ADHD dopamine loop<br>
> **2** : to build software through relentless tinkering by someone with no formal training and too many browser tabs open
>
> <hr>
>
> **Read everything carefully as you go (or don't, entirely your call).** If something breaks mid-install, don't panic (or do, also your call):
>
> 1. **Get Claude CLI up first (Step 1).** Once it's running, you can paste any error straight into it and Claude will help you troubleshoot EVERYTHING downstream.
> 2. **Re-run the install step.** A lot of first-pass failures quietly clear themselves on the second try — re-running is almost always the right first move before anything fancier.

## The Trilogy

This is one of three repos in the cli-maxxing stack:

| Repo | What it does |
|------|-------------|
| **`cli-maxxing`** | **This repo** — Foundation — Claude Code, shell aliases, Ruflo, dev tools, productivity MCPs |
| [`creativity-maxxing`](https://github.com/lorecraft-io/creativity-maxxing) | Design skills + video/audio pipeline |
| [`task-maxxing`](https://github.com/lorecraft-io/task-maxxing) | Three-way task sync — Obsidian ↔ Notion ↔ Morgen (requires [`2ndBrain-mogging`](https://github.com/lorecraft-io/2ndBrain-mogging)) |

Install `cli-maxxing` first. `creativity-maxxing` and `task-maxxing` can be installed in either order after that.

## Quick Navigation

| | Section | What it does | Time |
|---|------|-------------|------|
| [Before You Start](#before-you-start) | Requirements | What you need before running anything | |
| [Install Everything](#install-everything) | One-shot | Run all steps at once | ~20 min |
| [How It Works](#how-it-works) | Overview | How the steps fit together | |
| [Keyboard + Command Cheat Sheet](#keyboard--command-cheat-sheet) | Commands & Shortcuts | Hotkeys, typing, and commands for your terminal | |
| [Step 1](#step-1---get-claude-running) | Get Claude Running | Sets up the foundation on your machine | ~5 min |
| [Bonus: Ghostty](#bonus---ghostty-terminal) | Ghostty Terminal | GPU-accelerated terminal with clickable links and tabs | ~2 min |
| [Bonus: Arc Browser](#bonus---arc-browser) | Arc Browser | The browser for power users — fast, clean, no tab clutter | ~2 min |
| [Step 2](#step-2---dev-tools) | Dev Tools | Adds file converters, search, utilities, and no-flicker mode | ~3 min |
| [Step 3](#step-3---ruflo--context-hub) | Ruflo + Context Hub | Multi-agent orchestration, API docs, Opus locked | ~3 min |
| [creativity-maxxing](https://github.com/lorecraft-io/creativity-maxxing) | Design + Media | UI/UX Pro Max, Taste Skill, 21st.dev Magic, Remotion, yt-dlp, Whisper, FFmpeg | [separate repo](https://github.com/lorecraft-io/creativity-maxxing) |
| [Step 6](#step-6---productivity-tools) | Productivity Tools | Notion + Granola + n8n + GCal + Morgen + Motion + Playwright + SwiftKit (pick what you use; Morgen recommended) | ~5 min |
| [2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing) | Second Brain | Obsidian vault setup, Claude history import, `cbrain`/`cbraintg` commands | [separate repo](https://github.com/lorecraft-io/2ndbrain-maxxing) |
| [Step 8](#step-8---telegram) | Telegram *(optional)* | Message Claude from your phone via Telegram bot | ~2 min |
| [Step 9](#step-9---safety-check) | Safety Check | Security auditing — scan any project for vulnerabilities + full MCP security checks | ~2 min |
| [Step 10](#step-10---developer-tools) | Developer Tools *(optional)* | GitHub MCP — repos, issues, PRs, code search via Claude (requires PAT) | ~2 min |
| [Final Step](#final-step---status-line) | Status Line + /gitfix | Final config — status indicators + /gitfix skill installed | ~2 min |
| [You're Ready](#youre-ready) | **Start here after setup** | Your daily command and what to do next | |
| [Video Tutorials (coming soon)](#video-tutorials-coming-soon) | Walkthroughs | Shows you exactly how to do everything, screen by screen | |
| [Staying Up to Date](#staying-up-to-date) | Update command | Re-run everything, catch new steps | |
| [Uninstall](#uninstall) | Remove everything | Reverses all steps, cleans up tools and config | |

---

## Before You Start

[Back to top](#quick-navigation)

> [!IMPORTANT]
> **You need a paid [claude.ai](https://claude.ai) subscription before anything below is useful.**
>
> The Claude Code CLI installs for free — but USING Claude requires a paid plan. If you don't have one yet, [sign up first](https://claude.ai) (Claude Pro is the minimum tier at $20/mo; Max is recommended for heavy use). Otherwise the installer downloads ~500 MB of tooling that has nothing to talk to.
>
> The installer will prompt you upfront — press Enter if you're subscribed, Ctrl+C to bail and sign up first.

- Your computer needs to be from roughly **2020 or later** (macOS Big Sur+ or a recent Linux).
- You need an **internet connection** since the scripts download everything live.
- **Don't run it as root.** Just open your terminal normally and paste the command.
- If anything is already installed on your machine, the scripts will detect that and skip it automatically.

> **Windows:** Not supported. This is built for macOS and Linux only.

---

## Install Everything

[Back to top](#quick-navigation)

If you already know your way around a terminal and just want everything installed at once:

> [!IMPORTANT]
> **Paste this into your terminal:**
> ```
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/install.sh)
> ```

This runs Steps 1, 2, 3, 9, and the Final Step automatically, plus both bonuses (Ghostty and Arc Browser). Arc is macOS-only and will be skipped on Linux. Everything is idempotent — already-installed tools are skipped.

**Steps that need interactive input** run separately after the above:

```bash
# Step 6 — Productivity Tools (Notion, Morgen, n8n, etc.)
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-6/step-6-install.sh)

# Step 8 — Telegram (optional — press Enter to skip if you don't have a bot token yet)
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-8/step-8-install.sh)

# Step 10 — Developer Tools (optional — GitHub MCP, skip if you don't need it)
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-10/step-10-install.sh)
```

We recommend reading through the steps below first so you understand what each tool does — but the one-shot option is here if you want it.

---

## How It Works

[Back to top](#quick-navigation)

Run the steps in order. Each one builds on the last.

**[Step 1](#step-1---get-claude-running)** is the only part that feels "techy." This step gets the bare essentials on your machine so Claude (your AI assistant) can run. You paste one command and it handles the rest, but there are a few manual steps after it finishes, like logging into Claude. This is the most hands-on part of the entire process. After Step 1, you can ask Claude questions at any point. If something doesn't make sense, just ask. That's the whole point.

**[Bonus: Ghostty](#bonus---ghostty-terminal)** is an optional step right after Step 1 that installs and configures Ghostty, a GPU-accelerated terminal. It's faster than CPU-rendered terminals, fully customizable, and has Cmd+Click support for opening URLs, file paths, and PDFs directly from the terminal. You don't need it to continue — everything works in any terminal — but if you want the nicest terminal experience, this is it.

**[Bonus: Arc Browser](#bonus---arc-browser)** is another optional step that installs Arc, a browser built from the ground up for people who actually use their computer all day. If you're still on Chrome or Safari, Arc is a massive upgrade — built-in tab management, Spaces for context switching, a sidebar instead of a tab bar, and it just feels faster. It imports everything from Chrome in about 30 seconds, so switching is painless. Highly recommended.

**[Step 2](#step-2---dev-tools)** is where you install the rest of your development tools. Things like file converters, search tools, and utilities. You run this from your terminal after Step 1 is done. Much more straightforward.

**[Step 3](#step-3---ruflo--context-hub)** is where you set up Ruflo and Context Hub. Ruflo is the multi-agent orchestration layer that turns Claude into a full team of AI agents. Context Hub stops Claude from hallucinating when writing code that calls APIs.

**[creativity-maxxing](https://github.com/lorecraft-io/creativity-maxxing)** adds professional design skills and a full video/audio production pipeline. Install it after this repo.

**[Step 6](#step-6---productivity-tools)** connects Claude to your productivity tools — notes, calendars, meetings, workflows, browser automation, and hosted toolkits. Pick the ones you use: Notion, Granola, your own n8n instance, Google Calendar, Morgen (recommended), Motion Calendar, Playwright, or SwiftKit. All optional, install only what you need.

**[2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing)** sets up your Obsidian PKM vault and installs `cbrain`/`cbraintg` commands. Install it after this repo.

**[Step 8](#step-8---telegram)** connects Claude to Telegram so you can message it straight from your phone. You create a free bot through Telegram (takes about two minutes), the script handles the rest, and then you use `ctg` or `cbraintg` to launch Claude with Telegram connected — messages show up in your session in real time. This step is completely optional; everything else works without it.

**[Step 9](#step-9---safety-check)** installs a security auditing skill that lets Claude scan any project for exposed keys, missing rate limiting, input sanitization gaps, dependency vulnerabilities, and more. Just point Claude at a project and ask it to run a safety check. It catches the stuff that slips through code review.

**[Step 10](#step-10---developer-tools)** is for developers only — it installs the GitHub MCP so Claude can read and write your repos, issues, pull requests, and search code across your GitHub organizations. Requires a GitHub Personal Access Token. Skip it if you don't use GitHub with Claude.

**[Final Step](#final-step---status-line)** is the wrap-up. It installs a custom status line that shows you what's active at a glance — your vault, MCP connection, design tools, and any running swarms, mini swarms, or hive-minds. It also installs the `/gitfix` skill and runs a final verification to make sure every command and tool from the cheat sheet is installed and working.

After the Final Step, head to **[You're Ready](#youre-ready)** — it tells you the one command you need going forward and what to do next.

Between Steps 1 and 2, make sure to read the **[Keyboard + Command Cheat Sheet](#keyboard--command-cheat-sheet)** so you know how to type, navigate, and use hotkeys in your terminal.

**[Video tutorials](#video-tutorials-coming-soon)** walking through every step are coming soon.

Already done with everything? Use the **[Staying Up to Date](#staying-up-to-date)** command to catch any new steps or updates that have been added since your last visit.

If you ever want to start fresh or remove everything this setup installed, there's a one-command **[Uninstall](#uninstall)** that reverses all steps. It won't touch your Obsidian vault or notes.

### Already have Claude Code installed?

If you already have Claude Code working on your machine, you can skip Step 1 entirely. Just jump straight to [Step 2](#step-2---dev-tools). Everything will work the same. You can paste the install commands directly in your terminal, or if you prefer, download this repo as a ZIP from GitHub, unzip it, and tell Claude to run the scripts from whatever folder they landed in.

### Bonus

Want to get better at using the terminal in general? Check out [Terminal Academy](https://github.com/lorecraft-io/terminal-academy), a gamified way to learn terminal commands and workflows. It makes the learning curve way less painful.

---

## [Keyboard + Command Cheat Sheet](CHEATSHEET.md)

[Back to top](#quick-navigation)

This is a quick reference for terminal hotkeys, typing basics, launching Claude, and useful commands. **Read this before starting the steps**, especially if you're new to working in a terminal.

**[Open the full Cheat Sheet →](CHEATSHEET.md)**

Here are the commands you'll use most:

| Command | What it does |
|---------|-------------|
| `cskip` | Start with all permissions skipped (fastest, no prompts) |
| `cbrain` | Jump straight into your 2ndBrain vault with permissions skipped *(requires [2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing))* |
| `Shift+Tab` | Toggle permissions on/off mid-session without restarting |
| `/rswarm *write task here*` | Launch a 15-agent swarm — just describe what you want in plain English after `/rswarm` |
| `/rmini *write task here*` | Launch a compact 5-agent swarm — same power, tighter team. Describe your task after `/rmini` |
| `/w4w` | Maximum attention to detail mode — word for word, line for line. No skipping, no summarizing, zero regard for credit burn |
| `Ctrl+C` | Stop whatever is running or exit Claude |
| `/resume` | Pick up right where you left off — reloads your last session's context |

Everything else — aliases, slash commands, natural-language tools, troubleshooting — is in the **[full Cheat Sheet](CHEATSHEET.md)**.

---

## Step 1 - Get Claude Running

[Back to top](#quick-navigation)

This step is the foundation. It installs the minimum needed to get Claude Code working on your machine.

**Heads up:** This is the most manual part of the setup. The script itself runs automatically, but afterwards you'll need to set up your Claude account yourself. Don't worry, it's all spelled out below. Once you're past this, Claude is there to help you with everything else.

### macOS / Linux

**How to open Terminal:** On Mac, press **Cmd+Space** to open Spotlight, type **Terminal**, and hit Enter. On Linux, look for "Terminal" in your applications menu, or press **Ctrl+Alt+T**.

> [!IMPORTANT]
> **Copy and paste this into Terminal, then hit Enter:**
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-1/step-1-install.sh)
> ```

> **It will ask for your Mac password.** The script needs it to install system tools. When you see `Password:`, type your Mac login password and hit Enter. The install will pause until you do this. You won't see what you're typing — no characters, no dots, just a lock icon or a blank line. That's normal. Just type it and press Enter.

### What This Step Installs

These are the tools that get installed automatically when you run the command above:

| Tool | What it does |
|------|-------------|
| Xcode CLT (Mac) / build-essential (Linux) | Build tools that other installers need. Runs automatically in the background. |
| Homebrew (Mac) / apt or dnf (Linux) | This is a package manager. It installs other software for you. |
| Git | This tracks and manages code changes. |
| nvm | Node Version Manager — installs and manages Node.js versions. |
| Node.js (v18+) | This runs JavaScript. Claude Code needs it to work. |
| Claude Code | This is your AI coding assistant. The main tool you'll be using. |
| Shell aliases | Shortcuts: `cskip`, `cc`, `ccr`, `ccc` — faster ways to launch Claude with different settings. |
| cbrain | Launches Claude pointed at your Obsidian vault. Your daily driver after setting up [2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing). Do not use until your vault is set up. |
| ctg | Launches Claude with Telegram connected from any directory. Includes a token check — exits cleanly if no token is configured. |
| cbraintg | Same as cbrain but with Telegram integration. Includes the same token check as ctg. |

### Shift+Tab — Toggle Permissions

When Claude is running in any terminal, you can press **Shift+Tab** to switch between normal mode (where Claude asks before doing anything) and auto-approve mode (where Claude just does it). No need to exit and relaunch. This works in any terminal app — Terminal.app, iTerm2, Ghostty, or whatever you prefer.

After the script finishes, you need to activate the tools that were just installed. Do these three things in order:

**1. Close this terminal and open a new one.**

This is the most important step. Homebrew, nvm, and the new shell aliases only load when a fresh shell starts. If you skip this, `claude` and `cskip` won't be found even though they're installed. Fully close the Terminal window (Cmd+Q on Mac works too) and open a new one.

**2. Verify Claude is working** — in the new terminal, run:

```bash
claude --version
```

You should see a version number like `2.1.112 (Claude Code)`. If you see that, you're good.

> If `claude --version` says "command not found," try `source ~/.zshrc` (or `source ~/.bashrc` if you're on Linux or still using bash). macOS uses zsh by default since Catalina, so `.zshrc` is almost always the right one. If that still doesn't work, see the [Troubleshooting](#troubleshooting) section below — specifically "I ran the installer but `claude` command is not found."

**3. Exit and switch to auto-approve mode:**

Press **Ctrl+C** to exit Claude, then run `cskip` to continue with auto-approve mode (Claude runs without asking permission for each action). This is the recommended way to work through the remaining setup steps.

### Set Up Your Claude Account

You'll need a Claude account with an active subscription before you can use Claude Code. **Do this now if you haven't already.** You won't be able to log in during Step 2 without it.

Sign up at [claude.ai](https://claude.ai).

#### Why Claude?

We use Claude because it's genuinely the best AI platform for the kind of work we do. Not marketing, just what we've seen firsthand. Claude consistently outperforms other models at understanding complex instructions, writing clean code, and reasoning through multi-step problems without losing the thread. They also ship new features incredibly fast. The pace of improvement is unreal.

But beyond the tech, we chose Anthropic for how they operate. Their CEO Dario Amodei left OpenAI specifically to take a more responsible approach to AI development. He's shown real backbone, including being willing to walk away from government contracts rather than compromise on their principles. Anthropic leads on safety research, they're transparent about what their models can and can't do, and they actually listen to their users when building new features. No shady practices, no cutting corners, no chasing hype at the expense of doing things right.

That philosophy shows up in how Claude actually works. It's careful, honest, and doesn't try to BS you when it doesn't know something.

Claude is the smartest tool in the room, built by people who actually care about getting this right.

#### Subscription Plans

Claude Code requires a paid plan. The software itself is free to install, but to actually use it you'll need one of these:

| Plan | Cost | What you get |
|------|------|-------------|
| **Claude Pro** | $20/month | Good for getting started. Handles everyday tasks like writing code, editing files, and answering questions. You'll hit usage limits if you run long sessions or do heavy back-to-back work. |
| **Claude Max 5x** | $100/month | This gives you 5x the usage of Pro. Best for people who use Claude throughout the day or run multi-step workflows. You can work for hours without hitting a wall. |
| **Claude Max 20x** | $200/month | This gives you 20x the usage of Pro. For power users running complex, long-running tasks like full codebase refactors, multi-agent swarms, or all-day sessions. Virtually unlimited for most people. |

**Our recommendation:** Start with **Pro** ($20/month). If you find yourself getting rate-limited or waiting for usage to reset, upgrade to Max. You'll know pretty quickly which tier fits your workflow.

That's it for Step 1. Continue to the [Ghostty bonus](#bonus---ghostty-terminal), the [Arc Browser bonus](#bonus---arc-browser), or jump straight to [Step 2](#step-2---dev-tools).

---

## Bonus - Ghostty Terminal

[Back to top](#quick-navigation)

This is optional. Everything in this setup works in any terminal app — Terminal.app, iTerm2, whatever you've got. But if you want a terminal that's noticeably faster, looks great out of the box, and lets you Cmd+Click URLs and file paths to open them instantly, Ghostty is worth the two minutes.

### Why Ghostty?

Ghostty is a GPU-accelerated terminal emulator. Most terminals (including Terminal.app) render text on the CPU. Ghostty uses Metal on Mac (and OpenGL on Linux), which means it draws frames faster, scrolls smoother, and handles large output without lagging. If you've ever had your terminal choke on a massive log dump or a long build output, you'll feel the difference.

Beyond speed, it's the customization and clickable links that make it worth switching:

- **GPU-accelerated rendering.** Metal on Mac, OpenGL on Linux. Noticeably faster than CPU-rendered terminals, especially with large output.
- **Tabbed interface with native title bar.** Looks and feels like a proper Mac app. Cmd+T for new tabs, red/yellow/green traffic light buttons, everything where you'd expect it.
- **Cmd+Click to open anything.** URLs open in your browser. File paths open in the associated app. PDFs, websites, local files — just hold Cmd and click. This is the single most useful terminal feature you didn't know you were missing.
- **Fully customizable.** Fonts, colors, padding, key bindings — everything is a plain text config file. No preferences UI to dig through, just edit the config and reload.
- **Lightweight.** Ghostty launches fast and stays out of your way. No account, no telemetry, no update nags.

This script installs Ghostty via Homebrew, sets up JetBrains Mono as the font, applies a dark color theme, configures the tabbed window style with traffic light buttons, enables Cmd+Click for URLs and file paths, and sets TextEdit as the default opener for text files so Cmd+Click on a `.md`, `.json`, or `.sh` file opens it right away.

### Install Ghostty

You can run this from your terminal directly — no Claude session needed:

> [!IMPORTANT]
> **Paste this into your terminal:**
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/bonus-ghostty/bonus-ghostty.sh)
> ```

Or if you're already in a Claude session, paste this:

> **Paste this into your Claude session:**
> ```
> run this command to install Ghostty: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/bonus-ghostty/bonus-ghostty.sh)
> ```

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| Ghostty | GPU-accelerated terminal emulator. Fast, lightweight, customizable. |
| JetBrains Mono | Clean monospace font designed for code. Installed via Homebrew. |
| Ghostty Config | Pre-configured with dark theme, tabbed interface, traffic light buttons, link clicking, and font settings. |
| duti (Mac) | File association manager. Sets TextEdit as the default opener for text files so Cmd+Click works the way you'd expect. |
| g2 (Mac) | Window tiling command. Type `g2` in your terminal to tile 2 Ghostty windows side by side, filling your screen. |
| g4 (Mac) | Window tiling command. Type `g4` to tile 4 Ghostty windows in a 2x2 grid. Great for running multiple Claude sessions at once. |

### After Installing

1. Open Ghostty — press **Cmd+Space**, type **Ghostty**, hit Enter.
2. All your shell aliases (`cskip`, `cbrain`, `cc`, etc.) work immediately. Nothing to reconfigure.
3. Try **Cmd+Click** on any URL or file path in the terminal output. It just opens.
4. Use **Cmd+T** to open new tabs.

### Customizing Ghostty

The config file is plain text:

- **Mac:** `~/Library/Application Support/com.mitchellh.ghostty/config`
- **Linux:** `~/.config/ghostty/config`

Edit it with any text editor. Changes take effect the next time you open a Ghostty window. Common tweaks:

| Setting | What it does | Default |
|---------|-------------|---------|
| `font-size` | Text size | `14` |
| `font-family` | Font face | `JetBrains Mono` |
| `background` | Background color (hex) | `000000` (black) |
| `window-padding-x` / `y` | Inner padding in pixels | `8` |
| `macos-titlebar-style` | Window style: `native`, `tabs`, or `transparent` | `tabs` |

Full docs: [ghostty.org/docs](https://ghostty.org/docs)

---

## Bonus - Arc Browser

[Back to top](#quick-navigation)

This is optional, but if you're still using Chrome, Safari, or Firefox as your daily driver — do yourself a favor and switch to Arc. It's not just another Chromium reskin. Arc was built from scratch for people who live in their browser, and once you use it for a week you genuinely won't want to go back.

### Why Arc?

Chrome is fine. It works. But it was designed in 2008 and it still feels like it. You've got 47 tabs open, you can't find anything, your browser is eating 8GB of RAM, and the tab bar is a graveyard of things you meant to read three weeks ago. Arc fixes all of that.

- **No tab bar.** Tabs live in a collapsible sidebar. Your screen is the website, not a row of tiny rectangles you can't read. It's immediately cleaner and you actually use more of your screen.
- **Spaces.** Group tabs by context — one Space for work, one for personal, one for a project. Swipe between them. It's like virtual desktops but for your browser. No more mixing your Jira tickets with your YouTube rabbit holes.
- **Pinned tabs that actually work.** Pin the sites you use every day (Gmail, Notion, calendar) to the top of your sidebar. They stay open, they stay fresh, and they don't get lost in a sea of other tabs.
- **Split view.** Open two pages side by side without a window manager. Drag a tab to the right and it snaps into place. Great for referencing docs while writing code, or comparing two pages.
- **Built-in ad blocking and tracker blocking.** No extensions needed. Pages load faster and you're not being surveilled by every ad network on the internet.
- **Command bar (Cmd+T).** This replaces the traditional URL bar with something closer to Spotlight. Search your open tabs, bookmarks, history, and the web from one place. It's fast and it learns your habits.
- **Little Arc.** Press a hotkey and get a tiny floating browser window for a quick search or link preview without leaving what you're doing. Dismiss it and you're right back.
- **Fast profile switching.** If you have multiple profiles (work, personal, client accounts), you can switch between them instantly from the sidebar. No logging out, no "Choose a profile" screen, no waiting. You just click between identities the same way you switch Spaces. It's the fastest multi-account workflow in any browser.
- **Automatic tab archiving.** Tabs you haven't looked at in 12 hours get archived automatically. They're not gone — you can find them — but they're not cluttering your sidebar. Your browser stays clean without you doing anything.
- **It's Chromium under the hood.** All your Chrome extensions work. 1Password, React DevTools, Vimium, whatever you use — it all carries over.

Arc is free. There's no premium tier or paywall. It's just a better browser.

### Switching from Chrome

This is the part that stops most people, and it shouldn't. Arc makes migration dead simple:

1. **Open Arc for the first time** and it asks if you want to import from Chrome.
2. **Say yes.** It pulls over your bookmarks, saved passwords, history, autofill data, and extensions. All of it. Takes about 30 seconds.
3. **Set Arc as your default browser** when it asks (or do it later in System Settings > Desktop & Dock > Default web browser).
4. That's it. You're done. Everything you had in Chrome is now in Arc.

You don't lose anything. Your Chrome profile stays untouched — you can always go back if you want. But you probably won't want to.

### Install Arc

You can run this from your terminal directly — no Claude session needed:

> [!IMPORTANT]
> **Paste this into your terminal:**
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/bonus-arc/bonus-arc.sh)
> ```

Or if you're already in a Claude session, paste this:

> **Paste this into your Claude session:**
> ```
> run this command to install Arc: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/bonus-arc/bonus-arc.sh)
> ```

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| Arc Browser | Chromium-based browser with sidebar tabs, Spaces, split view, built-in ad blocking, and automatic tab management. |

### After Installing

1. Open Arc — press **Cmd+Space**, type **Arc**, hit Enter.
2. Import your Chrome data when prompted (bookmarks, passwords, history, extensions).
3. Set it as your default browser when asked.
4. Press **Cmd+T** to open the command bar — this replaces the URL bar and it's way faster.
5. Try **Cmd+S** to pin a tab to your sidebar.

> **Note:** Arc is available on macOS and Windows. This install script uses Homebrew, so it only runs on macOS. If you're on Linux, this step will be skipped automatically.

---

## Step 2 - Dev Tools

[Back to top](#quick-navigation)

This step installs the development tools that Claude uses when working on your projects. Things like file converters, search tools, and other utilities that make Claude more capable.

#### 2a. Open Your Terminal

If you haven't already, open a fresh terminal window (press **Ctrl+C** first if something is still running in the old one, then close it).

#### 2b. Launch Claude

> [!IMPORTANT]
> **Type this in your terminal and hit Enter:**
> ```bash
> cskip
> ```

If this is your first time, Claude will automatically open a browser and ask you to log in. Sign in with your Anthropic account.

Once you're in a Claude session, you can ask it questions, and it will help you through the rest of the process. This is where it stops being manual and starts being a conversation.

> **Reminder:** You can press **Shift+Tab** at any time to toggle auto-approve permissions on or off without restarting Claude.

#### Why auto-approve mode?

When Claude runs in normal mode, it asks your permission before every single action. Every file it reads, every command it runs. During a setup that installs 10+ tools, that means dozens of approval prompts. There's no sound or notification when Claude is waiting for you, so if you look away for a moment, the whole process just sits there frozen until you come back and type "y".

**Auto-approve mode (`cskip`) lets Claude run without stopping to ask.** It will install everything in one smooth pass. You can watch it work in real time, you just don't have to babysit it.

You can always switch back to normal mode later for regular work. This is just for setup.

#### 2c. Run the install

Once you're inside the Claude session, paste this and hit Enter:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to install my dev tools: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-2/step-2-install.sh)
> ```


Claude will run the install for you. You can watch it work. If Claude tells you to restart your terminal at any point, just close the window, reopen your terminal, type `cskip` again, and let Claude know where you left off. It'll pick right back up.

### What This Step Installs

These are the tools that Claude will install for you:

| Tool | What it does |
|------|-------------|
| Python 3 + pip | This runs Python scripts and tools. |
| Pandoc | This converts documents like Word and PowerPoint files into text. |
| xlsx2csv | This converts spreadsheets into a readable format. |
| pdftotext | This extracts text from PDF files. |
| jq | This reads and edits config files. |
| ripgrep | This searches through code fast. Claude Code uses it internally. |
| GitHub CLI | This lets you manage GitHub from your terminal. |
| tree | This shows your folder structure visually. |
| fzf | This helps you find files and commands quickly. |
| wget | This downloads files from the web. |
| weasyprint | This converts HTML files to PDF. Used by Claude for generating documents. |
| No-flicker mode | This enables fullscreen rendering in Claude Code. The screen stops jumping and flickering while Claude is working. Scroll speed is set to 3 (matches vim). |
| Memory auto-save hook | This makes Claude automatically save important notes from your conversation when you end a session. You don't have to do anything. It just works in the background. |

### What's no-flicker mode?

Step 2 turns on fullscreen rendering in Claude Code. This is a research preview feature (requires Claude Code v2.1.89 or later, which Step 1 installs). Without it, the screen jumps and flashes while Claude is working — text scrolls past and the input box bounces around. With no-flicker mode on, the screen stays still. Your input box stays pinned to the bottom, and everything updates cleanly in place. It works by setting `CLAUDE_CODE_NO_FLICKER=1` in your shell profile.

It also sets your scroll speed to 3, so scrolling through the conversation with your mouse wheel feels smooth. You can also scroll with PgUp/PgDn or Ctrl+Home/End. Click on collapsed tool results to expand them, and click URLs to open them.

If you ever want to turn it off, open your `~/.zshrc` (or `~/.bashrc`) and delete these two lines:

```
export CLAUDE_CODE_NO_FLICKER=1
export CLAUDE_CODE_SCROLL_SPEED=3
```

Then close and reopen your terminal. You can also set `CLAUDE_CODE_NO_FLICKER=0` to disable it temporarily without removing the lines.

### What's the memory hook?

Step 2 also sets up something called a "stop hook." Every time you end a Claude session (by pressing Ctrl+C or typing `/exit`), Claude will automatically review the conversation and save anything important to memory. Things like decisions you made, preferences you mentioned, or context about what you were working on. Next time you start a session, Claude already knows that stuff. You don't have to repeat yourself.

You don't need to do anything to make this work. It's already configured. Just keep using Claude normally and it'll build up memory over time.

---

## Step 3 - Ruflo + Context Hub

[Back to top](#quick-navigation)

This step installs Ruflo, a multi-agent swarming layer that turns Claude from a single assistant into a full team of coordinated AI agents. Each agent focuses on a particular task, work is split up, done with more attention to detail: power in numbers. It also installs Context Hub, which makes sure those agents don't hallucinate when writing code that talks to external APIs.

### Ruflo

Built by [@ruvnet](https://github.com/ruvnet) ([repo](https://github.com/ruvnet/ruflo)). This is an open-source multi-agent orchestration system that sits on top of Claude Code.

> **Note:** We made one change from the default Ruflo setup. Out of the box, Ruflo uses a model routing system that can silently send some of your tasks to cheaper, weaker models like Haiku instead of Opus. If you're paying for Opus, you should always get Opus. Our install locks everything to Opus and disables the auto-downgrading. You can always turn routing back on later if you want to save on costs, but we default to giving you the best answers every time.

> This applies to all agents in the swarm — every agent spawned by `/rswarm`, `/rhive`, or `/rmini` runs on Opus. No agent is silently downgraded to a cheaper model.

Claude Code is already powerful on its own. But Ruflo takes it to another level by adding coordinated multi-agent workflows, persistent memory, and smart cost optimization on top:

- **Multiple agents working in parallel.** Claude can spin up several agents at once, each focused on a different part of your task. A researcher, a coder, a reviewer, all working simultaneously instead of one after the other.
- **Smart model routing (optional, disabled by default).** Ruflo can route simple tasks to cheaper models to save costs. We disable this by default and lock everything to Opus so you always get the best reasoning. If you want to enable cost savings later, you can turn routing back on. But we'd rather you get the best results out of the box.
- **Autonomous execution.** You describe what you want, and Ruflo figures out how to break it down, assign it, and execute it. You don't have to micromanage every step.
- **Persistent memory.** Ruflo has its own memory system that agents share. Context doesn't get lost between tasks or sessions. Your agents remember what they learned.
- **Self-healing workflows.** If something fails, Ruflo can detect it and recover automatically instead of just stopping.

### Context Hub

Built by [@andrewyng](https://github.com/andrewyng) ([repo](https://github.com/andrewyng/context-hub)). Andrew Ng is one of the most respected names in AI. He built this tool to solve a real problem: AI agents hallucinating API calls.

When Claude writes code that calls an external API, it's working from its training data, which can be outdated or just wrong. Context Hub fixes that by giving Claude access to curated, up-to-date API documentation on demand.

- **Accurate API docs.** Claude can look up the real function signatures, parameters, and usage patterns instead of guessing from memory.
- **Persistent annotations.** You and Claude can add notes to docs that carry over across sessions. If you figure out a quirk with an API, it stays documented.
- **Less hallucination.** This is the big one. Claude stops making up function names that don't exist.

Together, Ruflo and Context Hub are what take you from "using AI" to actually being an AI super user.

### Swarm Skills

Step 3 also installs three slash commands that let you launch multi-agent swarms on demand:

- **`/rswarm <task>`** — Launches 15 agents immediately. You describe the task, Claude assigns roles (architect, coders, testers, security auditor, etc.) and they all work in parallel. Use this when you know what you want done and want brute-force execution.

- **`/rmini <task>`** — Launches 5 agents immediately. Same architecture as `/rswarm` but with a tighter team: architect, developer, tester, reviewer, and researcher. Use this for focused tasks where you don't need the full battalion.

- **`/rhive <goal>`** — Launches a queen agent that autonomously manages everything. You describe the goal, the queen decides how to break it down, what workers to spawn, and how to coordinate them. Use this when you want to set a direction and step back.

#### Swarm tiers — extended thinking

Subagents inherit the parent session's model (Opus stays Opus) but do **not** inherit its extended-thinking setting. The `/effort` slider does not tether to spawned agents, so the only way to get deep thinking inside a swarm is to bake a trigger phrase into each Agent's prompt. That's what these tier variants do:

| Tier | Mini (5 agents) | Swarm (15 agents) | Trigger appended | Thinking budget |
|------|-----------------|-------------------|------------------|-----------------|
| 0    | `/rmini`        | `/rswarm`         | *(none)*         | 0               |
| 1    | `/rmini1`       | `/rswarm1`        | `Think.`         | ~4k             |
| 2    | `/rmini2`       | `/rswarm2`        | `Think hard.`    | ~10k            |
| 3    | `/rmini3`       | `/rswarm3`        | `Think harder.`  | ~31k            |
| max  | `/rminimax`     | `/rswarmmax`      | `Ultrathink.`    | ~32k (max)      |

Natural-language aliases also work: "hard"/"deep" → tier 2, "harder"/"deeper" → tier 3, "max"/"mega"/"ultra" → max.

Base `/rswarm` and `/rmini` are unchanged — the tier variants are purely additive. Use `/rminimax` for architecture reasoning or hairy debugging where you want a small team thinking hard; use `/rmini2` for routine feature work that still benefits from a bit of deliberation; reach for `/rswarm3` or `/rswarmmax` when you need 15 agents each chewing on a problem at full depth.

All 10 commands enforce Opus-only (never Haiku or Sonnet) and all share the same `/tmp/ruflo-{swarm,mini}-active` signal files, so the statusline indicators (🐝 for `/rswarm*`, 🍯 for `/rmini*`) fire for every tier.

All three skills signal the statusline so you can see live indicators while agents are working.

### Run Step 3

You should still have a Claude session open from Step 2. If you closed it, open your terminal and type `cskip` to start a new Claude session. Remember, you can press **Shift+Tab** at any time to toggle auto-approve on or off.

Once you're inside the Claude session, paste this and hit Enter:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to set up Ruflo and Context Hub: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-3/step-3-install.sh)
> ```


Claude will run the install for you. Same as Step 2. If Claude tells you to restart your terminal, close the window, reopen your terminal, type `cskip`, and let Claude know where you left off.

### Quick note: what's an MCP?

You'll see "MCP" mentioned here and in future steps. MCP stands for Model Context Protocol. Think of it as a plugin system for Claude. When you connect an MCP to Claude Code, you're giving Claude access to a new tool or data source it didn't have before. Claude can then use that tool automatically whenever it's relevant. You don't have to manage it. You just connect it once and Claude takes it from there.

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| Ruflo CLI | This is the command-line tool that manages everything below. |
| MCP Server Connection | This connects Ruflo to Claude Code so they can talk to each other (see above). |
| Ruflo Daemon | This runs in the background and coordinates agents, memory, and tasks. |
| Memory System | This gives your agents persistent, searchable memory across sessions. |
| Smart Model Routing | This is disabled by default so you always get Opus. Can be turned on later to save up to 75% on costs by routing simple tasks to cheaper models. |
| Opus Lock | This locks all tasks to Opus so nothing silently downgrades to a weaker model. You're paying for Opus, so you should always get Opus. |
| Context Hub | This gives Claude access to curated, up-to-date API documentation so it stops hallucinating function names. |
| Context Hub Skill | This teaches Claude when and how to look up API docs automatically before writing integration code. |
| Swarm Skill (`/rswarm`) | Type `/rswarm` followed by any task and Claude immediately launches 15 parallel agents to tackle it. A lead architect coordinates backend devs, testers, security auditors, and more — all working simultaneously. |
| Mini Swarm Skill (`/rmini`) | Type `/rmini` followed by any task and Claude launches 5 focused agents — architect, developer, tester, reviewer, and researcher. Same parallel execution as `/rswarm`, just a tighter team for focused work. |
| Hive Skill (`/rhive`) | Type `/rhive` followed by a goal and a queen agent takes full control. She decides what workers to spawn, how to coordinate them, and when the work is done. You set the goal and step back. |
| Attention Skill (`/w4w`) | Word-for-word, line-for-line mode. Maximum attention to detail for critical tasks. |
| TypeScript | Required by some Ruflo features. Installed globally. |
| agentic-flow | Enables embeddings and advanced routing capabilities. |
| Statusline | A real-time status bar that shows your active tools, model, session time, and context usage. When a swarm or hive is running, you'll see live indicators so you always know what's happening. |

### After Step 3

Your core tools are installed. Continue to Step 6 for productivity tools. For design tools and video/audio production, install [creativity-maxxing](https://github.com/lorecraft-io/creativity-maxxing). For your Obsidian knowledge base, install [2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing). Or open a new `cskip` session and try something ambitious. Ruflo kicks in automatically when the task calls for it.

### MCP Server Setup

Claude Code can connect to MCP (Model Context Protocol) servers for extended capabilities. After running Step 3 (Ruflo), the MCP server is configured automatically.

For manual MCP setup or troubleshooting, see the [Claude Code MCP documentation](https://docs.anthropic.com/en/docs/claude-code/mcp-servers).

#### Verify MCP Connection

After setup, verify the MCP server is connected:
```bash
claude mcp list
```

If the Ruflo MCP server isn't showing, re-add it:
```bash
claude mcp add ruflo -- npx -y ruflo@latest
```

---

## Step 4 - Design Tools

[Back to top](#quick-navigation)

> **This step has moved.**
>
> Design tools (UI/UX Pro Max, Taste Skill, and 21st.dev Magic) are now part of **[creativity-maxxing](https://github.com/lorecraft-io/creativity-maxxing)**.
>
> Install it after completing this repo:
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/creativity-maxxing/main/install.sh)
> ```
>
> creativity-maxxing also includes Step 5 (Remotion, YouTube Transcripts, yt-dlp, Whisper, FFmpeg). You get both in one install.

---

## Step 5 - Visual Media

[Back to top](#quick-navigation)

> **This step has moved.**
>
> Visual media tools (Remotion, YouTube Transcripts, yt-dlp, Whisper, and FFmpeg) are now part of **[creativity-maxxing](https://github.com/lorecraft-io/creativity-maxxing)**.
>
> Install it after completing this repo:
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/creativity-maxxing/main/install.sh)
> ```
>
> creativity-maxxing also includes Step 4 (UI/UX Pro Max, Taste Skill, 21st.dev Magic). You get both in one install.

---

## Step 6 - Productivity Tools

[Back to top](#quick-navigation)

This step connects Claude to the productivity tools you already use. Everything here is optional — install only the tools that match your workflow. Skip what you don't use.

Once installed, these tools work through natural language. No commands to memorize, no special syntax — you just talk to Claude the way you'd talk to a person:

- *"What's on my calendar this week?"*
- *"Add a task called 'Review contracts' due Friday, high priority"*
- *"Create a new page in Notion called Project Roadmap"*
- *"What were the key points from my last meeting?"*
- *"Trigger my lead-qualification workflow for this inbound email"*

Claude picks the right tool automatically based on what you ask. You never need to think about which MCP is handling it.

Step 6 installs eight optional tools in this order:

1. **Notion** — pages, databases, knowledge management
2. **Granola** — meeting transcripts and notes
3. **n8n** — your own n8n instance for workflow automation
4. **Google Calendar** — calendar events via Google OAuth
5. **Morgen** — unified calendar + tasks (recommended default)
6. **Motion Calendar** — Motion-specific events, teammate visibility
7. **Playwright** — browser automation via Microsoft's official `@playwright/mcp`
8. **SwiftKit** — hosted MCP toolkit with 100+ tools across services

> **Calendar recommendation:** Morgen (5) is the recommended default calendar + task tool. It unifies Google, Outlook, iCloud, and native tasks behind a single API key. Google Calendar (4) and Motion (6) are secondary — install them only if you specifically need direct access to those accounts.
>
> **Obsidian MCP?** That lives in [2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing), not here. Install 2ndbrain-maxxing after this repo completes — it handles vault setup AND registers the Obsidian MCP with Claude Code.

### Notion

Built by [@notionhq](https://github.com/makenotion/notion-mcp-server) — the official MCP server from Notion's own team. Gives Claude full access to your Notion workspace.

- **Read and search.** Search across all your pages and databases.
- **Create and edit.** Create new pages, append content, update existing pages — all in Markdown.
- **Databases.** Query, create, and update Notion databases.
- **22 tools** covering pages, databases, comments, and templates.

> **Requires:** A free Notion account and an integration token. Go to [notion.so/profile/integrations](https://www.notion.so/profile/integrations), create a new integration named "Claude Code", select your workspace, and copy the token (starts with `ntn_`). Then share any pages you want Claude to access: on each page, click the `...` menu > **Connections** > add your integration. Claude can only see pages you explicitly share.

### Granola

[Granola](https://granola.ai) is an AI meeting notes app for Mac. This MCP connects Claude to your Granola library — all your meeting transcripts and notes, searchable through conversation.

- **Meeting transcripts.** Ask Claude what was decided in a meeting, who said what, or what action items came out of it.
- **Search across meetings.** Find notes from a specific person, project, or topic without digging through folders.
- **Zero config.** No API keys needed — Granola handles auth through the app itself.

> **Requires:** Granola installed and signed in on your Mac. Get it at [granola.ai](https://granola.ai).

### n8n

Connect Claude to **your own** n8n instance (cloud or self-hosted) so Claude can trigger and inspect the workflows you've built. This is a thin HTTP bridge to an MCP Server Trigger node that you create inside your n8n workflow — it is NOT a hosted service. Everything runs against your own n8n.

- **Trigger workflows.** Ask Claude to run any workflow you've exposed through an MCP Server Trigger.
- **Pass structured inputs.** Claude can call the workflow with arbitrary JSON parameters.
- **Bring your own auth.** Optional Bearer Token if you've secured the trigger in n8n.

> **Requires:** An n8n instance you control (n8n Cloud or self-hosted), and a workflow that includes an **MCP Server Trigger** node. In n8n, create a workflow, add the MCP Server Trigger (search "MCP"), activate the workflow, and copy the Production URL the node shows. Paste that URL when the setup script asks for it. Docs: [docs.n8n.io/advanced-ai/mcp/mcp-server-trigger](https://docs.n8n.io/advanced-ai/mcp/mcp-server-trigger/).

### Google Calendar

Direct Google Calendar access via OAuth. This is a secondary calendar tool — if you have Morgen or Motion installed, Claude will use those first. Install Google Calendar only if you need direct access to a specific Google account that isn't synced through your primary calendar tool.

- **Direct Google access.** Reads and writes events on a specific Google Calendar account.
- **Independent auth.** Useful for a Google account that isn't wired into Morgen or Motion.

> **Requires:** A Google account and ~5 minutes to create OAuth credentials in Google Cloud Console. The setup script walks you through it.

### Morgen

**Recommended default.** Built by [@lorecraft-io](https://github.com/lorecraft-io/morgen-mcp). Wraps [Morgen](https://morgen.so)'s public API so Claude can read and change events across all your connected calendars (Google, Outlook, iCloud, native) AND manage Morgen tasks — all through a single API key.

- **Unified calendar.** Morgen aggregates all your calendar accounts. One MCP, all your events.
- **Tasks with auto-schedule.** Create tasks with due dates, priorities, and tag labels. Morgen's scheduler places them on your calendar automatically.
- **Natural-language dates and recurrence.** "next Tuesday at 3pm", "every other Thursday" — parsed and sent as proper JSCalendar recurrence.
- **Reflow your day.** Compress or rearrange your solo blocks back-to-back without touching real meetings.
- **Single API key.** No OAuth, no refresh tokens, no Firebase — just one key from the Morgen developer portal.

> **Requires:** A Morgen account and an API key from [platform.morgen.so/developers-api](https://platform.morgen.so/developers-api). The setup script asks for the key and an optional IANA timezone (defaults to `America/New_York`).

### Motion Calendar

Built by [@lorecraft-io](https://github.com/lorecraft-io/motion-mcp). A Motion-specific MCP that fills a few gaps Morgen doesn't cover — install this only if you specifically need Motion's teammate features or full event search.

- **Teammate visibility.** See when teammates are busy or out of office — something Morgen's API doesn't expose.
- **Full event search.** Query events by title or description across all your Motion calendars.
- **Direct calendar management.** Create and manage Motion's internal calendar objects.

> **Requires:** A Motion account and ~5 minutes to extract your API credentials (Motion API key, Firebase API key, Firebase refresh token, Motion user ID). The setup script walks you through it.

### Playwright

Built by [Microsoft](https://github.com/microsoft/playwright-mcp) — the official [`@playwright/mcp`](https://www.npmjs.com/package/@playwright/mcp) server. Lets Claude log into and operate web apps that don't have an API. Runs a separate Chromium instance — not your real browser — so Claude's automation is fully isolated from your own session.

- **Real Chromium, not a session hijack.** Playwright launches its own browser instance. Your Chrome/Arc profile, cookies, and tabs are untouched. Authenticated sessions Claude creates live inside Playwright's own user-data directory.
- **Structured DOM, not pixels.** Claude reads the page via accessibility-tree snapshots, not by guessing from screenshots. It sees button labels, input names, and link targets as structured data. Faster and dramatically more reliable than vision-based browser control.
- **Full automation surface.** Navigate, click, type, submit forms, follow links, take screenshots, and scrape content — all exposed as MCP tools Claude can invoke from natural language.
- **Best use case: no-API web apps.** Anything with a web UI but no public API (e.g. Higgsfield, scrappy internal tools, niche SaaS) becomes scriptable. Tell Claude to log in, navigate a few pages, fill a form, and report what it saw — Playwright handles the rest.
- **No credentials to configure.** Just install and start asking.

> **Requires:** Node.js 18+ (already installed in Step 1) and ~hundreds of MB of disk space for Chromium. Browser binaries auto-download on first use. Defaults to headed mode (you'll see the browser window); pass `--headless` to the server for background runs.
>
> **Scope note:** Playwright MCP is designed for productivity, not security isolation. Microsoft explicitly says "Playwright MCP is not a security boundary" — treat anything Claude loads through it with the same trust you'd give any browser session you drove manually.

### SwiftKit

Built by [SwiftKit](https://swiftkit.sh). A hosted MCP service that bundles 100+ tools across multiple services into a single HTTP endpoint. Instead of installing individual MCP servers for every service, SwiftKit provides a unified toolkit behind one API key.

- **Single endpoint, many tools.** One MCP connection gives Claude access to a wide range of capabilities across different services.
- **No local packages.** Everything runs on SwiftKit's hosted infrastructure — nothing to install, update, or maintain locally.
- **HTTP transport.** Connects via Bearer token auth over HTTPS. Your key is stored in Claude's MCP config only.

> **Requires:** A SwiftKit account and API key from [swiftkit.sh](https://swiftkit.sh). Sign up, generate a key (starts with `sk_live_` or `sk_test_`), and paste it when the setup script asks.

### Run Step 6

You should still have a Claude session open. If you closed it, open your terminal and type `cskip` to start a new Claude session.

Once you're inside the Claude session, paste this and hit Enter:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to install productivity tools: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-6/step-6-install.sh)
> ```

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| Notion MCP | Official Notion integration — pages, databases, search, content management. 22 tools. |
| Granola MCP | Meeting transcript access — search and query your Granola meeting notes through conversation. |
| n8n MCP | HTTP bridge to YOUR OWN n8n instance — trigger and inspect workflows you built. |
| Google Calendar MCP | Direct Google Calendar access via OAuth — secondary, install only if needed. |
| Morgen MCP | **Recommended default.** Unified calendar + tasks across Google/Outlook/iCloud/native. Single API key. |
| Motion Calendar MCP | Motion-specific MCP for teammate visibility and full event search. Secondary. |
| Playwright MCP | Microsoft's official browser automation — runs a separate Chromium instance (not your browser), uses accessibility-tree snapshots instead of pixels. Lets Claude log into and operate web apps that have no API. No credentials. |
| SwiftKit MCP | Hosted MCP toolkit by [SwiftKit](https://swiftkit.sh) — 100+ tools across services behind a single HTTP endpoint. Bearer token auth, nothing to install locally. |

### After Step 6

You now have your productivity stack connected to Claude. Ask about your schedule, add a task, query Notion, trigger a workflow — all from your terminal. If you skipped any tools, you can always come back and re-run Step 6 to add them. For the Obsidian MCP and vault access, install [2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing).

---

## Step 7 — Second Brain (Obsidian)

[Back to top](#quick-navigation)

> **This step has moved.** See [lorecraft-io/2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing).

2ndbrain-maxxing sets up your Obsidian knowledge base, imports your Claude conversation history, and installs `cbrain`/`cbraintg` commands. Install it after completing cli-maxxing.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/2ndbrain-maxxing/main/install.sh)
```

---

## Step 8 - Telegram

[Back to top](#quick-navigation)

This step connects Claude to Telegram so you can message it from your phone. You create a bot on Telegram using @BotFather (free, takes about 2 minutes), then the script configures it locally. After setup, you can send Claude messages, photos, and files from anywhere — your phone, tablet, or any device with Telegram installed. The `ctg` command (already installed in Step 1) launches Claude with Telegram connected, and `cbraintg` does the same but also opens your 2ndBrain vault (requires [2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing)). This step is optional but makes Claude accessible from your pocket.

### What It Sets Up

| Component | What it does |
|-----------|--------------|
| Telegram Bot | Your personal bot created via @BotFather on Telegram |
| Bot Token | Stored locally at `~/.claude/channels/telegram/.env` |
| Access Policy | Controls who can message your bot (default: ask before accepting) |
| `ctg` command | Launch Claude with Telegram from any directory (installed in Step 1) |
| `cbraintg` command | Launch Claude with Telegram inside your 2ndBrain vault (installed in Step 1) |

### Run Step 8

> [!NOTE]
> Step 8 is interactive — it will ask you to create a bot on Telegram and paste the token. The whole process takes about 2 minutes.

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to set up Telegram: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-8/step-8-install.sh)
> ```

### After Step 8

Open a new terminal and run `ctg` to launch Claude with Telegram connected. Inside your Claude session, tell it to pair your Telegram bot. Once paired, messages you send from Telegram will appear in your Claude session in real time. You can also use `cbraintg` to launch with both Telegram and your 2ndBrain vault loaded.

> **If you see repeating `TELEGRAM_BOT_TOKEN required` warnings that won't stop:** Press **Ctrl+C** to exit. Your token isn't being detected — Claude Code keeps restarting the Telegram channel in a loop. Use `cskip` instead of `ctg` to continue setup, and troubleshoot Telegram separately later. See [Troubleshooting → Telegram: stuck in a warning loop](#telegram-stuck-in-a-warning-loop-after-setup).

---

## Step 9 - Safety Check

[Back to top](#quick-navigation)

This step installs a security auditing skill that lets Claude scan any project for vulnerabilities. Exposed API keys, missing rate limiting, input sanitization gaps, dependency vulnerabilities, insecure configurations — the stuff that slips through code review. For MCP projects, it automatically activates 12 additional checks covering tool poisoning, prompt injection vectors, transport security, authentication, and supply chain attacks. You point Claude at a project and tell it to run a safety check. It does the rest.

### What It Does

The `/safetycheck` skill gives Claude a structured security audit framework. Instead of asking Claude to "look for security issues" and hoping for the best, this skill runs a systematic scan across the categories that actually matter:

**API Security (all projects):**
- **Exposed secrets.** API keys, tokens, passwords hardcoded in source files, git history, or MCP config files.
- **Missing rate limiting.** Endpoints that accept unlimited requests without throttling.
- **Input sanitization gaps.** User input flowing into queries, commands, file paths, or MCP tool handlers without validation.
- **Dependency vulnerabilities.** Known CVEs in npm/pip packages, including MCP SDK version checks.
- **Insecure configurations.** CORS misconfigurations, missing .gitignore entries, untracked secrets.

**MCP Security (auto-activated for MCP projects):**
- **Tool description integrity.** Hidden instructions, file path references, and injection markers in tool descriptions.
- **Unicode smuggling.** Invisible Unicode characters used to hide malicious instructions from human reviewers.
- **MCP transport security.** DNS rebinding vulnerabilities, HTTP vs HTTPS, known CVEs (CVE-2025-66414, CVE-2025-66416).
- **MCP authentication.** Missing bearer auth on HTTP-based MCP servers.
- **Supply chain hygiene.** `@latest` floating versions, rug-pull risk, unverified packages in MCP configs.
- **Tool response sanitization.** Stack traces and raw errors leaking through tool results.
- **Audit logging.** Missing structured logging for tool invocations.

This isn't a replacement for a full security audit. It's a first line of defense — the kind of check you should run before every deploy, every PR, every time you hand code off to someone else.

### Run Step 9

You should still have a Claude session open. If you closed it, open your terminal and type `cskip` to start a new Claude session.

Once you're inside the Claude session, paste this and hit Enter:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to install the safety check skill: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-9/step-9-install.sh)
> ```

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| Safety Check Skill (`/safetycheck`) | A Claude Code skill that runs 8 API security checks on any project, plus 12 MCP-specific checks when an MCP project is detected. Covers tool poisoning, prompt injection vectors, DNS rebinding CVEs, supply chain attacks, and more. |

### After Step 9

Open any project in Claude and type `/safetycheck` to run a security audit. For standard projects, Claude runs 8 checks and reports findings by severity. For MCP projects, it automatically detects the project type and activates 12 additional MCP-specific checks. You can also ask Claude to "run a safety check" in plain English — the skill kicks in automatically.

---

## Step 10 - Developer Tools

[Back to top](#quick-navigation)

This step is for developers who want Claude to have direct access to their GitHub repositories, issues, pull requests, and code search. It's completely optional — skip it if you don't use GitHub with Claude, and everything else still works.

### What It Installs

The [GitHub MCP server](https://github.com/modelcontextprotocol/servers/tree/main/src/github) (`@modelcontextprotocol/server-github`) gives Claude a structured tool interface for reading and writing GitHub resources — repos, issues, PRs, files, code search, branches, commits. Once installed, you can ask Claude things like "list open PRs on lorecraft-io/cli-maxxing", "create an issue for this bug", or "search my repos for any file that uses `MORGEN_API_KEY`" and it'll just work.

### Before You Run It

You need a GitHub Personal Access Token (classic PAT). Create one at [github.com/settings/tokens/new](https://github.com/settings/tokens/new):

- **Token name:** `claude-github-mcp`
- **Expiration:** No expiration (or pick whatever you're comfortable with)
- **Scopes:** check only `repo`, `read:org` (under `admin:org`), and `gist`

Click **Generate token** and copy the `ghp_...` value. You'll paste it into the install script.

### Run Step 10

```
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-10/step-10-install.sh)
```

The script prompts for your PAT, registers the GitHub MCP with Claude Code, and injects the token into your local MCP config only — nothing is written to disk outside of `~/.claude.json` (same place every other MCP credential lives).

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| GitHub MCP (`@modelcontextprotocol/server-github`) | Claude Code MCP server that exposes GitHub API operations as tools — read/write repos, issues, PRs, code search, branches, commits. |

### After Step 10

Ask Claude to "list my open GitHub issues" or "create a PR on cli-maxxing" and the MCP tools kick in automatically. If you ever need to rotate the token, re-run Step 10 — it'll overwrite the entry in your MCP config.

---

## Final Step - Status Line + /gitfix

[Back to top](#quick-navigation)

This is the wrap-up step. It installs a custom status line that shows you what's active at a glance — your vault, MCP connection, design tools, and any running swarms, mini swarms, or hive-minds. It also installs the `/gitfix` skill.

### What It Sets Up

**Status line indicators:**

| Component | What it shows |
|-----------|--------------|
| ⚡ Ruflo | The Ruflo MCP server is connected |
| 🎨 UIPro | Design skill is loaded (installed with [creativity-maxxing](https://github.com/lorecraft-io/creativity-maxxing)) |
| 🐝 Swarm | A swarm is active (shows agent count during `/rswarm`) |
| 🍯 Mini | A mini swarm is active (shows agent count during `/rmini`) |
| 👑 Hive | A hive-mind is active (during `/rhive`) |

The status line also shows your current model, session duration, and context window usage.

> **2ndbrain-maxxing adds a 🧠 brain indicator** that lights up when you're working inside your Obsidian vault. It's part of [2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing)'s statusline patch.

**`/gitfix` skill:**

Also installed here. Type `/gitfix` inside any Claude session when you want to do a full repo sync — it reads every install script, skill file, and documentation file in the repo, finds every gap between the code and the docs, and fixes all of it. Use it any time you make changes to a repo and need everything to reflect reality.

### Run Final Step

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to set up your status line: bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-final/step-final-install.sh)
> ```

Or manually:
1. Copy `statusline.sh` to `~/.claude/statusline.sh`
2. Add to your `~/.claude/settings.json`:
```json
"statusLine": {
  "type": "command",
  "command": "~/.claude/statusline.sh"
}
```
3. Restart Claude Code

### Verify Everything Works

After the status line installs, run a quick check to make sure every command, skill, and tool from the setup was installed correctly.

> [!IMPORTANT]
> **Open a new `cskip` session and paste this:**
> ```
> Open the cheat sheet at CHEATSHEET.md in this repo and go through every command, skill, and tool listed there. For each one, verify it's installed and working on my machine. If anything is missing, broken, or not configured, fix it. Give me a summary of what passed and what you had to fix.
> ```

This tells Claude to cross-reference the cheatsheet against your actual system and fill in any gaps. It's the final sanity check — if a skill didn't install, an MCP didn't connect, or an alias didn't register, Claude will catch it and fix it right there.

> **Note:** Use `cskip` for this step, not `cbrain`. The `cbrain` command requires your Obsidian vault to exist. If you haven't run 2ndbrain-maxxing yet, or if something went wrong during vault setup, `cbrain` will error out. `cskip` always works.

### After Final Step

Setup is complete. Head to **[You're Ready](#youre-ready)** below for your daily command.

---

## Troubleshooting

[Back to top](#quick-navigation)

### I ran the installer but `claude` command is not found

First install has a catch: the installer adds Homebrew, nvm, and the shell aliases to your config files, but those only load when a brand new shell starts. On top of that, the script may have been running in bash while your default shell on modern macOS is zsh — so even `source`-ing the file the script wrote can miss.

**Fix:**
1. Fully close the terminal window (Cmd+Q on Mac works too).
2. Open a fresh terminal.
3. Run `claude --version`. You should see something like `2.1.112 (Claude Code)`.

If it's still missing after a fresh terminal, paste the **Reset PATH (stuck install)** block from [CHEATSHEET.md](CHEATSHEET.md#reset-path-stuck-install) — it rewires `~/.zshrc` with Homebrew shellenv, nvm, `~/.local/bin`, and the four aliases in one shot.

### Some steps say "Homebrew not found" during install

Step 1 installs Homebrew mid-pipeline and the downstream steps in the same shell session don't see it yet — the installer hadn't refreshed PATH for subsequent commands. Known issue, fixed 2026-04-17.

**Fix:** close the terminal, open a fresh one, and re-run the installer:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/install.sh)
```
It's idempotent — anything already installed gets skipped.

### I see the zsh/bash shell prompt change after install

The installer detects your default shell and writes integrations accordingly. On modern macOS, zsh is the default even if `/etc/passwd` still says bash (Terminal.app overrides passwd with the "default login shell" preference), so you may notice your prompt looks different after a fresh terminal.

**Fix:** confirm which shell you're actually in:
```bash
echo $SHELL
```
If you want your passwd entry to match what Terminal.app uses, run:
```bash
chsh -s /bin/zsh
```
This is optional — everything works fine either way. The installer writes to both `~/.zshrc` and `~/.bashrc` so both shells pick up the aliases.

### xlsx2csv failed to install

Python 3.9 (the macOS default) ships with PEP 668 restrictions that block `pip install` into the system Python. The installer now uses `pipx` to work around this.

**Fix:** re-run Step 2:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-2/step-2-install.sh)
```
If it's still failing, install manually:
```bash
brew install pipx
pipx install xlsx2csv
```

### I want to completely remove everything

Run the uninstall script:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/uninstall.sh)
```

This removes the cli-maxxing aliases (`cskip`, `cc`, `ccr`, `ccc`), the `ctg`/`cbrain`/`cbraintg` scripts in `~/.local/bin/`, all MCP servers, skills, and breadcrumbs this setup dropped. See the [Uninstall](#uninstall) section below for the full list.

It does **not** remove Homebrew, nvm, Node.js, or Claude Code itself — those are general-purpose tools you might use outside of cli-maxxing. The uninstall script will show you how to remove them manually if you want a completely clean machine.

### Telegram: pressing Enter skips setup

This is intentional. If you press Enter without pasting a token, the script skips Telegram setup and continues. You can always re-run Step 8 later when you have your bot token ready.

### Telegram: stuck in a warning loop after setup

If you launch Claude with `ctg` or `cbraintg` and see a stream of repeating messages like `telegram channel: TELEGRAM_BOT_TOKEN required` that never stops — your bot token isn't being detected.

**What's happening:** Claude Code is trying to start the Telegram channel, the server exits immediately because there's no token, and then Claude Code restarts it — over and over. This creates an infinite loop of warning messages in your terminal.

**Fix:**
1. Press **Ctrl+C** to kill the session
2. Continue with the remaining setup steps using `cskip` (no Telegram) instead of `ctg`
3. Come back to Telegram troubleshooting later — type `cskip`, then ask Claude: *"My Telegram bot token isn't being detected — can you check my config at ~/.claude/channels/telegram/ and fix it?"*

The most common cause is the token file being missing or in the wrong format. Re-running Step 8 (`bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-8/step-8-install.sh)`) and re-entering your token usually resolves it.

### Step 6 (Productivity Tools) skips when run through the update command

Step 6 requires interactive input for API credentials. When run via `curl | bash` (including through the update command), it detects non-interactive mode and exits with instructions.

**Fix:** Run Step 6 directly in your terminal:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-6/step-6-install.sh)
```

### Obsidian MCP returns internal errors

See the [2ndbrain-maxxing troubleshooting guide](https://github.com/lorecraft-io/2ndbrain-maxxing#troubleshooting). The Obsidian MCP is installed and configured by 2ndbrain-maxxing.

### `cbrain` says it can't find my vault

See [2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing) — vault setup is handled there. If your vault exists but isn't found, set `VAULT_PATH=/path/to/your/vault cbrain`.


### A step failed or something is missing

Run the update command to re-run everything. It skips what's already installed and fills in any gaps:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/update.sh)
```

Or open a `cskip` session and describe the problem to Claude. It can diagnose and fix most issues on the spot.

---

## You're Ready

[Back to top](#quick-navigation)

### Quick MCP Check

Before you dive into `cbrain`, take 30 seconds to verify your MCP connections are live. Open a new terminal and run:

```
cskip
```

Once you're inside Claude, type:

```
/mcp
```

This shows every MCP server and its connection status. Everything you installed — Ruflo, Notion, Granola, n8n, Morgen, Motion Calendar, Google Calendar, Playwright, SwiftKit, Obsidian (from 2ndbrain-maxxing), design tools (from creativity-maxxing) — should show as **Connected**. If anything shows as failed or disconnected, just tell Claude:

> "One of my MCP servers isn't connecting — can you troubleshoot it?"

Claude will diagnose and fix it on the spot. Once everything is green, you're ready.

---

Everything is installed, configured, and wired together. From now on, this is the only command you need:

> [!IMPORTANT]
> **Your daily command:**
> ```
> cbrain
> ```

That's it. `cbrain` opens Claude Code directly inside your 2ndBrain vault with all permissions skipped. Your vault is your home base — every tool, skill, and MCP server you just installed is available the moment you type it.

> **Haven't run 2ndbrain-maxxing yet?** Use `cskip` instead of `cbrain` until your Second Brain vault is set up. `cbrain` requires the Obsidian vault to exist — it will error if you haven't created one. Once [2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing) is complete, switch to `cbrain` as your daily driver.

**What `cbrain` gives you:**
- Drops you into your Obsidian vault automatically — no `cd`-ing around
- All permissions skipped — Claude acts immediately, no approval prompts
- Full access to everything: `/rswarm` (+ tiers `1`/`2`/`3`/`max`), `/rmini` (+ tiers `1`/`2`/`3`/`max`), `/rhive`, `/w4w`, `/safetycheck`, `/gitfix`, Ruflo, Context Hub, Morgen, Motion Calendar, Notion, Obsidian, Granola, n8n, design tools, video tools — all of it
- Your status line shows what's active at a glance

**When to use something else:**
- `cskip` — when you need to work outside your vault (a different project, a random folder)
- `cbraintg` — same as `cbrain` but with your Telegram channel connected
- `ctg` — skip-permissions + Telegram from any directory

But for day-to-day use? Just type `cbrain` and go.

---

## Installation Order

[Back to top](#quick-navigation)

Run the steps in this order:

| Step | Name | What it does |
|------|------|-------------|
| 1 | CLI Basics | Git, Node.js, Claude Code, shell aliases |
| Bonus | Ghostty Terminal | GPU-accelerated terminal (optional) |
| Bonus | Arc Browser | Power-user browser with sidebar tabs (optional, macOS) |
| 2 | Dev Tools | Python, Pandoc, jq, ripgrep, no-flicker mode, etc. |
| 3 | Ruflo + Context Hub | Multi-agent orchestration + API docs |
| 4 | Design Tools | → **[creativity-maxxing](https://github.com/lorecraft-io/creativity-maxxing)** (UI/UX Pro Max, Taste Skill, 21st.dev Magic) |
| 5 | Visual Media | → **[creativity-maxxing](https://github.com/lorecraft-io/creativity-maxxing)** (Remotion, YouTube Transcripts, yt-dlp, Whisper, FFmpeg) |
| 6 | Productivity Tools | Notion + Granola + n8n + Google Calendar + Morgen + Motion Calendar + Playwright + SwiftKit (all optional — pick what you use; Morgen recommended) |
| 7 | Second Brain | → **[2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing)** (Obsidian vault setup, Claude history import, `cbrain`/`cbraintg`) |
| 8 | Telegram *(optional)* | Telegram bot setup — message Claude from your phone. Press Enter to skip if you don't have a bot yet. |
| 9 | Safety Check | Security auditing — 8 API checks + 12 MCP checks for tool poisoning, DNS rebinding, supply chain attacks |
| **Final** | **Status Line + /gitfix** | **Final config — status indicators, system health check, /gitfix skill** |

> **Note:** Step 6 (Productivity Tools) is all optional — install only the tools you use. Steps 4 and 5 are handled by [creativity-maxxing](https://github.com/lorecraft-io/creativity-maxxing). Step 7 (Second Brain) is handled by [2ndbrain-maxxing](https://github.com/lorecraft-io/2ndbrain-maxxing). Step 8 (Telegram) is completely optional — press Enter to skip if you don't have a bot token yet; you can always re-run it later. Step 9 (Safety Check) installs a security auditing skill — 8 standard checks for any project, plus 12 MCP-specific checks that auto-activate when an MCP project is detected. The Final Step (Status Line + /gitfix) is the wrap-up — it wires your status indicators, installs the /gitfix skill, and runs a system health check.

---

## Video Tutorials *(coming soon)*

[Back to top](#quick-navigation)

Video walkthroughs for every step are coming soon. These will show you exactly what to do, screen by screen, so you can follow along at your own pace.

---

## Staying Up to Date

[Back to top](#quick-navigation)

This command re-runs every step, skips anything already installed, and picks up anything new. It covers everything in this repo as of right now. If new steps get added in the future, the update command will include them too.

Open your terminal and run `cskip` to start a Claude session, then paste the update command. Or if you prefer, just paste it directly into your terminal without Claude.

> [!IMPORTANT]
> **Paste this into your terminal:**
> ```
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/update.sh)
> ```


---

## Uninstall

[Back to top](#quick-navigation)

If you need to remove everything installed by this setup, the uninstall script reverses all steps. It removes Claude Code, MCP servers, skills, shell aliases, dev tools, and brew packages. Your Obsidian vault and notes are never touched.

> [!IMPORTANT]
> **Paste this into your terminal:**
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/uninstall.sh)
> ```

**What it removes:**
- Claude Code + shell aliases (`cskip`, `cc`, `ccr`, `ccc`) and scripts (`ctg`, `cbrain`, `cbraintg` in `~/.local/bin/`)
- All MCP servers (Ruflo, Notion, Granola, n8n, Morgen, Motion Calendar, Playwright, SwiftKit) — Magic, YouTube Transcript, yt-dlp, Whisper, and Obsidian are managed by the companion repos
- All skills (rswarm, rmini, rhive, w4w, get-api-docs, gitfix, safetycheck) — UI/UX Pro Max, Taste Skill pack, and Remotion are managed by creativity-maxxing
- Dev tools (pandoc, jq, ripgrep, gh, tree, fzf, wget, weasyprint, ffmpeg, xlsx2csv, poppler)
- Whisper models (~/.whisper/)
- Motion Calendar config (~/.motion-mcp/)
- Google Calendar config (~/.google-calendar-mcp/)
- Arc Browser (if installed via the bonus script)
- Ghostty config (the app itself is kept — only the config file installed by this setup is removed)
- Status line config

**What it does NOT remove:**
- Homebrew, Git, Node.js (other tools may depend on these — the script shows you how to remove them manually if you want)
- Your Obsidian vault and notes
- Your Claude account

---

## More Coming Soon

[Back to top](#quick-navigation)

This setup is a living project. New steps, tools, and workflows will be added as they're ready. If you have the update command above, you'll always be able to catch up with one paste.

---

## License

MIT — see [LICENSE](LICENSE).

---

Built by [Nate Davidovich / Lorecraft](https://github.com/lorecraft-io)

[⤴ back to top](#top)
