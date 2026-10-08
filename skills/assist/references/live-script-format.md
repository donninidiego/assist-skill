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

## Interactive controls (checked on MATLAB R2026a Update 5)
A plain-text Live Script can hold sliders, dropdowns and buttons; the older note "controls are not supported in plain
text" is out of date for R2026a. Two parts are needed, as the editor itself writes them when it converts a `.mlx` that has
controls (the shipped example `toolbox/matlab/demos/SolarPanelEstimator.mlx` is a good reference):
1. **A tag at the end of the code line that holds the number**, after any comment:
   ```
   myShot.impulse = 11;   % [N s] strength %[control:slider:91d3]{"position":[18,20]}
   ```
   `position` is `[c1, c2]`: `c1` the 1-based column of the first character of the number, `c2 = c1 + length of the number`
   (a minus sign belongs to the number). The id (4 hex characters) is yours but must be unique in the file.
2. **An entry in the appendix**, after `%[metadata:view]`, one per control:
   ```
   %[control:slider:91d3]
   %   data: {"defaultValue":11,"label":"Strength, impulse J [N s]","max":15,"min":3,"run":"Section","runOn":"ValueChanged","step":0.5}
   %---
   ```
   `"run":"Section"` re-runs the section when the control changes; `"runOn":"ValueChanged"` does it when the slider is
   released, `"ValueChanging"` while it is dragged (use it only if the section is light). A button is a tag
   `%[control:button:ID]{"position":[1,2]}` on a line of its own with data `{"label":"...","run":"Section"}`.
Verification: save the file as `.mlx` through the editor (the `PK` test above) and count `livecontrol` elements in
`matlab/document.xml` of the archive; each one carries its minimum, maximum, step and run mode.

**One source of parameters.** A control cannot read `parameters.m`: its limits live in the file. Copy them, and add a test
that **reads the Live Script as text** and fails if the tag does not point at the number it controls, or if the limits
differ from the ranges in the parameters file (`tWalkthroughControls` in the penalty_kick example does this).

## LaTeX that the Live Editor does not render
The equation renderer shows these commands as red raw text; use the replacement:

| Do not use | Use |
|---|---|
| `\boldsymbol{\omega}` | `\mathbf{\omega}` |
| `\tfrac{a}{b}` | `\frac{a}{b}` |
| `\lvert x \rvert` | plain vertical bars: `|x|` in an equation (inside a table cell they must be written `\|x\|`) |
| `\text{word}` | `\mathrm{word}` |

Check by exporting to HTML with execution and looking at the equation images: `export(file, out.html, Run=true)`; the
images are the small PNGs embedded in the page.

## The Live Editor writes the outputs into the file
When the user runs a plain-text Live Script in the editor and saves it, the file gains `%[output:ID]` tags on the code
lines and one appendix entry per output with the figure as base64 (20 KB became 175 KB in the penalty_kick demo). The
code is unchanged. Decide with the user which copy goes into version control (normally the one without outputs), and
never strip or overwrite the saved copy without asking: it is their save.

## Animations
A loop that updates graphics objects and calls `drawnow` updates the output figure of the editor while it runs, so a
section can replay a motion. Keep the drawing in a function that takes a frame callback, so that a tool script can
record the same frames to a GIF without waiting for real time. A GIF keeps the palette of its first frame for
all the following ones: give it one fixed palette for the whole animation, or colours that only appear at the end (a
verdict in green or red) turn grey.
