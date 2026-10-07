# Phase 2 — Block architecture

Goal: decide *how the pieces fit* before writing any of them, so each can be built, tested and later
explained independently. Read `mbd-integration.md` too: it explains how this maps onto a Model-Based
Design process when the project uses one.

## Shape of the architecture
A chain of **numbered blocks** in data-flow order, one folder each:

```
src/
  1_input/   2_domain/   3_solver/   4_extraction/   5_evaluation/   6_visualization/
  <entryPoint>.m          % chains the blocks; contains no physics
  requireFields.m
```
The names above are an example. Choose the chain from the project's own data flow. Inside a block,
split further when it holds independent physical factors: one file per factor, so each can be switched
off and tested on its own. Keep numbering consistent between folders, READMEs and the demo.

## For every block write a contract
| Item | Content |
|---|---|
| Purpose | one sentence of physical/mathematical meaning |
| Inputs | name, class, size, **unit**, **reference frame** |
| Outputs | same |
| Parameters | which sub-struct of the parameters file it receives |
| Assumptions | numbered, with validity range |
| Theory | document section / equation it implements |
| Test | the test class and the analytic or reference case it must match |

Contracts go in `docs/assist/architecture.md`. The data passed between blocks (e.g. a `grid` struct)
gets its own contract: list every field.

## Parameters file skeleton
One file (`parameters.m`), numbered sections, one sub-struct per block (`par.domain`, `par.solver`, …).
Each line `value; % [unit] meaning`. Scenario-dependent lists start as empty typed structs.
Template: `templates/matlab/parameters.m`. A second table (`PARAMETERS.md`) is filled in phase 5.

## Traceability matrix
`Requirement → block → theory section → file → test`. Rows are created now with files/tests marked
*planned*; phases 4–5 fill them in. A requirement without a test, or a block without a requirement, is a
finding to raise with the user.

## Decisions to raise (do not decide silently)
Block boundaries, what is a parameter vs a constant, which quantities are exposed between blocks, level
of fidelity of each model, which blocks are in scope now.

## Output and gate
`docs/assist/architecture.md` (template provided), with a block diagram (ASCII is fine). Present it,
end the turn, and wait for approval. If the project uses Simulink/System Composer, include the mapping
table from `mbd-integration.md`.
