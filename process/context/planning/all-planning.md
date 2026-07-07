# Planning Context

This file is the canonical planning context entrypoint for vibecode-pro-max-kit.

Use it after `process/context/all-context.md` when the task needs plan-shape calibration,
planning conventions, or implementation-plan examples.

## Scope

This group covers:

- example plan shapes
- SIMPLE vs COMPLEX plan calibration
- durable planning references that should not stay at the `process/context/` root

It does not cover:

- active implementation plans
- feature reports
- backlog items

Those belong under `process/general-plans/` or `process/features/`.

## Read When

Read this entrypoint when:

- creating a new plan with `generate-plan`
- checking whether work should be `SIMPLE` or `COMPLEX`
- comparing an active plan against the repo's example plan shapes

## Quick Routing

- use `.claude/skills/vc-generate-plan/references/example-simple-prd.md` to calibrate a one-session plan
- use `.claude/skills/vc-generate-plan/references/example-complex-prd.md` to calibrate a complex or multi-phase plan
- for Cursor adapter work, store plans under `process/features/cursor-platform/active/{slug}_{date}/`

## Source Paths

- `.claude/skills/vc-generate-plan/references/example-simple-prd.md`
- `.claude/skills/vc-generate-plan/references/example-complex-prd.md`
- `.claude/skills/vc-generate-plan/references/generate-plan.md` (Cursor Plan + RIPER-5 integration section)

## Update Triggers

Update this group when:

- the plan artifact contract changes
- `generate-plan` expects different plan sections or statuses
- the example plan shapes move, split, or become stale
