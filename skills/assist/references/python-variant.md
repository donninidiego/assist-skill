# Python variant

The phases, gates and principles are the same. Only the artefacts change. Python style (PEP 8, type
hints, docstrings with Physical Context / Theory / Args / Returns / Assumptions, f-strings, pytest) is in
`coding-standards.md`.

## Mapping MATLAB → Python
| MATLAB artefact | Python artefact |
|---|---|
| `parameters.m` (`par.block.field`) | `parameters.py`: frozen dataclasses, one per block, grouped in `Parameters`; each field with `# [unit] meaning` |
| `requireFields` + `arguments` block | dataclass construction (missing field = `TypeError`) plus explicit `ValueError` checks with a message that states the theory reason |
| `src/N_block/` | package `src/<project>/n_block/` with `__init__.py`; same numbering and one module per physical factor |
| `matlab.unittest` class `t<Block>` | `tests/test_<block>.py`, pytest; fixtures build the grid, parameters come from `parameters.default()` and a test changes only what it verifies |
| Live Script walkthrough | `examples/walkthrough.py` in **percent format** (`# %%` cells, `# %% [markdown]` text cells) — opens as notebook in VS Code/Spyder/Jupytext, runs as a script; or a `.ipynb` if the user prefers |
| `checkcode` | `ruff` / `pylint`, `mypy` for types |
| `error identifier` | custom exception class or `ValueError` with the same message style |

## Rules specific to Python
- **One parameters module, no defaults in functions.** Functions take the block's dataclass
  (`example: ExampleParams`) and never `gain: float = 2.0`.
- Use `numpy` vectorization; preallocate; avoid loops over cells when an array expression exists.
- Plots: `matplotlib`, same academic standards (ask the journal-target question first; units in
  brackets; LaTeX text via `usetex` only if a TeX install is confirmed, otherwise mathtext).
- Environment: `requirements.txt` or `environment.yml` with exact tested versions; list them in the
  "verified stack" table of the guide.
- Percent-format walkthrough: keep cells short, text cells follow the same rhythm (idea → inputs →
  run → result → what to observe → printed check). Equations in Markdown cells with `$...$`.
- Long runs: same rule — verify with linters/unit tests, let the user run the full demo.

## Templates
`templates/python/parameters.py`, `example_block.py`, `test_block.py`, `walkthrough.py`. They are the
Python twins of the MATLAB templates (same toy block) and keep the same structure. Put the project root
on `PYTHONPATH` (or install the package in editable mode) so tests and the walkthrough can import it.

> These templates were written but not executed on the machine where /assist was authored (no Python
> available). On first use, run `pytest` once and fix any environment-specific issue before relying on them.
