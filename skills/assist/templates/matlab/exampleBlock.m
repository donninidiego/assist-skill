function kFactor = exampleBlock(grid, example)
% EXAMPLEBLOCK Factor that favours a preferred altitude (header template).
%
%   KFACTOR = EXAMPLEBLOCK(GRID, EXAMPLE) returns a factor equal to
%   EXAMPLE.GAIN at the altitude GRID.REF_ALTITUDE_M that decreases to 1 at a
%   distance EXAMPLE.WIDTH_M, with a parabolic profile.
%
%   This file is the reference for the function header of /assist projects:
%   replace the physics, keep the sections.
%
%   PHYSICAL CONTEXT:
%   Say what the quantity means physically and why the block exists, in terms
%   a researcher can defend. Here: the vehicle flies preferably at one
%   altitude; where the factor exceeds 1, flying costs less.
%
%       t       = (z - h_ref) / width_m            z: altitude [m]
%       kFactor = 1 + (gain - 1) * max(0, 1 - t^2)
%
%   State the formula with units, the shape of the profile and where it stops
%   having an effect.
%
%   THEORY:
%   Where the formula comes from and which condition the theory imposes on the
%   parameters: THEORY.md sec. F, Eq. (7'); [Author, Year, Eq. 3.2]. Say here why
%   the assertions below exist ("with gain = 0 the condition K > 0 would fail").
%
%   Inputs:
%       grid    - struct with fields
%                     .z_levels      altitude of each level [m], column vector
%                     .ref_altitude_m preferred altitude [m]
%       example - par.example, uses:
%           .gain     - factor at the preferred altitude [-], > 0
%           .width_m  - half-width of the layer [m], > 0
%
%   Outputs:
%       kFactor - factor [-], one value per level [nLev x 1]
%
%   ASSUMPTIONS:
%   1. Absolute altitude: z is the altitude of the level, not height above ground.
%   2. The factor depends only on altitude (same on every column).
%
%   Example:
%       run('parameters.m');
%       g.z_levels       = (0:par.domain.dz_m:par.domain.max_altitude_m)';
%       g.ref_altitude_m = par.domain.ref_altitude_m;
%       k = exampleBlock(g, par.example);
%       plot(g.z_levels, k)   % rises to gain at ref_altitude_m, back to 1 beyond
%
%   See also: REQUIREFIELDS

arguments
    grid    (1,1) struct
    example (1,1) struct
end

requireFields(example, ["gain", "width_m"], "exampleBlock");
assert(example.gain > 0, 'Project:exampleBlock:InvalidGain', ...
    '[exampleBlock] gain must be positive: with 0 the condition K > 0 would fail.');
assert(example.width_m > 0, 'Project:exampleBlock:InvalidWidth', ...
    '[exampleBlock] width_m must be positive.');

t       = (grid.z_levels(:) - grid.ref_altitude_m) / example.width_m;   % [-] per level
kFactor = 1 + (example.gain - 1) * max(0, 1 - t.^2);

end
