# Phase 8 — Close

Goal: leave the project in a state anyone can pick up, and the process knowledge saved.

## Checklist (show it with real values, not ticks)
- [ ] Full test suite run; count and date recorded (e.g. "<N> passed, 0 failed, <date>")
- [ ] Static analysis clean on `src/` and `tests/`
- [ ] Parameters: every value in the parameters file, documented in `PARAMETERS.md`, no defaults in
      functions (grep the sources)
- [ ] Traceability matrix complete: every requirement has block, theory section, file, test
- [ ] `REFERENCES.md` verified against sources
- [ ] README guide, block READMEs and theory index consistent with the code
- [ ] Demo runs end to end (user-confirmed); captions match what is measured
- [ ] `REVIEW_LOG.md`: every section understood or parked with a reason
- [ ] `DECISIONS.md` up to date; open questions listed
- [ ] Known limits declared in the README
- [ ] Originals untouched (if the project was adopted): verify with version-control status or a diff
- [ ] No absolute machine paths, no commented-out code, no debug prints

## Wrap-up
1. Update `STATE.md`: phase *closed*, date, what remains open.
2. Propose a commit with specific files and a descriptive message; **ask before committing or
   pushing**, unless the user pre-authorized it.
3. If the review surfaced preferences about how the user works, save them to memory.
4. Suggest what to do next (new feature = new cycle from phase 1; unresolved doubts = review again).
