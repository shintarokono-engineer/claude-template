#!/usr/bin/env bash
# Apply this Claude Code template to a project directory.
# Usage: apply.sh <project-dir>
# - Copies .claude/, CLAUDE.md, mcp.example.json into the target.
# - Never overwrites existing files (uses cp -n).
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <project-dir>" >&2
  exit 1
fi

TARGET="$1"
TEMPLATE_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -d "$TARGET" ]]; then
  echo "Target directory does not exist: $TARGET" >&2
  exit 1
fi

echo "Applying template from $TEMPLATE_DIR to $TARGET ..."

# .claude/ — recursive, no overwrite
if [[ -d "$TARGET/.claude" ]]; then
  echo "  .claude/ already exists, merging individual files (no overwrite)"
  # cp -rn is non-portable; use a safe loop
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

cat <<EOF

Done. Next steps:
  1. Edit $TARGET/CLAUDE.md and replace the <...> placeholders.
  2. To enable MCP servers: mv $TARGET/mcp.example.json $TARGET/.mcp.json (and edit).
  3. For personal overrides: cp $TARGET/.claude/settings.local.json.example $TARGET/.claude/settings.local.json
  4. Add to .gitignore (project-side):
       .claude/settings.local.json
       .mcp.json
EOF
