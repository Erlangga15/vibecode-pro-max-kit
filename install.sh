#!/usr/bin/env bash
set -euo pipefail

# vibecode-pro-max-kit installer
# Clean install with backup for both new and existing projects.
# Replaces .claude/, .codex/, .agents/, CLAUDE.md, AGENTS.md with kit versions.
# Preserves: process/ (user content), .claude/settings.json (user config).
# After this script, run Claude Code and say "Run vc-setup" to
# auto-detect your project, scaffold process/, and populate context.

REPO="https://github.com/withkynam/vibecode-pro-max-kit.git"
TMPDIR="/tmp/vc-kit-install-$$"
BACKUP_DIR=".vibecode-backup"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

cleanup() { rm -rf "$TMPDIR" 2>/dev/null; }
trap cleanup EXIT

echo ""
echo "  vibecode-pro-max-kit installer"
echo "  ─────────────────────────────────"
echo ""

# Clone kit to temp
echo "  Fetching kit..."
git clone --depth 1 --quiet "$REPO" "$TMPDIR"

# Read version from manifest
VERSION=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$TMPDIR/vc-manifest.json','utf8')).version)" 2>/dev/null || echo "unknown")
echo "  Kit version: $VERSION"
echo ""

# ══════════════════════════════════════════════════════
# Backup existing setup (if any)
# ══════════════════════════════════════════════════════
HAS_EXISTING=false
if [ -d ".claude" ] || [ -d ".codex" ] || [ -d ".agents" ] || [ -f "CLAUDE.md" ] || [ -f "AGENTS.md" ]; then
  HAS_EXISTING=true
  echo -e "  ${YELLOW}Existing setup detected.${NC} Backing up..."
  mkdir -p "$BACKUP_DIR"

  # Back up directories
  [ -d ".claude" ] && cp -R .claude "$BACKUP_DIR/.claude" && echo -e "    ${YELLOW}Backed up${NC} .claude/"
  [ -d ".codex" ] && cp -R .codex "$BACKUP_DIR/.codex" && echo -e "    ${YELLOW}Backed up${NC} .codex/"
  [ -d ".agents" ] && cp -R .agents "$BACKUP_DIR/.agents" && echo -e "    ${YELLOW}Backed up${NC} .agents/"

  # Back up root protocol files
  [ -f "CLAUDE.md" ] && cp CLAUDE.md "$BACKUP_DIR/CLAUDE.md" && echo -e "    ${YELLOW}Backed up${NC} CLAUDE.md"
  [ -f "AGENTS.md" ] && cp AGENTS.md "$BACKUP_DIR/AGENTS.md" && echo -e "    ${YELLOW}Backed up${NC} AGENTS.md"
  [ -f "GUIDE.md" ] && cp GUIDE.md "$BACKUP_DIR/GUIDE.md" && echo -e "    ${YELLOW}Backed up${NC} GUIDE.md"

  echo -e "    Backup at: ${CYAN}$BACKUP_DIR/${NC}"
  echo ""

  # Save user config before wiping
  USER_SETTINGS=""
  if [ -f ".claude/settings.json" ]; then
    USER_SETTINGS=$(cat .claude/settings.json)
  fi

  # Clean slate — remove old agent tooling dirs
  rm -rf .claude .codex .agents
fi

# ══════════════════════════════════════════════════════
# Install kit — clean copy
# ══════════════════════════════════════════════════════
echo "  Installing agents..."
mkdir -p .claude/agents .codex/agents
cp -R "$TMPDIR/.claude/agents/"* .claude/agents/
cp -R "$TMPDIR/.codex/agents/"* .codex/agents/

echo "  Installing skills..."
mkdir -p .claude/skills
cp -R "$TMPDIR/.claude/skills/"* .claude/skills/

echo "  Installing hooks..."
mkdir -p .claude/hooks .codex/hooks
cp -R "$TMPDIR/.claude/hooks/"* .claude/hooks/
cp -R "$TMPDIR/.codex/hooks/"* .codex/hooks/

echo "  Installing configs..."
# Settings: restore user's if they had one, otherwise use kit default
if [ -n "${USER_SETTINGS:-}" ]; then
  echo "$USER_SETTINGS" > .claude/settings.json
  echo -e "    ${CYAN}Restored${NC} .claude/settings.json (your config)"
else
  cp "$TMPDIR/.claude/settings.json" .claude/settings.json
fi
cp "$TMPDIR/.codex/hooks.json" .codex/hooks.json
cp "$TMPDIR/.codex/config.toml" .codex/config.toml

echo "  Installing protocol files..."
cp "$TMPDIR/CLAUDE.md" CLAUDE.md
cp "$TMPDIR/AGENTS.md" AGENTS.md

# ══════════════════════════════════════════════════════
# Process directory — managed parts only, preserve user content
# ══════════════════════════════════════════════════════
echo "  Installing process directory..."

# Seeds: always overwrite (managed reference material)
rm -rf process/_seeds 2>/dev/null
mkdir -p process
cp -R "$TMPDIR/process/_seeds" process/

# Development protocols: always overwrite (managed system files)
rm -rf process/development-protocols 2>/dev/null
cp -R "$TMPDIR/process/development-protocols" process/

# Example PRDs: copy if missing
mkdir -p process/context/planning
[ ! -f "process/context/planning/example-simple-prd.md" ] && cp "$TMPDIR/process/context/planning/example-simple-prd.md" "process/context/planning/example-simple-prd.md"
[ ! -f "process/context/planning/example-complex-prd.md" ] && cp "$TMPDIR/process/context/planning/example-complex-prd.md" "process/context/planning/example-complex-prd.md"

# ══════════════════════════════════════════════════════
# Symlinks
# ══════════════════════════════════════════════════════
echo "  Setting up symlinks..."
mkdir -p .agents
ln -sf ../.claude/skills .agents/skills

# ══════════════════════════════════════════════════════
# Manifest + version
# ══════════════════════════════════════════════════════
cp "$TMPDIR/vc-manifest.json" vc-manifest.json
echo "$VERSION" > .vc-version

cleanup

# ══════════════════════════════════════════════════════
# Summary
# ══════════════════════════════════════════════════════
AGENT_COUNT=$(ls .claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(ls -d .claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
HOOK_COUNT=$(ls .claude/hooks/*.cjs 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo -e "  ${GREEN}Install complete.${NC} (v$VERSION)"
echo ""
echo -e "    ${CYAN}Agents${NC}:     $AGENT_COUNT (Claude Code + Codex)"
echo -e "    ${CYAN}Skills${NC}:     $SKILL_COUNT"
echo -e "    ${CYAN}Hooks${NC}:      $HOOK_COUNT"
echo -e "    ${CYAN}Protocols${NC}:  6 development protocols"
echo -e "    ${CYAN}Seeds${NC}:      $(find process/_seeds -type f 2>/dev/null | wc -l | tr -d ' ') template files"

if [ "$HAS_EXISTING" = true ]; then
  echo ""
  echo -e "  ${YELLOW}Previous setup backed up to ${CYAN}$BACKUP_DIR/${NC}"
  echo -e "  ${YELLOW}Your process/ directory was preserved (plans, context, features).${NC}"
fi

echo ""
echo "  Next:"
echo "    1. Run: claude"
echo '    2. Say: "Run vc-setup"'
echo ""
echo "  vc-setup will auto-detect your project, scaffold the process/"
echo "  directory, deep-scan your codebase, and populate context with"
echo "  your real architecture, patterns, test commands, and conventions."
echo ""
