# Spec — penalty_kick

Status: approved by the user on 2026-10-07, with Q1 left on its default (illustrative coefficients, see D9)

## 1. Intent
A deliberately silly worked example for the `/assist` skill: kick a football at a goal in MATLAB and see
what the physics does. It exists to show the whole `/assist` flow (spec → blocks → plan → build → docs →
demo → review) on a project small enough to read in one sitting. The existing example, `synthScene`, is the
serious and large one; this is its opposite.

Said by the user: MATLAB; a football goal; simulate the physics of kicking the ball; in the demo the user
selects where to hit the ball and how hard.

Assumed by the assistant (to be corrected): the example runs the real workflow, with real decisions in
`DECISIONS.md`; the goal is only a target; success means the demo runs in seconds, changing the impact point
or the strength visibly changes the trajectory, and every number shown was measured.

## 2. Requirements
| ID | Requirement | Verification | Status |
|---|---|---|---|
| R1 | A kick whose impulse line passes through the ball centre shall give zero spin. | Impact offset (0, 0) gives `omega0 = [0 0 0]` exactly. | proposed |
| R2 | With drag and Magnus switched off, the flight shall reproduce the analytic parabola. | Range and apex height equal `v0^2 sin(2a)/g` and `(v0 sin a)^2/(2g)` within a stated tolerance. | proposed |
| R3 | With Magnus only (no drag), the mechanical energy shall be conserved. | The Magnus force is perpendicular to the velocity, so it does no work: `E = ½m|v|² + m g z` stays constant along the flight, within the solver tolerance (and `|v|` is constant if gravity is also switched off). Corrected on 2026-10-07: the first wording claimed `|v|` constant with gravity on, which is false. | proposed |
| R4 | An impact offset to one side shall curve the ball to the side predicted by the sign of `omega x v`. | Sign test on the lateral displacement at the goal plane, for left and right offsets. | proposed |
| R5 | Block 1 shall satisfy `m v0 = J` and `I omega0 = r x J`. | Direct numerical check on random valid inputs (seeded). | proposed |
| R6 | Every shot shall receive exactly one outcome label. | Labels GOAL, POST, CROSSBAR, WIDE, HIGH, SHORT; boundary cases just inside, just outside and on a post. | proposed |
| R7 | All values shall come from `parameters.m`; each function shall validate its sub-struct, and inputs outside the admissible domain shall be rejected with a clear error. | `requireFields` in every block; test with a missing field and with an offset of norm larger than the ball radius. | proposed |
| R8 | The demo shall run end to end in less than 10 s and shall contain a "Your shot" section with the five inputs. | Wall time measured and recorded with the date; the user runs it in the Live Editor. | proposed |
| R9 | The "Your shot" section of the demo shall offer one slider per input of the shot, with limits equal to the ranges of `par.kick` and a starting value inside them; releasing a slider shall re-run the section. A point chosen with the two offset sliders that lies outside the admissible circle shall be moved radially onto it, never refused (D13, D14). | `tWalkthroughControls` reads the demo as text: five sliders, each tag at the number it controls, limits equal to `par.kick`, run on release; `tClampImpactPoint`: inside points untouched, outside points on the circle with the same direction, never refused by `kickImpact` (seeded regression for a one-ulp overshoot). | proposed |
| R10 | The section shall replay the shot as a slow-motion animation of the spinning ball, ending exactly at the last sample of the path, next to the impact point and the verdict. | `tAnimationFrames`: first and last frame equal the first and last sample, frame count and duration follow `par.animation`, spin angle at the end is `|omega|·T`; `tVisualization`: `animateShot` ends with the ball at the last sample. | proposed |

## 3. Constraints
- Platform: MATLAB, base product only (`ode45` with events); no toolbox required.
- Language of docs and demo: English (D2). Code and comments: English.
- Run-time budget: any test under about 1 minute; demo under 10 s.
- Demo inputs (D4): impact offset (lateral, vertical) as a fraction of the ball radius, impulse strength `J`
  in N s (equivalent speed `J/m` shown next to it, D6), aim azimuth and elevation in degrees.
- Sliders in the Live Script itself (D13, which reverses D4): the plain-text Live Code of MATLAB R2026a supports
  controls. The ranges are copied from `par.kick` and tied to it by a test (D14). The section also plays the
  shot as a slow-motion animation in its output figure. Base MATLAB only.

## 4. Approach
Block chain (D8) of three blocks plus support code:

| Block | Input → output | Equation |
|---|---|---|
| 1 `kickImpact` | impact offset, aim, strength → `v0`, `omega0` | `v0 = J/m`, `omega0 = (r x J)/I`, shell sphere `I = (2/3) m R^2` |
| 2 `flightDynamics` | `v0`, `omega0` → trajectory (`ode45`, events on ground and goal plane) | `m dv/dt = -m g - (1/2) rho Cd A |v| v + (1/2) rho Cl A |v|^2 (omega_hat x v_hat)` |
| 3 `classifyShot` | trajectory, goal geometry → outcome label | crossing of the goal plane against posts and crossbar, ball radius included |

Support: `parameters.m` (single source), `requireFields.m`, a function drawing the goal and the trajectory
(demo style, D5). The model choice and its alternatives are D3; the direction of the impulse is D7.

## 5. Theory sources
Verified bibliographically on 2026-10-07: title, authors, journal and DOI read from the university
repository record, then each DOI resolved through doi.org to the publisher page (IOPscience), which shows the
same title, authors, volume and year. Only the bibliographic data were checked, not the content.

1. Goff, J.E., Carré, M.J. (2010). "Soccer ball lift coefficients via trajectory analysis". *European Journal
   of Physics* 31(4), 775–784. DOI 10.1088/0143-0807/31/4/007.
   <https://iopscience.iop.org/article/10.1088/0143-0807/31/4/007>
2. Goff, J.E., Kelley, J., Hobson, C.M., Seo, K., Asai, T., Choppin, S.B. (2017). "Creating drag and lift
   curves from soccer trajectories". *European Journal of Physics* 38(4), 044003.
   DOI 10.1088/1361-6404/aa6fcd. <https://iopscience.iop.org/article/10.1088/1361-6404/aa6fcd>
3. IFAB, *Laws of the Game* (goal 7.32 m wide and 2.44 m high; posts and crossbar not wider than 12 cm; ball
   circumference 68–70 cm, mass 410–450 g; penalty mark 11 m from the goal line). Read from the IFAB download
   pages, editions 2008–2015: <https://downloads.theifab.com/downloads/laws-of-the-game-2015-16?l=de>.
   The current edition has not been checked.

**Not verified yet:** the numerical values of `Cd` and `Cl` (and the form of `Cl(S)`, `S = R omega/|v|`). Both
papers hold them, but the full texts could not be read from here (the PDF copies are password protected and
were not opened). Until the user supplies them or chooses otherwise, `parameters.m` carries these values
flagged as illustrative, and every figure shall say so. See open question Q1 in `STATE.md`.

## 6. Plot intent
Not for a journal (D5). Screen-readable figures: goal and trajectory in 3D, plus a top view.

## 7. Out of scope
Foot-ball contact dynamics, goalkeeper, wind, bounce, rebound on posts and crossbar, spin decay in flight,
sound, camera following the ball, several balls at once.

## 8. Known limits to declare
- The impulse is given, not computed from a foot model (D7: its direction is the foot direction and friction
  is assumed sufficient to transmit it).
- Spin does not decay during the flight.
- `Cd` is constant, so the drag crisis (the drop of `Cd` at higher speed) is not modelled.
- A POST or CROSSBAR outcome is reported, but the ball does not rebound.
- The ball is a rigid thin-shell sphere; panels, seams and knuckle-ball effects are ignored.
- The coefficients are illustrative until Q1 is closed.
