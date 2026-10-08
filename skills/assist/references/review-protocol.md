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

## Ask the questions interactively
The check-understanding questions must **appear to the user as an interactive prompt**, not only as text in the
chat. In Claude Code use the interactive question tool (`AskUserQuestion`): one call with the 1–2 questions of the
section, then stop and wait for the answer.
- Write them as multiple choice, 3–4 options. The wrong options are the real misconceptions you expect (the plausible
  slip, the quantity that scales differently, the property that sounds right but is not), each with a short
  description, so that the choice itself is informative.
- Never mark an option as recommended and do not put the right answer first: this is a check, not a decision.
  Vary the position of the right one from question to question.
- The free-text "Other" is always available: invite the user to explain in their own words when no option fits.
- If the tool is not available in the harness, write the questions in the chat as a numbered list and say that the
  answer can be free text. Record in `REVIEW_LOG.md` which way was used.
- The explanation of the section comes first, in the chat. The prompt carries only the questions.

## Handling the answer
- **Right: always give feedback, and reward it.** The user must feel the progress. Say *why* it is right (so a
  right guess is not mistaken for understanding) and name **what exactly they got right**: the step of reasoning
  that mattered, or the trap they avoided (for example "you did not fall for the tempting answer that ..."). Be
  specific and sincere, never generic praise: a "well done" with nothing behind it is noise. Show where they stand
  ("3 sections understood out of 7", a streak, the point of the review it unlocks), log it, offer to continue.
- **Partly right:** name what is right (the user's principle is often correct and applied to the wrong system),
  point to the missing piece without giving it away, ask a narrower follow-up.
- **Wrong or "I don't know":** no judgement, and **first verify that it is really wrong**: re-read the code,
  run the test or a small simulation of the project's functions, check the source in `REFERENCES.md`. The user may
  be right, and then it is a bug or a decision to log, not a point to defend. Only when the check confirms the
  slip, re-explain from another angle, and ground the physical sense in what the project can show:
  - a statement from the **bibliography** (cite the source, section and equation number as read, never from
    memory), or
  - a **simulation run on the project's own code**, with the numbers printed (a table the user can reproduce),
    chosen so that the right and the wrong answer predict different numbers.
  Then ask a different question on the same point. A new analogy alone is not enough: tie it to a number or a source.
- **User disagrees with you:** treat it as possibly right. Check the code and the demo output; if they
  are right, log a bug or a decision change rather than defending the explanation.

## Soft gate
The user may say "next" at any time. Respect it, but leave the section marked *doubts* in
`REVIEW_LOG.md` if it was not resolved, and mention it when the review ends.

The user may also **validate** a section, or the whole review, at any point ("consider it validated"). Record it as
*validated by the user*, which is not the same as *understood* (that one the checks confirmed): write down what was
missed or left unanswered, and do not claim more than that in the README or the summary.

## Progress, and honesty about it
Show the user where they stand (sections understood out of N, questions right out of asked), but **count exactly**:
keep the tally in `REVIEW_LOG.md` and read it from there, never from memory. An inflated score is a false reward;
if you find that you reported a wrong count, say so plainly and correct it.

## Name the pattern
When the same slip comes back in different questions or sections, name it once, in the user's own terms, and give
the key that ends it; then offer to close the earlier doubts with it. In the penalty_kick review the slip was
applying a true law (energy is conserved) to a system that was not closed; the question "which system is the
balance written for?" ended three wrong answers in two sections.

## Honesty about the artefacts
If a caption or README claims something the figure does not show, say so and fix it. Never explain away
a mismatch between what the user sees and what the text says.
