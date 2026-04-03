# GitHub + Vault Integration Guide

This document tells Claude how to connect your Obsidian vault to your GitHub repos. Claude references this during Step 5 when setting up project folders.

## The Concept

Your Obsidian vault is your knowledge base. Your GitHub repos are where the actual code lives. The vault acts as the brain that connects everything together. When Claude can't find something in the vault, it falls back to checking your GitHub repos.

## Lookup Order

1. **Obsidian vault first.** Search `07-Projects/`, `03-Permanent/`, `04-MOC/`, etc.
2. **GitHub repos second.** If the vault doesn't have it, check the corresponding GitHub repo via `gh` CLI.

## Connecting Projects to Repos

Each project folder in `07-Projects/` can map to one or more GitHub repos. Add this to the project's index note:

```markdown
## GitHub Repos

- [repo-name](https://github.com/your-org/repo-name)
```

## GitHub CLI Commands (for Claude)

Claude can use these to pull information from GitHub when it's not in the vault:

```bash
# List files in a repo
gh api repos/YOUR-ORG/REPO-NAME/contents/ --jq '.[].name'

# Search code in a repo
gh search code "search term" --repo YOUR-ORG/REPO-NAME

# Read a specific file
gh api repos/YOUR-ORG/REPO-NAME/contents/path/to/file.md --jq '.content' | base64 -d

# Get repo README
gh repo view YOUR-ORG/REPO-NAME
```

## Setting Up the Connection

When Claude sets up your project folders in Step 5, tell it about your GitHub repos:

1. Tell Claude your GitHub username or organization name
2. Claude will run `gh repo list YOUR-ORG` to see all your repos
3. For each repo, Claude creates or updates the matching project folder in the vault
4. The project index note gets a GitHub Repos section with links

## Requirements

- GitHub CLI (`gh`) must be installed (done in Step 2)
- You need to be logged in: `gh auth login`
- Your repos can be public or private (gh CLI handles auth)

## How It Works Day-to-Day

Once connected, you can tell Claude things like:

- "Check the wagmi repo for the latest README and update my vault"
- "Pull the spec from the clocked-hq repo into my project notes"
- "Search my GitHub repos for anything about authentication"

Claude will use the `gh` CLI to grab what it needs and create or update vault notes accordingly.
