---
slug: cursor-first
date: 2026-07-08
feature: cursor-platform
supersedes: cursor-adapter_SPEC_07-07-26.md
supersedes-note: Tier B adapter approach (extend canonical .claude/agents) — abandoned in favor of full Cursor-native migration
verdict-source: cursor-feasibility-probe_FEASIBILITY_07-07-26.md
---

# Cursor-First Harness Migration — Product SPEC

> **TL;DR:** Cursor becomes a first-class platform with its own self-contained harness tree under `.cursor/`, a dedicated `cursor-first` install profile, and AGENTS.md as the sole orchestrator entry — not a thin adapter over `.claude/`. The legacy full profile for Claude+Codex stays unchanged. Feasibility findings on rules, hooks, and readonly still apply.

**Supersedes:** `process/features/cursor-platform/active/cursor-adapter_07-07-26/cursor-adapter_SPEC_07-07-26.md` (Tier B adapter — do not extend).

## Summary

Today the kit ships fully for Claude Code and Codex, while Cursor users rely on compatibility paths with no dedicated, self-contained harness. This work delivers a **Cursor-first fork**: a complete, native Cursor harness surface that stands on its own — agents, skills (full copies, not symlinks), rules, hooks, and validators — plus a new **`cursor-first` install profile** that installs only what Cursor needs (`.cursor/**`, `AGENTS.md`, `process/`). The existing **full/legacy profile** continues to install Claude, Codex, and all current surfaces for multi-tool teams. Enforcement remains **layered** (always-on rules + orchestrator docs + hooks + write-guard) because feasibility probes proved rules work after reload and hook script logic is sound, but live hook blocking and subagent readonly alone are **not yet proven** — delivery must diagnose and achieve live deny before treating hooks as production enforcement. No Cursor Cloud Automations; Composer 2.5 for all agents in this program.

## User Stories / Jobs To Be Done

1. **As a Cursor-only developer**, I want one installer command that gives me a complete, self-contained RIPER-5 harness without Claude or Codex files cluttering my project, so that I can work in Cursor without manual copying or symlink breakage on Windows.

2. **As a Cursor-only developer**, I want all 15 harness agents and 33 workflow skills available natively under `.cursor/`, so that Cursor discovers them from project files — not from a hidden dependency on `.claude/`.

3. **As an orchestrator running in Cursor**, I want `AGENTS.md` to be my single orchestrator entry (no `CLAUDE.md` in a cursor-first install), so that the harness reads correctly for a Cursor-first workflow.

4. **As an orchestrator running in Cursor**, I want always-on project rules that enforce RIPER-5 phase boundaries, so that agents see harness protocol even when hooks fail open.

5. **As an orchestrator running in Cursor**, I want hooks to **actually block** disallowed writes during a live session, so that read-only phases cannot silently mutate the repo.

6. **As a phase-locked subagent (e.g. RESEARCH, SPEC, INNOVATE)**, I want write attempts outside my allowed surface to be denied on Cursor, so that phase purity is enforced by tooling — not trust.

7. **As a Claude Code + Codex maintainer**, I want the existing full install profile to behave exactly as today, so that Cursor-first work does not regress my workflow.

8. **As a harness maintainer**, I want automated parity and portability validators that check the **self-contained Cursor tree** (not metadata bolted onto `.claude/agents`), so that drift is caught before merge.

9. **As a contributor on Windows**, I want skills installed as **full file copies** under `.cursor/skills/`, so that the harness works without symlink privileges.

10. **As a contributor merging upstream kit changes**, I accept manual conflict resolution on shared surfaces (`process/`, `AGENTS.md`, manifest), so that the fork can evolve without blocking on perfect automation.

## What The User Wants (Behavioral Outcomes)

### Two install profiles

| Profile | Who it's for | What gets installed | What does NOT get installed |
|---------|--------------|---------------------|----------------------------|
| **`cursor-first`** | Cursor-only projects | `.cursor/**` (agents, skills as full copies, rules, hooks + scripts), `AGENTS.md`, `process/` (protocols + seeds + generated catalog) | `.claude/**`, `.codex/**`, `CLAUDE.md`, `.agents/` symlink |
| **`full` / legacy (default)** | Claude Code + Codex (+ optional Cursor compat) | Current behavior: `.claude/**`, `.codex/**`, `CLAUDE.md`, `AGENTS.md`, `process/`, `.agents/skills` symlink | N/A — unchanged from today |

Both profiles share the portable RIPER-5 core in `process/`. The manifest and installer must express both profiles clearly so publish, update, and e2e trials can target each.

### Cursor-native harness (self-contained)

- **Agents:** 15 vc-* agents live canonically under `.cursor/agents/` for the cursor-first profile. They are first-class Cursor definitions — not wrapper files pointing at `.claude/agents/`.
- **Skills:** 33 vc-* skills live under `.cursor/skills/` as **full directory copies** (scripts, references, frontmatter included). No symlink to `.claude/skills/` — self-contained on Windows.
- **Rules:** `.cursor/rules/` carries always-apply RIPER-5 orchestrator and phase-enforcement rules. Required layer; hooks + orchestrator doc alone are not sufficient.
- **Hooks:** `.cursor/hooks.json` wires lifecycle hooks; hook scripts live under `.cursor/hooks/` (or a documented shared path strategy decided in a later phase). The missing **agent write-guard** script is implemented in the Cursor-first location.
- **Orchestrator entry:** `AGENTS.md` only for cursor-first — `CLAUDE.md` is not installed. No separate `CURSOR.md` file.

### Layered enforcement on Cursor

- **Rules layer (required):** Always-apply project rules visible in the IDE after window reload.
- **Orchestrator doc layer (required):** `AGENTS.md` encodes orchestrator role and RIPER-5 routing for cursor-first installs.
- **Hooks layer (required, with live proof):** Pre-tool-use hooks run deny/allow logic verified in local stdin tests; in a live Cursor chat, a probe write to a blocked path must be **denied** before the file appears on disk. If live deny fails, delivery must document root cause and remediate — not ship production hooks as "done" without live block evidence.
- **Write-guard script (required):** Hard-deny on Cursor for out-of-allowlist writes. Layered with rules and hooks — not readonly subagents alone (feasibility: readonly writes still succeeded).

### Validators and audit

- Parity and portability validators check the **self-contained `.cursor/` tree** — not extended `cursor_*` fields on `.claude/agents/`.
- Tier-1 harness audit runs after cursor-first changes with the same confidence as Claude/Codex edits.
- Full/legacy profile validators remain green (zero regression).

### Migration scope inventory (what moves / what stays)

| Surface | Cursor-first action | Full/legacy action |
|---------|--------------------|--------------------|
| **15 agents** | Canonical copies under `.cursor/agents/` | Remain under `.claude/agents/` + `.codex/agents/` mirrors |
| **33 skills** | Full copy under `.cursor/skills/` | Remain under `.claude/skills/`; `.agents/skills` symlink |
| **Rules** | New `.cursor/rules/*.mdc` (alwaysApply) | N/A (Claude uses CLAUDE.md + settings) |
| **Hooks** | `.cursor/hooks.json` + `.cursor/hooks/*.mjs` incl. agent-write-guard | `.claude/hooks/` + `.codex/hooks.json` unchanged |
| **Orchestrator** | `AGENTS.md` (cursor-first tailored) | `CLAUDE.md` + `AGENTS.md` |
| **Manifest** | `vc-manifest.json` gains cursor-first include blocks / profile selector | Existing include blocks preserved |
| **Installer** | `install.sh` gains `--profile cursor-first` (or equivalent) | Default profile unchanged |
| **Validators** | New or extended checks for `.cursor/` self-containment | Existing Claude/Codex checks unchanged |
| **`process/`** | Shipped in both profiles (portable RIPER-5 core) | Same |

## Flow / State Diagram

```
[Contributor chooses install profile]
        |
        +--- cursor-first ----------------+--- full/legacy (default) ----+
        |                                 |                              |
        v                                 v                              v
[install.sh --profile cursor-first]   [install.sh default]
        |                                 |
        v                                 v
[.cursor/ + AGENTS.md + process/]    [.claude/ + .codex/ + CLAUDE.md
 NO .claude/ .codex/ CLAUDE.md]      + AGENTS.md + process/ + symlink]
        |                                 |
        v                                 v
[User opens Cursor]                   [User opens Claude/Codex]
        |                                 |
        v                                 v
[Reload window]                       [Existing harness flow]
        |
        +--> [Rules: alwaysApply visible]
        +--> [AGENTS.md: orchestrator context]
        +--> [Hooks: preToolUse wired]
                    |
                    v
            {Live write to blocked path?}
                    |
         +----------+----------+
         |                     |
    [DENY: no file]      [ALLOW: in allowlist]
    (required for            |
     production)              v
                    [Phase agent completes]
        |
        v
[Validators: cursor-first parity + portability + e2e]
        |
        v
    {all green?} --yes--> [Cursor-first DONE]
         |
        no
         v
    [Fix before release]
```

**Enforcement stack (Cursor-first — all layers required):**

```
              +------------------+
              |    AGENTS.md     |
              |  (orchestrator)  |
              +--------+---------+
                       |
        +--------------+--------------+
        |              |              |
+-------v------+ +-----v-------+ +----v---------+
| alwaysApply  | | preToolUse  | | write-guard  |
| .mdc rules   | | hooks.json  | | per-agent    |
+--------------+ +-------------+ +--------------+
        \              |              /
         \             |             /
          v            v            v
        [Layered deny — NOT hooks-only, NOT readonly-only]
```

## Acceptance Criteria (Testable Outcomes)

### Install profiles and manifest

- **AC1:** A clean `cursor-first` install into a disposable trial directory produces `.cursor/` (agents, skills, rules, hooks), `AGENTS.md`, and `process/` — and does **not** place `.claude/`, `.codex/`, `CLAUDE.md`, or `.agents/skills`.
  - proven by: e2e-kit-flows — cursor-first install trial
  - strategy: Fully-Automated

- **AC2:** A clean full/legacy install still produces all current Claude and Codex surfaces with no regression from today's behavior.
  - proven by: e2e-kit-flows — default install trial
  - strategy: Fully-Automated

- **AC3:** The kit manifest indexes cursor-first ship paths (`.cursor/**`, cursor-first `AGENTS.md` variant if applicable) so publish and update flows treat Cursor-first as a first-class ship surface.
  - proven by: validate-kit-portability.mjs — cursor-first paths indexed
  - strategy: Fully-Automated

### Self-contained Cursor tree

- **AC4:** All 15 harness agents exist under `.cursor/agents/` with no runtime dependency on `.claude/agents/` for cursor-first installs.
  - proven by: validate-agent-parity.mjs — cursor self-contained agent count
  - strategy: Fully-Automated

- **AC5:** All 33 workflow skills exist under `.cursor/skills/` as full copies (not symlinks), and skill discovery smoke test passes from the cursor-first tree.
  - proven by: discover-skills.mjs smoke against cursor-first install
  - strategy: Fully-Automated

- **AC6:** Skills under `.cursor/skills/` are real directory copies — validator or portability check fails if any entry is a symlink to `.claude/skills/`.
  - proven by: validate-kit-portability.mjs — no symlink dependency on cursor-first skills
  - strategy: Fully-Automated

### Orchestrator entry

- **AC7:** A cursor-first install ships `AGENTS.md` as the orchestrator entry and does not install `CLAUDE.md` or `CURSOR.md`.
  - proven by: e2e-kit-flows — cursor-first orchestrator file presence/absence check
  - strategy: Fully-Automated

### Write-guard script

- **AC8:** Agent write-guard script exists under the Cursor-first hooks location and local stdin tests show deny for out-of-allowlist writes and allow for in-allowlist paths.
  - proven by: agent-write-guard stdin deny/allow probe
  - strategy: Fully-Automated

- **AC9:** On Cursor, the write-guard produces a **hard deny** (blocked write, user-visible failure) for a phase-locked agent attempting a disallowed write.
  - proven by: Cursor live write-guard deny probe
  - strategy: Hybrid

### Rules layer

- **AC10:** At least one always-apply project rule exists under `.cursor/rules/`, and after a Cursor window reload it appears in the IDE rules UI and is readable by the agent in a new chat.
  - proven by: rules visibility retest — post-reload UI + agent read
  - strategy: Hybrid

- **AC11:** The rules layer is required in every cursor-first ship; acceptance does not treat hooks + AGENTS.md alone as sufficient without always-apply rules.
  - proven by: validate-kit-portability.mjs — rules glob required for cursor-first
  - strategy: Fully-Automated

### Hooks layer — script logic and live deny

- **AC12:** Hook deny script logic passes local stdin test (block returns deny payload / non-zero exit; allow returns allow).
  - proven by: hook stdin deny/allow probe
  - strategy: Fully-Automated

- **AC13:** In a live Cursor session (new chat after reload), a probe write to an explicitly blocked path is **denied** — the file must not be created on disk.
  - proven by: live preToolUse deny retest — blocked write does not land
  - strategy: Agent-Probe

- **AC14:** Delivery documents the live-hook diagnosis outcome: if AC13 initially fails, the phase records cause (hooks disabled, tool_name mismatch, Windows path, fail-open) and the remediated wiring that achieved AC13, or a formal Known-Gap with residual enforcement = rules + write-guard only.
  - proven by: live-hook diagnosis report artifact in task folder
  - strategy: Hybrid

### Validators, parity, and regression

- **AC15:** Agent parity validation covers the self-contained `.cursor/agents/` tree (not `cursor_*` fields on `.claude/agents/`) and fails on intentional drift.
  - proven by: validate-agent-parity.mjs --strict with cursor-first dimension
  - strategy: Fully-Automated

- **AC16:** Full e2e kit flow suite passes for **both** install profiles (cursor-first and full/legacy).
  - proven by: node --test e2e-kit-flows.test.mjs
  - strategy: Fully-Automated

- **AC17:** Phase-lock enforcement design does not rely solely on subagent readonly (documented and verified against feasibility regression note).
  - proven by: enforcement design checklist — readonly-not-sufficient flag
  - strategy: Hybrid

- **AC18:** Tier-1 `vc-audit-vc` run after cursor-first changes reports no blocking parity or portability failures.
  - proven by: vc-audit-vc tier-1 gate on cursor-first PR
  - strategy: Fully-Automated

- **AC19:** All agents in the cursor-first program use Composer 2.5 as the declared model in their Cursor agent definitions.
  - proven by: validate-agent-parity.mjs — model field check on .cursor/agents
  - strategy: Fully-Automated

- **AC20:** `validate-skills.mjs` passes for the cursor-first skills tree (registry consistency with canonical skill set).
  - proven by: validate-skills.mjs exit 0 on cursor-first branch
  - strategy: Fully-Automated

## Out Of Scope

- **Tier C — Cursor Cloud Automations** (scheduled/autonomous cloud agents, automation UI).
- **Phased Tier B adapter** — extending canonical `.claude/agents/` with `cursor_*` metadata fields instead of a self-contained `.cursor/` tree (superseded approach; see `cursor-adapter_SPEC_07-07-26.md`).
- **`CURSOR.md`** — AGENTS.md is the sole orchestrator entry for cursor-first.
- **Installing `CLAUDE.md` on cursor-first profile** — explicitly excluded.
- **Symlinked skills** for cursor-first — full copies only.
- **Third-party Cursor skills marketplace** integration.
- **Codex `run-node.sh` gap** — backlog only.
- **Application/product code** in consumer repos — harness kit surfaces only.
- **Changing RIPER-5 phase semantics** — migration enforces existing protocol.
- **Fixing upstream Cursor IDE bugs** beyond wiring, diagnosis, and documented Known-Gaps.
- **Automatic upstream merge conflict resolution** — manual resolution is acceptable per user.

## Constraints

### User-locked design decisions

| Decision | Requirement |
|----------|-------------|
| Platform stance | **Cursor-first fork** — Cursor is first-class, not a thin adapter over `.claude/` |
| Migration shape | **Full migration** — entire harness surface native to Cursor, not phased adapter |
| Agent source | **`.cursor/agents/`** — 15 canonical agents for cursor-first profile |
| Skill source | **`.cursor/skills/`** — 33 full copies, NOT symlink |
| Rules | **`.cursor/rules/*.mdc`** with alwaysApply — required |
| Orchestrator | **`AGENTS.md` only** on cursor-first; no `CLAUDE.md`, no `CURSOR.md` |
| Install profiles | **`cursor-first`** vs **`full`/legacy** — both documented and testable |
| Parity validators | **Self-contained `.cursor/` checks** — NOT extending `.claude/agents` with cursor fields |
| Write guard | **Hard deny** on Cursor; implement in `.cursor/hooks/` (or documented shared path) |
| Model | **Composer 2.5** for all agents in this program |
| Automations | **No** Cursor Cloud Automations |
| Upstream merges | User accepts **manual conflict resolution** |
| Portable core | **`process/`** remains shared RIPER-5 core in both profiles |

### Non-functional requirements (enforcement critical)

| NFR | Requirement |
|-----|-------------|
| **Defense in depth** | Production Cursor enforcement = rules + AGENTS.md + hooks + per-agent write-guard; no single layer alone |
| **Self-containment** | cursor-first install must run completely without `.claude/` or `.codex/` present |
| **Windows portability** | Skills as full copies; no symlink dependency for cursor-first |
| **Fail-safe documentation** | If live `preToolUse` cannot be made blocking, ship only with documented Known-Gap and compensating controls — never silent "hooks.json present = enforced" |
| **No vacuous green** | Every developed behavior has Fully-Automated or Hybrid proof; Agent-Probe only for live IDE hooks |
| **Zero regression** | Full/legacy profile install, validator, and e2e paths remain green |
| **Evidence retention** | Feasibility probe artifacts remain referenceable under `cursor-feasibility-probe_07-07-26/` |

### Prior Feasibility (findings still apply)

Feasibility probe verdict: **INCONCLUSIVE** — mechanisms tested on Cursor native surfaces (`.cursor/hooks.json`, `.cursor/rules/*.mdc`, subagent readonly). Intent changed from adapter to cursor-first, but **enforcement conclusions are unchanged**:

| Mechanism | Verdict | Implication for this SPEC |
|-----------|---------|----------------------------|
| Hook script stdin logic | **VIABLE** | Ship script; automate AC12 |
| Live preToolUse | **NOT BLOCKED** (inconclusive) | AC13–AC14 mandatory before calling hooks "production" |
| Subagent readonly | **NOT VIABLE** alone | AC17; layered enforcement required |
| alwaysApply rules after reload | **VIABLE** | AC10–AC11 required |

**Source:** `cursor-feasibility-probe_FEASIBILITY_07-07-26.md`

### System / process

- RIPER-5 phase locking unchanged; SPEC does not choose implementation approach (INNOVATE/PLAN).
- Tier-1 validators must pass before UPDATE PROCESS closes the feature.
- Node >= 22, git in PATH (existing kit prerequisites).

## Open Questions

None for product intent — design choices above are locked.

**EXECUTE-phase diagnostics (not blocking SPEC/INNOVATE/PLAN):**

| Item | Owner | Notes |
|------|-------|-------|
| Why live `preToolUse` did not fire in feasibility sessions | EXECUTE | AC13–AC14; baseline: feasibility verdict + transcript `879c1c1a-1d06-4ff1-88d7-7a44535235a5` |
| Exact hook `tool_name` mapping for Cursor Write/Edit tools | EXECUTE | PLAN may specify; SPEC requires live deny outcome only |
| Hook script path strategy (`.cursor/hooks/` vs shared) | INNOVATE/PLAN | SPEC requires self-contained cursor-first; path choice is implementation |
| AGENTS.md cursor-first variant vs single file with profile sections | INNOVATE/PLAN | SPEC requires AGENTS.md as sole orchestrator on cursor-first |
| Windows path normalization for hook commands | EXECUTE | If AC13 fails on Windows, diagnose here |

## Background / Research Findings

### Intent change from adapter SPEC

The prior **Tier B adapter** SPEC (`cursor-adapter_SPEC_07-07-26.md`) planned to extend canonical `.claude/agents/` with Cursor metadata fields and reuse `.claude/hooks/` paths — Cursor as compat reader of Claude surfaces. User intent now requires **full Cursor-native migration**: self-contained `.cursor/` tree, dedicated install profile, and AGENTS.md-only orchestrator. The adapter SPEC is **superseded** and must not be extended.

### Repository state (2026-07-08)

- **`.cursor/` absent** in kit today; Claude (`.claude/`) and Codex (`.codex/`) adapters are complete.
- **Inventory:** 15 agents, 33 skills, 10 hook scripts; `vc-manifest.json` v3.2.5 lists Claude/Codex only — no `.cursor/**`.
- **`install.sh`:** no profile selector or Cursor-specific install lines yet.
- **`agent-write-guard.mjs`:** referenced in agent frontmatter but **missing** — blocks write-guard POC.
- **`validate-agent-parity.mjs`:** Claude ↔ Codex only; no self-contained Cursor dimension.

### Test context (from `process/context/tests/all-tests.md`)

- **E2E:** `node --test e2e-kit-flows.test.mjs` — install/update trials (extend for cursor-first profile).
- **Validators:** `validate-agent-parity.mjs`, `validate-kit-portability.mjs`, `validate-skills.mjs`, `discover-skills.mjs`.
- **Tier-1:** `vc-audit-vc` after harness edits.
- **Known gaps (pre-migration):** missing `agent-write-guard.mjs`; no `.cursor/` tree; no cursor-first install profile.

### User brainstorm (locked — do not re-open)

1. Cursor-first fork — NOT thin adapter over `.claude/`
2. Full migration — NOT phased adapter
3. Canonical surfaces in `.cursor/` (agents, skills full copy, rules, hooks)
4. Orchestrator entry: AGENTS.md only; no CLAUDE.md on cursor-first; no CURSOR.md
5. `install.sh` profile `cursor-first` installs only `.cursor/**`, `AGENTS.md`, `process/`
6. Legacy/full profile for Claude+Codex unchanged
7. Self-contained Cursor validators — NOT extending `.claude/agents`
8. Feasibility findings still apply
9. Manual upstream merge conflicts OK
10. No Cursor Cloud Automations
11. Composer 2.5 for agents in this program
12. agent-write-guard.mjs required in Cursor-first location
13. `process/` remains portable RIPER-5 core

### Evidence paths (reference)

- `process/features/cursor-platform/active/cursor-feasibility-probe_07-07-26/cursor-feasibility-probe_FEASIBILITY_07-07-26.md`
- `process/features/cursor-platform/active/cursor-feasibility-probe_07-07-26/FEASIBILITY_PROBE_BLOCK_live-test.md`
- `process/features/cursor-platform/active/cursor-feasibility-probe_07-07-26/FEASIBILITY_PROBE_BLOCK/retest.md`
- `process/features/cursor-platform/active/cursor-adapter_07-07-26/cursor-adapter_SPEC_07-07-26.md` (superseded)
