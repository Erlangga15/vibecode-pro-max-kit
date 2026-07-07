---
slug: cursor-adapter
date: 2026-07-07
feature: cursor-platform
tier: B
status: superseded
superseded-by: cursor-first_SPEC_08-07-26.md
verdict-source: cursor-feasibility-probe_FEASIBILITY_07-07-26.md
---

> **SUPERSEDED — do not implement.** Replaced by Cursor-first full migration: `process/features/cursor-platform/active/cursor-first_08-07-26/cursor-first_SPEC_08-07-26.md`. Kept for audit trail only.

# Cursor Third-Platform Adapter (Tier B) — Product SPEC

> **TL;DR:** Ship a native Cursor adapter so the harness installs and enforces RIPER-5 the same way Claude Code and Codex already do — using project rules, hooks, manifest wiring, and validators — without Cursor Cloud Automations or duplicate agent wrappers.

## Summary

Today the kit works fully on Claude Code and Codex, but Cursor users get no dedicated adapter surface and weaker phase safety. This work adds **Tier B** Cursor support: native project rules that always apply, lifecycle hooks that can block unsafe writes, manifest and install wiring so `.cursor/` ships with the kit, extended parity validators, and a real write-guard script. Enforcement must be **layered** (rules + shared orchestrator docs + hooks) because feasibility probes showed rules work after reload, hook script logic is sound in isolation, but live hook interception and subagent readonly alone are **not yet proven** — EXECUTE must diagnose and achieve live deny before we treat hooks as production enforcement. Design choices are locked: no Tier C automations, no duplicate `.cursor/agents` wrappers, Composer 2.5 for all agents in this program, and hard deny on Cursor / advisory on Claude for the write guard.

## User Stories / Jobs To Be Done

1. **As a harness maintainer**, I want Cursor to be a first-class install target alongside Claude and Codex, so that one `install.sh` run gives Cursor users the same RIPER-5 kit without manual copying.

2. **As a harness maintainer**, I want automated parity checks to cover Cursor agent metadata (readonly, model) on the canonical agent definitions, so that drift between platforms is caught before merge.

3. **As an orchestrator running in Cursor**, I want always-on project rules that state phase boundaries and orchestrator role, so that agents see harness protocol even when hooks fail open.

4. **As an orchestrator running in Cursor**, I want hooks to **actually block** disallowed writes during a live session (not only in a terminal stdin test), so that read-only phases cannot silently mutate the repo.

5. **As a phase-locked subagent (e.g. RESEARCH, SPEC, INNOVATE)**, I want write attempts outside my allowed surface to be denied on Cursor, so that phase purity is enforced by tooling—not trust.

6. **As a Claude Code user**, I want the new write-guard script to remain **advisory** (warn, not hard-block), so that existing Claude workflows are not regressed.

7. **As a contributor validating a PR**, I want kit portability and agent-parity validators to include Cursor surfaces, so that CI and local gates match what we ship.

8. **As a kit consumer on Windows**, I want hook scripts to reuse the same canonical hook paths as Claude where possible, so that maintenance stays single-source.

## What The User Wants (Behavioral Outcomes)

**Install and ship**

- Running the kit installer on a target project places a complete Cursor adapter tree (hooks config, rules, and any Cursor-specific wiring) next to the existing Claude and Codex surfaces.
- The kit version manifest lists Cursor paths so updates and publish flows treat Cursor as part of the shipped product.

**Agent identity (no duplicate wrappers)**

- All 15 harness agents remain defined once in the canonical agent prompt files; Cursor-specific behavior is expressed through added fields (readonly flag, model = Composer 2.5) on those same definitions—not through parallel wrapper files under a separate Cursor agents folder.

**Layered enforcement on Cursor**

- **Rules layer (required):** Project rules with always-apply scope load after a Cursor window reload and are visible in the IDE rules UI; they encode orchestrator vs phase-agent boundaries and complement CLAUDE.md.
- **Hooks layer (required, with live proof):** Pre-tool-use hooks run the same deny/allow logic already verified in local stdin tests; in a live Cursor chat, a probe write to a blocked path must be **denied** before the file appears on disk. If live deny fails, EXECUTE must document root cause and remediate (settings, wiring, tool name, path, or fail-open behavior)—not ship production hooks as "done" without live block evidence.
- **Write-guard script (required):** The missing agent write-guard hook script is implemented. On Cursor it **hard-denies** writes outside each agent's allowlist. On Claude Code it logs or warns but does not hard-block (preserves current behavior).
- **Readonly subagents:** May be set on canonical agent metadata for documentation and Task delegation hints, but **must not** be the only enforcement mechanism for phase lock (feasibility: readonly subagent writes still succeeded in probe).

**Validators and audit**

- Agent parity validation covers Claude, Codex, **and** Cursor-relevant fields on canonical agents.
- Kit portability validation fails if Cursor adapter files are missing from the manifest or install output.
- Tier-1 harness audit (`vc-audit-vc`) can be run after Cursor adapter changes with the same confidence as Claude/Codex edits.

**Explicit non-goals reflected in behavior**

- No Cursor Cloud Automations product surface.
- No dependency on third-party "skills" marketplace settings—only native `.cursor/` project files.
- Codex `run-node.sh` gap remains backlog-only (not solved in this SPEC).

## Flow / State Diagram

```
[Contributor merges Cursor adapter]
        |
        v
[install.sh / kit update] --> [.cursor/ + rules + hooks.json land in target project]
        |
        v
[User opens Cursor] --> [Reload window]
        |
        +--> [Rules: alwaysApply visible in UI] ----+
        |                                          |
        +--> [Hooks: preToolUse wired]              |
                    |                               |
                    v                               v
            {Live write to blocked path?}    [Agent reads CLAUDE.md + rules]
                    |
         +----------+----------+
         |                     |
    [DENY: no file]      [ALLOW: within allowlist]
    (required for          |
     production)            v
                    [Phase-locked agent completes]
        |
        v
[Validators: parity + portability + e2e install] --> {all green?} --yes--> [Tier B DONE]
                                                    |
                                                   no
                                                    v
                                            [Fix before release]
```

**Enforcement stack (Cursor — all layers required):**

```
                    +------------------+
                    |  CLAUDE.md       |
                    |  (orchestrator)  |
                    +--------+---------+
                             |
              +--------------+--------------+
              |              |              |
     +--------v-----+ +------v------+ +-----v--------+
     | alwaysApply  | | preToolUse  | | write-guard  |
     | .mdc rules   | | hooks.json  | | per-agent    |
     +--------------+ +-------------+ +--------------+
              \              |              /
               \             |             /
                v            v            v
              [Layered deny — NOT hooks-only, NOT readonly-only]
```

## Acceptance Criteria (Testable Outcomes)

### Install, manifest, and e2e

- **AC1:** A clean kit install into a disposable trial directory produces a `.cursor/` adapter tree (hooks configuration and always-apply rules at minimum) alongside existing Claude and Codex surfaces.
  - proven by: e2e-kit-flows install trial — Cursor artifacts present
  - strategy: Fully-Automated

- **AC2:** The kit manifest and installer include Cursor adapter paths so publish/update flows ship `.cursor/**` the same way other harness surfaces are shipped.
  - proven by: validate-kit-portability.mjs — Cursor paths indexed
  - strategy: Fully-Automated

### Agent model and parity (canonical agents only)

- **AC3:** All 15 canonical agent definitions carry Cursor-oriented `readonly` and `model` metadata (model value Composer 2.5 for every agent in this program), with no requirement for duplicate agent wrapper files under a separate Cursor agents directory.
  - proven by: validate-agent-parity.mjs — Cursor dimension added
  - strategy: Fully-Automated

- **AC4:** Extended agent parity check fails on intentional drift (missing model, wrong readonly on a phase-locked agent) across Claude, Codex, and Cursor metadata expectations.
  - proven by: validate-agent-parity.mjs --strict with negative fixture or deliberate drift test
  - strategy: Fully-Automated

### Write-guard script

- **AC5:** `agent-write-guard.mjs` exists at the canonical hooks path referenced by agent frontmatter, and local stdin tests show deny (exit/block) for out-of-allowlist writes and allow for in-allowlist paths.
  - proven by: agent-write-guard stdin deny/allow probe (same class as feasibility hook script test)
  - strategy: Fully-Automated

- **AC6:** On Cursor, the write-guard path produces a **hard deny** (blocked write, user-visible failure) for a phase-locked agent attempting a disallowed write.
  - proven by: Cursor live write-guard deny probe — disallowed path
  - strategy: Hybrid

- **AC7:** On Claude Code, the same write-guard script remains **advisory only** (warn/log without hard-blocking legitimate Claude disallowedTools behavior).
  - proven by: Claude advisory write-guard probe — no regression on existing agent sessions
  - strategy: Agent-Probe

### Rules layer

- **AC8:** At least one always-apply project rule file exists under `.cursor/rules/`, uses always-apply scope, and after a Cursor window reload appears in the IDE rules UI and is readable by the agent in a new chat.
  - proven by: rules visibility retest — post-reload UI + agent read (feasibility probe class; evidence path retained)
  - strategy: Hybrid

- **AC9:** The rules layer is present in every shipped adapter; acceptance does not treat hooks plus CLAUDE.md alone as sufficient without always-apply rules.
  - proven by: validate-kit-portability.mjs — rules glob required
  - strategy: Fully-Automated

### Hooks layer — script logic and live deny

- **AC10:** Pre-tool-use hook scripts reuse canonical `.claude/hooks/` script paths where feasible (single source), wired through `.cursor/hooks.json`.
  - proven by: validate-kit-portability.mjs or parity script — hook command paths point to shared hooks tree
  - strategy: Fully-Automated

- **AC11:** Hook deny script logic passes local stdin test (block returns deny payload / non-zero exit; allow returns allow).
  - proven by: hook stdin deny/allow probe (feasibility evidence: probe verdict table)
  - strategy: Fully-Automated

- **AC12:** In a live Cursor session (new chat after reload), a probe write to an explicitly blocked path is **denied** — the file must not be created on disk.
  - proven by: live preToolUse deny retest — blocked write does not land (contrasts with feasibility NOT BLOCKED baseline; EXECUTE must diagnose root cause if failing)
  - strategy: Agent-Probe

- **AC13:** EXECUTE documents the live-hook diagnosis outcome: if AC12 initially fails, the phase records cause (e.g. hooks disabled in settings, tool_name mismatch, Windows path, fail-open) and the remediated wiring that achieved AC12, or a formal Known-Gap with residual enforcement = rules + write-guard only.
  - proven by: live-hook diagnosis report artifact in task folder
  - strategy: Hybrid

### Validators and regression

- **AC14:** `validate-agent-parity.mjs` covers Cursor as a third platform (not Claude↔Codex only).
  - proven by: validate-agent-parity.mjs exit 0 on adapter branch
  - strategy: Fully-Automated

- **AC15:** Full e2e kit flow suite passes with Cursor adapter included (install/update trials do not regress).
  - proven by: node --test e2e-kit-flows.test.mjs
  - strategy: Fully-Automated

- **AC16:** Skill discovery smoke test still passes after adapter land (no broken catalog or symlink surface).
  - proven by: discover-skills.mjs smoke
  - strategy: Fully-Automated

### Enforcement policy constraints (testable)

- **AC17:** Phase-lock enforcement design does not rely solely on subagent `readonly: true` (documented in adapter guide and verified by probe regression note).
  - proven by: enforcement design checklist — readonly-not-sufficient flag in audit output
  - strategy: Hybrid

- **AC18:** Tier-1 `vc-audit-vc` run after Cursor adapter changes reports no blocking parity/portability failures.
  - proven by: vc-audit-vc tier-1 gate on adapter PR
  - strategy: Fully-Automated

## Out Of Scope

- **Tier C — Cursor Cloud Automations** (scheduled/autonomous cloud agents, automation UI, cloud hook products).
- **Duplicate `.cursor/agents/*.md` wrapper files** — canonical `.claude/agents/*.md` is the single source; Cursor reads compat paths only.
- **Third-party Cursor skills marketplace** integration (setting unavailable; native `.cursor/` only).
- **Codex `run-node.sh` gap** — backlog note only; not part of this adapter.
- **Application/product code** in consumer repos — harness kit surfaces only.
- **Changing RIPER-5 phase semantics** — adapter enforces existing protocol, does not redesign it.
- **Opus/Sonnet model policy for spawned subagents** — this program locks Composer 2.5 on Cursor metadata; broader model policy is unchanged elsewhere.
- **Fixing upstream Cursor IDE bugs** beyond wiring, diagnosis, and documented Known-Gaps.

## Constraints

### User-locked design decisions

| Decision | Requirement |
|----------|-------------|
| Tier target | **B only** — hooks + rules + manifest + validators |
| Rules | `.cursor/rules/*.mdc` with alwaysApply — **required**; hooks + CLAUDE.md alone **not sufficient** |
| Agent source | Extend canonical agent files with `readonly`, `model` — **no** `.cursor/agents` duplicates |
| Write guard | **Hard deny** on Cursor; **advisory** on Claude Code |
| Hook scripts | Reuse `.claude/hooks/` paths where possible |
| Model | **Composer 2.5** for all agents in this program |
| Automations | **No** Cursor Cloud Automations |
| Skills setting | Native `.cursor/` only |

### Non-functional requirements (enforcement critical)

| NFR | Requirement |
|-----|-------------|
| **Defense in depth** | Production Cursor enforcement = rules + CLAUDE.md + hooks + per-agent write-guard; no single layer alone |
| **Fail-safe documentation** | If live `preToolUse` cannot be made blocking, ship only with documented Known-Gap and compensating controls (rules + write-guard hard deny) — never silent "hooks.json present = enforced" |
| **No vacuous green** | Every developed behavior has Fully-Automated or Hybrid proof; Agent-Probe only for live IDE hooks and Claude advisory regression |
| **Single source of truth** | Hook logic and agent prompts not forked into Cursor-only copies unless platform API forces a thin adapter file |
| **Parity with ship manifest** | Cursor files versioned in `vc-manifest.json` and installed by `install.sh` — same class as `.codex/**` |
| **Zero regression** | Claude and Codex install/validator/e2e paths remain green |
| **Evidence retention** | Feasibility probe artifacts remain referenceable under `cursor-feasibility-probe_07-07-26/` |

### Feasibility-derived constraints (from prior probe)

| Mechanism | Verdict | SPEC implication |
|-----------|---------|------------------|
| Hook script stdin logic | VIABLE | Ship script; automate AC11 |
| Live preToolUse | NOT BLOCKED (inconclusive) | AC12–AC13 mandatory before calling hooks "production" |
| Subagent readonly | NOT VIABLE alone | AC17; layered enforcement |
| alwaysApply rules after reload | VIABLE | AC8–AC9 required |

### System / process

- RIPER-5 phase locking unchanged; SPEC does not choose implementation approach (INNOVATE/PLAN).
- Tier-1 validators (`vc-audit-vc`, kit portability, agent parity) must pass before UPDATE PROCESS closes the feature.
- Node >= 22, git in PATH (existing kit prerequisites).

## Open Questions

None for product intent — design choices above are locked.

**EXECUTE-phase diagnostics (not blocking SPEC/INNOVATE/PLAN):**

| Item | Owner | Notes |
|------|-------|-------|
| Why live `preToolUse` did not fire in feasibility sessions | EXECUTE | Addressed by AC12–AC13; evidence baseline: `cursor-feasibility-probe_FEASIBILITY_07-07-26.md`, transcript `879c1c1a-1d06-4ff1-88d7-7a44535235a5`, `FEASIBILITY_PROBE_BLOCK/retest.md` |
| Exact hook `tool_name` mapping for Cursor Write/Edit tools | EXECUTE | PLAN may specify; SPEC requires live deny outcome only |
| Windows path normalization for hook commands | EXECUTE | If AC12 fails on Windows, diagnose here |

## Background / Research Findings

### Repository state (2026-07-07)

- **`.cursor/` absent** in kit today; Claude (`.claude/`) and Codex (`.codex/`) adapters are complete.
- **Inventory:** 15 agents, 33 skills, 10 hook scripts; `vc-manifest.json` v3.2.5 lists Claude/Codex but not `.cursor/**`.
- **`install.sh`:** no Cursor-specific install lines yet (grep: no `cursor` / `.cursor` matches).
- **`agent-write-guard.mjs`:** referenced in 12 agent frontmatter files but **missing** from `.claude/hooks/` — blocks faithful Cursor hard-deny POC.
- **`validate-agent-parity.mjs`:** Claude ↔ Codex only; no Cursor dimension.
- **Codex pattern:** `.codex/agents/*.toml` mirrors canonical prompts — Cursor adapter should mirror **metadata** on canonical `.claude/agents/*.md`, not duplicate full prompts in `.cursor/agents/`.

### Feasibility probe summary

**Source:** `process/features/cursor-platform/active/cursor-feasibility-probe_07-07-26/cursor-feasibility-probe_FEASIBILITY_07-07-26.md`

| Probe | Result |
|-------|--------|
| Hook deny script (stdin) | VIABLE — BLOCK/ALLOW exits correct |
| Live preToolUse (same session) | NOT BLOCKED — write succeeded |
| Live preToolUse (reload + new chat) | NOT BLOCKED — `FEASIBILITY_PROBE_BLOCK/retest.md` created |
| Subagent `readonly: true` | NOT VIABLE — writes succeeded |
| alwaysApply rules (after reload) | VIABLE — UI + agent read rule file |

**Verdict:** INCONCLUSIVE — licenses rules + script logic; forbids readonly-only phase lock and assuming live hooks work without proof.

### Test context (from `process/context/tests/all-tests.md`)

- **E2E:** `node --test e2e-kit-flows.test.mjs` — install/update trials (extend expectations for `.cursor/`).
- **Validators:** `validate-agent-parity.mjs`, `validate-kit-portability.mjs`, `validate-skills.mjs`, `discover-skills.mjs`.
- **Tier-1:** `vc-audit-vc` after harness edits.
- **Known gap (pre-adapter):** missing `agent-write-guard.mjs`; no Cursor parity validators — both are in scope for this SPEC.

### User brainstorm (locked)

- Tier B target (hooks + rules + manifest + validators) — NOT Tier C automations.
- `.cursor/rules/*.mdc` REQUIRED.
- Extend canonical agents — not duplicate `.cursor/agents` wrappers.
- `agent-write-guard.mjs`: hard deny Cursor, advisory Claude.
- Reuse `.claude/hooks/` where possible.
- `run-node.sh` Codex gap: out of scope, backlog only.
- No Cursor Cloud Automations; no third-party skills setting.
- Composer 2.5 for all agents in this program.

### Evidence paths (reference)

- `process/features/cursor-platform/active/cursor-feasibility-probe_07-07-26/cursor-feasibility-probe_FEASIBILITY_07-07-26.md`
- `process/features/cursor-platform/active/cursor-feasibility-probe_07-07-26/FEASIBILITY_PROBE_BLOCK_live-test.md`
- `process/features/cursor-platform/active/cursor-feasibility-probe_07-07-26/FEASIBILITY_PROBE_BLOCK/retest.md`
- `process/features/cursor-platform/active/cursor-feasibility-probe_07-07-26/READONLY_PROBE_OUTPUT.md`
- `process/features/cursor-platform/active/cursor-feasibility-probe_07-07-26/READONLY_TASK_PARAM_PROBE.md`
- Agent transcript: `879c1c1a-1d06-4ff1-88d7-7a44535235a5` (rules visible after reload; live hook still not blocked)
