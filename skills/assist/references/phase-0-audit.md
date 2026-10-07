# Phase 0 — Audit of an existing project

Use only when code already exists. Goal: understand what is there and map it onto the block chain
*without touching it*, so the user can decide what to keep, move or rewrite.

## Rules
- **Read-only on the original tree.** If anything has to be reorganized, copy it to a new location and
  work on the copy. The user decides what is deleted, never you.
- Do not judge the science. Map, measure, list gaps; leave verdicts to the user.

## Steps
1. **Inventory.** Folder tree, entry points, which functions call which. Use an explorer subagent for
   wide trees. Record the language(s), toolboxes, external dependencies.
2. **Block map.** Propose a chain of processing blocks in data-flow order (input → domain/model →
   solver → extraction → evaluation → visualization is a typical shape, not a requirement). For every
   block: files, inputs, outputs, units. Mark files that mix several blocks.
3. **Parameter inventory.** Grep for magic numbers, defaults buried in function signatures, `struct`
   configs and name-value options. List each parameter with value, where it lives, and how many places
   define it. Duplicated defaults are the main finding.
4. **Gap table against the standards.** Rows: function headers (physical context / theory / units /
   assumptions), `arguments` validation, tests per block, README per folder, REFERENCES file, theory
   traceability, demo. Columns: present / partial / missing, with file examples.
5. **Open model questions.** Things only the user can answer (why this formula, which assumption is
   intentional). Do not guess; list them.

## Output
`docs/assist/architecture.md` draft section "As-is" (block map + parameter inventory + gap table) and
the open questions in `STATE.md`.

## Gate
Present the block map and gap table. End the turn. The user approves or corrects the map; only then
move to phase 1 (new feature/refactor goals) or phase 2 (restructure into the target architecture).
