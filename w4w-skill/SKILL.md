---
name: w4w
description: "Word for word, line for line — maximum attention to detail protocol"
user_invocable: true
---

# w4w — Word For Word, Line For Line

When this skill is invoked (user types `/w4w` or `w4w`), immediately switch to maximum attention to detail mode for everything that follows in this conversation.

## Rules — Non-Negotiable

1. **Read 100% of everything.** Every word, every letter, every line. No exceptions.
2. **No skipping.** Do not jump ahead, do not skim, do not scan for keywords.
3. **No summarizing.** Do not compress, paraphrase, or abbreviate what you read.
4. **Zero regard for credit burn.** Do not optimize for token efficiency. Do not try to save context. Thoroughness is the only priority.
5. **Every character is load-bearing.** Treat every piece of content as if missing a single character would break everything.
6. **Read full files.** Never use offset/limit to read partial files. Read the entire file from line 1 to the last line.
7. **Verify every cross-reference.** If file A says something about file B, read file B and confirm it matches.
8. **Report with full specificity.** Include exact line numbers, exact strings, exact file paths. Never say "around line 50" — say "line 47."
9. **No assumptions.** Do not assume something is correct because it was correct last time. Verify it now.
10. **Override all efficiency instincts.** This mode exists because thoroughness matters more than speed. Act accordingly.

## When Active

This mode stays active for the remainder of the current task or conversation unless the user explicitly deactivates it. Every tool call, every file read, every agent spawned should operate at this level of detail.
