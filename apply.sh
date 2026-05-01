#!/usr/bin/env bash
# Apply this Claude Code template to a project directory.
#
# Usage:
#   apply.sh <project-dir> [--no-official] [--add <skill>]...
#
# - Copies .claude/, CLAUDE.md, mcp.example.json into the target.
# - Never overwrites existing files.
# - Fetches default official skills from anthropics/skills (skill-creator,
#   mcp-builder, frontend-design, webapp-testing, doc-coauthoring) unless
#   --no-official is given.
# - --add <skill> adds an opt-in official skill (docx, pdf, pptx, xlsx).
#   Repeatable.
set -euo pipefail

DEFAULT_OFFICIAL=(skill-creator mcp-builder frontend-design webapp-testing doc-coauthoring)
OPTIN_OFFICIAL=(docx pdf pptx xlsx)
OFFICIAL_REPO="https://github.com/anthropics/skills.git"

usage() {
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
}

TARGET=""
SKIP_OFFICIAL=false
ADD_LIST=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-official) SKIP_OFFICIAL=true; shift ;;
    --add)
      [[ $# -lt 2 ]] && { echo "--add requires a skill name" >&2; exit 1; }
      ADD_LIST+=("$2"); shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) TARGET="$1"; shift ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  usage >&2
  exit 1
fi

TEMPLATE_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -d "$TARGET" ]]; then
  echo "Target directory does not exist: $TARGET" >&2
  exit 1
fi

echo "Applying template from $TEMPLATE_DIR to $TARGET ..."

# .claude/ — recursive, no overwrite
if [[ -d "$TARGET/.claude" ]]; then
  echo "  .claude/ already exists, merging individual files (no overwrite)"
  find "$TEMPLATE_DIR/.claude" -type f | while read -r src; do
    rel="${src#$TEMPLATE_DIR/}"
    dst="$TARGET/$rel"
    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" ]]; then
      echo "    skip (exists): $rel"
    else
      cp "$src" "$dst"
      echo "    add:           $rel"
    fi
  done
else
  cp -r "$TEMPLATE_DIR/.claude" "$TARGET/.claude"
  echo "  copied .claude/"
fi

# Top-level files — no overwrite
for f in CLAUDE.md mcp.example.json; do
  if [[ -e "$TARGET/$f" ]]; then
    echo "  skip (exists):   $f"
  else
    cp "$TEMPLATE_DIR/$f" "$TARGET/$f"
    echo "  copied:          $f"
  fi
done

# Validate --add entries against the opt-in list
ALLOWED=("${DEFAULT_OFFICIAL[@]}" "${OPTIN_OFFICIAL[@]}")
for s in "${ADD_LIST[@]:-}"; do
  [[ -z "$s" ]] && continue
  found=false
  for a in "${ALLOWED[@]}"; do
    [[ "$s" == "$a" ]] && { found=true; break; }
  done
  if ! $found; then
    echo "Unknown --add skill: $s" >&2
    echo "  Allowed: ${ALLOWED[*]}" >&2
    exit 1
  fi
done

# Fetch official skills
if ! $SKIP_OFFICIAL; then
  echo ""
  echo "Fetching official skills from $OFFICIAL_REPO ..."
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT

  if git clone --depth 1 --quiet "$OFFICIAL_REPO" "$TMP/repo" 2>/dev/null; then
    SKILLS_TO_INSTALL=("${DEFAULT_OFFICIAL[@]}" "${ADD_LIST[@]:-}")
    for skill in "${SKILLS_TO_INSTALL[@]}"; do
      [[ -z "$skill" ]] && continue
      src="$TMP/repo/skills/$skill"
      dst="$TARGET/.claude/skills/$skill"
      if [[ -d "$dst" ]]; then
        echo "  skip official (exists): $skill"
      elif [[ -d "$src" ]]; then
        cp -r "$src" "$dst"
        echo "  added official:         $skill"
      else
        echo "  not found in official repo: $skill"
      fi
    done
  else
    echo "  Failed to clone $OFFICIAL_REPO (offline?). Skipping official skills."
  fi
fi

cat <<EOF

Done. Next steps:
  1. Edit $TARGET/CLAUDE.md and replace the <...> placeholders.
  2. To enable MCP servers: mv $TARGET/mcp.example.json $TARGET/.mcp.json (and edit).
  3. For personal overrides: cp $TARGET/.claude/settings.local.json.example $TARGET/.claude/settings.local.json
  4. Add to .gitignore (project-side):
       .claude/settings.local.json
       .mcp.json
EOF
