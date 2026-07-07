# vibecode-pro-max-kit - All Context

Last updated: 2026-07-07

**Project:** Agent harness kit (RIPER-5 plan-first development system) — not an application product. Ships `.claude/`, `.codex/`, skills, hooks, and `process/` protocols for installation into any codebase.

**Maintainer fork:** `https://github.com/Erlangga15/vibecode-pro-max-kit.git` (origin). Upstream kit: `https://github.com/withkynam/vibecode-pro-max-kit.git`.

**Active initiative:** Add **Cursor IDE** as third platform adapter (`process/features/cursor-platform/`). Target: Tier B (hooks, rules, manifest) + audit/validators; no Cursor Automations.

---

## Quick Start

1. Read this file
2. Route via tables below
3. For Cursor adapter work → `process/features/cursor-platform/_GUIDE.md`
4. For testing/validators → `process/context/tests/all-tests.md`
5. For planning → `process/context/planning/all-planning.md`

---

## Current Root Entry Points

| File | Read when |
|---|---|
| `process/context/all-context.md` | any substantial planning, research, review, or implementation task |
| `process/context/tests/all-tests.md` | testing, validators, e2e kit flows |
| `process/context/planning/all-planning.md` | creating or calibrating plans |

## Current Context Groups

| Group | Entry point | Scope |
|---|---|---|
| tests | `process/context/tests/all-tests.md` | e2e kit flows, harness validators, test commands |
| planning | `process/context/planning/all-planning.md` | plan shape examples, SIMPLE vs COMPLEX calibration |

## Current Features

| Feature | Path | Status |
|---|---|---|
| cursor-platform | `process/features/cursor-platform/` | in-progress — Cursor third-platform adapter |

## Task Routing Table

| Task type | Load first | Then load |
|---|---|---|
| general harness research | `all-context.md` | relevant `.claude/skills/*/SKILL.md` |
| Cursor adapter work | `all-context.md`, `features/cursor-platform/_GUIDE.md` | active plan in `features/cursor-platform/active/` |
| agent/skill/hook edits | `all-context.md`, `tests/all-tests.md` | `vc-audit-vc/SKILL.md` |
| implementation planning | `all-context.md`, `planning/all-planning.md` | active plan under `general-plans/` or `features/` |
| test planning or verification | `all-context.md`, `tests/all-tests.md` | validate-contract in active plan |
| harness contribution | `CONTRIBUTING.md`, `tests/all-tests.md` | Tier-1 validators |

---

## Repository Structure

```
vibecode-pro-max-kit/
  .claude/
    agents/           -- 15 RIPER-5 + specialist agents (YAML frontmatter, tool lists)
    skills/           -- 33 workflow skills (SKILL.md + scripts/references)
    hooks/            -- 10 lifecycle hook scripts
    settings.json     -- Claude Code hook wiring
  .codex/
    agents/           -- 15 TOML mirrors (Codex adapter)
    hooks.json        -- Codex hook wiring
    config.toml       -- Codex project config
  .agents/skills/     -- symlink → .claude/skills (Codex/Cursor skill discovery)
  process/
    context/          -- project knowledge (this file + groups)
    development-protocols/  -- 22 RIPER-5 protocol docs
    general-plans/    -- cross-cutting plans (active/completed/backlog)
    features/         -- feature-scoped plans (cursor-platform/)
    _seeds/           -- read-only setup templates
  CLAUDE.md           -- Claude orchestrator + RIPER-5 (Cursor reads this too)
  AGENTS.md           -- cross-tool registry + Codex compat
  install.sh          -- install harness into target projects
  vc-manifest.json    -- kit version + ship manifest (v3.2.5)
  e2e-kit-flows.test.mjs  -- kit e2e tests (Node built-in test)
  resolve-manifest.mjs    -- manifest resolver for install
```

**Not yet present:** `.cursor/` adapter directory (cursor-platform EXECUTE target).

---

## Technology Stack

- **Language:** JavaScript (ESM `.mjs`), Node.js **>= 22**
- **Shell:** Bash (`install.sh`) — WSL/Git Bash on Windows
- **Docs:** Markdown (protocols, agents, skills, context)
- **Config:** JSON (manifest, settings, hooks), TOML (Codex agents)
- **Test runner:** Node built-in `node:test` (e2e-kit-flows); no root package.json
- **Version control:** Git; `main` is working branch for this fork
- **Supported agent platforms (shipped):** Claude Code, Codex
- **Supported agent platforms (in progress):** Cursor IDE (compat + planned `.cursor/` adapter)

---

## Key Patterns and Conventions

**RIPER-5 phases:** RESEARCH → SPEC → INNOVATE → PLAN → VALIDATE → EXECUTE → UPDATE PROCESS. Orchestrator delegates; no inline execution when plan + validate-contract exist.

**Skill layers:** actor agents (`.claude/agents/`, not skills), contract skills (own artifacts), helper skills (assist agents).

**Platform adapters:** Canonical prompts in `.claude/agents/`; Codex uses `.codex/agents/*.toml`; Cursor planned via `.cursor/` + compat paths (`.claude/skills`, `.claude/agents` auto-discovered by Cursor).

**Plans:** Task-folder convention `{slug}_{dd-mm-yy}/` under `active/` or `completed/`; plan file `{slug}_PLAN_{dd-mm-yy}.md` inside.

**Commit policy (this fork):** commit directly on `main` unless user requests feature branch/PR.

**Model policy (harness):** EXECUTE = opus; all other phases = sonnet (when spawning subagents).

**Agent status codes:** DONE, DONE_WITH_CONCERNS, BLOCKED, NEEDS_CONTEXT.

---

## Environment and Configuration

**No application secrets.** Kit repo has no `.env` for runtime.

**Key env vars (install/e2e):**

- `VC_KIT_SOURCE` — local path or URL for install.sh / e2e trials
- `VC_INSTALL_TMPDIR` — install temp dir override
- `TMPDIR` — e2e writes to temp only

**Git remotes:**

- `origin` → Erlangga15 fork (push target)
- `upstream` → withkynam kit (sync source)

---

## Context Group Lifecycle

Context groups are durable knowledge domains, not feature folders. Create a group when a topic has 3+ durable docs or multiple agents repeatedly need one slice of knowledge. Do not create groups for plans or feature-specific content — use `process/features/`.

Indexed entrypoints: `tests/all-tests.md`, `planning/all-planning.md`.

---

## Agent Harness Inventory

| Component | Count | Location |
|-----------|-------|----------|
| Agents | 15 | `.claude/agents/`, `.codex/agents/` |
| Skills | 33 | `.claude/skills/` |
| Hooks | 10 | `.claude/hooks/`, `.codex/hooks.json` |
| Protocol docs | 22 | `process/development-protocols/` |

**Discovery:** `node .claude/skills/vc-context-discovery/scripts/discover-skills.mjs`

---

## Validator Registry (harness maintenance)

Run change-type-relevant validators before closing phases. Full D1/D2 registry: `process/development-protocols/vc-system-behavior/12-reference.md`.

**Tier-1 (UPDATE PROCESS):**

- Harness edits → `vc-audit-vc`
- Context edits → `vc-audit-context`
- Plan edits → `vc-audit-plans`

**Common commands:** see `process/context/tests/all-tests.md`.

---

## Gotchas and Pain Points

- Bootstrap guard: tasks requiring routing fail if `all-context.md` missing — now satisfied after vc-setup
- `agent-write-guard.mjs` referenced but missing — block for plan-agent write allowlist
- Cursor enforcement is softer than Claude Code `disallowedTools` — hooks + `readonly` subagents required
- README claims "zero adapters" but Claude/Codex have full adapters; Cursor adapter is explicit fork goal
- Do not edit `CLAUDE.md` / `AGENTS.md` for project-specific content — use this file and `process/features/`

---

## Scan Metadata

- Generated: 2026-07-07
- HEAD: 3bcb2f9891308fcaa305e2b64027bd0a7dc8251e
- Branch: main
- Mode: vc-setup Flow A (Fresh scaffold + STUDY)
- Runtime: Node v24.x
- Kit version: 3.2.5 (`vc-manifest.json`)

---

## Open Questions and Outstanding Work

- Implement `.cursor/` adapter (cursor-platform feature) via Full RIPER-5
- Implement missing `agent-write-guard.mjs`
- Extend `validate-agent-parity.mjs` for Cursor platform
- Fix `.agents/skills` on Windows: junction created (Developer Mode); install.sh should prefer junction on win32
- Backfill YAML `keywords` frontmatter on context docs (UPDATE PROCESS)
- `validate-context-discovery.mjs` path indexing fails on Windows backslash paths — upstream validator fix optional
