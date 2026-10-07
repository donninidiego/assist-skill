# Fitting /assist into Model-Based Design (MBD)

**Model-Based Design** is the practice of developing a system around an executable model that is
requirement-traced, simulated, verified and only then turned into code. /assist does not require
Simulink: the block chain *is* the model structure, and the phases line up with the usual MBD "V".
Pick the profile with the user in phase 1 (record it as a decision).

## Profiles
| Profile | When | What changes |
|---|---|---|
| **Block chain** (default) | research code, algorithms, planners | MATLAB functions per block, matlab.unittest per block, Live Script demo. No Simulink |
| **Hybrid** | needs formal traceability but not a Simulink model | block chain + a requirements table with verification method per requirement and a trace matrix kept current |
| **Full MBD** | plant/controller models, code generation, certification-adjacent work | blocks become Simulink subsystems / System Composer components; requirements and tests formally linked |

## Phase ↔ MBD stage mapping
| /assist phase | MBD stage |
|---|---|
| 1 brainstorm | Requirements capture (numbered R1.., each with a verification method) |
| 2 architecture | System/architecture design: components, interfaces, interface data dictionary |
| 3 plan | Verification plan: which test level checks which requirement |
| 4 build | Component modelling and unit verification (the left leg of the V, bottom) |
| 5 docs | Design documentation and trace report |
| 6 demo | System-level simulation / integration view (all blocks closed-loop in the chain) |
| 7 review | Design review with the model owner |
| 8 close | Verification summary, baseline |

## Mapping tables (phase 2, when Simulink or System Composer is used)
| Chain element | Simulink / System Composer |
|---|---|
| Block (folder) | Subsystem / component |
| Block contract: inputs/outputs, units | Ports with typed interfaces (bus objects, units on signals) |
| Parameters sub-struct | Data dictionary section / model workspace; keep **one** source, generated or loaded from the parameters file |
| `requireFields` + `arguments` validation | Port data-type and range constraints, assertions blocks |
| `matlab.unittest` per block | Simulink Test harness per subsystem (same analytic case) |
| Traceability matrix | Requirements links (Requirements Toolbox) |
| Demo | Top-level model + scripted scenarios |

If a block exists as both a MATLAB function and a subsystem, the function stays the oracle: the
subsystem's test compares against it (software-in-the-loop style equivalence), within a tolerance the
user chooses.

## Verification levels to propose
- **Unit** — block against analytic or literature case (always).
- **Integration** — block pairs through their data contract.
- **System** — the demo scenarios, with numeric pass criteria (not just plots).
- **Equivalence** (Full MBD) — model vs MATLAB reference, model vs generated code.

## Rules
- Do not generate Simulink models unprompted; propose the mapping and let the user decide how far to go.
- Never duplicate parameter values between the parameters file and a dictionary — one is generated from
  the other, and that direction is a logged decision.
- Keep the requirement IDs stable across spec, matrix, tests (name or tag tests with the R-ID) and demo.
