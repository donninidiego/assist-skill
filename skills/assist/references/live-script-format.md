# Plain-text Live Script format (MATLAB R2025a+)

A `.m` file in Live Code format is rendered by the Live Editor only if it meets three requirements.
Break one and MATLAB opens it as an ordinary script, with raw `%[text]` markers on screen — a symptom
that does not point at the cause. If the `matlab-core:matlab-create-live-script` skill is available,
load it as well; this file records what was learned in practice.

## The three requirements
1. **Complete appendix block at the end of the file**, exactly:
   ```
   %[appendix]{"version":"1.0"}
   %---
   %[metadata:view]
   %   data: {"layout":"inline"}
   %---
   ```
   `%[appendix]` alone is not enough.
2. **One single blank line in the whole file**, immediately before the appendix. This is the least
   intuitive requirement and the easiest to break when writing by hand — including between local
   functions. Use a comment line, not an empty line, to separate things.
3. **No explicit `figure` command.** The figure is created by the first `plot`; take its handle with
   `gcf`.

## Syntax in short
| Element | Written as |
|---|---|
| Section break | `%%` |
| Text line | `%[text] markdown here` (headings `## Title`, lists, tables) |
| Table | rows `%[text] \| a \| b \|` wrapped between `%[text:table]` lines |
| Table of contents | `%[text:tableOfContents]{"heading":"Contents"}` |
| Math (inline) | `$ ... $` with **doubled backslashes**: `$ \\nabla \\cdot ( k \\nabla \\varphi ) = 0 $` |
| Escapes in math/text | `_` → `\_`, `<` → `\<`, `>` → `\>`, `\|` for a bar inside a table cell |
| Code | plain MATLAB lines between text cells |
| Local functions | at the end of the file, after the last `%%`, before the appendix |

Do not write `%[output:...]` tags by hand: they are produced by MATLAB when the script is run in the
editor. Invented tags mislead.

## How to verify (and what does *not* verify)
Ask the editor to save the file as `.mlx`. If MATLAB recognized it as a Live Script, the result is a
binary archive that starts with `PK`; otherwise it is text with the wrong extension.

```matlab
ed = matlab.desktop.editor.openDocument(src, Visible=0);
ed.saveAs(fullfile(tempdir, 'probe.mlx')); ed.closeNoPrompt;
fid = fopen(fullfile(tempdir, 'probe.mlx')); hdr = fread(fid, 2, '*char')'; fclose(fid);   % 'PK' = valid
```
`export(src, ..., 'Format', 'markdown')` is **not** a valid test: it accepts files that the Live Editor
then shows raw.

To check what the figures really show, export to HTML **with execution**:
`export(file, out.html, Run=true)`. It runs the file in *its own folder*; for a low-resolution copy,
write the copy inside the examples folder and delete it afterwards (not with `onCleanup`, which
`export` triggers early). Look at the figures: captions must not claim what is not drawn.

## Practical traps
- **The Live Editor can overwrite your version.** If the user has the file open, their editor may save
  an older copy (possibly with embedded outputs, tens of MB). After rewriting a Live Script: check size
  and headers with `grep` before editing again, keep a copy in the scratchpad, and tell the user to
  close the tab **without saving**.
- **Start every plotting section with `tiledlayout`** (for a single plot: `tiledlayout(1, 1); nexttile`). The
  Live Editor gives a section its own figure only when the first call is `tiledlayout`; a section that begins
  with `plot`, `surf`, `hold on` or `show3D` draws over the previous figure. For `show3D` pass the tile:
  `show3D(scenario, 'Parent', nexttile)`.
- The Live Editor does not change the current folder: locate `parameters.m` from `pwd` (examples/ or
  the project root), as the template does.
- Reset `par = struct()` at the start of the parameters file: a second run in the same session would
  otherwise keep fields of an older version.
- Keep cells short and commented. Long runs: give a parameter that lowers resolution for a quick pass.
- Template: `templates/matlab/Walkthrough.m` (valid; verified by the `PK` test above).
