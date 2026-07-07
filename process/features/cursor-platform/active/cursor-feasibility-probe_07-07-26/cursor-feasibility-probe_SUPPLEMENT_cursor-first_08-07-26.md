---
slug: cursor-feasibility-probe
date: 2026-07-08
feature: cursor-platform
relates-to: cursor-first_SPEC_08-07-26.md
type: intent-change-supplement
---

# Feasibility Probe — Supplement for Cursor-First Intent Change

> **TL;DR:** Product intent shifted from Tier B adapter (extend `.claude/agents`) to full Cursor-native migration (self-contained `.cursor/`). The feasibility probe tested Cursor **native surfaces** — its verdicts still apply unchanged.

## What Changed

| Before (adapter SPEC) | After (cursor-first SPEC) |
|-----------------------|---------------------------|
| Cursor reads compat paths (`.claude/agents`, `.claude/hooks`) | Cursor has its own canonical tree under `.cursor/` |
| Extend `.claude/agents` with `readonly`, `model` fields | 15 agents live in `.cursor/agents/` |
| Reuse `.claude/skills` via symlink/compat | 33 skills as **full copies** in `.cursor/skills/` |
| `CLAUDE.md` + rules + hooks | `AGENTS.md` only (no `CLAUDE.md` on cursor-first profile) |
| Single install surface | Two profiles: `cursor-first` vs `full`/legacy |

## What Did NOT Change (feasibility still applies)

The probe exercised **Cursor-native mechanisms** — the same ones cursor-first will ship:

| Mechanism | Probe verdict | Still applies because |
|-----------|---------------|----------------------|
| `.cursor/hooks.json` preToolUse | Script VIABLE; live NOT BLOCKED | cursor-first ships `.cursor/hooks.json` — live deny still unproven |
| `.cursor/rules/*.mdc` alwaysApply | VIABLE after reload | cursor-first requires always-apply rules (AC10–AC11) |
| Subagent `readonly: true` | NOT VIABLE alone | cursor-first still needs layered enforcement (AC17) |
| Third-party skills setting | Not used | cursor-first uses native `.cursor/skills/` copies only |

## Implication for Next Phases

- **INNOVATE** may explore sync strategy between `.cursor/` and `.claude/` in the **kit repo** (maintainer concern), but consumer cursor-first installs must remain self-contained.
- **PLAN** must budget for live hook diagnosis (AC13–AC14) — same gap the adapter SPEC already required.
- **EXECUTE** must not treat probe's "NOT BLOCKED" live hook result as resolved; retest is mandatory on the final cursor-first wiring.

## Reference

- Original verdict: `cursor-feasibility-probe_FEASIBILITY_07-07-26.md`
- Superseded adapter SPEC: `cursor-adapter_SPEC_07-07-26.md`
- Replacement SPEC: `cursor-first_SPEC_08-07-26.md`
