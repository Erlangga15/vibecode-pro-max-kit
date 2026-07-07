# cursor-platform

Part of vibecode-pro-max-kit

## Scope

Third-platform adapter work to bring Cursor IDE to parity with existing Claude Code (`.claude/`) and Codex (`.codex/`) harness surfaces. Covers `.cursor/` hooks and rules, agent compat fields, manifest/install wiring, enforcement POC, and audit extensions — not Cursor Cloud Automations.

## Key Source Files

- `.cursor/` — target adapter surface (to be created during EXECUTE)
- `.claude/agents/*.md` — canonical agent prompts (add Cursor fields: `readonly`, `model`)
- `.claude/hooks/` — hook scripts to port or reuse
- `.codex/agents/*.toml` — reference pattern for platform-specific adapter
- `vc-manifest.json`, `install.sh` — ship surface for `.cursor/**`
- `.claude/skills/vc-audit-vc/` — parity validators to extend for Cursor

## Related Context

- `process/context/all-context.md` — harness architecture and routing
- `process/context/tests/all-tests.md` — validator and e2e commands
- `process/context/planning/all-planning.md` — plan shape calibration

## Current Status

Status: in-progress (vc-setup complete; RIPER-5 Cursor adapter work not yet started)

## Folder Contents

```
process/features/cursor-platform/
  active/       -- in-progress plans (task folders: {slug}_{date}/)
  completed/    -- archived completed plans
  backlog/      -- deferred/future plans
```

All artifacts colocate inside each `{slug}_{date}/` task folder.
