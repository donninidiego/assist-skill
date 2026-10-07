# <Project name>

One sentence: the idea of the project and what it produces.

## Contents
0. Architecture · 1–N. One section per block · Examples · Known issues · Verification runbook · Documentation map

---

## 0. Architecture

```
input ──► model ──► solver ──► extraction ──► evaluation ──► visualization
```

### Folder tree
```
src/ 1_input/ 2_model/ ...   parameters.m   tests/   examples/   doc/
```

### Data contract between blocks
Struct `<name>`: one row per field — class, size, unit, frame.

### Parameters
| Sub-struct | Received by | Documented in |
|---|---|---|
| `par.domain` | block 1 | `doc/PARAMETERS.md` |

### Quick start
```matlab
run('parameters.m');
% minimal call of the entry point
```

## 1. Block 1 — <name>
Physical meaning, the method in one line, input → output, status line with measured evidence
(`verified to 1e-12 against <case>`), link to `src/1_<name>/README.md` and to the theory section.

## N. Block N — <name>
...

## Examples
| Script | Blocks | What it shows | Measured duration |
|---|---|---|---|
| `examples/Walkthrough.m` | all | step-by-step demo | <s> |

## Known issues
### <short title>
- **Symptom:** what the user sees.
- **Cause:** what is actually happening (official docs / found empirically).
- **Handling:** what the code does about it, or the workaround.

## Verification runbook
```matlab
results = runtests('tests');   % expected: <N> passed, 0 failed (<date>)
```
- Tests that matter most: `<t...>` (why).
- Originals integrity (if adopted): `<command>` shows no change.

## Documentation map
| File | Content |
|---|---|
| `doc/THEORY.md` | derivations, index section → file → test |
| `REFERENCES.md` | sources and where each enters |
| `doc/PARAMETERS.md` | every parameter |
