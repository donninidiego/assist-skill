# Phase 5 — Engineering documentation

Goal: documentation that lets the author defend the work and lets a newcomer rerun it. Written
*from the code and tests that exist*, never ahead of them.

## Deliverables
| File | Shape |
|---|---|
| `README.md` (the guide) | one-sentence idea; index; **0 Architecture** (diagram, folder tree, data contract between blocks, parameter table by sub-struct, quick start); one section per block; **Examples**; **Known issues** as Symptom → Cause → Handling; **Verification runbook** (exact test command, expected counts with date, the tests that matter most, an originals-integrity check); **Documentation map** |
| `src/<N_block>/README.md` | from `templates/docs/BLOCK_README.md`: "Block N of the chain" with a link back to the guide, File \| What it does table, the method in one line, Inputs/Outputs, Status line with measured evidence, theory section, test file |
| `doc/THEORY.md` | lettered sections with primed equation numbers; ends with an index Section → Eq. → implementing file → test; code links back with `% [THEORY §N]` |
| `REFERENCES.md` | table Reference \| Where it enters (which folder). Primary and secondary sources. Every entry verified against the source |
| `doc/PARAMETERS.md` | one table per sub-struct: Field \| Default \| Meaning \| Consumer |
| `tests/README.md` | block → test class map |
| `examples/README.md` | Script \| Blocks covered \| What it shows \| Measured duration |

## Guide structure for setup/runbook-style documents
Four parts: **Prerequisites** (verified stack, exact versions) · **Steps** (numbered, exact commands,
traps called out where they bite) · **Known issues** (chronological, Symptom / Cause / Fix, note whether
the cause came from official docs or from experiment) · **Coding-agent instructions** (self-contained
runbook, each step with a verification criterion, explicit marks where a human must act). Close with a
checklist and a sources footer.

## Rules
- Every number in docs is measured or cited; dates on test counts.
- Notation table: paper symbol → code variable → meaning, unit.
- Physical assumptions listed with source.
- Language: the project language recorded in `STATE.md`.

## Exit
Docs checklist (all rows above exist and are consistent with the code) shown to the user; fix gaps they
point out. Then proceed to the demo.
