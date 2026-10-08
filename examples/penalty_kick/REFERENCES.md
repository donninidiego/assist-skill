# Theoretical references

## Overview
A football kicked off-centre gets a velocity and a spin from the impulse of the foot (block 1); in flight it feels
gravity, drag and the Magnus force (block 2); at the goal plane it is judged against the frame (block 3). The physics
of blocks 1 and 2 is first-year mechanics plus the force on a spinning ball; block 3 is plane geometry with the
dimensions of the Laws of the Game.

## How these entries were verified
Each equation below was read on the page of the source on **2026-10-08** (online edition, through a page-reading tool,
not from a printed copy) and the equation number is the one the page shows. Where the source does **not** say what the
code does, the row says so: nothing here is cited from memory.

## Primary sources
| Reference | Where it enters |
|---|---|
| Goff, J.E., Carré, M.J. (2010), "Soccer ball lift coefficients via trajectory analysis", *Eur. J. Phys.* 31(4), 775–784, DOI 10.1088/0143-0807/31/4/007 | `src/2_flight/liftCoefficient.m`: the real `Cl(S)` curve. **Full text not read**: the values used are illustrative (D9) |
| Goff, J.E., Kelley, J., Hobson, C.M., Seo, K., Asai, T., Choppin, S.B. (2017), "Creating drag and lift curves from soccer trajectories", *Eur. J. Phys.* 38(4), 044003, DOI 10.1088/1361-6404/aa6fcd | `par.flight.dragCoeff`, `liftSlope`, `liftMax`. **Full text not read** (D9) |
| IFAB, *Laws of the Game* (editions 2008–2015 read; current edition not checked) | `parameters.m` section 1 (ball) and 4 (goal) |

## Secondary sources (textbook, free)
Moebs, W., Ling, S.J., Sanny, J. (2016), *University Physics Volume 1*, OpenStax, Houston.
<https://openstax.org/books/university-physics-volume-1/>. Referred to below as **UP1**.

| Equation in the project | Source | What the source says | Where it enters |
|---|---|---|---|
| Impulse `J = ∫F dt`; `J = Δp` (an impulse changes the momentum by exactly its value) | UP1 §9.2 *Impulse and Collisions*, Eq. 9.3 and 9.7 | "The product of a force and a time interval (over which that force acts) is called impulse"; `J = Δp` | `kickImpact`: `launch.velocity = impulse / m` (the ball starts at rest, so `Δp = m v0`) |
| Torque `τ = r × F` | UP1 §10.6 *Torque*, Eq. 10.22 | "the torque τ around O is τ = r × F" | `kickImpact`: `cross(r, impulse)` |
| Rate of change of angular momentum `dL/dt = Στ`; `L = Iω` | UP1 §11.2 *Angular Momentum*, Eq. 11.8 and 11.9 | Eq. 11.9 is stated for a rigid body rotating **about a fixed axis** | `kickImpact`: `launch.spin = cross(r, impulse) / inertia` (see the note on angular impulse below) |
| Moment of inertia of a thin spherical shell `I = (2/3) M R²` (and of a solid sphere `(2/5) M R²`) | UP1 §10.4, Figure 10.20 (the page lists it as a figure, not a numbered table) | "Thin spherical shell about any diameter: (2/3) M R²"; "Solid sphere about diameter: (2/5) M R²" | `par.ball.inertiaFactor = 2/3`, `kickImpact`: `inertia` |
| Drag force `F_D = ½ C ρ A v²` | UP1 §6.4 *Drag Force and Terminal Speed*, Eq. 6.5 | `C` drag coefficient, `ρ` fluid density, `A` area of the object facing the fluid; valid for large objects at high speed, where drag grows with the square of the speed (baseballs are named; soccer balls are not) | `flightDynamics`: drag term of `ballAcceleration` |
| Work `dW = F·dr`; zero when the force is perpendicular to the displacement | UP1 §7.1 *Work*, Eq. 7.1 | "zero work is done when the force is perpendicular to the displacement (cos θ = 0)" | requirement R3: the Magnus force is perpendicular to the velocity, so it does no work and the mechanical energy is conserved when it acts alone (`tFlightDynamics`) |
| Flight time `T = 2 v0 sin θ / g` and range `R = v0² sin 2θ / g`, launch and landing at the same height | UP1 §4.3 *Projectile Motion*, Eq. 4.24 and 4.26 | "neglecting air resistance", "launch and impact on a flat horizontal surface" | requirement R2 and the demo check: `2 vh vz / g` is the same range, since `vh = v0 cos θ` and `vz = v0 sin θ` |

## Sources for the force on a spinning ball
| Statement | Source | Verified? |
|---|---|---|
| The force on a spinning ball is perpendicular to the flow direction and to the axis of rotation; the lift of a spinning soccer ball is the origin of the "bend" | NASA Glenn Research Center, *Lift of a Soccer Ball*, <https://www.grc.nasa.gov/WWW/k-12/airplane/soclift.html> | yes (read 2026-10-08). The page also gives its own formula for a smooth ball, **not used** here, and mentions a lift coefficient of about 0.25 for a soccer ball (not checked further) |
| Lift written with a lift coefficient: `L = Cl (ρ V² / 2) A` | NASA Glenn, *Lift Equation*, <https://www1.grc.nasa.gov/beginners-guide-to-aeronautics/lift-equation/> | yes, but the page defines `A` as **the wing area**. Using the same form for a ball, with `A = π R²` the cross-section, is a modelling convention of this project; the convention of the soccer papers was not checked |
| Backspin gives an upward force, topspin a downward swerve | Wikipedia, *Magnus effect*, section Description (secondary; it cites a web page) | yes as a statement. The project's sign `ω × v` reproduces it: for a ball moving along `+x`, backspin `ω = −y` gives `ω × v = +z` (lift), topspin gives `−z`. Tests `R5_signsOfSpinForStraightKick` (block 1) and `R4_offsetSideSetsTheDirectionOfTheCurve` (end to end) pin the signs |
| The vector form `F ∝ ω × v` | none read | **no source found**: it is the project's way of writing the rule above in vector form |

## Implementation notes
- **Frame:** origin at the penalty mark, `x` to the goal, `y` to the left looking at the goal, `z` up (D10).
- **Angular impulse (derived here, not quoted).** Integrating Eq. 11.8 over the short contact time gives
  `ΔL = ∫ τ dt = ∫ r × F dt ≈ r × J` if the point of contact `r` does not move during the kick (assumption: the
  contact is instantaneous). Eq. 11.9 is stated for a fixed axis; for a sphere the moment of inertia is the same about
  **every** diameter (Figure 10.20, "about any diameter"), so `L = I ω` holds as a vector and `ω0 = (r × J) / I`.
- **Physical assumptions:** 1. impulse along the foot direction with enough friction to transmit it (D7);
  2. the ball is a thin spherical shell (2/3), a good model of an inflated ball whose mass is in the skin;
  3. constant spin in flight; 4. constant `Cd`, `Cl` from `S = R|ω|/|v|` only (illustrative, D9); 5. no wind.
  None of 3–5 is taken from the textbook; they are limits declared in `spec.md` §8.

## Notation correspondence
| Symbol | Code variable | Description / unit |
|---|---|---|
| `J`, `d̂` | `shot.impulse`, `d` in `kickImpact` | impulse magnitude [N s], unit vector of its direction |
| `m`, `R` | `par.ball.mass_kg`, `par.ball.radius_m` | mass [kg], radius [m] |
| `I` | `inertia` = `par.ball.inertiaFactor * m * R^2` | moment of inertia [kg m²] |
| `r` | `r` in `kickImpact` | impact point relative to the centre [m] |
| `v0`, `ω0` | `launch.velocity`, `launch.spin` | initial velocity [m/s], initial spin [rad/s] |
| `ρ`, `Cd`, `Cl`, `A` | `par.flight.airDensity_kgm3`, `par.flight.dragCoeff`, `cl` (from `liftCoefficient`), `k.area` = `π R²` | air density [kg/m³], coefficients [-], cross-section [m²] |
| `S` | `S` in `ballAcceleration` | spin parameter `R|ω|/|v|` [-] |
| `g` | `par.flight.gravity_ms2` | gravity [m/s²] |

## Version history
- v1.0 (2026-10-08): first list of sources, added during the guided review of the demo (section 1).

> Every entry is verified against the original source. Never cite from memory.
