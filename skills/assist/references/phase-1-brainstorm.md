# Phase 1 — Brainstorm and requirements

Goal: turn "I want X" into a spec the user recognizes and has corrected. Invoke
`superpowers:brainstorming` if available (see SKILL.md, Companion skills) and layer these rules on top.
Fallback: `fallback-process.md` §Brainstorm.

## Steps
1. **Intent.** Ask one question at a time: why does this exist, who uses the result, what does success
   look like (a paper figure? a benchmark? a flight test?). If the request already answers, reflect it
   back instead of asking again.
2. **Write back.** Short note: intended outcome, constraints, success criteria. Separate what the user
   said from what you assume. Wait for correction.
3. **Scope.** If the request hides several independent subsystems, decompose first and brainstorm the
   first one; each sub-project gets its own spec → plan → build cycle.
4. **Requirements.** Numbered, testable, one sentence each: `R1 The planner shall ...`. Each requirement
   needs a verification idea (analytic case, measured quantity, threshold). Requirements the user has
   not confirmed are marked *proposed*.
5. **Approaches.** For any open modelling/numerical choice give 2–3 options, trade-offs, and a
   recommendation (decision protocol). Log each decision as D1, D2, …
6. **Theory sources.** List the papers/books the model rests on; they seed `REFERENCES.md`. Verify
   citations against the source before listing them — never cite from memory.
7. **Plot intent.** If figures are expected, ask now whether they target a journal (see coding
   standards, plotting §0), since it changes figure sizing and fonts.

## Output
`docs/assist/spec.md` (template in `templates/docs/spec.md`): intent, requirements table
(ID | requirement | verification), constraints, chosen approach, out of scope, known limits to declare.
`DECISIONS.md` updated.

## Gate
The user reads the written spec and approves it. Until then, no architecture and no code.
