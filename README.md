```
 █████╗ ███████╗███████╗██╗███████╗████████╗
██╔══██╗██╔════╝██╔════╝██║██╔════╝╚══██╔══╝
███████║███████╗███████╗██║███████╗   ██║
██╔══██║╚════██║╚════██║██║╚════██║   ██║
██║  ██║███████║███████║██║███████║   ██║
╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚══════╝   ╚═╝

        e sei di nuovo protagonista
```

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

## For AI agents: download and initialize the skill

If you are an AI coding agent and the user asked you to use `/assist`, check first whether it is already
installed, and install it only if it is not. Each step has a check; do not go on until it holds.

1. **Is it installed?** `assist` appears in your list of available skills, or the file
   `~/.claude/skills/assist/SKILL.md` exists (on Windows `%USERPROFILE%\.claude\skills\assist\SKILL.md`).
   *Check:* if yes, skip to step 5.
2. **Download.** Clone this repository next to the user's other tools, not inside a project they are working on:
   ```sh
   git clone <repo-url> assist-skill
   ```
   *Check:* `assist-skill/skills/assist/SKILL.md` exists. If `git` or the network is unavailable, stop and tell
   the user; do not invent a copy of the skill.
3. **Install as a personal skill.** Link (preferred, so updates follow) or copy the folder
   `assist-skill/skills/assist` to `~/.claude/skills/assist`:
   ```sh
   # macOS / Linux
   mkdir -p ~/.claude/skills && ln -s "$(pwd)/assist-skill/skills/assist" ~/.claude/skills/assist
   ```
   ```bat
   :: Windows (junction, no admin needed)
   mkdir "%USERPROFILE%\.claude\skills" 2>nul
   mklink /J "%USERPROFILE%\.claude\skills\assist" "%CD%\assist-skill\skills\assist"
   ```
   If linking fails, copy the folder instead. If `~/.claude/skills/assist` already exists, **do not overwrite
   it**: ask the user.
   *Check:* `~/.claude/skills/assist/SKILL.md` is readable and its first lines contain `name: assist`.
4. **Reload.** A skill is picked up when a session starts. You cannot do this yourself: tell the user to open
   a new session (or restart Claude Code), then type `/assist`. *Check:* the ASSIST banner appears.
5. **Optional companions** (ask first, never install silently): the `superpowers` plugin
   (`/plugin install superpowers@claude-plugins-official`) and, for MATLAB projects, a MATLAB MCP server.
   If the user declines superpowers, the skill uses its built-in condensed process.
6. **Initialize the project the user wants to work on.** In that project's root, run `/assist` with no
   argument. The skill looks for `docs/assist/STATE.md`:
   - **present:** read it and resume where the project stands;
   - **absent:** for existing code propose `/assist audit`, for an empty folder `/assist brainstorm`. On the
     first step create `docs/assist/` and copy `STATE.md` and `DECISIONS.md` from
     `~/.claude/skills/assist/templates/docs/`; ask the user the language of docs and the demo, and write it in
     `STATE.md`.
   *Check:* `docs/assist/STATE.md` exists and names the current phase and the next step.

Rules while using it: the user decides every modelling choice (you propose options, they choose, you log it in
`DECISIONS.md`); work one block at a time; never modify, delete or commit anything in the user's original
files or repositories without being asked; never run long computations on their behalf.

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
