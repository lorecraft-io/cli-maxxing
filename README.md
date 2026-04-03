# CLI Maxxing

Everything you need to start working with AI-powered development tools, installed in the right order with one command per step.

## Quick Nav

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
| [Step 4](#step-4---design-tools) | Design Tools | UI/UX skills + component generation | ~3 min |
| [Step 5](#step-5---visual-media) | Visual Media | Remotion video creation + YouTube transcripts + Instagram/social transcription | ~5 min |
| [Step 6](#step-6---productivity-tools) | Productivity Tools | Motion Calendar + Notion (pick what you use) | ~5 min |
| [Step 7](#step-7---second-brain-obsidian) | Second Brain (Obsidian) | Personal knowledge management system | ~30+ min |
| [Step 8](#step-8---status-line) | Status Line | Final config — status indicators wired up | ~2 min |
| [Video Tutorials (coming soon)](#video-tutorials-coming-soon) | Walkthroughs | Shows you exactly how to do everything, screen by screen | |
| [Staying Up to Date](#staying-up-to-date) | Update command | Re-run everything, catch new steps | |
| [Uninstall](#uninstall) | Remove everything | Reverses all steps, cleans up tools and config | |

---

## Before You Start

[Back to top](#quick-nav)

- Your computer needs to be from roughly **2020 or later** (macOS Big Sur+ or a recent Linux).
- You need an **internet connection** since the scripts download everything live.
- **Don't run it as root.** Just open your terminal normally and paste the command.
- If anything is already installed on your machine, the scripts will detect that and skip it automatically.

> **Windows:** Not supported. This is built for macOS and Linux only.

---

## Install Everything

[Back to top](#quick-nav)

If you already know your way around a terminal and just want everything installed at once, you can run the full setup in one shot. This runs all eight steps in order, skips anything already installed, and picks up anything new.

> [!IMPORTANT]
> **Paste this into your terminal:**
> ```
> curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/update.sh | bash
> ```

This includes both bonuses (Ghostty and Arc Browser). Arc is macOS-only and will be skipped on Linux. Step 6 (Productivity Tools) will pause to ask which tools you want, so it's not completely hands-free. Everything else runs automatically.

We recommend reading through the steps below first so you understand what each tool does — but the one-shot option is here if you want it.

---

## How It Works

[Back to top](#quick-nav)

There are eight steps. Run them in order. Each one builds on the last.

**[Step 1](#step-1---get-claude-running)** is the only part that feels "techy." This step gets the bare essentials on your machine so Claude (your AI assistant) can run. You paste one command and it handles the rest, but there are a few manual steps after it finishes, like logging into Claude. This is the most hands-on part of the entire process. After Step 1, you can ask Claude questions at any point. If something doesn't make sense, just ask. That's the whole point.

**[Bonus: Ghostty](#bonus---ghostty-terminal)** is an optional step right after Step 1 that installs and configures Ghostty, a GPU-accelerated terminal. It's faster than CPU-rendered terminals, fully customizable, and has Cmd+Click support for opening URLs, file paths, and PDFs directly from the terminal. You don't need it to continue — everything works in any terminal — but if you want the nicest terminal experience, this is it.

**[Bonus: Arc Browser](#bonus---arc-browser)** is another optional step that installs Arc, a browser built from the ground up for people who actually use their computer all day. If you're still on Chrome or Safari, Arc is a massive upgrade — built-in tab management, Spaces for context switching, a sidebar instead of a tab bar, and it just feels faster. It imports everything from Chrome in about 30 seconds, so switching is painless. Highly recommended.

**[Step 2](#step-2---dev-tools)** is where you install the rest of your development tools. Things like file converters, search tools, and utilities. You run this from your terminal after Step 1 is done. Much more straightforward.

**[Step 3](#step-3---ruflo--context-hub)** is where you set up Ruflo and Context Hub. Ruflo is the multi-agent orchestration layer that turns Claude into a full team of AI agents. Context Hub stops Claude from hallucinating when writing code that calls APIs.

**[Step 4](#step-4---design-tools)** gives Claude professional design skills and a library of production-ready UI components.

**[Step 5](#step-5---visual-media)** gives Claude the ability to create videos programmatically using React, pull transcripts from any YouTube video, and download + transcribe content from Instagram Reels and other social platforms. Animations, captions, transitions, data visualizations — all generated from code. YouTube transcripts — just paste a link. Instagram Reels — paste a link and Claude downloads the audio and transcribes it locally.

**[Step 6](#step-6---productivity-tools)** connects Claude to your productivity tools — your calendar and your notes. Pick the ones you use: Motion Calendar for seeing and managing your schedule, or Notion for your knowledge base. All optional, install only what you need.

**[Step 7](#step-7---second-brain-obsidian)** sets up your personal knowledge management system in Obsidian. This is the biggest step but also the most rewarding. It's the transition from setup to daily use.

**[Step 8](#step-8---status-line)** is the wrap-up. It installs a custom status line that shows you what's active at a glance — your vault, MCP connection, design tools, and any running swarms, mini swarms, or hive-minds. After this, you're done.

Between Steps 1 and 2, make sure to read the **[Keyboard + Command Cheat Sheet](#keyboard--command-cheat-sheet)** so you know how to type, navigate, and use hotkeys in your terminal.

**[Video tutorials](#video-tutorials-coming-soon)** walking through every step are coming soon.

Already done with everything? Use the **[Staying Up to Date](#staying-up-to-date)** command to catch any new steps or updates that have been added since your last visit.

If you ever want to start fresh or remove everything this setup installed, there's a one-command **[Uninstall](#uninstall)** that reverses all eight steps. It won't touch your Obsidian vault or notes.

### Already have Claude Code installed?

If you already have Claude Code working on your machine, you can skip Step 1 entirely. Just jump straight to [Step 2](#step-2---dev-tools). Everything will work the same. You can paste the install commands directly in your terminal, or if you prefer, download this repo as a ZIP from GitHub, unzip it, and tell Claude to run the scripts from whatever folder they landed in.

### Bonus

Want to get better at using the terminal in general? Check out [Terminal Academy](https://github.com/lorecraft-io/terminal-academy), a gamified way to learn terminal commands and workflows. It makes the learning curve way less painful.

---

## [Keyboard + Command Cheat Sheet](CHEATSHEET.md)

[Back to top](#quick-nav)

This is a quick reference for terminal hotkeys, typing basics, launching Claude, and useful commands. **Read this before starting the steps**, especially if you're new to working in a terminal.

**[Open the full Cheat Sheet →](CHEATSHEET.md)**

Here are the eight commands you'll use most:

| Command | What it does |
|---------|-------------|
| `cskip` | Start with all permissions skipped (fastest, no prompts) |
| `cbrain` | Jump straight into your 2ndBrain vault with permissions skipped *(requires Obsidian — set up in [Step 7](#step-7---second-brain-obsidian))* |
| `Shift+Tab` | Toggle permissions on/off mid-session without restarting |
| `/rswarm *write task here*` | Launch a 15-agent swarm — just describe what you want in plain English after `/rswarm` |
| `/rmini *write task here*` | Launch a compact 5-agent swarm — same power, tighter team. Describe your task after `/rmini` |
| `/w4w` | Maximum attention to detail mode — word for word, line for line. No skipping, no summarizing, zero regard for credit burn |
| `Ctrl+C` | Stop whatever is running or exit Claude |
| `/resume` | Pick up right where you left off — reloads your last session's context |

Everything else — aliases, slash commands, natural-language tools, troubleshooting — is in the **[full Cheat Sheet](CHEATSHEET.md)**.

---

## Step 1 - Get Claude Running

[Back to top](#quick-nav)

This step is the foundation. It installs the minimum needed to get Claude Code working on your machine.

**Heads up:** This is the most manual part of the setup. The script itself runs automatically, but afterwards you'll need to set up your Claude account yourself. Don't worry, it's all spelled out below. Once you're past this, Claude is there to help you with everything else.

### macOS / Linux

**How to open Terminal:** On Mac, press **Cmd+Space** to open Spotlight, type **Terminal**, and hit Enter. On Linux, look for "Terminal" in your applications menu, or press **Ctrl+Alt+T**.

> [!IMPORTANT]
> **Copy and paste this into Terminal, then hit Enter:**
> ```bash
> curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-1/step-1-install.sh | bash
> ```

### What This Step Installs

These are the tools that get installed automatically when you run the command above:

| Tool | What it does |
|------|-------------|
| Homebrew (Mac) / apt or dnf (Linux) | This is a package manager. It installs other software for you. |
| Git | This tracks and manages code changes. |
| Node.js (v18+) | This runs JavaScript. Claude Code needs it to work. |
| Claude Code | This is your AI coding assistant. The main tool you'll be using. |

### Shift+Tab — Toggle Permissions

When Claude is running in any terminal, you can press **Shift+Tab** to switch between normal mode (where Claude asks before doing anything) and auto-approve mode (where Claude just does it). No need to exit and relaunch. This works in any terminal app — Terminal.app, iTerm2, Ghostty, or whatever you prefer.

After the script finishes, you need to activate the tools that were just installed. Do these three things in order:

**1. Reload your shell config** — copy and paste this, then hit Enter:

```bash
source ~/.zshrc
```

> On Linux or if you use bash, run `source ~/.bashrc` instead.

**2. Close the terminal window and reopen it.**

**3. Verify Claude is working:**

```bash
claude --version
```

If you see a version number, you're good. If not, repeat steps 1 and 2.

**4. Exit and switch to auto-approve mode:**

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

[Back to top](#quick-nav)

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
> curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/bonus-ghostty/bonus-ghostty.sh | bash
> ```

Or if you're already in a Claude session, paste this:

> **Paste this into your Claude session:**
> ```
> run this command to install Ghostty: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/bonus-ghostty/bonus-ghostty.sh | bash
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

[Back to top](#quick-nav)

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
> curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/bonus-arc/bonus-arc.sh | bash
> ```

Or if you're already in a Claude session, paste this:

> **Paste this into your Claude session:**
> ```
> run this command to install Arc: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/bonus-arc/bonus-arc.sh | bash
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

[Back to top](#quick-nav)

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
> run this command to install my dev tools: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-2/step-2-install.sh | bash
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

[Back to top](#quick-nav)

This step installs Ruflo, a multi-agent swarming layer that turns Claude from a single assistant into a full team of coordinated AI agents. Each agent focuses on a particular task, work is split up, done with more attention to detail: power in numbers. It also installs Context Hub, which makes sure those agents don't hallucinate when writing code that talks to external APIs.

### Ruflo

Built by [@ruvnet](https://github.com/ruvnet) ([repo](https://github.com/ruvnet/ruflo)). This is an open-source multi-agent orchestration system that sits on top of Claude Code.

> **Note:** We made one change from the default Ruflo setup. Out of the box, Ruflo uses a model routing system that can silently send some of your tasks to cheaper, weaker models like Haiku instead of Opus. If you're paying for Opus, you should always get Opus. Our install locks everything to Opus and disables the auto-downgrading. You can always turn routing back on later if you want to save on costs, but we default to giving you the best answers every time.

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

Both skills signal the statusline so you can see live indicators while agents are working.

### Run Step 3

You should still have a Claude session open from Step 2. If you closed it, open your terminal and type `cskip` to start a new Claude session. Remember, you can press **Shift+Tab** at any time to toggle auto-approve on or off.

Once you're inside the Claude session, paste this and hit Enter:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to set up Ruflo and Context Hub: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-3/step-3-install.sh | bash
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
| Statusline | A real-time status bar that shows your active tools, model, session time, and context usage. When a swarm or hive is running, you'll see live indicators so you always know what's happening. |

### After Step 3

Your core tools are installed. Continue to Step 4 for design tools, Step 5 for visual media, and Step 6 for your productivity tools. Or open a new `cskip` session and try something ambitious. Ruflo kicks in automatically when the task calls for it.

### MCP Server Setup

Claude Code can connect to MCP (Model Context Protocol) servers for extended capabilities. After running Step 3 (Ruflo), the MCP server is configured automatically.

For manual MCP setup or troubleshooting, see the [Claude Code MCP documentation](https://docs.claude.ai/en/docs/mcp-servers).

#### Verify MCP Connection

After setup, verify the MCP server is connected:
```bash
claude mcp list
```

If the Ruflo MCP server isn't showing, re-add it:
```bash
claude mcp add claude-flow -- npx -y @claude-flow/cli@latest
```

---

## Step 4 - Design Tools

[Back to top](#quick-nav)

This step supercharges how Claude handles anything visual. It installs two tools that make Claude dramatically better at building user interfaces, web pages, apps, and anything design-related.

### UI/UX Pro Max Skill

Built by [@nextlevelbuilder](https://github.com/nextlevelbuilder) ([repo](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)). This is an open-source design intelligence engine that gives Claude professional-level UI/UX knowledge.

Without this skill, Claude generates generic-looking interfaces. With it, Claude has access to:

- **161 industry-specific design rules.** Claude knows how a fintech dashboard should look different from a fitness app or a restaurant website.
- **67 UI styles.** Glassmorphism, Brutalism, Dark Mode, Neumorphism, and more. You can just say the style you want and Claude nails it.
- **161 color palettes and 57 font pairings.** No more default blues and grays. Claude picks cohesive, professional color schemes and typography.
- **99 UX guidelines.** Accessibility, responsive layouts, user flow patterns. Claude doesn't just make things look good, it makes things that actually work.
- **13 tech stacks supported.** React, Vue, Flutter, SwiftUI, Tailwind, and more. The skill adapts to whatever you're building with.

You don't have to tell Claude to "use the UI/UX skill." It activates automatically whenever you ask for anything design-related. Just describe what you want and Claude will generate a complete design system before writing a single line of code.

### 21st.dev Magic MCP

Built by the team at [@21st-dev](https://github.com/21st-dev) ([site](https://21st.dev)). This connects Claude to a massive library of production-ready UI components.

While the UI/UX Pro Max Skill handles the design thinking, 21st.dev Magic handles the actual components. Claude can pull from a library of pre-built, beautifully designed React components and assemble them into whatever you're building.

- **Production-ready components.** Not rough prototypes. These are polished, responsive, accessible components you can ship.
- **Huge library.** Buttons, cards, modals, navigation, forms, dashboards, and more. Claude picks the right ones for your design.
- **Works right inside Claude.** Once connected, Claude just uses the components automatically when building UI.

**Setting up 21st.dev requires a free account.** The script will install the MCP connection, but you'll also need to do this:

1. Go to [21st.dev](https://21st.dev) and create a free account. No payment needed to start.
2. Once logged in, go to the [Magic MCP setup page](https://21st.dev/magic-chat?mcp_section=true) and follow their instructions. They'll give you a command to run.
3. If the auto-install didn't connect it, the setup page will walk you through it.

### Run Step 4

You should still have a Claude session open. If you closed it, open your terminal and type `cskip` to start a new Claude session.

Once you're inside the Claude session, paste this and hit Enter:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to install design tools: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-4/step-4-install.sh | bash
> ```


### After the script runs, set up 21st.dev

The UI/UX Pro Max Skill installs automatically. But 21st.dev needs you to create an account:

1. Go to [21st.dev](https://21st.dev)
2. Sign up for free (no payment required)
3. Go to the [Magic MCP setup page](https://21st.dev/magic-chat?mcp_section=true) and follow their instructions. They'll give you a command to paste in your terminal.
4. Once connected, Claude will automatically use their component library when building UI.

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| UI/UX Pro Max Skill | This gives Claude professional design intelligence. 161 design rules, 67 styles, 161 palettes, 57 font pairings, 99 UX guidelines. |
| 21st.dev Magic MCP | This connects Claude to a library of production-ready UI components it can use when building interfaces. |
| Pretext Skill | Text measurement and layout tool via @chenglou/pretext. Use the `/pretext` command for shrinkwrap, profiling, and variable-width flow. |

---

## Step 5 - Visual Media

[Back to top](#quick-nav)

This step gives Claude the ability to create videos programmatically using React, pull transcripts from any YouTube video, and download + transcribe audio from Instagram Reels and other social platforms — all locally on your machine. Instead of editing video in a timeline tool, you describe what you want and Claude writes code that generates the video. Animations, captions, transitions, data visualizations, 3D content — all from code. Need a transcript? Just paste a YouTube or Instagram link.

### Remotion

Built by [@remotion-dev](https://github.com/remotion-dev) ([site](https://remotion.dev)). Remotion is a framework for creating videos using React. You write React components and Remotion renders them into actual video files.

This is not screen recording or template filling. It's real programmatic video creation:

- **React-based video.** Every frame is a React component. If you can build it in React, you can turn it into a video.
- **Animations and transitions.** Spring animations, easing curves, scene transitions, text animations — all built in.
- **Captions and subtitles.** Automatic caption generation and styling, synced to audio.
- **Audio and sound.** Import audio, control volume, trim, adjust speed and pitch, add sound effects, visualize audio as waveforms or spectrum bars.
- **3D content.** Three.js and React Three Fiber integration for 3D scenes in your videos.
- **Charts and data viz.** Bar charts, pie charts, line charts, stock charts — animated and rendered as video.
- **Maps.** Animated Mapbox maps in your videos.
- **FFmpeg integration.** Trim videos, detect silence, process audio — the heavy-duty video operations.
- **Parametric videos.** Define a schema and generate different versions of the same video with different data.

The Remotion skill teaches Claude best practices, patterns, and techniques for all of these. Claude doesn't just know about Remotion — it knows the right way to use it.

### YouTube Transcripts

Built by [@kimtaeyoon83](https://github.com/kimtaeyoon83/mcp-server-youtube-transcript). This MCP server pulls transcripts from any YouTube video — no API key, no paid service, completely free.

- **Just paste a link.** Give Claude a YouTube URL and ask for the transcript. That's it.
- **Language support.** Request transcripts in any available language with automatic fallback.
- **Timestamps.** Include or exclude timestamps in the output.
- **Ad filtering.** Sponsorship and ad segments are stripped out automatically.
- **Works with Shorts.** YouTube Shorts URLs and bare video IDs work too.

This is useful for research, content repurposing, note-taking, summarizing videos, or feeding video content into your Second Brain.

### Instagram + Social Media Transcription

This gives Claude the ability to transcribe audio from Instagram Reels, TikToks, Twitter/X videos, and other social platforms — completely locally on your machine. It works by combining two tools behind the scenes: [yt-dlp](https://github.com/yt-dlp/yt-dlp) (a widely-used open-source media downloader) handles the downloading, and [Whisper](https://github.com/jwulff/whisper-mcp) (OpenAI's speech-to-text model) handles the transcription. No API keys, no cloud services.

- **Paste any link.** Instagram Reels, TikToks, Twitter/X posts, Facebook videos — if the platform is supported, Claude can download it.
- **Local transcription.** Audio is transcribed on your machine using OpenAI's Whisper model. Nothing leaves your computer.
- **Multiple models.** The default is base, which is a good balance of speed and accuracy. You can also use tiny (fastest), small, medium, or large (most accurate) if you need to.
- **First run downloads the model.** The first time you transcribe, Claude downloads the Whisper model (~148 MB for base). After that, there's no download wait.
- **Output formats.** Plain text, timestamped, or structured JSON.

The flow is simple: paste a link → Claude downloads the audio → Whisper transcribes it → you get the text. Works great for capturing ideas from Reels, transcribing interviews, pulling quotes, or feeding social content into your Second Brain.

### Run Step 5

You should still have a Claude session open. If you closed it, open your terminal and type `cskip` to start a new Claude session.

Once you're inside the Claude session, paste this and hit Enter:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to install visual media tools: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-5/step-5-install.sh | bash
> ```


### What This Step Installs

| Component | What it does |
|-----------|-------------|
| Remotion Skills | Teaches Claude best practices for programmatic video creation with React — animations, transitions, captions, audio, 3D, charts, and more. |
| YouTube Transcript MCP | Pulls transcripts from any YouTube video. Free, no API key needed. Supports language selection, timestamps, and ad filtering. |
| yt-dlp MCP | Downloads audio/video from Instagram Reels, TikTok, Twitter/X, and many other platforms. Used to grab audio for local transcription. |
| yt-dlp CLI | The command-line downloader that powers the yt-dlp MCP. Installed via Homebrew (macOS) or your system package manager (Linux). |
| whisper-cpp | The transcription engine that actually converts speech to text. Installed via Homebrew on Mac, built from source on Linux. |
| Whisper MCP | Connects whisper-cpp to Claude so it can transcribe audio files on demand. Runs entirely on your machine — no API keys, no cloud. |
| FFmpeg | Powerful command-line tool for video and audio processing. Used by Remotion for rendering and by Claude for media operations. |

### After Step 5

You're now set up for visual media creation. Ask Claude to create a Remotion project and describe the video you want. Claude will scaffold the project, write the components, and you can render the output. You can also paste any YouTube link and ask Claude for the transcript — it'll pull it automatically. For Instagram Reels, TikToks, or other social media, just paste the link and ask Claude to transcribe it. The first time, it'll download the Whisper model (~148 MB), then there's no download wait after that.

---

## Step 6 - Productivity Tools

[Back to top](#quick-nav)

This step connects Claude to the productivity tools you already use. Everything here is optional — install only the tools that match your workflow. Skip what you don't use.

Once installed, these tools work through natural language. No commands to memorize, no special syntax — you just talk to Claude the way you'd talk to a person:

- *"What's on my calendar today?"*
- *"Am I free Thursday afternoon?"*
- *"Schedule a meeting called Team Sync tomorrow at 2pm"*
- *"Search my Notion for the meeting notes from last week"*
- *"Create a new page in Notion called Project Roadmap"*

Claude picks the right tool automatically based on what you ask. You never need to think about which MCP is handling it.

### Motion Calendar

Built by [@lorecraft-io](https://github.com/lorecraft-io/motion-calendar-mcp). This is a custom MCP that gives Claude full access to your Motion calendar — something Motion's own public API doesn't support. While other Motion integrations are limited to tasks and projects, this one reads, creates, updates, and deletes calendar events directly.

- **See your schedule.** Ask Claude what's on your calendar today, this week, or any date range.
- **Check availability.** Ask when you're free and Claude will find open slots across all your calendars.
- **Create and manage events.** Schedule meetings, rename events, move them around, or delete them — all from your terminal.
- **Search events.** Find that meeting you forgot the name of by searching titles and descriptions.
- **Teammate visibility.** See when teammates are busy or out of office.
- **All your calendars.** Motion aggregates Google Calendar, Outlook, and others into one place. This MCP sees all of them.

> **Requires:** A Motion account and ~5 minutes to extract your API credentials. The setup script walks you through it.

### Notion

Built by [@notionhq](https://github.com/makenotion/notion-mcp-server) — the official MCP server from Notion's own team. Gives Claude full access to your Notion workspace.

- **Read and search.** Search across all your pages and databases.
- **Create and edit.** Create new pages, append content, update existing pages — all in Markdown.
- **Databases.** Query, create, and update Notion databases.
- **22 tools** covering pages, databases, comments, and templates.

> **Requires:** A free Notion account and an integration token. Go to [notion.so/profile/integrations](https://www.notion.so/profile/integrations), create a new integration named "Claude Code", select your workspace, and copy the token (starts with `ntn_`). Then share any pages you want Claude to access: on each page, click the `...` menu > **Connections** > add your integration. Claude can only see pages you explicitly share.

### Run Step 6

You should still have a Claude session open. If you closed it, open your terminal and type `cskip` to start a new Claude session.

Once you're inside the Claude session, paste this and hit Enter:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to install productivity tools: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-6/step-6-install.sh | bash
> ```

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| Motion Calendar MCP | Full calendar access — events, availability, scheduling. Uses Motion's internal API for features the public API doesn't have. |
| Notion MCP | Official Notion integration — pages, databases, search, content management. 22 tools. |

### After Step 6

You now have your productivity stack connected to Claude. Ask about your schedule, create tasks, search your Notion — all from your terminal. If you skipped any tools, you can always come back and re-run Step 6 to add them.

---

## Step 7 - Second Brain (Obsidian)

[Back to top](#quick-nav)

This is the biggest step. It sets up your personal knowledge management system, a "Second Brain" that captures, connects, and retrieves everything you know and everything you're working on. This step takes real time. Don't rush it.

> **Heads up:** This step has multiple parts (7a through 7d). Each one is its own script. Take them one at a time.

### What is a Second Brain?

Your brain is great at having ideas. It's terrible at storing them. You read an article, have an insight, learn something useful, and a week later it's gone. A Second Brain is a system outside your head that captures all of that, organizes it, and makes it findable later. Instead of trying to remember everything, you write it down in a structured way and let the system do the remembering for you.

This isn't just note-taking. It's building a personal knowledge base that grows smarter over time. Every note you add connects to other notes. Over months and years, you end up with a web of knowledge that's uniquely yours.

### What is Obsidian?

[Obsidian](https://obsidian.md) is a free note-taking app that stores everything as plain text files on your computer. No cloud lock-in, no subscription required, your notes are just files in a folder. But the magic is in how Obsidian connects them.

Every note can link to any other note using `[[wikilinks]]`. You type `[[` and start typing a concept, and Obsidian lets you link to it. Over time, these links create a web of connected knowledge that you can actually visualize.

### What is Zettelkasten?

Zettelkasten is a German word that means "slip box." It's a method for organizing knowledge that was invented by a sociologist named Niklas Luhmann who used it to write over 70 books and 400 academic papers. The core idea is simple:

- **One idea per note.** Each note captures a single concept, written in your own words.
- **Link everything.** Every note connects to related notes. The value isn't in any single note, it's in the connections between them.
- **Let structure emerge.** You don't start with a rigid folder hierarchy. You start by writing notes and linking them, and the structure reveals itself over time.

Obsidian is the perfect tool for Zettelkasten because it makes linking effortless and lets you see your entire knowledge web as a visual graph.

### The Node Graph

This is the part that clicks for most people. Obsidian has a graph view that shows every note as a dot and every link as a line between dots. When you first start, it's a handful of scattered points. But as you add notes and link them, clusters form. You can literally see which topics are deeply connected and which ones are isolated. It's your knowledge, visualized.

The more you link, the more useful it gets. Claude will help you create these links automatically.

### What You're About to Set Up

The folder structure we use is based on Zettelkasten principles:

| Folder | What goes in it |
|--------|----------------|
| **00-Inbox** | Raw captures. URLs, quick thoughts, anything unprocessed. This is your dumping ground. |
| **01-Fleeting** | Quick ideas and thoughts, lightly formatted. Shower thoughts, observations, things you want to remember. |
| **02-Literature** | Notes from articles, videos, books, podcasts. Summarized in your own words with a source link. |
| **03-Permanent** | Refined, atomic notes. One clear concept per note, written as if explaining to someone else. Densely linked. These are the core of your knowledge graph. |
| **04-MOC** | Maps of Content. Index notes that group and link related permanent notes. Think of these as tables of contents for topic areas. |
| **05-Templates** | Note templates for each type above. Claude uses these when creating new notes. |
| **06-Assets** | Images, PDFs, attachments. Anything that isn't a text note. |
| **07-Projects** | Active projects. Each one gets its own folder with an index note. If you use Claude Projects, you can mirror your Claude project names here. |

### Step 7a - Install Obsidian + Create Your Vault

This part installs Obsidian on your machine and has Claude set up the full folder structure for you.

**First, install Obsidian:**

- **Mac:** Press **Cmd+Space**, type **Terminal**, and run: `brew install --cask obsidian`
- **Linux:** `sudo snap install obsidian` or `sudo flatpak install obsidian` or download from [obsidian.md](https://obsidian.md)

Or just go to [obsidian.md/download](https://obsidian.md/download) and download it directly.

**Then, open Obsidian and create your vault:**

1. Open Obsidian. **How to find it:** On Mac, press **Cmd+Space** and type **Obsidian**. On Linux, look for "Obsidian" in your applications menu.
2. Click **Create new vault**
3. Name it something you'll remember. "2ndBrain" or "Second-Brain" or "Vault" all work fine.
4. For the location, pick somewhere easy to find. We recommend your **Desktop** or a **Documents** folder. Don't bury it deep in some random directory.
5. Click **Create**

Obsidian will open with an empty vault. That's perfect. Now Claude will set it up for you.

**Open your terminal, run cskip, and paste this:**

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to set up my Second Brain vault structure: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-7/step-7a-setup-vault.sh | bash
> ```


Claude will ask you where your vault is located, then:

- Create all the Zettelkasten folders (00-Inbox through 07-Projects)
- Drop in ready-to-use **note templates** for each note type (Fleeting, Literature, Permanent, MOC) so Claude and you always create notes in a consistent format
- Create the **CLAUDE.md** file that teaches Claude how to work with your vault going forward (linking conventions, frontmatter standards, tagging rules, note types)
- Set up the **WebFetch workflow** so Claude knows how to capture content from URLs into your vault (it pulls the page, creates a Literature Note, extracts permanent notes, and links everything)
- Set up a **sync automation script** you can run later to keep things tidy

### Step 7b - Import Your Claude History

Before importing your other notes, let's get your Claude conversation history in first. This helps because some people name their vault project folders after their Claude Projects, and having that data available makes the whole organization process smoother.

**Download your Claude data:**

1. Go to [claude.ai](https://claude.ai) in your browser
2. Click your profile icon (bottom left)
3. Go to **Settings**
4. Go to **Privacy**
5. Click **Download my data** and select **All time** for the date range
6. Click **Request download**
7. Check your email. Anthropic will send you a download link. This can take a few minutes.
8. Download the zip file and save it somewhere easy to find (like your Desktop)

**Once you have the zip file, go back to your cskip session and paste this:**

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to import my Claude history into my vault: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-7/step-7b-import-claude.sh | bash
> ```


Claude will ask you where the zip file is, then:

- Parse your conversations and sort them into the right vault folders
- Create **project folders** in `07-Projects/` based on your Claude Projects (you can name them whatever you want, Claude will ask)
- Generate a **project index note** for each project with a knowledge base summary and conversation log links
- Convert conversation highlights into **literature notes** in `02-Literature/`
- Extract key concepts into **permanent notes** in `03-Permanent/`
- Start building **bidirectional links** between related projects and notes

### Step 7c - Import Your Existing Notes

Now let's get the rest of your notes in. If you have notes in Apple Notes, Google Keep, Notion, Evernote, or any other app, this step helps you export them and bring them into your vault.

**For Apple Notes (Mac):**

1. Download [Apple Notes Exporter](https://apps.apple.com/us/app/exporter/id1099120373) from the App Store. This is a free app that exports your Apple Notes as files Claude can read.
2. **How to find it after downloading:** Check your Downloads folder. On Mac, press **Cmd+Space** and type the app name. On Linux, check your applications menu.
3. Open it, select the notes you want to export, and save them to a folder you can find easily.

**For other apps (Notion, Evernote, Google Keep, OneNote):**
- Most note apps have an export feature somewhere in their settings. Export as markdown if possible, HTML if not.
- Save everything to a single folder.

**Once you have your exported notes in a folder, go back to your cskip session and paste this:**

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to import my notes into my vault: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-7/step-7c-import-notes.sh | bash
> ```


Claude will ask you where your exported notes are, what format they're in, and then:

- **Convert files to markdown** using Pandoc (installed in Step 2). This handles Word docs (.docx), PowerPoint (.pptx), Excel spreadsheets (.xlsx), and HTML files. Everything becomes clean, linkable markdown.
- **Validate every file.** Claude checks for corrupt, empty, or fake files (like a .pdf that's actually an empty text file) and flags them.
- **Move everything into the Inbox** for processing in Step 7d.
- **Ask you how you want to organize things.** Claude will have a conversation with you about what folders make sense for your notes, what categories you care about, and how you want things grouped. This isn't one-size-fits-all. Your vault should reflect how your brain works.

### Step 7d - Wire It All Up

This is where the magic happens. Claude goes through everything in your vault and connects it all together. This is the stuff that would take you hours to do manually. Claude does it in minutes.

What Claude will do:
- **Process your Inbox.** Sort raw captures into Fleeting, Literature, or Permanent notes based on what they are.
- **Create wikilinks.** Find related concepts across your notes and link them together with `[[wikilinks]]`. Claude looks at every note and asks "what else in this vault relates to this?" Then it creates the links.
- **Fix bidirectional links.** Make sure if Note A links to Note B, Note B also links back to Note A. This is critical for the graph to work properly.
- **Build Maps of Content.** Create MOC index notes that group related permanent notes by topic. These are like tables of contents for different areas of your knowledge.
- **Create project index notes.** Each project in `07-Projects/` gets an index note with a summary, knowledge base links, and conversation log references.
- **Convert tables to bullet lists.** Obsidian's graph view doesn't detect wikilinks that are inside markdown tables. Claude converts them to bullet lists so every link shows up in the graph.
- **Validate files.** Catch any corrupt, empty, or misplaced files and flag them for you.
- **Add frontmatter.** Every note gets proper YAML frontmatter (title, date, type, tags, source, related) so Obsidian can filter and search them.
- **Set up the sync script.** A simple script you can run anytime to re-process your Inbox, fix broken links, and keep your vault tidy.

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to wire up my vault: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-7/step-7d-wire-vault.sh | bash
> ```


After this runs, open Obsidian and click the **graph view** icon (it looks like a network of dots, in the left sidebar). You'll see your entire knowledge base visualized as connected nodes. The more you add and link over time, the more powerful this becomes.

**Connecting to GitHub (optional but recommended):**

If you have GitHub repos, Claude can connect them to your vault. This means if information isn't in your notes, Claude can fall back to checking your actual code repos. Tell Claude your GitHub username or org name and it will map your repos to project folders. You need to be logged into GitHub CLI first (run `gh auth login` if you haven't).

**Claude does the heavy lifting here.** The whole point of this setup is that you don't have to manually organize, link, or categorize anything. You dump things into the Inbox, and Claude (or you working with Claude) processes them into the right places. The system gets smarter as it grows.

> **This step takes the longest.** Depending on how many notes and Claude conversations you have, this could take 30+ minutes. Let Claude work. You can watch it go or come back when it's done.

### Step 7e - Connect Google Calendar

One last thing before you move on. Claude can read and manage your Google Calendar — check your schedule, create events, find conflicts, and help you plan your day. This is a built-in Claude integration, no install needed. You just need to authorize it once.

In your Claude session, type:

```
/mcp
```

A menu will appear. Select **claude.ai Google Calendar** and complete the Google login in your browser. Once you approve the connection, come back to your terminal — Claude will automatically have access to your calendar from that point on.

This is a one-time setup. The connection persists across sessions. You can verify it's connected anytime by running `/mcp` again and checking the status.

### Step 7 Troubleshooting

If things don't look right, here are the most common issues and how to fix them. You can ask Claude to fix any of these for you.

**Notes aren't showing connections in the graph:**
- Open the graph view in Obsidian (left sidebar, looks like connected dots). If you see a bunch of isolated dots with no lines between them, your notes don't have wikilinks yet. Tell Claude: "Create wikilinks between related notes in my vault."
- Take a screenshot of the graph and share it with Claude. Claude can see what's connected and what's not.

**Wikilinks inside tables aren't showing in the graph:**
- This is a known Obsidian limitation. Links inside markdown tables are invisible to the graph. Tell Claude: "Convert all wikilinks inside tables to bullet lists in my vault." This was an issue we hit during our own setup.

**Bidirectional links are broken:**
- If Note A links to Note B but Note B doesn't link back, the graph is incomplete. Tell Claude: "Fix all bidirectional links in my vault. If A links to B, make sure B links back to A."

**Some files failed to convert:**
- If Pandoc couldn't convert a file, it might be corrupt or in an unexpected format. Tell Claude: "Validate all files in my vault and flag anything that's corrupt or failed to convert."
- We caught a fake PDF during our own setup (a file with a .pdf extension that was actually empty). Claude will catch these.

**Frontmatter is missing on some notes:**
- If notes don't have the YAML frontmatter block at the top, Obsidian can't filter or categorize them properly. Tell Claude: "Add proper frontmatter to any notes in my vault that are missing it."

**The Inbox is still full after running 7d:**
- Claude might have been conservative about categorizing some notes. Tell Claude: "Process everything remaining in my Inbox. Sort each note into the appropriate folder and create links."

**You want to reorganize folders or rename projects:**
- Just tell Claude. For example: "Rename the project folder WAGMI to WAGMI-HQ and update all links." Claude handles the renaming and fixes every reference.

**General rule:** If something looks off, take a screenshot and show it to Claude. Or just describe the problem. Claude can read your vault, find the issue, and fix it. That's the whole point of this setup.

---

## Step 8 - Status Line

[Back to top](#quick-nav)

This is the wrap-up step. It installs a custom status line that shows you what's active at a glance — your vault, MCP connection, design tools, and any running swarms, mini swarms, or hive-minds.

### What It Sets Up

| Component | What it shows |
|-----------|--------------|
| 🧠 2ndBrain | You're working inside your Obsidian vault |
| ⚡ Ruflo | The Ruflo MCP server is connected |
| 🎨 UIPro | Design skill is loaded (always on after Step 4) |
| 🐝 Swarm | A swarm is active (shows agent count during `/rswarm`) |
| 🍯 Mini | A mini swarm is active (shows agent count during `/rmini`) |
| 👑 Hive | A hive-mind is active (during `/rhive`) |

The status line also shows your current model, session duration, and context window usage.

### Run Step 8

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to set up your status line: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/step-8/step-8-install.sh | bash
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

> **Note:** Use `cskip` for this step, not `cbrain`. The `cbrain` command requires your Obsidian vault to exist. If you haven't finished Step 7 yet, or if something went wrong during vault setup, `cbrain` will error out. `cskip` always works.

### After Step 8

You're done. Everything is installed, configured, and wired together.

From here on out, use `cbrain` as your main command — it drops you straight into your 2ndBrain vault with all permissions skipped. If you ever need to work outside the vault, `cskip` still works from any directory. But for day-to-day use, `cbrain` is your home base.

---

## Installation Order

[Back to top](#quick-nav)

Run the steps in this order:

| Step | Name | What it does |
|------|------|-------------|
| 1 | CLI Basics | Git, Node.js, Claude Code, shell aliases |
| Bonus | Ghostty Terminal | GPU-accelerated terminal (optional) |
| Bonus | Arc Browser | Power-user browser with sidebar tabs (optional, macOS) |
| 2 | Dev Tools | Python, Pandoc, jq, ripgrep, no-flicker mode, etc. |
| 3 | Ruflo + Context Hub | Multi-agent orchestration + API docs |
| 4 | Design Tools | UI/UX Pro Max + 21st.dev Magic + Pretext |
| 5 | Visual Media | Remotion + YouTube Transcripts + IG/Social Transcription + FFmpeg |
| 6 | Productivity Tools | Motion Calendar + Notion (optional) |
| 7 | Second Brain | Obsidian vault setup + data import (7a-7e) |
| **8** | **Status Line** | **Final config — status indicators, system health check** |

> **Note:** Step 6 (Productivity Tools) is all optional — install only the tools you use. Step 7 (Second Brain) is the biggest step with five sub-parts (7a-7e). Step 8 (Status Line) is the wrap-up — it wires your status indicators to show what's active across all the tools you installed.

---

## Video Tutorials *(coming soon)*

[Back to top](#quick-nav)

Video walkthroughs for every step are coming soon. These will show you exactly what to do, screen by screen, so you can follow along at your own pace.

---

## Staying Up to Date

[Back to top](#quick-nav)

This command re-runs all eight steps (1 through 8), skips anything already installed, and picks up anything new. It covers everything in this repo as of right now. If new steps get added in the future, the update command will include them too.

Open your terminal and run `cskip` to start a Claude session, then paste the update command. Or if you prefer, just paste it directly into your terminal without Claude.

> [!IMPORTANT]
> **Paste this into your Claude session (or your terminal directly):**
> ```
> run this update command: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/update.sh | bash
> ```


---

## Uninstall

[Back to top](#quick-nav)

If you need to remove everything installed by this setup, the uninstall script reverses all eight steps. It removes Claude Code, MCP servers, skills, shell aliases, dev tools, and brew packages. Your Obsidian vault and notes are never touched.

> [!IMPORTANT]
> **Paste this into your terminal:**
> ```bash
> curl -fsSL https://raw.githubusercontent.com/lorecraft-io/cli-maxxing/main/uninstall.sh | bash
> ```

**What it removes:**
- Claude Code + shell aliases (cskip, ctg, cc, ccr, ccc, cbrain, cbraintg)
- All MCP servers (Ruflo, claude-flow, Magic, YouTube Transcript, yt-dlp, Whisper, Obsidian, Motion Calendar, Notion)
- All skills (rswarm, rmini, rhive, w4w, get-api-docs, UI/UX Pro Max, Remotion, Pretext)
- Dev tools (pandoc, jq, ripgrep, gh, tree, fzf, wget, weasyprint, ffmpeg, xlsx2csv, poppler)
- Whisper models (~/.whisper/)
- Motion Calendar config (~/.motion-calendar-mcp/)
- Arc Browser (if installed via the bonus script)
- Ghostty config (the app itself is kept — only the config file installed by this setup is removed)
- Status line config

**What it does NOT remove:**
- Homebrew, Git, Node.js (other tools may depend on these — the script shows you how to remove them manually if you want)
- Your Obsidian vault and notes
- Your Claude account

---

## More Coming Soon

[Back to top](#quick-nav)

This setup is a living project. New steps, tools, and workflows will be added as they're ready. If you have the update command above, you'll always be able to catch up with one paste.
