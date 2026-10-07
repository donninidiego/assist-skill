# Phase 4 — Build, one block at a time

Goal: implement each block to its contract, with its test, in a form the user can read in one sitting.
Use `superpowers:test-driven-development` if available; fallback: `fallback-process.md` §Build.
Style rules are in `coding-standards.md` — read it first.

## Loop per block
1. **State what is missing and why.** Before writing code, analyze the current state and explain in a
   few lines what the block adds and why it comes next.
2. **Test first.** Write the block's test from its contract: an analytic or reference case with a
   tolerance, plus the failure cases the assertions promise. Run it and watch it fail for the right
   reason (only if it runs in well under a minute).
3. **Implement.** Function header with PHYSICAL CONTEXT, THEORY (document section/equation),
   Inputs/Outputs with units and frames, ASSUMPTIONS, an `Example` that starts from the parameters file,
   `See also`. Then `arguments` block, `requireFields`, and `assert` with identifiers like
   `Project:fn:Reason` whose messages say *why* in theory terms.
4. **Parameters.** New values go into the parameters file with `[unit]` comments and into the block's
   sub-struct; never as defaults in the function. Every parameter that a user might tune is discussed
   before it is added (decision protocol).
5. **Verify.** Static check (`checkcode` / `check_matlab_code`), then the block's test and any case that
   runs under a minute. Report numbers, not adjectives.
6. **Document the block.** Folder README from `templates/docs/BLOCK_README.md`, update the traceability
   matrix row and the `THEORY` section index.
7. **Stop.** Show what changed, the verification result, and the one question the user's judgement is
   needed on. Wait for "next".

## Rules of the road
- One logical block per turn. If a block turns out to hide complexity, say so and split it.
- Marker comments for modifications of existing code: `% [NEW]` / `% [CHANGED]` with a one-line why, if
  the project uses them.
- Do not "fix" unexpected results by adjusting tolerances or parameters. Report the discrepancy; it may
  be a modelling issue that is the user's call.
- Anything that needs a plot: ask the journal-target question first (coding standards, plotting §0).
- Long runs: write the script, check it statically, hand it to the user. See SKILL.md principle 6.
- Bugs found later (demo, review) come back here as logged items with a regression test.
- **Time the tests.** Print the duration of the suite and of the slowest test; a single test that exercises
  an impossible request (an exhausted search, a huge input) can cost most of the minute. Make such a test
  ask for just enough to fail, and call the function once, not twice.
- **Keep the path clean.** Remove the folders of earlier or toy projects from the MATLAB path (`which name -all`
  shows copies of a function): a stale function with the same name answers in place of yours and the failure
  looks like a bug in the new code.
- Comparing structs that contain `NaN`: `isequal` says NaN differs from NaN, `isequaln` does not (and
  `verifyEqual` already treats them as equal). A check in the demo built on `isequal` can print a false alarm.
- A default left in a signature (for example an optional-argument sentinel) is still a default: say so and let
  the user decide, rather than reporting "no defaults".

## Exit
Block test green, README and matrix updated, user says next. After the last block, run the whole test
suite once and record the count with the date in `STATE.md`.
