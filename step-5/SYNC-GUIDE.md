# Claude Projects to Obsidian Vault Sync Guide

This document tells Claude how to sync Claude Project data into your Obsidian vault. Claude references this when running Step 5b.

## Vault Structure Per Project

```
07-Projects/
  PROJECT-NAME/
    PROJECT-NAME.md      ← Index note (knowledge base + conversation log + related links)
    conversations/       ← All conversation markdown files
    knowledge/           ← All text-based knowledge (md, txt, jsx, html, sh) + converted docx/pptx/xlsx
    assets/              ← Only real PDFs and zips (things that can't be markdown)
```

## File Routing Rules

| Source | Extension | Destination | Action |
|---|---|---|---|
| conversations/ | .md | conversations/ | Copy as-is |
| knowledge/ | .md, .txt, .jsx, .html, .sh | knowledge/ | Copy as-is |
| knowledge/ | .docx | knowledge/ | Convert to .md via `pandoc`, delete .docx |
| knowledge/ | .pptx | knowledge/ | Convert to .md via `pandoc`, delete .pptx |
| knowledge/ | .xlsx | knowledge/ | Convert to .md via `xlsx2csv` or `python3 + openpyxl`, delete .xlsx |
| knowledge/ | .pdf | assets/ | Copy, but validate first (check magic bytes `%PDF`) |
| knowledge/ | .zip | assets/ | Copy as-is |
| system-prompt/ | any | knowledge/ | Copy (instructions, etc.) |

## Validation Rules

1. **Fake PDFs:** Check that `.pdf` files actually start with `%PDF` (hex `25504446`). Claude.ai exports sometimes save text content with a `.pdf` extension. If fake, rename to `.md` and place in `knowledge/`
2. **Fake DOCX:** Check that `.docx` files start with PK zip header (hex `504b0304`). Same for `.xlsx`, `.pptx`
3. **Empty files:** Flag any 0-byte files
4. **Deduplication:** Skip files that already exist in the destination (compare by filename)

## Index Note Format

Each project's index note (`PROJECT-NAME.md`) should have:

1. **Frontmatter** with title, date, type: project, tags, status
2. **Description** of what the project is
3. **Knowledge Base** section with `[[wikilinks]]` to each file (NOT backtick plain text)
4. **Conversation Log** section with date and topic
5. **Related** section with bidirectional `[[wikilinks]]` to related projects

### Wikilink Rules

- Use `[[filename]]` without extension for .md files (Obsidian resolves by name)
- Use `[[filename.pdf]]` for PDFs (extension needed for non-md files)
- Never use backtick code formatting for filenames that should be clickable
- Obsidian resolves wikilinks by searching the entire vault, regardless of subfolder

## Conversion Commands

```bash
# docx/pptx to markdown
pandoc input.docx -t markdown -o output.md

# xlsx to CSV (then to markdown)
xlsx2csv input.xlsx > output.csv

# Check if a file is a real PDF
xxd -l 4 file.pdf | grep "2550 4446"

# Check if a file is a real zip-based format (docx/pptx/xlsx)
xxd -l 4 file.docx | grep "504b 0304"
```

## Lessons Learned

- Claude.ai exports sometimes save plain text with `.pdf` extension (validate every PDF)
- Obsidian can render PDFs natively but NOT docx/pptx/xlsx, always convert to markdown
- Knowledge Base sections must use `[[wikilinks]]` not backtick filenames, otherwise files aren't clickable in Obsidian
- Related links must be bidirectional. If A links to B, B must link to A
- Pandoc handles docx to markdown cleanly
- Tables with wikilinks inside them don't show in Obsidian's graph view. Use bullet lists instead.
