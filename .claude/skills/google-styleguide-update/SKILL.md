---
name: google-styleguide-update
description: >-
  Fetch and update local copies of all Google style guides.
  Downloads from github.com/google/styleguide and converts
  HTML/XML/Markdown sources to markdown, embedding the content
  directly into each language skill's SKILL.md file.
manual: true
---

# Google Style Guide Update

Download all Google style guides and embed them into the
per-language SKILL.md files in the `google-styleguide` plugin.

## Prerequisites

- `curl` on PATH
- `pandoc` on PATH (for HTML/XML to markdown conversion)

## Instructions

1. **Verify prerequisites**:
   - Run `which pandoc` — if not found, tell the user to
     install pandoc (`brew install pandoc` on macOS) and stop
   - Run `which curl` — if not found, tell the user to
     install curl and stop

2. **Run the update script for each language**:

   The script `update-guide.sh` is in the same directory as
   this SKILL.md. Run it once per language with the arguments
   shown below.

   ```bash
   .claude/skills/google-styleguide-update/update-guide.sh cpp html cppguide.html
   .claude/skills/google-styleguide-update/update-guide.sh csharp md csharp-style.md
   .claude/skills/google-styleguide-update/update-guide.sh go md go/guide.md go/decisions.md go/best-practices.md
   .claude/skills/google-styleguide-update/update-guide.sh java html javaguide.html
   .claude/skills/google-styleguide-update/update-guide.sh javascript html jsguide.html
   .claude/skills/google-styleguide-update/update-guide.sh typescript html tsguide.html
   .claude/skills/google-styleguide-update/update-guide.sh python md pyguide.md
   .claude/skills/google-styleguide-update/update-guide.sh objectivec md objcguide.md
   .claude/skills/google-styleguide-update/update-guide.sh shell md shellguide.md
   .claude/skills/google-styleguide-update/update-guide.sh htmlcss html htmlcssguide.html
   .claude/skills/google-styleguide-update/update-guide.sh lisp xml lispguide.xml
   .claude/skills/google-styleguide-update/update-guide.sh r md Rguide.md
   .claude/skills/google-styleguide-update/update-guide.sh json xml jsoncstyleguide.xml
   .claude/skills/google-styleguide-update/update-guide.sh vimscript xml vimscriptfull.xml
   .claude/skills/google-styleguide-update/update-guide.sh angularjs html angularjs-google-style.html
   .claude/skills/google-styleguide-update/update-guide.sh xml html xmlstyle.html
   ```

   Run these in parallel where possible (e.g. 4-8 at a time)
   for faster fetching.

3. **Report results**:
   - Each invocation prints `<language>: ok` on success or
     an error message on failure
   - Summarize successes and failures for the user
   - If any failed, suggest the user check their network
     connection and retry

## Example

```
/google-styleguide-update
```

Expected result: all 16 language SKILL.md files updated with
embedded guide content between the marker comments.
