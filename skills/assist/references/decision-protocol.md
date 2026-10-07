# Decision protocol — who decides what

The user is the engineer of record. The research or product claims are theirs, so the choices that
shape them are theirs. Your job is to make each choice cheap to make well.

## What counts as a user decision
Anything that changes the model, the physics, the numerics, an interface other code depends on, or
what is measured: formulas and their terms, which effects are in scope, boundary conditions, default
values of physical parameters, tolerances that define "correct", metrics, benchmarks, what is deleted.

## What is yours
Conventional implementation choices: vectorization, preallocation, helper structure inside an agreed
block, naming that follows the standards, test layout. If in doubt whether it changes behaviour, treat it
as a decision.

## How to present a decision
1. One line on what has to be decided and why it matters now.
2. **2–3 options**, each with what it does physically/numerically, what it costs, and where it can break.
3. A **recommendation** and the reason. Lead with it.
4. Ask. Stop. Do not start implementing the recommendation "while they think".

Prefer simplification when the model is crowded: inventory every term first (table: term | formula |
parameters | source file:line), expose redundancies, and only then ask what to remove. Compare models
only after they are simple enough to read.

## Decision rules before measuring
When a question will be settled by an experiment, state the decision rule first: "if the quantity stays
above X, we keep the current formulation; if it approaches Y, we change Z". This prevents rationalizing
the result afterwards and gives the user a falsifiable plan.

## Logging (`docs/assist/DECISIONS.md`)
| ID | Date | Question | Options considered | Decision | Why | Affects |
|---|---|---|---|---|---|---|
Number sequentially (D1, D2, …). Never rewrite history: a reversed decision gets a new row that
references the old one, plus the list of artefacts to update. Reference decision IDs from code comments
and docs where they explain a non-obvious choice.

## Authority is not transferable between contexts
A yes to one decision is not a yes to the next. A yes to a design is not a yes to committing, pushing,
deleting or publishing. Ask again when the action changes.
