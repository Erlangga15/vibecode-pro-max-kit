# vibecode-pro-max-kit - All Tests

Last updated: 2026-07-07

Attach this file first when the task involves testing, verification, or test debugging.

## Quick Decision Guide

### Use `node --test` (Node built-in) when

- running kit-level e2e install/update flows
- validating harness behavior without external test deps

### Use individual `validate-*.mjs` scripts when

- verifying harness structure after agent/skill/hook/context/plan edits
- closing VALIDATE, UPDATE PROCESS, or contribution gates

**Always run from project root:**

```bash
cd d:/Erlangga/Personal/vibecode-pro-max-kit
node .claude/skills/<skill>/scripts/<validator>.mjs
```

## Primary Test Commands

| Command | Purpose |
|---------|---------|
| `node e2e-kit-flows.test.mjs` | Four e2e kit trials (install, update, merge) — writes only to `/tmp` |
| `node --test e2e-kit-flows.test.mjs` | Same suite via Node test runner |

**Env:** set `VC_KIT_SOURCE` to kit root when running e2e from another directory.

## Tier-1 Harness Validators (run after relevant changes)

| Validator | When to run |
|-----------|-------------|
| `node .claude/skills/vc-audit-vc/scripts/validate-agent-parity.mjs` | Agent edits (`.claude/agents/`, `.codex/agents/`) |
| `node .claude/skills/vc-audit-vc/scripts/validate-agent-parity.mjs --strict` | Before commit with agent changes |
| `node .claude/skills/vc-audit-vc/scripts/validate-skills.mjs` | Skill registry changes |
| `node .claude/skills/vc-audit-vc/scripts/validate-kit-portability.mjs` | Manifest/install surface changes |
| `node .claude/skills/vc-audit-context/scripts/validate-context-discovery.mjs` | Context doc routing edits |
| `node .claude/skills/vc-generate-context/scripts/validate-all-context.mjs` | After `all-context.md` changes |
| `node .claude/skills/vc-generate-plan/scripts/validate-plan-artifact.mjs <plan-path>` | After writing a plan file |
| `node .claude/skills/vc-audit-plans/scripts/validate-phase-plan-completeness.mjs` | Phase program plans |

## Skill Discovery Smoke Test

```bash
node .claude/skills/vc-context-discovery/scripts/discover-skills.mjs
```

Requires `process/context/generated-skills-catalog.json` (kit-installed).

## Catalog Regeneration

If catalog missing:

```bash
node .claude/skills/vc-audit-context/scripts/generate-skills-catalog.mjs --write
```

## Prerequisites

- **Node.js >= 22** (required by `resolve-manifest.mjs`, install.sh, validators)
- **git** in PATH (validators resolve project root via `git rev-parse`)
- On Windows: Developer Mode recommended for symlink support (`.agents/skills` → `.claude/skills`)

## Known Gaps

- `agent-write-guard.mjs` referenced in agent frontmatter but not present in repo — implement before Cursor write-guard POC
- No `.cursor/` adapter yet — Cursor parity validators to be added during cursor-platform feature
- Root has no `package.json`; per-skill `package.json` exists only under some skills (vc-agent-browser, vc-docs-seeker, vc-sequential-thinking)

## Quick Routing

| If you need... | Read next |
|---|---|
| contribution validator checklist | `CONTRIBUTING.md` |
| VC-system behavior validators (D1/D2) | `process/development-protocols/vc-system-behavior/12-reference.md` |
| e2e kit flow source | `e2e-kit-flows.test.mjs` |
