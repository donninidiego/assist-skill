function requireFields(s, fieldNames, ownerName)
% REQUIREFIELDS Check that a parameter struct contains the required fields.
%
%   REQUIREFIELDS(S, FIELDNAMES, OWNERNAME) raises an error if S lacks any of
%   FIELDNAMES. The message names the missing field and the function that asked
%   for it, so a parameter forgotten in parameters.m is found at once.
%
%   Model functions receive their parameters as structs (for example par.ball)
%   and have no internal defaults: the only source of values is parameters.m.
%
%   Inputs:
%       s          - parameter struct, for example par.ball
%       fieldNames - string array of mandatory fields
%       ownerName  - name of the calling function, for the message
%
%   Example:
%       run('parameters.m');
%       requireFields(par.ball, ["mass_kg", "radius_m"], "kickImpact");
%
%   See also: KICKIMPACT

arguments
    s          (1,1) struct
    fieldNames       string
    ownerName  (1,1) string
end

missing = fieldNames(~isfield(s, fieldNames));
assert(isempty(missing), 'PenaltyKick:requireFields:MissingParameter', ...
    '[%s] missing parameters: %s. Add them to parameters.m.', ...
    ownerName, strjoin(missing, ', '));

end
