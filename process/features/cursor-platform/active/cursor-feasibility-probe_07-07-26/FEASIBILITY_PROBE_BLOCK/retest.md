# Feasibility probe — preToolUse hook retest

- **Probe:** live Write to path containing `FEASIBILITY_PROBE_BLOCK`
- **Expected:** hook denies Write (`permission: deny`, exit 2)
- **Session:** orchestrator direct Write (not delegated)
- **Timestamp:** 2026-07-07T16:21+07:00

If this file exists on disk, the live preToolUse hook did **not** block the write.
