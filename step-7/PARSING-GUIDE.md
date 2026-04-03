# Parsing Methodology Guide

This document tells Claude how to parse and organize imported files into your Second Brain vault. Claude references this automatically when running Steps 5b, 5c, and 5d.

## General Rules

1. **Read every file before categorizing it.** Don't sort by filename alone. Look at the content.
2. **One concept per permanent note.** If a source covers multiple ideas, split them into separate permanent notes and link them.
3. **Always write in your own words.** Literature notes should summarize, not copy-paste.
4. **Link everything.** Every note should connect to at least one other note or MOC.
5. **Bidirectional links are mandatory.** If A links to B, B must link back to A.
6. **Never put wikilinks inside tables.** Use bullet lists instead. Obsidian's graph can't see links in tables.

## How to Categorize Files

### Goes into 00-Inbox (for later processing)
- Anything you're not sure about
- Raw text dumps with no clear structure
- Files that need more context before categorizing

### Goes into 01-Fleeting
- Short thoughts, ideas, observations
- Personal reflections
- Things that aren't sourced from somewhere else
- Shower thoughts, brainstorms, quick captures

### Goes into 02-Literature
- Notes about articles, books, videos, podcasts
- Summaries of external content
- Anything with a source URL or reference
- Meeting notes, lecture notes
- Conversation summaries (including Claude conversations)

### Goes into 03-Permanent
- Clear, refined explanations of a single concept
- Written as if explaining to someone else
- Heavily linked to other permanent notes
- Timeless knowledge (not time-specific events)

### Goes into 04-MOC
- Index notes that group related permanent notes
- Created when you notice a cluster of related concepts
- Named like: MOC-topic-name.md

### Goes into 07-Projects
- Anything tied to a specific active project
- Each project gets its own subfolder with an index note
- Project index includes: overview, knowledge base links, conversation logs, related projects

## File Conversion Rules

### docx (Word)
```bash
pandoc input.docx -t markdown -o output.md
```

### pptx (PowerPoint)
```bash
pandoc input.pptx -t markdown -o output.md
```
Note: Slide content becomes sections. Images may need manual handling.

### xlsx (Excel)
```bash
xlsx2csv input.xlsx > output.csv
```
Then convert CSV to markdown table or bullet lists.

### html
```bash
pandoc input.html -t markdown -o output.md
```

### rtf (Rich Text)
```bash
pandoc input.rtf -t markdown -o output.md
```

## Frontmatter Template

Every note MUST have this at the top:

```yaml
---
title: "Note Title"
date: YYYY-MM-DD
type: fleeting | literature | permanent | moc | project
tags: []
source: ""
related: []
---
```

## Naming Conventions

| Type | Format | Example |
|------|--------|---------|
| Inbox | `YYYY-MM-DD-brief-description.md` | `2026-03-23-meeting-notes.md` |
| Fleeting | `YYYY-MM-DD-brief-description.md` | `2026-03-23-idea-about-workflows.md` |
| Literature | `LIT-brief-description.md` | `LIT-zettelkasten-method.md` |
| Permanent | `brief-concept-name.md` | `wikilinks-explained.md` |
| MOC | `MOC-topic-name.md` | `MOC-productivity-systems.md` |
| Project Index | `index.md` (inside project folder) | `07-Projects/MY-PROJECT/index.md` |

## Claude Conversation Parsing

When parsing Claude data exports:

1. Each conversation becomes a literature note in `02-Literature/`
2. If the conversation belongs to a Claude Project, also create/update the project folder in `07-Projects/`
3. Extract key decisions, insights, and outcomes into permanent notes in `03-Permanent/`
4. Link conversation notes to their project index
5. Link permanent notes to relevant MOCs
6. Add conversation date to frontmatter

## Validation Checks

After importing, verify:
- [ ] No empty files (0 bytes)
- [ ] No files with wrong extensions (e.g., .pdf that's actually empty text)
- [ ] All files have frontmatter
- [ ] All wikilinks resolve to real notes (no broken links)
- [ ] All links are bidirectional
- [ ] No wikilinks inside markdown tables
- [ ] No duplicate notes (same content, different filenames)
