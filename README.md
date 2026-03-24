# AI Super User Setup

Everything you need to start working with AI-powered development tools, installed in the right order with one command per step.

## Quick Nav

| | Section | What it does | Time |
|---|------|-------------|------|
| [Before You Start](#before-you-start) | Requirements | What you need before running anything | |
| [How It Works](#how-it-works) | Overview | How the steps fit together | |
| [Keyboard + Command Cheat Sheet](#keyboard--command-cheat-sheet) | Terminal reference | Hotkeys, typing, and commands for your terminal | |
| [Step 1](#step-1---get-claude-running) | Get Claude Running | Sets up the foundation on your machine | ~5 min |
| [Step 2](#step-2---dev-tools) | Dev Tools | Adds file converters, search, and utilities | ~3 min |
| [Step 3](#step-3---claudeflow--context-hub) | ClaudeFlow + Context Hub | Multi-agent orchestration, API docs, 75% cost savings | ~3 min |
| [Step 4](#step-4---design-tools) | Design Tools | UI/UX skills + component generation | ~3 min |
| [Step 5](#step-5---coming-soon) | Coming soon | | |
| [Staying Up to Date](#staying-up-to-date) | Update command | Re-run everything, catch new steps | |

---

## Before You Start

[Back to top](#quick-nav)

- Your computer needs to be from roughly **2020 or later** (macOS Big Sur+, Windows 10+, or a recent Linux).
- You need an **internet connection** since the scripts download everything live.
- **Don't run it as admin/root.** Just open your terminal normally and paste the command.
- If anything is already installed on your machine, the scripts will detect that and skip it automatically.

> **A note on Windows:** This setup was built and tested on macOS. The Windows PowerShell versions were generated to match, but I don't have a Windows machine to test on personally. If you run into any issues on Windows, let me know and we'll get it sorted.

---

## How It Works

[Back to top](#quick-nav)

There are three steps. Run them in order. Each one builds on the last.

**Step 1** is the only part that feels "techy." This step gets the bare essentials on your machine so Claude (your AI assistant) and Warp (your new terminal) can run. You paste one command and it handles the rest, but there are a few manual steps after it finishes, like setting up your Warp account and logging into Claude. This is the most hands-on part of the entire process. After Step 1, you can ask Claude questions at any point. If something doesn't make sense, just ask. That's the whole point.

**Step 2** is where you install the rest of your development tools. Things like file converters, search tools, and utilities. You run this from inside Warp after Step 1 is done. Much more straightforward.

**Step 3** is where you set up ClaudeFlow. This is the multi-agent orchestration layer that turns Claude from a single assistant into a full team of AI agents. It also cuts your token costs by up to 75% with smart model routing. This is where everything comes together.

### Already have Claude Code installed?

If you already have Claude Code working on your machine, you can skip Step 1 entirely. Just make sure you have [Warp](https://www.warp.dev) installed (we use it for the Shift+Tab permissions toggle), then jump straight to [Step 2](#step-2---dev-tools). Everything will work the same. You can paste the install commands directly in Warp, or if you prefer, download this repo as a ZIP from GitHub, unzip it, and tell Claude to run the scripts from whatever folder they landed in.

### Bonus

Want to get better at using the terminal in general? Check out [Terminal Academy](https://github.com/lorecraft-io/terminal-academy), a gamified way to learn terminal commands and workflows. It makes the learning curve way less painful.

---

## [Keyboard + Command Cheat Sheet](CHEATSHEET.md)

[Back to top](#quick-nav)

This is a quick reference for terminal hotkeys, typing basics, launching Claude, and useful commands. **Read this before starting the steps**, especially if you're new to working in a terminal.

---

## Step 1 - Get Claude Running

[Back to top](#quick-nav)

This step is the foundation. It installs the minimum needed to get Claude Code working on your machine.

**Heads up:** This is the most manual part of the setup. The script itself runs automatically, but afterwards you'll need to set up Warp and your Claude account yourself. Don't worry, it's all spelled out below. Once you're past this, Claude is there to help you with everything else.

### macOS / Linux

**How to open Terminal:** On Mac, press **Cmd+Space** to open Spotlight, type **Terminal**, and hit Enter. On Linux, look for "Terminal" in your applications menu, or press **Ctrl+Alt+T**.

Paste this command and hit Enter:

```bash
curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-1/step-1-install.sh | bash
```

### Windows

**How to open PowerShell:** Press the **Windows key**, type **PowerShell**, and click on it.

Paste this command and hit Enter:

```powershell
irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-1/step-1-install.ps1 | iex
```

### What This Step Installs

These are the tools that get installed automatically when you run the command above:

| Tool | What it does |
|------|-------------|
| Homebrew (Mac) / winget (Win) | This is a package manager. It installs other software for you. |
| Git | This tracks and manages code changes. |
| Node.js (v18+) | This runs JavaScript. Claude Code needs it to work. |
| Warp Terminal | This is your new terminal. More on this below. |
| Claude Code | This is your AI coding assistant. The main tool you'll be using. |

### Why Warp Terminal?

This step installs [Warp](https://www.warp.dev) as your terminal. Here's why we use it:

- **Shift+Tab to toggle permissions.** When Claude is running, you can press Shift+Tab to switch between normal mode (where Claude asks before doing anything) and auto-approve mode (where Claude just does it). No need to exit and relaunch.
- **Built for AI workflows.** Warp handles long-running output, code blocks, and multi-step processes better than a standard terminal.
- **Works on Mac, Linux, and Windows.** Same experience everywhere.

After the script finishes, press **Ctrl+C** if anything is still running, close your old terminal, and open Warp. Everything from here on happens in Warp.

### After the Script Finishes

#### 1a. Open Warp

Open **Warp** (it was just installed by the script above).

**How to find Warp:** On Mac, press **Cmd+Space**, type **Warp**, and hit Enter. On Windows, press the **Windows key**, type **Warp**, and click on it. On Linux, look for "Warp" in your applications menu.

Warp will ask you to create an account. Go ahead and sign up. **The free plan is all you need.** No payment required for Warp.

#### 1b. Configure Warp

Before doing anything else, you need to change one setting:

1. Open Warp settings (**Cmd+Comma** on Mac, **Ctrl+Comma** on Windows/Linux)
2. Go to **Features**
3. The very first setting is **Default Mode**. Make sure it's set to **Terminal**, not Agent

This keeps Warp acting as a normal terminal so Claude Code runs properly.

> **If you see "Agent Oz" instead of a terminal:** Press the **Esc** key. This switches you back to the normal terminal view. That's why we changed the default to Terminal, so this doesn't keep happening.

#### 1c. Set Up Your Claude Account

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

That's it for Step 1. Continue to Step 2.

---

## Step 2 - Dev Tools

[Back to top](#quick-nav)

This step installs the development tools that Claude uses when working on your projects. Things like file converters, search tools, and other utilities that make Claude more capable.

#### 2a. Open Warp

If you haven't already, close your old terminal (press **Ctrl+C** if something is still running, then close the window) and open **Warp**.

> If you see "Agent Oz" instead of a terminal, press **Esc**.

#### 2b. Launch Claude

In Warp, type this command:

```bash
cskip
```

If this is your first time, Claude will automatically open a browser and ask you to log in. Sign in with your Anthropic account.

Once you're in a Claude session, you can ask it questions, and it will help you through the rest of the process. This is where it stops being manual and starts being a conversation.

> **Reminder:** You can press **Shift+Tab** in Warp at any time to toggle auto-approve permissions on or off without restarting Claude.

#### Why auto-approve mode?

When Claude runs in normal mode, it asks your permission before every single action. Every file it reads, every command it runs. During a setup that installs 10+ tools, that means dozens of approval prompts. There's no sound or notification when Claude is waiting for you, so if you look away for a moment, the whole process just sits there frozen until you come back and type "y".

**Auto-approve mode (`cskip`) lets Claude run without stopping to ask.** It will install everything in one smooth pass. You can watch it work in real time, you just don't have to babysit it.

You can always switch back to normal mode later for regular work. This is just for setup.

#### 2c. Run the install

Once you're inside the Claude session, paste this and hit Enter:

**macOS / Linux:**
```
run this command to install my dev tools: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-2/step-2-install.sh | bash
```

**Windows:**
```
run this command to install my dev tools: irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-2/step-2-install.ps1 | iex
```

Claude will run the install for you. You can watch it work. If Claude tells you to restart your terminal at any point, just close the window, reopen Warp, type `cskip` again, and let Claude know where you left off. It'll pick right back up.

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
| Memory auto-save hook | This makes Claude automatically save important notes from your conversation when you end a session. You don't have to do anything. It just works in the background. |

### What's the memory hook?

Step 2 also sets up something called a "stop hook." Every time you end a Claude session (by pressing Ctrl+C or typing `/exit`), Claude will automatically review the conversation and save anything important to memory. Things like decisions you made, preferences you mentioned, or context about what you were working on. Next time you start a session, Claude already knows that stuff. You don't have to repeat yourself.

You don't need to do anything to make this work. It's already configured. Just keep using Claude normally and it'll build up memory over time.

---

## Step 3 - ClaudeFlow + Context Hub

[Back to top](#quick-nav)

This step installs ClaudeFlow, the layer that turns Claude from a single assistant into a full team of coordinated AI agents. Each agent focuses on a particular task, work is split up, done with more attention to detail: power in numbers. It also installs Context Hub, which makes sure those agents don't hallucinate when writing code that talks to external APIs.

### ClaudeFlow

Built by [@ruvnet](https://github.com/ruvnet) ([repo](https://github.com/ruvnet/claude-flow)). This is an open-source multi-agent orchestration system that sits on top of Claude Code.

Without ClaudeFlow, Claude works alone. One conversation, one task at a time. ClaudeFlow changes that completely:

- **Multiple agents working in parallel.** Claude can spin up several agents at once, each focused on a different part of your task. A researcher, a coder, a reviewer, all working simultaneously instead of one after the other.
- **Saves up to 75% on token costs.** ClaudeFlow uses smart model routing. Simple tasks get handled by faster, cheaper models. Complex reasoning goes to the heavy hitters. You stop paying full price for things that don't need it.
- **Autonomous execution.** You describe what you want, and ClaudeFlow figures out how to break it down, assign it, and execute it. You don't have to micromanage every step.
- **Persistent memory.** ClaudeFlow has its own memory system that agents share. Context doesn't get lost between tasks or sessions. Your agents remember what they learned.
- **Self-healing workflows.** If something fails, ClaudeFlow can detect it and recover automatically instead of just stopping.

### Context Hub

Built by [@andrewyng](https://github.com/andrewyng) ([repo](https://github.com/andrewyng/context-hub)). Andrew Ng is one of the most respected names in AI. He built this tool to solve a real problem: AI agents hallucinating API calls.

When Claude writes code that calls an external API, it's working from its training data, which can be outdated or just wrong. Context Hub fixes that by giving Claude access to curated, up-to-date API documentation on demand.

- **Accurate API docs.** Claude can look up the real function signatures, parameters, and usage patterns instead of guessing from memory.
- **Persistent annotations.** You and Claude can add notes to docs that carry over across sessions. If you figure out a quirk with an API, it stays documented.
- **Less hallucination.** This is the big one. Claude stops making up function names that don't exist.

Together, ClaudeFlow and Context Hub are what take you from "using AI" to actually being an AI super user.

### Run Step 3

You should still be in Warp from Step 2. If you closed it, open Warp and type `cskip` to start a new Claude session. Remember, you can press **Shift+Tab** at any time to toggle auto-approve on or off.

Once you're inside the Claude session, paste this and hit Enter:

**macOS / Linux:**
```
run this command to set up ClaudeFlow and Context Hub: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-3/step-3-install.sh | bash
```

**Windows:**
```
run this command to set up ClaudeFlow and Context Hub: irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-3/step-3-install.ps1 | iex
```

Claude will run the install for you. Same as Step 2. If Claude tells you to restart your terminal, close the window, reopen Warp, type `cskip`, and let Claude know where you left off.

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| ClaudeFlow CLI | This is the command-line tool that manages everything below. |
| MCP Server Connection | This connects ClaudeFlow to Claude Code so they can talk to each other. |
| ClaudeFlow Daemon | This runs in the background and coordinates agents, memory, and tasks. |
| Memory System | This gives your agents persistent, searchable memory across sessions. |
| Smart Model Routing | This automatically picks the cheapest model that can handle each task, saving up to 75% on costs. |
| Context Hub | This gives Claude access to curated, up-to-date API documentation so it stops hallucinating function names. |
| Context Hub Skill | This teaches Claude when and how to look up API docs automatically before writing integration code. |

### After Step 3

Your core setup is done. Open a new `cskip` session and try something ambitious. Ask Claude to build something, research something, or refactor something complex. You'll see ClaudeFlow kick in automatically when the task calls for it.

More steps are being added below. Check back or run the update command to stay current.

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
2. Once logged in, go to the MCP setup page and follow their instructions. They'll give you a command to run.
3. If the auto-install didn't connect it, the setup page will walk you through it.

### Run Step 4

You should still be in Warp. If you closed it, open Warp and type `cskip` to start a new Claude session.

Once you're inside the Claude session, paste this and hit Enter:

**macOS / Linux:**
```
run this command to install design tools: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-4/step-4-install.sh | bash
```

**Windows:**
```
run this command to install design tools: irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-4/step-4-install.ps1 | iex
```

### After the script runs, set up 21st.dev

The UI/UX Pro Max Skill installs automatically. But 21st.dev needs you to create an account:

1. Go to [21st.dev](https://21st.dev)
2. Sign up for free (no payment required)
3. Follow their MCP setup instructions. They'll give you a command to paste in your terminal.
4. Once connected, Claude will automatically use their component library when building UI.

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| UI/UX Pro Max Skill | This gives Claude professional design intelligence. 161 design rules, 67 styles, 161 palettes, 57 font pairings, 99 UX guidelines. |
| 21st.dev Magic MCP | This connects Claude to a library of production-ready UI components it can use when building interfaces. |

---

## Step 5 - Coming Soon

[Back to top](#quick-nav)

Details coming soon.

---

## Staying Up to Date

[Back to top](#quick-nav)

New steps and updates get added to this repo over time. If you've already completed the steps above and want to make sure you have everything current, open Warp and run `cskip` to start a Claude session, then paste the update command. Claude will run it for you.

Or if you prefer to run it directly without Claude, just paste the command into Warp on its own.

**macOS / Linux:**
```
run this update command: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/update.sh | bash
```

**Windows:**
```
run this update command: irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/update.ps1 | iex
```

---

## More Coming Soon

This setup is a living project. New steps, tools, and workflows will be added as they're ready. If you have the update command above, you'll always be able to catch up with one paste.
