# Architecture — <project>

Status: draft / approved by <user> on <date>

## 1. Block diagram
```
input ──► domain/model ──► solver ──► extraction ──► evaluation ──► visualization
 [1]          [2]            [3]          [4]            [5]             [6]
```
(Replace with the project's own chain, in data-flow order.)

## 2. Folder layout
```
src/
  1_input/   2_model/   3_solver/   ...
  <entryPoint>.m      % chains the blocks, no physics
  requireFields.m
parameters.m          % the single parameters file
tests/  examples/  doc/
```

## 3. Data contract between blocks
Struct `<name>` passed along the chain: every field with class, size, unit, frame.
| Field | Class | Size | Unit | Frame | Produced by | Used by |
|---|---|---|---|---|---|---|

## 4. Block contracts
### Block <N> — <name>
| Item | Content |
|---|---|
| Purpose | one sentence of physical/mathematical meaning |
| Inputs | name, class, size, unit, frame |
| Outputs | same |
| Parameters | `par.<sub-struct>` |
| Assumptions | numbered, with validity range |
| Theory | document section / equation |
| Test | test class and analytic/reference case |

## 5. Parameters skeleton
Sub-structs of `parameters.m`, one per block, with the fields each needs.

## 6. Traceability matrix
| Requirement | Block | Theory § | File | Test | Status |
|---|---|---|---|---|---|
| R1 | 2 | F | `src/2_model/...` | `t...` | planned |

## 7. MBD mapping (only if Simulink / System Composer is used)
| Chain element | Model element | Notes |
|---|---|---|

## 8. Open decisions
Decision ids still to be taken before the plan.
