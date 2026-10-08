# Demo review log

Walk through the demo section by section. Status: not started / explained / understood / doubts / validated by the user.
Demo: `examples/PenaltyKickWalkthrough.m`. The user has run it in the Live Editor (outputs saved in the file, total
time 4.7 s there) and checked the sliders; their screen wins over the explanation if they disagree.

| # | Demo section | Block | Status | Questions asked | Doubts left | Bugs found | Decisions raised |
|---|---|---|---|---|---|---|---|
| 1 | The idea on one page | all (overview) | understood (2026-10-08): Q1.1 right; Q1.2, Q1.3, Q1.4 missed and re-explained with numbers; Q1.2 bis right after the "which system" key (Magnus does no work: kinetic + potential conserved) | Q1.1 prediction (double J): right, both linear in J. Q1.2 defend it (Magnus accelerating the ball): chose "never changes |v|", the tempting slip. Q1.3 reading the output: why the Magnus-only ball is slower at the goal (24.107 vs 24.204 m/s): chose "the ball rotates and steals kinetic energy" (the spin is constant in the model, so nothing can pass to it); re-explained with the energy account (1.01 J kinetic lost = 1.01 J potential gained). Retry of Q1.2 offered after Q3.5 with the "which system" key. Q1.4 prediction: topspin instead of backspin, speed at the goal: chose "lower" (it is higher: 24.303 vs 24.204 m/s; z 0.396 vs 0.641 m; +1.034 J kinetic = -1.034 J potential) | Magnus does no work but |v| changes through height (energy exchanged between kinetic and potential, never created): missed three times in a row (Q1.2, Q1.3, Q1.4). Parked on purpose: it comes back at the R3 check of Step 2, where the demo prints the energy drift | | |
| 2 | Setup | support | understood (2026-10-08) | Q2.1 localization: where to change the ball mass for the whole demo: right, `par.ball.mass_kg` | | | |
| 3 | Step 1: the kick | 1 `kickImpact` | understood (2026-10-08): Q3.1 right, Q3.2 missed, Q3.3 missed, Q3.4 right (the extra energy comes from the foot, which the model does not contain) | Q3.3 energy after the kick (it rises: 128.20 -> 214.73 J): chose "stays equal" (principle right, system wrong: energy is conserved for foot + ball, the model has the ball alone after the contact). Q3.4 where the extra energy comes from: right, foot + ball + impact is the closed system, the model starts after the contact (D7, spec §8) | Q3.1 prediction: double the lateral offset (omega_z doubles, |v0| unchanged: 131.90 vs 65.95 rad/s, 24.419 m/s both). Q3.1 right. Q3.2 defend it: |v0| = J/m does not depend on the impact point: chose "the energy goes into the rotation", checked false with the code (translational energy is the same in every case, the rotational one is added on top: the model does not track the foot's energy because J is an input). Q3.3 asked; Q3.5 (extra check of the "which system" concept, drag only: energy of ball + gravity decreases): right, 2 in a row | | | |
| 4 | Step 2: the flight | 2 `flightDynamics` | validated by the user (2026-10-08), not confirmed by the checks: Q4.1 missed, Q4.2 right, Q4.3 not answered | Q4.1 reading the output: what the R2 check (relative error 2.1e-16) covers and what it does not. Q4.2 localization: only the ground event, what happens to the verdict (every shot SHORT: checked with the goal moved to 100 m); Q4.1 missed: chose "circular, tells nothing" (the check has teeth: a 1% gravity error shows as 1e-2; it covers gravity, integration and the ground event, not drag, Magnus or the tolerances). Q4.3 (a flipped Magnus sign is invisible to R2 and R3; only R4 and the figure see it) was not answered: the user validated the review | | | |
| 5 | Step 3: the verdict, and every outcome | 3 `classifyShot` | not run (the user validated the flow and stopped after section 4) | | | | |
| 6 | Step 4: your shot | 4 (`clampImpactPoint`, `animateShot`) | not run | | | | |
| 7 | Result and key points | all | not run | | | | |

## Tally of the questions (exact, 2026-10-08)
| Question | Result |
|---|---|
| Q1.1 double J | right |
| Q1.2 Magnus accelerating the ball | missed (then right as Q1.2 bis) |
| Q1.3 why the Magnus-only ball is slower | missed |
| Q1.4 topspin, speed at the goal | missed |
| Q1.2 bis, with the "which system" key | right |
| Q2.1 where the ball mass is changed | right |
| Q3.1 double the lateral offset | right |
| Q3.2 defend v0 = J/m | missed |
| Q3.3 energy after the kick | missed |
| Q3.4 where the extra energy comes from | right |
| Q3.5 drag only, energy of ball + gravity | right |
| Q4.1 what the R2 check says | missed |
| Q4.2 only the ground event | right |
| Q4.3 flipped Magnus sign | not answered |

13 answered: **7 right, 6 missed**. Earlier messages of the review reported "6 of 10" and "8 of 12": both were wrong
and were corrected in the conversation.

## Bugs found (sent back to build)
| ID | Section | Symptom | Cause | Regression test | Fixed |
|---|---|---|---|---|---|

## Doc / caption gaps found
- The equations on the first page of the demo carried no source. Found on 2026-10-08 while explaining section 1; fix: `REFERENCES.md` (equation, section and number read on the source page, what is derived here, what has no source) and links from the headers of `kickImpact`, `flightDynamics`, `liftCoefficient` and from spec §5. The line "Sources" was added to the demo on 2026-10-08 (user's ok).
- The demo file saved by the Live Editor carries the outputs (175 KB at first, 455 KB later, images in base64). Decision of the user on 2026-10-08: the repository copy stays clean (no outputs), the saved copy was kept outside the repository. Done.

## How the user likes the review conducted
- Always give feedback, also on a right answer, and reward the user: say why it is right, name what they did well, show the progress. Said on 2026-10-08; saved to memory and written into the skill.
- When the user answers wrong: verify that it is really wrong (code, test, small simulation, source) and then ground the physical sense in the bibliography or in a simulation of the project's code, with numbers. Said on 2026-10-08; saved to memory and written into the skill.
- The check-understanding questions must appear to the user **interactively** (the interactive question tool, multiple choice with a free-text option), never only written in the chat. Said by the user on 2026-10-08; saved to memory and written into the skill (`references/review-protocol.md`).
- Physical sense before the formalism, no acronym or term taken for granted, one block at a time closed by a
  question (from the saved preference "stile di spiegazione"; applied from the start).
