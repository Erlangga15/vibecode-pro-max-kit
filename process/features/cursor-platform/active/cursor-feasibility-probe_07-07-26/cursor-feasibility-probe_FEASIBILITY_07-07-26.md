---
slug: cursor-feasibility-probe
date: 2026-07-07
verdict: INCONCLUSIVE
originating-phase: spec
---

# Cursor Tier B Enforcement — Feasibility Verdict

Combined pre-SPEC probe for hooks, readonly subagents, and alwaysApply rules.

## Hypothesis

Cursor Tier B enforcement for the harness adapter can rely on `.cursor/hooks.json` preToolUse deny, subagent `readonly: true`, and `.cursor/rules/*.mdc` alwaysApply — without third-party skills setting.

## Mechanism Under Test

Cursor native hooks (`preToolUse`), subagent `readonly` (Task tool + frontmatter), and project rules (`.mdc` alwaysApply).

## Probe Family

1 — Local process / Node script + in-IDE agent delegation

## Probe Cost Class

cheap-local — safety gate met; all probes run locally in workspace

## Probe Method

1. **Hooks:** Created `.cursor/hooks.json` + `deny-write-probe.mjs`; local stdin test; live Write to `FEASIBILITY_PROBE_BLOCK_live-test.md`
2. **Readonly:** Created `.cursor/agents/feasibility-readonly-probe.md`; Task subagent with `readonly: true` attempted Write to `READONLY_PROBE_OUTPUT.md` and `READONLY_TASK_PARAM_PROBE.md`
3. **Rules:** Created `.cursor/rules/feasibility-probe-orchestrator.mdc` with `alwaysApply: true` and marker `PROBE_RULE_MARKER_X7K9`; checked orchestrator context same session

## Evidence Captured

**Hook script (local stdin):**
```
BLOCK: {"permission":"deny",...} exit 2
ALLOW: {"permission":"allow"} exit 0
```

**Hook live (same session after hooks.json created):** Write to `FEASIBILITY_PROBE_BLOCK_live-test.md` succeeded — hook did not intercept.

**Readonly subagent:** Both Write attempts succeeded; files created on disk with expected content. No errors.

**Rules:** Marker `PROBE_RULE_MARKER_X7K9` on disk only; not observed in orchestrator loaded context same session.

**Manual retest (post window reload, new chat — transcript `879c1c1a-1d06-4ff1-88d7-7a44535235a5`):**
- User confirmed probe rule **appears** in Customize → Rules after reload — **VIABLE**
- New chat: agent read `.cursor/rules/feasibility-probe-orchestrator.mdc` and hook files
- Write to `FEASIBILITY_PROBE_BLOCK/retest.md` **succeeded** — file created on disk; live `preToolUse` **did not block** even after reload + new chat
- Agent conclusion in transcript: hook script valid in isolation; live intercept **NOT BLOCKED**

## Verdict

INCONCLUSIVE

## Resulting Design Constraint

**What this licenses:** Ship `.cursor/rules/*.mdc` alwaysApply (verified after reload); hook deny **script logic**; layered stack rules + CLAUDE.md + hooks (user requirement); keep investigating hook runtime wiring in EXECUTE/SPEC.

**What this forbids:** Phase-lock depending **only** on subagent `readonly:`; treating `.cursor/hooks.json` as enforced without live block proof; skipping rules layer (hooks + CLAUDE.md alone insufficient per user preference).

**What remains uncertain:** Why live `preToolUse` did not fire despite `hooks.json` present (Cursor hooks enabled in settings? tool_name mismatch? Windows path? fail-open?) — SPEC must include AC to diagnose and achieve live deny before EXECUTE ships production hooks.

### Probe detail summary (final)

| Probe | Sub-verdict |
|-------|-------------|
| Hook script logic | **VIABLE** |
| Live preToolUse (same session) | **NOT BLOCKED** |
| Live preToolUse (reload + new chat) | **NOT BLOCKED** — transcript evidence |
| Subagent readonly | **NOT-VIABLE** as sole enforcement |
| alwaysApply rules (after reload) | **VIABLE** — user UI + agent read rule file |

Trial `.cursor/` artifacts **deleted** before commit; evidence retained in this folder (`retest.md`, probe outputs, this verdict).
