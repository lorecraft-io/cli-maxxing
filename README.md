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
| [Step 3](#step-3---claudeflow--context-hub) | ClaudeFlow + Context Hub | Multi-agent orchestration, API docs, Opus locked | ~3 min |
| [Step 4](#step-4---design-tools) | Design Tools | UI/UX skills + component generation | ~3 min |
| [Step 5](#step-5---second-brain-obsidian) | Second Brain (Obsidian) | Personal knowledge management system | 15-30+ min |
| [Video Tutorials (coming soon)](#video-tutorials-coming-soon) | Walkthroughs | Shows you exactly how to do everything, screen by screen | |
| [Staying Up to Date](#staying-up-to-date) | Update command | Re-run everything, catch new steps | |

---

## Before You Start

[Back to top](#quick-nav)

- Your computer needs to be from roughly **2020 or later** (macOS Big Sur+ or a recent Linux).
- You need an **internet connection** since the scripts download everything live.
- **Don't run it as root.** Just open your terminal normally and paste the command.
- If anything is already installed on your machine, the scripts will detect that and skip it automatically.

> **Windows:** Not supported yet. This is built for macOS and Linux right now. Windows support may be added in the future.

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

> [!IMPORTANT]
> **Copy and paste this into Terminal, then hit Enter:**
> ```bash
> curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-1/step-1-install.sh | bash
> ```

### What This Step Installs

These are the tools that get installed automatically when you run the command above:

| Tool | What it does |
|------|-------------|
| Homebrew (Mac) / apt or dnf (Linux) | This is a package manager. It installs other software for you. |
| Git | This tracks and manages code changes. |
| Node.js (v18+) | This runs JavaScript. Claude Code needs it to work. |
| Warp Terminal | This is your new terminal. More on this below. |
| Claude Code | This is your AI coding assistant. The main tool you'll be using. |

### Why Warp Terminal?

This step installs [Warp](https://www.warp.dev) as your terminal. Here's why we use it:

- **Shift+Tab to toggle permissions.** When Claude is running, you can press Shift+Tab to switch between normal mode (where Claude asks before doing anything) and auto-approve mode (where Claude just does it). No need to exit and relaunch.
- **Built for AI workflows.** Warp handles long-running output, code blocks, and multi-step processes better than a standard terminal.
- **Works on Mac and Linux.** Same experience on both.

After the script finishes, press **Ctrl+C** if anything is still running, close your old terminal, and open Warp. Everything from here on happens in Warp.

### After the Script Finishes

#### 1a. Open Warp

Open **Warp** (it was just installed by the script above).

**How to find Warp:** On Mac, press **Cmd+Space**, type **Warp**, and hit Enter. On Linux, look for "Warp" in your applications menu.

Warp will ask you to create an account. Go ahead and sign up. **The free plan is all you need.** No payment required for Warp.

#### 1b. Configure Warp

Before doing anything else, you need to change one setting:

1. Open Warp settings (**Cmd+Comma** on Mac, **Ctrl+Comma** on Linux)
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

> [!IMPORTANT]
> **Type this in Warp and hit Enter:**
> ```bash
> cskip
> ```

If this is your first time, Claude will automatically open a browser and ask you to log in. Sign in with your Anthropic account.

Once you're in a Claude session, you can ask it questions, and it will help you through the rest of the process. This is where it stops being manual and starts being a conversation.

> **Reminder:** You can press **Shift+Tab** in Warp at any time to toggle auto-approve permissions on or off without restarting Claude.

#### Why auto-approve mode?

When Claude runs in normal mode, it asks your permission before every single action. Every file it reads, every command it runs. During a setup that installs 10+ tools, that means dozens of approval prompts. There's no sound or notification when Claude is waiting for you, so if you look away for a moment, the whole process just sits there frozen until you come back and type "y".

**Auto-approve mode (`cskip`) lets Claude run without stopping to ask.** It will install everything in one smooth pass. You can watch it work in real time, you just don't have to babysit it.

You can always switch back to normal mode later for regular work. This is just for setup.

#### 2c. Run the install

Once you're inside the Claude session, paste this and hit Enter:

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to install my dev tools: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-2/step-2-install.sh | bash
> ```


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

> **Note:** We made one change from the default ClaudeFlow setup. Out of the box, ClaudeFlow uses a model routing system that can silently send some of your tasks to cheaper, weaker models like Haiku instead of Opus. If you're paying for Opus, you should always get Opus. Our install locks everything to Opus and disables the auto-downgrading. You can always turn routing back on later if you want to save on costs, but we default to giving you the best answers every time.

Claude Code is already powerful on its own. But ClaudeFlow takes it to another level by adding coordinated multi-agent workflows, persistent memory, and smart cost optimization on top:

- **Multiple agents working in parallel.** Claude can spin up several agents at once, each focused on a different part of your task. A researcher, a coder, a reviewer, all working simultaneously instead of one after the other.
- **Smart model routing (optional, disabled by default).** ClaudeFlow can route simple tasks to cheaper models to save costs. We disable this by default and lock everything to Opus so you always get the best reasoning. If you want to enable cost savings later, you can turn routing back on. But we'd rather you get the best results out of the box.
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

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to set up ClaudeFlow and Context Hub: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-3/step-3-install.sh | bash
> ```


Claude will run the install for you. Same as Step 2. If Claude tells you to restart your terminal, close the window, reopen Warp, type `cskip`, and let Claude know where you left off.

### Quick note: what's an MCP?

You'll see "MCP" mentioned here and in future steps. MCP stands for Model Context Protocol. Think of it as a plugin system for Claude. When you connect an MCP to Claude Code, you're giving Claude access to a new tool or data source it didn't have before. Claude can then use that tool automatically whenever it's relevant. You don't have to manage it. You just connect it once and Claude takes it from there.

### What This Step Installs

| Component | What it does |
|-----------|-------------|
| ClaudeFlow CLI | This is the command-line tool that manages everything below. |
| MCP Server Connection | This connects ClaudeFlow to Claude Code so they can talk to each other (see above). |
| ClaudeFlow Daemon | This runs in the background and coordinates agents, memory, and tasks. |
| Memory System | This gives your agents persistent, searchable memory across sessions. |
| Smart Model Routing | This is disabled by default so you always get Opus. Can be turned on later to save up to 75% on costs by routing simple tasks to cheaper models. |
| Opus Lock | This locks all tasks to Opus so nothing silently downgrades to a weaker model. You're paying for Opus, so you should always get Opus. |
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

> [!IMPORTANT]
> **Paste this into your Claude session:**
> ```
> run this command to install design tools: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-4/step-4-install.sh | bash
> ```


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

## Step 5 - Second Brain (Obsidian)

[Back to top](#quick-nav)

This is the biggest step. It sets up your personal knowledge management system, a "Second Brain" that captures, connects, and retrieves everything you know and everything you're working on. This step takes real time. Don't rush it.

> **Heads up:** This step has multiple parts (5a through 5d). Each one is its own script. Take them one at a time.

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

### Step 5a - Install Obsidian + Create Your Vault

This part installs Obsidian on your machine and has Claude set up the full folder structure for you.

**First, install Obsidian:**

- **Mac:** Press **Cmd+Space**, type **Terminal** (or open **Warp** if you have it), and run: `brew install --cask obsidian`
- **Linux:** `sudo snap install obsidian` or `sudo flatpak install obsidian` or download from [obsidian.md](https://obsidian.md)

Or just go to [obsidian.md/download](https://obsidian.md/download) and download it directly.

**Then, open Obsidian and create your vault:**

1. Open Obsidian. **How to find it:** On Mac, press **Cmd+Space** and type **Obsidian**. On Linux, look for "Obsidian" in your applications menu.
2. Click **Create new vault**
3. Name it something you'll remember. "Brain" or "Second-Brain" or "Vault" all work fine.
4. For the location, pick somewhere easy to find. We recommend your **Desktop** or a **Documents** folder. Don't bury it deep in some random directory.
5. Click **Create**

Obsidian will open with an empty vault. That's perfect. Now Claude will set it up for you.

**Open Warp, run cskip, and paste this:**

> [!IMPORTANT]
> **macOS / Linux. Paste this into your Claude session:**
> ```
> run this command to set up my Second Brain vault structure: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-5/step-5a-setup-vault.sh | bash
> ```


Claude will ask you where your vault is located, then:

- Create all the Zettelkasten folders (00-Inbox through 07-Projects)
- Drop in ready-to-use **note templates** for each note type (Fleeting, Literature, Permanent, MOC) so Claude and you always create notes in a consistent format
- Create the **CLAUDE.md** file that teaches Claude how to work with your vault going forward (linking conventions, frontmatter standards, tagging rules, note types)
- Set up the **WebFetch workflow** so Claude knows how to capture content from URLs into your vault (it pulls the page, creates a Literature Note, extracts permanent notes, and links everything)
- Set up a **sync automation script** you can run later to keep things tidy

### Step 5b - Import Your Claude History

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
> **macOS / Linux. Paste this into your Claude session:**
> ```
> run this command to import my Claude history into my vault: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-5/step-5b-import-claude.sh | bash
> ```


Claude will ask you where the zip file is, then:

- Parse your conversations and sort them into the right vault folders
- Create **project folders** in `07-Projects/` based on your Claude Projects (you can name them whatever you want, Claude will ask)
- Generate a **project index note** for each project with a knowledge base summary and conversation log links
- Convert conversation highlights into **literature notes** in `02-Literature/`
- Extract key concepts into **permanent notes** in `03-Permanent/`
- Start building **bidirectional links** between related projects and notes

### Step 5c - Import Your Existing Notes

Now let's get the rest of your notes in. If you have notes in Apple Notes, Google Keep, Notion, Evernote, or any other app, this step helps you export them and bring them into your vault.

**For Apple Notes (Mac):**

1. Download [Apple Notes Exporter](https://github.com/thijsve/apple-notes-exporter). This is a free app that exports your Apple Notes as files Claude can read.
2. **How to find it after downloading:** Check your Downloads folder. On Mac, press **Cmd+Space** and type the app name. On Linux, check your applications menu.
3. Open it, select the notes you want to export, and save them to a folder you can find easily.

**For other apps (Notion, Evernote, Google Keep, OneNote):**
- Most note apps have an export feature somewhere in their settings. Export as markdown if possible, HTML if not.
- Save everything to a single folder.

**Once you have your exported notes in a folder, go back to your cskip session and paste this:**

> [!IMPORTANT]
> **macOS / Linux. Paste this into your Claude session:**
> ```
> run this command to import my notes into my vault: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-5/step-5c-import-notes.sh | bash
> ```


Claude will ask you where your exported notes are, what format they're in, and then:

- **Convert files to markdown** using Pandoc (installed in Step 2). This handles Word docs (.docx), PowerPoint (.pptx), Excel spreadsheets (.xlsx), and HTML files. Everything becomes clean, linkable markdown.
- **Validate every file.** Claude checks for corrupt, empty, or fake files (like a .pdf that's actually an empty text file) and flags them.
- **Move everything into the Inbox** for processing in Step 5d.
- **Ask you how you want to organize things.** Claude will have a conversation with you about what folders make sense for your notes, what categories you care about, and how you want things grouped. This isn't one-size-fits-all. Your vault should reflect how your brain works.

### Step 5d - Wire It All Up

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
> **macOS / Linux. Paste this into your Claude session:**
> ```
> run this command to wire up my vault: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-5/step-5d-wire-vault.sh | bash
> ```


After this runs, open Obsidian and click the **graph view** icon (it looks like a network of dots, in the left sidebar). You'll see your entire knowledge base visualized as connected nodes. The more you add and link over time, the more powerful this becomes.

**Connecting to GitHub (optional but recommended):**

If you have GitHub repos, Claude can connect them to your vault. This means if information isn't in your notes, Claude can fall back to checking your actual code repos. Tell Claude your GitHub username or org name and it will map your repos to project folders. You need to be logged into GitHub CLI first (run `gh auth login` if you haven't).

**Claude does the heavy lifting here.** The whole point of this setup is that you don't have to manually organize, link, or categorize anything. You dump things into the Inbox, and Claude (or you working with Claude) processes them into the right places. The system gets smarter as it grows.

> **This step takes the longest.** Depending on how many notes and Claude conversations you have, this could take 15-30+ minutes. Let Claude work. You can watch it go or come back when it's done.

### Step 5 Troubleshooting

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

**The Inbox is still full after running 5d:**
- Claude might have been conservative about categorizing some notes. Tell Claude: "Process everything remaining in my Inbox. Sort each note into the appropriate folder and create links."

**You want to reorganize folders or rename projects:**
- Just tell Claude. For example: "Rename the project folder WAGMI to WAGMI-HQ and update all links." Claude handles the renaming and fixes every reference.

**General rule:** If something looks off, take a screenshot and show it to Claude. Or just describe the problem. Claude can read your vault, find the issue, and fix it. That's the whole point of this setup.

---

## Video Tutorials *(coming soon)*

[Back to top](#quick-nav)

Video walkthroughs for every step are coming soon. These will show you exactly what to do, screen by screen, so you can follow along at your own pace.

---

## Staying Up to Date

[Back to top](#quick-nav)

New steps and updates get added to this repo over time. If you've already completed the steps above and want to make sure you have everything current, open Warp and run `cskip` to start a Claude session, then paste the update command. Claude will run it for you.

Or if you prefer to run it directly without Claude, just paste the command into Warp on its own.

> [!IMPORTANT]
> **macOS / Linux. Paste this into your Claude session (or Warp directly):**
> ```
> run this update command: curl -fsSL https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/update.sh | bash
> ```


---

## More Coming Soon

This setup is a living project. New steps, tools, and workflows will be added as they're ready. If you have the update command above, you'll always be able to catch up with one paste.
