# Phase 3 — Implementation plan

Goal: a plan the user can follow and stop at. Invoke `superpowers:writing-plans` if available; fallback:
`fallback-process.md` §Plan. The plan lives in `docs/assist/plan.md`.

## Plan structure (proven format)
1. **Context** — why this work, what prompted it, the intended outcome.
2. **User decisions** — numbered table of what the user already decided (copy from `DECISIONS.md`).
3. **Tasks per block** — a table `# | File | Change`. Describe repeated patterns once and list
   representative files instead of every file. Reuse existing functions: name them with paths.
4. **Execution order with stop points** — e.g. "build blocks 1–2, then stop and explain the model on the
   code, then continue". Stops are where the user digests; place them after every block that
   introduces new physics.
5. **Falsifiable verification** — numbered checks with a pass/fail criterion that can be stated before
   measuring ("if the smallest field value stays above 1e-12, keep the formulation; if it nears underflow, rescale inside the same formulation").
   Commit to the decision rule before running anything.
6. **Out of scope** — explicit, so nobody wonders later.
7. **Known limits to declare** — limitations the work does not remove, stated by us rather than found
   by a reviewer.
8. **References to verify during execution** — sources to check against the original, not cite from
   memory.

Finished tasks are struck through (`~~Done~~`) rather than deleted, so the plan doubles as a history.

## Gate
The user approves the plan and chooses the execution mode: inline with stops after each block
(default for this workflow), or delegated to subagents for independent tasks. Do not start building
before both.
