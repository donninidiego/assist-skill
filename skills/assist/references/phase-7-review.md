# Phase 7 — Guided review of the demo

Goal: the user understands every step of the architecture well enough to defend it. You walk the demo
**section by section**; the user asks, you answer; you check understanding with targeted questions.
Style and question types are in `review-protocol.md` — read it before starting.

## Setup
- Open or create `docs/assist/REVIEW_LOG.md` (template provided). One row per demo section:
  status (not started / explained / understood / doubts), questions asked, bugs found, decisions raised.
- `/assist review` resumes at the first section not marked *understood*. `/assist review <section>`
  jumps to one.
- Ask the user whether they have run the demo. Review is far better with their output on screen; if
  figures disagree with your explanation, theirs wins and it is a finding.

## Loop per section (one section per turn)
1. **Frame** — what this section is for and which block it exercises (one or two lines).
2. **Physical sense** — the analogy and what the physics guarantees.
3. **Numerical method and code** — the real lines, tied to the physical step they implement.
4. **Where it breaks** — limits, assumptions, what the check in the demo would show if it failed.
5. **Invite questions**, answer them from the code and theory docs (verify before answering; don't
   reconstruct from memory).
6. **Check understanding** — 1–2 targeted questions, then **stop** and wait.
   - Correct → say why it is correct in one line, log *understood*, offer the next section.
   - Partial or wrong → do not mark it; re-explain from a different angle (different analogy or a
     concrete number), rephrase the question, ask again.
7. **Log** the outcome in `REVIEW_LOG.md` and `STATE.md`.

Advance only on the user's "next". This is a soft gate: it never blocks the user from moving on, but
unresolved doubts stay visible in the log so they come back later.

## What the review produces
- *Understood* sections the user can now explain.
- **Bugs** → logged and sent back to phase 4 with a regression test; never patched silently.
- **Decisions** the user changes their mind about → `DECISIONS.md` updated, with every downstream
  artefact (spec, architecture, docs, demo captions) listed for update.
- Gaps in docs/captions found while explaining → fix list.
- Preferences about *how* the user likes the review conducted → save them to memory immediately so the
  next project starts from them.

## Exit
All sections *understood* or knowingly parked with a reason. Then `/assist close`.
