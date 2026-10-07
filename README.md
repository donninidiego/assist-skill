# /assist — engineering co-development with an AI

A Claude Code skill that turns the way you work with an AI on scientific/engineering code into a
repeatable workflow. **Claude writes the code; you own every engineering decision**, and you finish
able to defend the design in front of a reviewer.

MATLAB first (Live Scripts, `matlab.unittest`), Python as a variant (percent-format notebook, pytest).
It fits a Model-Based Design process: block architecture with I/O contracts, requirements traced to
tests, optional Simulink/System Composer mapping.

## The workflow

| # | Phase | Command | Result |
|---|---|---|---|
| 0 | Audit an existing project | `/assist audit` | block map, parameter inventory, gap table (originals untouched) |
| 1 | Brainstorm & requirements | `/assist brainstorm` | `docs/assist/spec.md`, decisions logged |
| 2 | Block architecture | `/assist architecture` | block chain, I/O contract per block, traceability matrix |
| 3 | Plan | `/assist plan` | `docs/assist/plan.md` with stop points and falsifiable checks |
| 4 | Build block by block | `/assist build` | tests first, code to the coding standards, one block per turn |
| 5 | Engineering docs | `/assist docs` | guide README, theory with index, references, parameters |
| 6 | Walkthrough demo | `/assist demo` | Live Script that exercises every block in order |
| 7 | Guided review | `/assist review` | Claude explains each demo section and checks your understanding |
| 8 | Close | `/assist close` | checklist, test count with date, commit proposal |

`/assist` alone reads `docs/assist/STATE.md` and resumes where the project stands.

## Principles
Code to Claude, decisions to you (logged as D1, D2, …) · one block at a time · one parameters file, no
hidden defaults · every equation traceable to a source and a test · captions state only what was
measured · no long runs on your behalf · never modify originals · explanations that start from the
physics.

## Install

Short command `/assist` (personal skill) — link or copy the skill folder:

```bat
:: Windows (junction, no admin needed)
mklink /J "%USERPROFILE%\.claude\skills\assist" "<path-to-this-repo>\skills\assist"
```
```sh
# macOS / Linux
ln -s "<path-to-this-repo>/skills/assist" ~/.claude/skills/assist
```

As a plugin: add this repo as a plugin source; the skill is then namespaced (`assist-workflow:assist`).

Optional but recommended: the `superpowers` plugin (`/plugin install superpowers@claude-plugins-official`).
/assist uses its brainstorming, planning and TDD skills when present and falls back to a condensed
built-in process otherwise.

## Requirements
- MATLAB R2025a+ for plain-text Live Scripts (earlier versions work for everything except the demo
  format); MATLAB MCP server recommended for static checks and quick runs.
- Python variant: Python 3.9+, `numpy`, `matplotlib`, `pytest`.

## Layout
```
skills/assist/
  SKILL.md              principles, phase router, state files
  references/           one file per phase + decision/review protocols, MBD integration,
                        Live Script format, Python variant, coding standards, fallback process
  templates/matlab/     parameters.m, requireFields.m, exampleBlock.m (header), tExampleBlock.m,
                        loadTestParams.m, Walkthrough.m
  templates/python/     the Python twins
  templates/docs/       STATE, spec, architecture, plan, DECISIONS, REVIEW_LOG, README guide,
                        block README, theory index, REFERENCES, PARAMETERS
```

## Verification status
MATLAB templates: static analysis clean, 5/5 unit tests pass, Live Script saved to `.mlx` as a valid
archive, walkthrough runs in under a second. Python templates: written to the same structure but not
executed on the authoring machine; run `pytest` once on first use.

## Origin
Distilled from a research-software project built plan
first with an AI, documented as an engineering guide, and studied by its author through a step-by-step
Live Script demo. License: MIT.
