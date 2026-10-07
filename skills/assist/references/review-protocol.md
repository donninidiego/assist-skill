# Review protocol — explaining and checking understanding

The point of the review is that the user can *defend* the design to someone who didn't write it. A
reviewer will ask questions nobody planned for; physical intuition is what answers them, formalism
alone does not.

## How to explain
Address a researcher. Order:
1. **Physical analogy** — a concrete picture (resistor network, Ohm and Kirchhoff, water filtering through
   rock, a wavefront) before any symbol.
2. **What the physics guarantees** — the conservation law, the maximum principle, the invariant.
3. **What the numerical method does to mirror it** — discretization, why that stencil, what is
   preserved exactly and what only approximately.
4. **The code** — the real lines, not pseudocode, each tied to the physical step it realizes.
5. **Where it breaks** — assumptions, limits, the failure signature the demo check would show.

Rules: expand every acronym at first use and say what it means concretely (e.g. "FDM = Finite Difference Method: derivatives are replaced by differences between
neighbouring grid points"). Prefer a number to
an adjective. One block per turn, closed by a question — then stop.

## Question types
Mix, 1–2 per section, chosen to expose the likely gap:
- **Prediction:** "If I double parameter X, what happens to field Y, and why?"
- **Counterfactual:** "What would break if we dropped this assumption / used the arithmetic mean here?"
- **Localization:** "Which line enforces that the flux through a wall is zero?"
- **Reading the output:** "The demo prints a residual of 3e-13 — what does that tell you, and what
  would a residual of 1e-3 mean?"
- **Defend it:** "A reviewer says this term is arbitrary. What is your answer?"
- **Transfer:** "How would this change for a different case (other dimension, other medium)?"

Avoid trivia and yes/no questions; they confirm nothing. Do not ask what you have not just explained.

## Handling the answer
- **Right:** confirm in one line *why* it is right (so a right guess is not mistaken for understanding),
  log it, offer to continue.
- **Partly right:** name what is right, point to the missing piece without giving it away, ask a
  narrower follow-up.
- **Wrong or "I don't know":** no judgement. Re-explain from another angle (new analogy, or a concrete
  numeric example from the demo), then ask a different question on the same point.
- **User disagrees with you:** treat it as possibly right. Check the code and the demo output; if they
  are right, log a bug or a decision change rather than defending the explanation.

## Soft gate
The user may say "next" at any time. Respect it, but leave the section marked *doubts* in
`REVIEW_LOG.md` if it was not resolved, and mention it when the review ends.

## Honesty about the artefacts
If a caption or README claims something the figure does not show, say so and fix it. Never explain away
a mismatch between what the user sees and what the text says.
