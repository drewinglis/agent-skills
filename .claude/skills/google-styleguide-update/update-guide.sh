#!/usr/bin/env bash
#
# Fetch a Google style guide and embed it into the corresponding
# SKILL.md file between <!-- BEGIN GUIDE CONTENT --> and
# <!-- END GUIDE CONTENT --> markers.
#
# Usage:
#   ./update-guide.sh <skill-dir> <format> <source-file>...
#
# Arguments:
#   skill-dir    Skill directory name (e.g. "cpp", "python")
#   format       Source format: "md", "html", or "xml"
#   source-file  One or more source filenames relative to the
#                base URL. Multiple files are concatenated with
#                section headers derived from the filename.
#
# Examples:
#   ./update-guide.sh cpp html cppguide.html
#   ./update-guide.sh python md pyguide.md
#   ./update-guide.sh go md go/guide.md go/decisions.md go/best-practices.md
#
# Prerequisites: curl, pandoc (for html/xml formats)

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/google/styleguide/gh-pages"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/../../.."
PLUGIN_DIR="$REPO_ROOT/plugins/google-styleguide"
BEGIN_MARKER="<!-- BEGIN GUIDE CONTENT -->"
END_MARKER="<!-- END GUIDE CONTENT -->"

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <skill-dir> <format> <source-file>..." >&2
  exit 1
fi

skill_dir="$1"
format="$2"
shift 2
sources=("$@")

skill_file="$PLUGIN_DIR/skills/$skill_dir/SKILL.md"
if [[ ! -f "$skill_file" ]]; then
  echo "error: $skill_file not found" >&2
  exit 1
fi

# Check prerequisites
if [[ "$format" == "html" || "$format" == "xml" ]]; then
  if ! command -v pandoc &>/dev/null; then
    echo "error: pandoc is required but not found" >&2
    exit 1
  fi
fi

# Fetch and convert a single source file to markdown
fetch_one() {
  local src="$1"
  local url="$BASE_URL/$src"

  case "$format" in
    md)
      curl -sL "$url"
      ;;
    html|xml)
      curl -sL "$url" | pandoc -f html -t markdown
      ;;
    *)
      echo "error: unknown format '$format'" >&2
      return 1
      ;;
  esac
}

# Build the guide content
guide_content=""
date_str="$(date +%Y-%m-%d)"
source_urls=""

for src in "${sources[@]}"; do
  source_urls="${source_urls:+$source_urls, }$BASE_URL/$src"
done

if [[ ${#sources[@]} -eq 1 ]]; then
  # Single file — fetch directly
  guide_content="$(fetch_one "${sources[0]}")"
else
  # Multiple files — concatenate with section headers
  for src in "${sources[@]}"; do
    # Derive a section title from the filename
    # e.g. "go/guide.md" -> "Guide", "go/best-practices.md" -> "Best Practices"
    basename="${src##*/}"
    name="${basename%.*}"
    title="$(echo "$name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')"

    content="$(fetch_one "$src")"
    if [[ -n "$guide_content" ]]; then
      guide_content="$guide_content"$'\n\n'
    fi
    guide_content="${guide_content}# ${title}"$'\n\n'"${content}"
  done
fi

if [[ -z "$guide_content" ]]; then
  echo "error: fetched content is empty for $skill_dir" >&2
  exit 1
fi

# Embed into SKILL.md between the markers
python3 -c "
import sys

skill_path = sys.argv[1]
header = sys.argv[2]
begin = sys.argv[3]
end = sys.argv[4]

with open(skill_path) as f:
    content = f.read()

guide = sys.stdin.read()

bi = content.index(begin)
ei = content.index(end)

new = (
    content[:bi + len(begin)]
    + '\n' + header + '\n'
    + guide + '\n'
    + content[ei:]
)

with open(skill_path, 'w') as f:
    f.write(new)
" "$skill_file" \
  "<!-- Fetched from $source_urls on $date_str -->" \
  "$BEGIN_MARKER" \
  "$END_MARKER" \
  <<< "$guide_content"

echo "$skill_dir: ok"
