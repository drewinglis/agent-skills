#!/usr/bin/env bash
# Copy skills from the vendored .dotfiles submodule into the dstack plugin.
set -euo pipefail

SKILLS=(
  cleanup
  pr-style
  ready-when-green
  shipit
)

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src_root="$repo_root/vendor/drewinglis/.dotfiles/claude/skills"
dest_root="$repo_root/plugins/dstack/skills"

if [ ! -d "$src_root" ]; then
  echo "error: $src_root not found; run 'git submodule update --init' first" >&2
  exit 1
fi

missing=()
for skill in "${SKILLS[@]}"; do
  [ -f "$src_root/$skill/SKILL.md" ] || missing+=("$skill")
done
if [ ${#missing[@]} -gt 0 ]; then
  echo "error: no SKILL.md for: ${missing[*]}" >&2
  exit 1
fi

mkdir -p "$dest_root"
for skill in "${SKILLS[@]}"; do
  rm -rf "$dest_root/$skill"
  cp -R "$src_root/$skill" "$dest_root/$skill"
  echo "synced $skill"
done
