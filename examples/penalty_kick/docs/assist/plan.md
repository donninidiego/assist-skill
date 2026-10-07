# Plan — penalty_kick

Status: approved by the user's instruction to run to the end of the demo (2026-10-07), executed inline without the intermediate stops; build log at the end

Spec: `docs/assist/spec.md`. Architecture: `docs/assist/architecture.md`. Decisions: `docs/assist/DECISIONS.md`.

## Context
A deliberately silly worked example for the `/assist` skill: kick a ball at a goal in MATLAB, with the impact
point and the strength chosen by the user in the demo. It must show the whole workflow on something small.
Intended outcome: three tested blocks, a Live Script demo with a "Your shot" section, and the process files that
produced them, all inside `assist-skill/examples/penalty_kick/`.

## Global constraints
- MATLAB base product only; `ode45` with events. Language of docs and demo: English. Tests under about 1 minute.
- Frame D10: origin at the penalty mark, `x` to the goal, `y` left, `z` up; the ball starts at `(0, 0, R)`.
- Every value comes from `parameters.m`; every function validates its sub-structs with `requireFields`.
- Tests are named with the requirement id they check (`R3_...`), so the trace matrix can be kept honest.
- Coefficients `Cd`, `Cl(S)` are illustrative (D9) and every figure caption says so.

## Review focus (inputs the spec implies but no requirement names)
Each line gets a test in the task that owns the code.
1. Zero spin: `omega0 = 0` makes the direction of `omega × v` undefined; the Magnus force must be zero, not NaN
   (task 3, `R3_zeroSpinGivesNoMagnusAndNoNaN`).
2. Aim into the ground (negative elevation) or out of the allowed ranges must be rejected, not silently simulated
   (task 2, `R7_aimOutsideRangeIsRejected`).
3. Impulse of zero or above the allowed range must be rejected (task 2, `R7_impulseOutsideRangeIsRejected`).
4. A flight that ends on neither event within `tMax_s` must raise an error, not return a truncated path
   (task 3, `R7_noEventWithinTMaxIsAnError`).
5. A label must not depend on the side: mirroring `y` must not change the label (task 4, `R6_labelIsMirrorSymmetric`).

## User decisions
| # | Decision |
|---|---|
| D1 | The example lives in `assist-skill/examples/penalty_kick/` |
| D2 | Docs and demo in English |
| D3 | Off-centre impulse + drag + Magnus (model B) |
| D4 | Demo input is a "Your shot" section in the Live Script, no app |
| D5 | Figures are for the screen, not for a journal |
| D6 | Strength is the impulse `J` in N s, equivalent speed `J/m` shown next to it |
| D7 | The impulse has the foot direction; friction is assumed sufficient |
| D8 | Profile: block chain, no Simulink |
| D9 | Illustrative `Cd`, `Cl(S)` (assumed, to be confirmed) |
| D10 | Frame: origin at the mark, `x` to the goal, `y` left, `z` up |
| D11 | A shot is judged as a disc at the goal plane; corner tie-break is POST |

## Tasks per block
Paths are relative to `assist-skill/examples/penalty_kick/`. Support files are adapted copies of the skill's
verified MATLAB templates (`templates/matlab/`), never edits of them.

| # | File | Change |
|---|---|---|
| 1a | `parameters.m` (new) | Sections 1–5 of `architecture.md` §5. Ball `0.43 kg`, `0.11 m`, `inertiaFactor = 2/3`; goal `11`, `7.32`, `2.44`, `0.12 m` (Laws of the Game, spec §5); `gravity = 9.81`, `airDensity = 1.2`; `maxOffset = 0.8` (proposed: a foot cannot hit the very edge), `impulseRange = [3 15] N s`, `azimuthRange = [-45 45] deg`, `elevationRange = [0 60] deg` (proposed). `dragCoeff`, `liftSlope`, `liftMax` carry the comment `ILLUSTRATIVE, not from a source (D9)`. Based on `templates/matlab/parameters.m` |
| 1b | `src/requireFields.m` (new) | Copy of `templates/matlab/requireFields.m`, error id changed to the project's |
| 1c | `tests/loadTestParams.m` (new) | Copy of `templates/matlab/loadTestParams.m` |
| 2a | `tests/tKickImpact.m` (new, written first) | Cases of checks V1, V2, V3 below. Based on `templates/matlab/tExampleBlock.m` |
| 2b | `src/1_kick/kickImpact.m` (new) | `launch = kickImpact(shot, parBall, parKick)`. Builds `d`, `e_y = z×d/|z×d|`, `e_z = d×e_y`, `r = R(oL e_y + oV e_z)`; `v0 = J d/m`; `omega0 = (r × J d)/I`, `I = inertiaFactor·m·R²`. Validates the `shot` against `parKick` ranges. Header with PHYSICAL CONTEXT, THEORY (T1), units, ASSUMPTIONS, Example |
| 3a | `tests/tFlightDynamics.m` (new, written first) | Checks V4–V8 and review-focus items 1 and 4 |
| 3b | `src/2_flight/liftCoefficient.m` (new) | `cl = liftCoefficient(S, parFlight)` = `min(liftSlope·S, liftMax)`; one place for the lift law, so it can be replaced when D9 is closed |
| 3c | `src/2_flight/flightDynamics.m` (new) | `traj = flightDynamics(launch, parBall, parFlight, parGoal)`. State `[x; v]`, spin constant. Acceleration from T2; zero spin gives zero Magnus. `ode45` with two terminal events: ground (`z = R` going down) and goal plane (`x = d` going forward). `traj.endReason` is `"goalPlane"` or `"ground"`; no event within `tMax_s` raises `Project:flightDynamics:NoEvent` |
| 4a | `tests/tClassifyShot.m` (new, written first) | Check V9 table and review-focus item 5 |
| 4b | `src/3_outcome/classifyShot.m` (new) | `result = classifyShot(traj, parBall, parGoal)`. Disc against axis-aligned rectangles: opening `[-W/2, W/2]×[0, H]`, posts `[W/2, W/2+w]×[0, H+w]` (both sides), bar `[-W/2-w, W/2+w]×[H, H+w]`. Order: GOAL if the disc is inside the opening; else POST if it overlaps a post; else CROSSBAR if it overlaps the bar; else WIDE if `|y| > W/2+w`, else HIGH. `endReason = "ground"` gives SHORT with `NaN` position |
| 5 | `src/takeShot.m` (new) | `[result, traj, launch] = takeShot(shot, par)`: calls blocks 1→2→3, no physics. Used by the demo and by the end-to-end check V10 |
| 6 | `src/4_visualization/drawGoal.m`, `plotShot.m` (new) | Goal frame and path in 3D, top view; caption built from `result` and states that coefficients are illustrative |
| 7 | `examples/PenaltyKickWalkthrough.m` (new) | Live Script (plain-text format, `references/live-script-format.md`): one section per block, then "Your shot" with the five inputs from `par.shot`, then a summary table of measured values |
| 8 | `README.md`, `doc/` (new) | Guide README, `PARAMETERS.md`, `REFERENCES.md`, theory notes T1–T3 with the equation index (phase 5) |

## Execution order, with stop points
1. Tasks 1a–1c, then 2a–2b (block 1). **Stop 1:** explain impulse, torque and spin on the code; the user runs
   `tKickImpact`.
2. Tasks 3a–3c (block 2). **Stop 2:** explain the forces, why Magnus does no work, and how `ode45` events end the
   flight.
3. Tasks 4a–4b (block 3) and 5. **Stop 3:** explain the disc-against-frame rule and the corner tie-break; run
   one full shot with `takeShot`.
4. Task 6, then 7. The demo is written and checked statically; **the user runs it** in the Live Editor.
5. Task 8, then `/assist review` section by section.
Within each block: write the test, watch it fail, write the code, watch it pass, run static analysis.

## Verification (falsifiable; rule stated before measuring)
| # | Check | Passes if | If not |
|---|---|---|---|
| V1 | R1: zero offset | `omega0` is exactly `[0 0 0]` | bug in block 1: fix the code, do not loosen |
| V2 | R5: 20 seeded random shots | `|m·v0 − J·d| ≤ 1e-12·J`; `|omega0| = R·J·sqrt(oL²+oV²)/I` within `1e-10` relative; `omega0 · d = 0` within `1e-10·|omega0|`; handedness: aim `(0,0)`, `oV < 0` gives `omega0` along `−y` (backspin), `oL < 0` gives `omega0` along `+z` | block 1 error: fix the code |
| V3 | R7: out-of-range `shot` | offset norm above `maxOffset`, impulse or aim outside the ranges, and a missing parameter each raise the expected error id | add the missing validation |
| V4 | R2: `Cd = Cl = 0`, `J` giving 20 m/s at 30°, `penaltyDistance_m` set to 100 so the ground ends the flight | range equals `v0² sin(2a)/g` within `1e-6` relative; apex height above launch equals `(v0 sin a)²/(2g)` within `1e-3` relative (sampled apex) | tighten `relTol`/`absTol` first; widen a criterion only with the user |
| V5 | R3: `Cd = 0`, `liftSlope > 0`, spin non-zero | mechanical energy `½m|v|² + m g z` constant: `max |E − E0| / E0 ≤ 1e-6` along the path; with `gravity = 0` also `max ||v| − |v0|| / |v0| ≤ 1e-6`. (First wording said `|v|` constant with gravity on: wrong, corrected 2026-10-07.) | same as V4 |
| V6 | Drag only (`Cl = 0`, `Cd > 0`) | mechanical energy `½m|v|² + m g z` never increases: all increments `≤ 1e-9·E0` | same as V4 |
| V7 | R4: aim `(0°, 5°)`, `oL = −0.5` and `+0.5`, fixed `J` | `y` at the goal plane is `> 0` for `oL = −0.5` and `< 0` for `+0.5`; the two values are equal in magnitude within `1e-6` relative; with `oL = 0` and `oV = 0`, `|y| < 1e-10` | sign wrong: re-derive `omega × v` before touching the code |
| V8 | Zero spin | with `oL = oV = 0` and `liftSlope > 0`, the trajectory is finite (no NaN) and equals the `Cl = 0` one exactly | fix the zero-division guard |
| V9 | R6: classification table with `W/2 = 3.66`, `H = 2.44`, `w = 0.12`, `R = 0.11`, ball at `x = d` | centre `(0, 1)` GOAL; `y = W/2−R−1e-6` GOAL, `+1e-6` POST; `y = W/2+w+R+1e-6` WIDE, `−1e-6` POST; `z = H−R−1e-6` GOAL, `+1e-6` CROSSBAR; `z = H+w+R+1e-6` HIGH, `−1e-6` CROSSBAR; corner `(W/2, H)` POST; `endReason = "ground"` SHORT; every label is symmetric under `y → −y` | a wrong label means the rule or the test geometry is wrong: decide with the user which |
| V10 | R8: one full shot with `par.shot`, then the demo | `takeShot` flight time lies between 0.4 and 0.6 s (11 m at about 24 m/s plus a little drag); demo wall time `< 10 s` measured with the date, run by the user | investigate the slow block before changing the budget |
| V11 | Static analysis | `checkcode` / `check_matlab_code` clean on `src/`, `tests/`, `examples/` | fix |

## Out of scope
Foot-ball contact dynamics, goalkeeper, wind, bounce and post rebounds, spin decay, the slider app, Simulink.

## Known limits to declare
See `spec.md` §8. Plus: the proposed ranges in `par.kick` (`maxOffset = 0.8`, impulse `3–15 N s`, aim ranges)
are our choices, not measurements; the demo prints them as such.

## References to verify during execution
- Goff & Carré (2010) and Goff et al. (2017): the form of `Cl(S)` and the values of `Cd`, to be checked against
  the full texts before D9 is closed. Do not cite numbers from memory.
- Laws of the Game, current edition: confirm the goal, post and ball numbers (Q2).
- A textbook for T1 (rigid-body impulse and angular momentum): to be chosen and checked in phase 5.

## Build log (2026-10-07)
Tasks 1a–7 done in one run, at the user's request to run to the end of the demo: the stop points were not
made. Task 8 (docs) is not done. Each block was built test first and the failing run was watched (all tests
failed with `Undefined function` before the code existed).

| Task | Result |
|---|---|
| ~~1a–1c~~ | `parameters.m`, `src/requireFields.m`, `tests/loadTestParams.m` |
| ~~2a–2b~~ | `kickImpact`, `tKickImpact`: 8 tests |
| ~~3a–3c~~ | `liftCoefficient`, `flightDynamics`, `tFlightDynamics`: 9 tests |
| ~~4a–4b~~ | `classifyShot`, `tClassifyShot`: 7 tests |
| ~~5~~ | `takeShot`, `tTakeShot`: 4 tests |
| ~~6~~ | `drawGoal`, `plotShot`, `tVisualization`: 2 tests (smoke); figures looked at, two layout defects fixed |
| ~~7~~ | `examples/PenaltyKickWalkthrough.m`: written, checked, run by Claude; **not yet run by the user** |

Verification outcome (all with the decision rule stated above):
| # | Outcome |
|---|---|
| V1, V2, V3 | pass (`tKickImpact`) |
| V4 | pass: range relative error 2e-16 (criterion 1e-6); apex within 1e-3 |
| V5 | pass: energy drift 8e-15 (criterion 1e-6); wording corrected, see D12 |
| V6, V7, V8 | pass (`tFlightDynamics`) |
| V9 | pass (`tClassifyShot`, boundaries at ±1e-6 m) |
| V10 | flight time of the default shot 0.492 s (criterion 0.4–0.6 s): pass. Demo 1.7 s from the command window: pass for the budget, but the user's Live Editor run is still to do |
| V11 | pass: 16 files, 0 issues (`codeIssues`) |

Changes to the plan found while building, logged as D12: minimum elevation 1°, new parameter `outputStep_s`,
R3/V5 reworded, `liftSlope` 0.5.

## Build log, second round (2026-10-07): sliders, animation, outcome tiles
Requested by the user after the demo ran: sliders for the parameters in "Your shot", a video of the trajectory,
and subplots in "Every outcome" showing both the impact point on the ball and the verdict on the goal.
A first answer, a `uifigure` window with sliders (`penaltyKickApp`), was built test first and then **discarded**
at the user's request (sliders in the demo itself, not a separate app); its files were removed. D13 now records sliders inside the Live Script.

| Task | Result |
|---|---|
| ~~9a~~ | `animationFrames` (pure frame generator), `tAnimationFrames`: 7 tests |
| ~~9b~~ | `clampImpactPoint`, `tClampImpactPoint`: 5 tests, including the seeded regression for a one-ulp overshoot found while trying the discarded window (about 11% of clamped points came out above the limit) |
| ~~9c~~ | `drawImpactPoint`, `drawVerdict` (moved out of the demo, now shared), `animateShot`; 6 tests in `tVisualization` |
| ~~9d~~ | demo: five `%[control:slider:...]` controls in step 4, `animateShot` replays the kick, tiles of every outcome (impact point on top, verdict below), `tWalkthroughControls`: 4 tests tie the slider limits to `par.kick` (D14) |

Verification, 2026-10-07: 50 tests pass, 0 fail (suite 6.2 s, slowest 0.80 s); static analysis 24 files, 0 issues; demo
3.5 s from the command window; MATLAB recognises 5 slider controls after converting the demo to `.mlx`; the
figures were looked at (two layout defects fixed). **Not verified:** the sliders have not been dragged in the
Live Editor, and the animation has not been watched there.

## Build log, third round (2026-10-07): recorded video and README
| Task | Result |
|---|---|
| ~~10a~~ | `animateShot` options `RealTime` and `OnFrame` (called after each frame), test first (`tVisualization`): 51 tests in total |
| ~~10b~~ | `tools/makeShotVideo.m` records three kicks (GOAL, POST, SHORT) with the slider values written on the frames: `media/penalty_kick_demo.gif` (2.1 MB, 153 frames) and `.mp4` (0.3 MB, 10 s) |
| ~~10c~~ | repo README: section "Example: a didactic Live Script" with the GIF, layout and verification lines |

Found while recording: a GIF keeps the palette of its first frame, and the first frame (before the verdict) is all grey,
so a per-frame palette turned the green and the red into grey. The script now uses one fixed palette (greys plus tints
of the two colours); checked by counting green pixels in frames 38–52 (GOAL) and red pixels in the POST and SHORT clips.
The video is a recording of the animation, not of the Live Editor.
