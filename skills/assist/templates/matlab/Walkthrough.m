%[text] # Project walkthrough: step by step
%[text] This demo runs the chain of blocks **one step at a time**. Every step adds one element to the model and has the same four parts:
%[text] 1. the **geometry or inputs**: what is fed into the block, before any effect is shown;
%[text] 2. the **run**: the block is called with its sub-struct of `par`;
%[text] 3. the **result**: the field in 3D and 2D when it is spatial, with a printed numeric check;
%[text] 4. the **entry into the next block**: how this output is used downstream. \
%[text] **Run time:** state here how long the demo takes and which parameters give a quick pass.
%[text] The formulation follows `THEORY.md`; every number printed below is measured, not assumed.
%[text:tableOfContents]{"heading":"Contents"}
%%
%[text] ## The idea on one page
%[text] Describe the physical picture first, in researcher language, with every acronym expanded. Then the chain of blocks:
%[text:table]
%[text] | Block | Folder | Role |
%[text] | --- | --- | --- |
%[text] | 1 | `src/1_input` | data in |
%[text] | 2 | `src/2_model` | the model factors |
%[text] | 3 | `src/3_solver` | the computation |
%[text:table]
%[text] Equations go in math cells with doubled backslashes and escaped symbols, for example $ k(z) = 1 + (g - 1)\\,\\max(0,\\,1 - t^2), \\quad t = (z - h\_{ref}) / w $, and conditions such as $ k \> 0 $.
%%
%[text] ## Setup
%[text] `par` (created by `parameters.m`) holds all parameters, in sub-structs that follow the chain.
tStart = tic;
% The Live Editor does not change the current folder: parameters.m is searched from pwd, which must be examples/ or the project root.
repoRoot = fileparts(pwd);
if ~isfile(fullfile(repoRoot, 'parameters.m'))
    cand = {pwd, fileparts(pwd)};
    ok   = cellfun(@(d) isfile(fullfile(d, 'parameters.m')), cand);
    assert(any(ok), 'Current folder not recognized: set the project examples/ folder as current folder.');
    repoRoot = cand{find(ok, 1)};
end
addpath(genpath(fullfile(repoRoot, 'src')));   % every folder of src/ at once
run(fullfile(repoRoot, 'parameters.m'));       % (re)builds the struct par from the parameters file
steps = {};                                    % one entry per step, for the final comparison
%%
%[text] ## Step 1: the domain
%[text] **Inputs first.** The altitude levels the block will see, before any factor is computed.
% ─── Parameters used here (same values as parameters.m) ────────────────────────
par.domain.dz_m           = 5;      % [m] vertical step
par.domain.max_altitude_m = 300;    % [m] top of the domain
par.domain.ref_altitude_m = 150;    % [m] preferred altitude
grid.z_levels       = (0:par.domain.dz_m:par.domain.max_altitude_m)';   % [m] altitude of each level
grid.ref_altitude_m = par.domain.ref_altitude_m;                        % [m] preferred altitude
fprintf('[Step1] levels: %d, from %g m to %g m\n', numel(grid.z_levels), grid.z_levels(1), grid.z_levels(end));
plot(grid.z_levels, zeros(size(grid.z_levels)), 'k.');
xlabel('Altitude [m]'); title('Levels of the domain')
%[text] **What to observe:** evenly spaced levels covering the domain, one point per level. If they are not, the block downstream receives a wrong grid.
%%
%[text] ## Step 2: the example block
%[text] **Idea.** The vehicle prefers one altitude. Where the factor $ k $ is above 1, flying costs less, so the paths gather in that layer. **Run.**
k = exampleBlock(grid, par.example);
steps{end+1} = recordStep("example block", grid, k);
plot(grid.z_levels, k, 'k-', 'LineWidth', 1.5);
xlabel('Altitude [m]'); ylabel('$k$ [-]', 'Interpreter', 'latex'); title('Factor versus altitude')
%[text] **What to observe:** a parabola peaking at the preferred altitude and flat at 1 beyond the layer width. A peak elsewhere or a value below 1 would be a bug.
%%
%[text] ## Numeric check
%[text] The check is printed, so the reader sees the value and what was expected.
[~, iRef] = min(abs(grid.z_levels - grid.ref_altitude_m));
fprintf('[Check] factor at preferred altitude: %.3f (expected %.3f)\n', k(iRef), par.example.gain);
assert(abs(k(iRef) - par.example.gain) < 1e-12, 'The factor at the preferred altitude must equal gain.');
%%
%[text] ## Result and comparison
%[text] One row per step: what each element changed.
disp(cellfun(@(s) describeStep(s), steps, 'UniformOutput', false)')
fprintf('Total time: %.1f s\n', toc(tStart));
%%
%[text] ## Key points
%[text] - Five lines the reader should keep after the demo.
%[text] - Each states a fact that was shown above, not a claim that was not measured.
%%
function s = recordStep(name, grid, k)
% RECORDSTEP Summary of one step, for the final table.
    s = struct('name', name, 'kMax', max(k), 'kMin', min(k), 'nLev', numel(grid.z_levels));
end
function line = describeStep(s)
% DESCRIBESTEP One-line summary of a recorded step.
    line = sprintf('%-18s k in [%.2f, %.2f] over %d levels', s.name, s.kMin, s.kMax, s.nLev);
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
