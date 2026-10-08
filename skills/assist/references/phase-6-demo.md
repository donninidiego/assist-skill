# Phase 6 — Walkthrough demo

Goal: one executable document that walks through **every block in order**, so the user can see each
step of the architecture working and debug it by looking. This demo is the object of the review in
phase 7, so it is written for study, not for show. Format rules: `live-script-format.md` (MATLAB Live
Script in plain text) or `python-variant.md` (percent-format notebook).

## Structure
1. **The idea on one page** — physical picture, the chain of blocks, what the demo will show.
2. **Setup** — paths, `run('parameters.m')`, a note on which parameters the reader may change.
3. **One part per block, in chain order.** Each part follows the same rhythm:
   1. *Idea* — a short text cell: the physics, in researcher language, acronyms expanded.
   2. *Geometry/inputs first* — show what is fed into the block **before** showing its effect.
   3. *Run the block.*
   4. *Result* — every field as a 3D view (semi-transparent volume) **and** a 2D view (plan + section)
      when the quantity is spatial.
   5. *How it enters the next block.*
   6. *What to observe* — a caption stating what the reader should see and what would indicate a bug.
   7. *Numeric check printed* — e.g. "mass balance residual: 3e-13 (tolerance 1e-9)", `assert` on connectivity.
4. **Incremental scenarios.** Introduce one element at a time (obstacle, threat, zone, …), re-plan after
   each, and print a one-line summary (`describeStep`) so the effect of each element is a row in a
   final comparison table.
5. **Result and metrics** — representative outputs, trade-off plot, per-step table.
6. **Key points** — five lines the reader should keep.
7. **Local helper functions** at the bottom (`showStep`, `describeStep`, field plotters).

## Rules
- **Captions state only what was measured.** If a caption says "the arrows bend below the zone", the
  figure must show it. Verify by exporting with `Run=true` and looking at the figures.
- Code commented and split into short sections; no 200-line cells.
- Heavy domains: provide a parameter that lowers resolution for a quick pass.
- Ask the journal-target question before any plotting code (coding standards §0); demo figures default
  to MATLAB defaults.
- Do not run the full demo through a tool call (SKILL.md principle 6). Check statically, run cases under
  a minute if needed, then hand it to the user.
- After rewriting a Live Script, warn the user to close the editor tab **without saving** — the Live
  Editor can overwrite your version with a stale one.

## Interactive parts
- If the user wants to choose values in the demo, use controls (`live-script-format.md`) with a section that re-runs
  on release, and tie the control limits to the parameters file with a test. Offer the animation of the result in the
  same output figure.
- Figures with several panels: look at the exported figure (`export(..., Run=true)`) for overlapping titles and
  unreadable markers before handing the demo over; panels meant to be small need their own readable settings (for
  example an enlarged marker, declared in the caption).
- Every equation on the first page of the demo needs a source in `REFERENCES.md`, read on the page, with what the
  project derives itself and what has no source marked as such.

## Exit
The user ran the demo end to end. Errors they hit return to phase 4 as logged items. Record the run in
`STATE.md` and start the review (phase 7) when they are ready.
