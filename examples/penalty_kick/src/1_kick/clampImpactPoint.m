function shot = clampImpactPoint(shot, parKick)
% CLAMPIMPACTPOINT Move an impact point that lies beyond the admissible circle onto it.
%
%   SHOT = CLAMPIMPACTPOINT(SHOT, PARKICK) leaves SHOT unchanged if its impact point is
%   inside the circle of radius PARKICK.MAXOFFSET (a fraction of the ball radius), and
%   otherwise moves the point radially onto the circle, keeping its direction.
%
%   PHYSICAL CONTEXT:
%   The impact point is chosen with two independent sliders, each within +/- maxOffset.
%   Their corner (both at the limit) lies at 1.41 times maxOffset from the centre, a
%   place the foot cannot hit and that kickImpact refuses. Instead of refusing, the
%   demo moves the point to the nearest direction-preserving admissible one: the same
%   side of the ball, as far out as the foot reaches.
%
%   The scale carries a margin of four units in the last place: scaling exactly to
%   maxOffset/norm can leave the norm one unit above the limit, and kickImpact would
%   then raise the very error this function exists to avoid.
%
%   Inputs:
%       shot    - struct with .offsetLateral and .offsetVertical [-] (fraction of R), and any
%                 other field, which is returned untouched
%       parKick - par.kick, uses .maxOffset [-]
%
%   Outputs:
%       shot - the same struct, with the impact point inside or on the circle
%
%   ASSUMPTIONS:
%   1. The admissible region is a disc centred on the ball centre (as in kickImpact).
%
%   Example:
%       run('parameters.m');
%       shot = par.shot;  shot.offsetLateral = 0.8;  shot.offsetVertical = 0.8;
%       shot = clampImpactPoint(shot, par.kick);   % now on the circle of radius 0.8
%
%   See also: KICKIMPACT, REQUIREFIELDS

arguments
    shot    (1,1) struct
    parKick (1,1) struct
end

requireFields(shot, ["offsetLateral", "offsetVertical"], "clampImpactPoint");
requireFields(parKick, "maxOffset", "clampImpactPoint");

offsetNorm = hypot(shot.offsetLateral, shot.offsetVertical);        % [-]
if offsetNorm > parKick.maxOffset
    scale = parKick.maxOffset / offsetNorm * (1 - 4*eps);           % [-] margin: see header
    shot.offsetLateral  = shot.offsetLateral * scale;
    shot.offsetVertical = shot.offsetVertical * scale;
end

end
