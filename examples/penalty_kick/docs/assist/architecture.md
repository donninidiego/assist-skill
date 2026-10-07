# Architecture — penalty_kick

Status: draft, waiting for decisions D10 and D11 and for approval by the user (written 2026-10-07)

## 1. Block diagram
```
 shot ──► [1] kickImpact ──► launch ──► [2] flightDynamics ──► traj ──► [3] classifyShot ──► result
 (user)    impulse, spin      v0, ω0      forces, ode45         path     goal geometry       label
                                                                   │                           │
                                                                   └──────► [4] plotShot ◄─────┘
 par ───────────────── one parameters file, one sub-struct per block ─────────────────────────────
```
`takeShot.m` chains blocks 1–3 and contains no physics. Block 4 only draws.

## 2. Folder layout
```
src/
  1_kick/       kickImpact.m  clampImpactPoint.m
  2_flight/     flightDynamics.m  liftCoefficient.m
  3_outcome/    classifyShot.m
  4_visualization/  drawGoal.m  drawImpactPoint.m  drawVerdict.m  plotShot.m  animationFrames.m  animateShot.m
  takeShot.m            % chains 1-3, no physics
  requireFields.m
parameters.m            % the single parameters file
tests/                  % tKickImpact.m  tFlightDynamics.m  tClassifyShot.m  loadTestParams.m
examples/               % PenaltyKickWalkthrough.m  (the demo, with "Your shot")
doc/                    % README_guide.md, THEORY, PARAMETERS.md, REFERENCES.md (phase 5)
docs/assist/            % process files
```

## 3. Frame and data contract
**Frame (proposed, D10).** World frame, right-handed: origin on the ground at the penalty mark; `x` from the
mark perpendicular to the goal line (towards the goal); `y` to the left when looking at the goal; `z` up. The
ball centre starts at `(0, 0, R)`. The goal plane is `x = d`. Aim azimuth is measured from `+x` towards `+y`,
elevation from the ground plane upwards. Kick frame: `d` = impulse direction, `e_y = z × d / |z × d|`
(left of the kick), `e_z = d × e_y` (up).

**`shot`** (input of block 1, edited by the user in "Your shot")
| Field | Class | Size | Unit | Meaning |
|---|---|---|---|---|
| `offsetLateral` | double | 1×1 | – (fraction of R) | impact point along `e_y`; positive = left of centre |
| `offsetVertical` | double | 1×1 | – (fraction of R) | impact point along `e_z`; positive = above centre |
| `impulse` | double | 1×1 | N s | magnitude of the impulse `J` (D6) |
| `aimAzimuth` | double | 1×1 | deg | towards `+y` positive |
| `aimElevation` | double | 1×1 | deg | upwards positive |

**`launch`** (block 1 → block 2)
| Field | Class | Size | Unit | Frame | Meaning |
|---|---|---|---|---|---|
| `position` | double | 3×1 | m | world | ball centre at launch |
| `velocity` | double | 3×1 | m/s | world | `v0 = J/m` |
| `spin` | double | 3×1 | rad/s | world | `omega0 = (r × J)/I` |
| `speedEquivalent` | double | 1×1 | m/s | – | `|v0|`, shown next to the impulse in the demo (D6) |

**`traj`** (block 2 → blocks 3, 4)
| Field | Class | Size | Unit | Frame | Meaning |
|---|---|---|---|---|---|
| `t` | double | 1×N | s | – | time stamps |
| `position` | double | 3×N | m | world | ball centre |
| `velocity` | double | 3×N | m/s | world | |
| `spin` | double | 3×1 | rad/s | world | constant along the flight (§8 of the spec) |
| `endReason` | string | 1×1 | – | – | `"goalPlane"` or `"ground"` |

**`result`** (block 3 → demo, block 4)
| Field | Class | Size | Unit | Meaning |
|---|---|---|---|---|
| `label` | string | 1×1 | – | `GOAL`, `POST`, `CROSSBAR`, `WIDE`, `HIGH`, `SHORT` |
| `yAtGoal`, `zAtGoal` | double | 1×1 | m | ball centre at the goal plane (NaN for `SHORT`) |
| `flightTime` | double | 1×1 | s | time of the last sample |

## 4. Block contracts
### Block 1 — kickImpact
| Item | Content |
|---|---|
| Purpose | Turn "where and how hard the foot hits" into the ball's initial velocity and spin. |
| Inputs | `shot` (above), `parBall`, `parKick` |
| Outputs | `launch` |
| Signature | `launch = kickImpact(shot, parBall, parKick)` |
| Parameters | `par.ball` (mass, radius, inertia factor), `par.kick` (largest admissible offset, impulse range, aim ranges) |
| Assumptions | A1 the impulse has the foot direction and friction is enough to transmit it (D7). A2 the ball is a rigid thin shell, `I = (2/3) m R²` (inertia factor in `par.ball`). A3 the foot contact is instantaneous. Valid for offsets with `sqrt(oL² + oV²) ≤ par.kick.maxOffset`. |
| Theory | T1: `m v0 = J`, `I ω0 = r × J`, with `r = R (oL e_y + oV e_z)` (the component of `r` along `J` gives no torque) |
| Test | `tKickImpact`: zero offset gives zero spin (R1); random seeded inputs satisfy `m v0 = J`, `I ω0 = r × J` (R5); offsets beyond the limit error (R7) |

### Block 2 — flightDynamics
| Item | Content |
|---|---|
| Purpose | Integrate the ball's path under gravity, drag and the Magnus force until it reaches the goal plane or the ground. |
| Inputs | `launch`, `parBall`, `parFlight`, `parGoal` (only `penaltyDistance_m` is used) |
| Outputs | `traj` |
| Signature | `traj = flightDynamics(launch, parBall, parFlight, parGoal)`; helper `cl = liftCoefficient(S, parFlight)` |
| Parameters | `par.flight` (gravity, air density, `Cd`, lift model, `tMax`, tolerances) |
| Assumptions | A1 spin constant along the flight. A2 `Cd` constant (no drag crisis). A3 lift `Cl` depends only on the spin parameter `S = R|ω|/|v|`. A4 no wind. Events stop the integration at the ground (`z = R`) and at the goal plane (`x = d`). |
| Theory | T2: `m dv/dt = −m g ẑ − ½ ρ Cd A |v| v + ½ ρ Cl A |v|² (ω̂ × v̂)`; form of `Cl(S)` from Goff & Carré (2010), not yet checked against the text |
| Test | `tFlightDynamics`: `Cd = Cl = 0` matches the parabola (R2); `Cd = 0`, `Cl > 0` keeps `|v|` constant (R3); offset left/right curves to the side given by `ω × v` (R4) |

### Block 3 — classifyShot
| Item | Content |
|---|---|
| Purpose | Decide what happened to the shot, with exactly one label. |
| Inputs | `traj`, `parBall`, `parGoal` |
| Outputs | `result` |
| Signature | `result = classifyShot(traj, parBall, parGoal)` |
| Parameters | `par.goal` (distance, width, height, post width) |
| Assumptions | A1 the shot is judged at the instant the ball centre crosses the goal plane, as a disc of radius `R` against the frame (D11). A2 no rebound. A3 posts and crossbar have square section of side `par.goal.postWidth_m`. |
| Theory | T3: plane geometry of D11 |
| Test | `tClassifyShot`: centre of the goal, just inside, just outside, on a post, under the crossbar, over it, ground before the plane (R6) |

### Block 4 — visualization (support)
`drawGoal(ax, parGoal)`, `drawImpactPoint(ax, shot, maxOffset)`, `drawVerdict(ax, result, par)` (optional enlarged ball for small tiles), `plotShot(traj, result, par)`, `animationFrames(traj, parAnimation)` (pure: instants, positions and spin angles of the slow-motion replay, R10) and `animateShot(shot, traj, result, par)` (impact point, flight with the spinning ball, verdict; the figure updates while it runs, so the Live Editor shows it as a short video). Captions state only measured values and, while D9 stands, that the coefficients are illustrative.

### Support in block 1 — clampImpactPoint
`shot = clampImpactPoint(shot, parKick)`: moves an impact point beyond the admissible circle radially onto it (with a margin of four ulp, so `kickImpact` never refuses it). Used by the demo because two independent sliders can reach the corner of their square (R9).

## 5. Parameters skeleton
`parameters.m`, numbered sections, one sub-struct per block, each line `% [unit] meaning`:
| Section | Fields |
|---|---|
| 1 `par.ball` | `mass_kg`, `radius_m`, `inertiaFactor` (2/3, thin shell) |
| 2 `par.kick` | `maxOffset` (fraction of R), `impulseRange_Ns`, `azimuthRange_deg`, `elevationRange_deg` (minimum 1°, not 0°: a ball started at `z = R` with `vz = 0` goes under the ground before any event can fire; found while writing the block 2 tests, 2026-10-07) |
| 3 `par.flight` | `gravity_ms2`, `airDensity_kgm3`, `dragCoeff`, `liftSlope`, `liftMax` (the last three illustrative, D9), `tMax_s`, `relTol`, `absTol`, `outputStep_s` (spacing of the returned samples; added during the build so the sampled apex is accurate enough for V4) |
| 4 `par.goal` | `penaltyDistance_m`, `width_m`, `height_m`, `postWidth_m` (from the Laws of the Game, spec §5) |
| 5 `par.shot` | default `shot` used by the reference steps of the demo |
| 6 `par.animation` | `slowMotion` (0.2: five times slower), `framesPerSecond`, `ballDrawScale` (the ball is drawn larger so that it can be seen); drawing only |

Blocks 1–3 also receive `par.ball`, which holds the mass and radius they share: one source, no copies. Each
function takes the sub-structs it needs, as separate arguments, and validates each with `requireFields`.
No function has a default of its own. Tests override values through `loadTestParams.m`, which edits a copy of
`parameters.m` output (for example `dragCoeff = 0`).

## 6. Traceability matrix
| Requirement | Block | Theory § | File | Test | Status |
|---|---|---|---|---|---|
| R1 | 1 | T1 | `src/1_kick/kickImpact.m` | `tKickImpact` | planned |
| R2 | 2 | T2 | `src/2_flight/flightDynamics.m` | `tFlightDynamics` | planned |
| R3 | 2 | T2 | `src/2_flight/flightDynamics.m`, `liftCoefficient.m` | `tFlightDynamics` | planned |
| R4 | 1, 2 | T1, T2 | `kickImpact.m`, `flightDynamics.m` | `tFlightDynamics` (end to end sign test) | planned |
| R5 | 1 | T1 | `src/1_kick/kickImpact.m` | `tKickImpact` | planned |
| R6 | 3 | T3 | `src/3_outcome/classifyShot.m` | `tClassifyShot` | planned |
| R7 | 1, 2, 3 | – | every block, `requireFields.m` | `tKickImpact`, `tFlightDynamics`, `tClassifyShot` | planned |
| R8 | all | – | `examples/PenaltyKickWalkthrough.m`, `takeShot.m` | demo timing, run by the user | planned |
| R9 | demo | – | `examples/PenaltyKickWalkthrough.m` (step 4), `src/1_kick/clampImpactPoint.m` | `tWalkthroughControls`, `tClampImpactPoint` | done |
| R10 | 4 | – | `src/4_visualization/animationFrames.m`, `animateShot.m` | `tAnimationFrames`, `tVisualization` | done |

Check: every requirement has a block and a test; every block has a requirement (block 4 is support and is
exercised by the demo only).

## 7. MBD mapping
Not applicable: block-chain profile, no Simulink (D8).

## 8. Open decisions
- **D10 — frame and sign conventions** (see §3). Options: A as in §3 (x to goal, y left, z up, origin at the
  mark); B origin at the goal centre with `x` pointing away from the goal; C geographic-style NED. Proposed: A.
- **D11 — how a shot is judged** (block 3, A1). Options: A the disc of radius `R` at the instant the centre
  crosses the goal plane (cheap, one geometry test; the ball is a sphere, so a disc is the cross-section at the
  plane); B sweep the whole path against the posts in 3D (exact for grazing shots, but needs the post
  rebound to mean anything, which is out of scope). Proposed: A. Tie-break in the corner where the disc
  touches both post and crossbar: POST (arbitrary, declared).
- Tolerances for R2, R3 are fixed in the plan, not here.
