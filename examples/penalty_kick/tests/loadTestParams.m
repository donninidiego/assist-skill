function par = loadTestParams()
% LOADTESTPARAMS Struct PAR of parameters.m, the starting point of every test.
%
%   PAR = LOADTESTPARAMS() runs parameters.m and returns its struct. Every test
%   starts from the real values and changes only the fields it verifies: a test
%   therefore never hides a parameter forgotten in parameters.m.
%
%   Example:
%       par = loadTestParams();
%       par.flight.dragCoeff = 0;
%
%   See also: PARAMETERS

here = fileparts(mfilename('fullpath'));
par  = struct();                              % overwritten by the script
run(fullfile(here, '..', 'parameters.m'));    % creates par in this workspace

end
