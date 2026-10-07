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
| 0 | Audit an existing project | `/assist audit` | first proposes which of your existing docs to use for context (you tick the boxes), and keeps a short digest with pointers, then block map, parameter inventory, gap table (originals untouched) |
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
physics · the cheapest model that can do each delegated task, and other agent CLIs only if you say yes.

## Example: a didactic Live Script

![A kick replayed in slow motion: the impact point on the ball, the flight with the ball spinning, the verdict on the goal](examples/penalty_kick/media/penalty_kick_demo.gif)

*Three kicks replayed by the last step of the demo: where the foot hits the ball, the flight in slow motion with
the ball turning at its spin rate, and the verdict on the goal (green: goal, red: anything else). The values of each
kick are written under the picture. [Same clips as MP4](examples/penalty_kick/media/penalty_kick_demo.mp4).*

[`examples/penalty_kick/`](examples/penalty_kick/) is a whole `/assist` run on a deliberately silly project: kick a
football at a goal and see what the physics does. It is small enough to read in one sitting, and it shows what each
phase leaves behind:

| You want to see | Look at |
|---|---|
| the intent, requirements R1–R10 with their verifications, the decisions D1–D14 (including the ones the user reversed) | [`docs/assist/`](examples/penalty_kick/docs/assist/) |
| three blocks with I/O contracts, one parameters file, a test per requirement | [`src/`](examples/penalty_kick/src/), [`tests/`](examples/penalty_kick/tests/), [`parameters.m`](examples/penalty_kick/parameters.m) |
| a Live Script written for study: one part per block, a numeric check printed in each, a table of every outcome (impact point on the ball above, verdict on the goal below), and a last step **Your shot** with five sliders | [`examples/PenaltyKickWalkthrough.m`](examples/penalty_kick/examples/PenaltyKickWalkthrough.m) |

To run it, open the Live Script in MATLAB with `examples/penalty_kick/examples` as the current folder. The sliders
are controls of the Live Editor: releasing one re-runs the section and replays the kick. The picture above is a
recording of that animation made by [`tools/makeShotVideo.m`](examples/penalty_kick/tools/makeShotVideo.m), not a
screen capture of the Live Editor. The drag and lift coefficients of the example are illustrative, not taken from a
source, and every figure says so.

## Install

Claude Code only looks for skills in fixed places: `~/.claude/skills/` (yours, for every project) and
`.claude/skills/` inside a project. A repository cloned anywhere else is not scanned, so installing means one
extra step: make the skill folder show up in `~/.claude/skills/`.

### The easy way: let your agent do it
1. Clone this repository anywhere you keep your tools:
   ```sh
   git clone https://github.com/donninidiego/assist-skill.git
   ```
2. Open your AI coding agent in that folder and say: **"install the assist skill from this repo"**. The agent
   follows the runbook in [For AI agents](#for-ai-agents-download-and-initialize-the-skill) below.
3. Open a **new session** (skills load when a session starts) and type `/assist`. The ASSIST banner appears.

### The manual way
After cloning (step 1 above), from the folder that contains `assist-skill/`, create a link so that
`~/.claude/skills/assist` points to the cloned skill. A link, not a copy: `git pull` then updates the skill.

```bat
:: Windows (junction, no admin needed)
mkdir "%USERPROFILE%\.claude\skills" 2>nul
mklink /J "%USERPROFILE%\.claude\skills\assist" "%CD%\assist-skill\skills\assist"
```
```sh
# macOS / Linux
mkdir -p ~/.claude/skills
ln -s "$(pwd)/assist-skill/skills/assist" ~/.claude/skills/assist
```
Then open a new session and type `/assist`. If linking is not possible, copy the folder
`assist-skill/skills/assist` to `~/.claude/skills/assist` instead (updates are then manual).

### Other options
- **As a plugin:** add this repo as a plugin source; the skill is then namespaced (`assist-workflow:assist`).
- **For one project only:** link or copy the same folder into that project's `.claude/skills/assist` instead.
- **Recommended companion:** the `superpowers` plugin (`/plugin install superpowers@claude-plugins-official`).
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
   git clone https://github.com/donninidiego/assist-skill.git assist-skill
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
5. **Optional companions** (ask first, never install silently): the `superpowers` plugin and, for MATLAB
   projects, a MATLAB MCP server. At its first start `/assist` checks for superpowers by itself: if it is
   missing it asks the user, and on a yes installs it with
   `claude plugin install superpowers@claude-plugins-official` (it then loads in the next session). If the
   user declines, the skill uses its built-in condensed process.
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
  format); MATLAB MCP server recommended for static checks and quick runs. Sliders in a plain-text Live Script
  were checked on R2026a Update 5 only.
- Python variant: Python 3.9+, `numpy`, `matplotlib`, `pytest`.

## Layout
```
skills/assist/
  SKILL.md              principles, phase router, state files
  references/           one file per phase + context intake, decision/review protocols, MBD integration,
                        Live Script format, Python variant, coding standards, fallback process
  templates/matlab/     parameters.m, requireFields.m, exampleBlock.m (header), tExampleBlock.m,
                        loadTestParams.m, Walkthrough.m
  templates/python/     the Python twins
  templates/docs/       STATE, CONTEXT, spec, architecture, plan, DECISIONS, REVIEW_LOG, README guide,
                        block README, theory index, REFERENCES, PARAMETERS
examples/penalty_kick/  a worked example: process files in docs/assist/, MATLAB blocks, tests, Live Script demo
                        with sliders, and tools/makeShotVideo.m that records the animation in media/
```

## Verification status
MATLAB templates: static analysis clean, 5/5 unit tests pass, Live Script saved to `.mlx` as a valid
archive, walkthrough runs in under a second. Python templates: written to the same structure but not
executed on the authoring machine; run `pytest` once on first use.

Example `penalty_kick` (7 October 2026, MATLAB R2026a Update 5): 51 tests pass, static analysis clean on 25 files,
the demo runs in about 4 s from the command window, and MATLAB recognises its 5 sliders when the Live Script is
converted to `.mlx`. The author dragged the sliders and watched the animation in the Live Editor (7 October 2026).
Not yet done: the documentation phase of that example (guide README, theory notes) and the guided review.

## Origin
Distilled from a research-software project built plan
first with an AI, documented as an engineering guide, and studied by its author through a step-by-step
Live Script demo. License: MIT.
