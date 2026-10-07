% PARAMETERS  All parameters of the project, in one struct PAR.
%
%   Values only, each with its unit and a short label. Meaning, consumer and
%   constraints of every field live in docs (PARAMETERS.md).
%
%   Functions of the model receive ONE sub-struct of PAR (for example
%   exampleBlock(grid, par.example)) and have no internal defaults: to change a
%   parameter, change PAR here or in a script before the call.
%
%   Usage:
%       run('parameters.m');   % creates the struct par in the caller
%
% See also: EXAMPLEBLOCK, REQUIREFIELDS

% Start from scratch at every run: in a second run in the same session (or in
% the Live Editor) fields of an earlier version would otherwise survive.
par = struct();

%% 1. DOMAIN
par.domain.max_altitude_m = 300;   % [m] top of the computational domain
par.domain.dz_m           = 5;     % [m] vertical step
par.domain.ref_altitude_m = 150;   % [m] preferred altitude

%% 2. EXAMPLE BLOCK
par.example.gain    = 2;           % [-] factor at the preferred altitude (> 0; > 1 favours it)
par.example.width_m = 50;          % [m] half-width of the preferred layer (> 0)

%% 3. SCENARIO (lists filled by scripts, typed empty here)
par.scenario.items = struct('name', {}, 'center_m', {});   % [-] one entry per scenario element
