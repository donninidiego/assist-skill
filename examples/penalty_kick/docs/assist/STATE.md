# Project state (/assist)

Read this first when resuming. Update it at the end of every step.

| Field | Value |
|---|---|
| Project | penalty_kick, silly example case for /assist |
| Language of docs and demo | English (D2) |
| Code language | MATLAB |
| MBD profile | block chain (D8) |
| superpowers | used |
| Existing docs | none (new project) |
| Current phase | 6 demo written, checked and run by Claude; waiting for the user to run it in the Live Editor. Phase 5 (docs, plan task 8) not done |
| Last completed step | sliders, slow-motion animation, outcome tiles and the recorded video (`media/`, `tools/makeShotVideo.m`) added; example cited in the repo README, 2026-10-07 |
| Next step | the user runs `examples/PenaltyKickWalkthrough.m` in the Live Editor, drags the sliders and watches the animation (close any open tab of the file without saving); then docs (task 8) and `/assist review` |

## Test status
51 passed, 0 failed, 0 incomplete (suite 2.2 s); static analysis clean (25 files, 0 issues); demo 3.9 s from the command
window; MATLAB recognises the 5 sliders after converting the demo to `.mlx`; 2026-10-07.

## Open questions for the user
- Q1: `Cd`, `Cl(S)` have no verified numerical source (the papers' PDFs are password protected). Proceeding
  with illustrative values declared as such (D9, assumed from the user's go-ahead); confirm or supply the real values.
- Q2: the Laws of the Game numbers were read from editions 2008–2015; confirm they are still the current ones
  or accept them as stated.
- The architecture was not explicitly approved; a one-letter answer was read as answering D10 and D11 and accepting the draft.
- The plan was approved by the instruction to run to the end of the demo, so the stops after each block were skipped. D12
  lists four changes made while building; confirm them.
- Ranges in `par.kick` (offset 0.8, impulse 3–15 N s, azimuth ±45°, elevation 1–60°) are our choices; the slider
  limits copy them (D14, tested).
- Whether to record in the skill's `references/live-script-format.md` that R2026a supports controls in plain text
  (the format notes in the matlab-create-live-script plugin still say "not yet supported").

## Parked items
- Block 4 plots are exercised by smoke tests and by the demo only (no requirement of their own).
- `liftCoefficient` has no dedicated test file; it is covered through `tFlightDynamics` (R3).
- Phase 5 docs (README guide, PARAMETERS.md, REFERENCES.md, theory T1–T3 with index) and the folder READMEs.
- The example is not yet linked from the repo README of `assist-skill`.
- The animation is real-time paced with `pause`: on a slow machine it will run slower than 5 times slow motion.
EOF
echo state written