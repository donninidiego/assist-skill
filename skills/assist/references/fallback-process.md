# Fallback process (when superpowers is not installed)

Use only if the user declined to install superpowers. Condensed versions of the three process skills.
The /assist rules (decisions, contracts, parameters, state files) still apply on top.

## Brainstorm
1. Read the project context first (files, docs, history).
2. Ask **one question at a time**, preferring multiple choice, about purpose, constraints, success
   criteria. Do not ask what the request already answers.
3. Reflect the understanding back in a short note and wait for correction.
4. If the scope contains independent subsystems, decompose and take one.
5. Propose 2–3 approaches with trade-offs and a recommendation; remove anything not needed (YAGNI).
6. Present the design in sections sized to their complexity, checking after each.
7. Write `docs/assist/spec.md`, scan it for placeholders, contradictions, ambiguity, scope. Ask the
   user to review the written file. **No code before approval.**

## Plan
- Context, user decisions, tasks per block (file | change), execution order with stop points, falsifiable
  verification, out of scope, known limits.
- Each task small enough to finish and verify in one turn; exact file paths; no placeholders such as
  "TBD" or "handle edge cases".
- Self-review: does every spec requirement map to a task and a check?
- The user approves the plan and the execution mode before building.

## Build (test-driven)
1. Write one failing test that expresses the contract (analytic case or literature value).
2. Run it; confirm it fails for the expected reason.
3. Write the minimum code to pass; run again.
4. Refactor with the test green; static check.
5. If a test fails unexpectedly, investigate the cause before changing anything: reproduce, read the
   error, form one hypothesis, test it. Do not stack guesses and do not loosen tolerances to pass.
6. Never claim "done" without having run the verification and seen the output.
