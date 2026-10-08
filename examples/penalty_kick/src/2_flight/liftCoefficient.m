function cl = liftCoefficient(S, parFlight)
% LIFTCOEFFICIENT Lift coefficient of the spinning ball from its spin parameter.
%
%   CL = LIFTCOEFFICIENT(S, PARFLIGHT) returns the lift coefficient Cl used by
%   the Magnus force in flightDynamics.
%
%   PHYSICAL CONTEXT:
%   A spinning ball drags a thin layer of air around with it and deflects the
%   flow: the faster the surface turns compared with the flight speed, the larger
%   the sideways force. The ratio is the spin parameter S = R*|omega|/|v| (surface
%   speed over flight speed). The coefficient grows with S and then levels off.
%
%       Cl = min(liftSlope * S, liftMax)           [-]
%
%   This is the one place where the lift law lives, so it can be replaced when the
%   coefficients are taken from a source (decision D9).
%
%   THEORY:
%   Sources: see REFERENCES.md (lift written as Cl (rho V^2/2) A; the Cl(S) curve itself is not sourced yet).
%   T2, force model of block 2. The linear-then-saturating shape is a placeholder
%   chosen for its qualitative behaviour; the real Cl(S) curve is in Goff & Carre
%   (2010), not yet checked against the text. The values are ILLUSTRATIVE (D9).
%
%   Inputs:
%       S          - spin parameter [-], scalar, >= 0
%       parFlight  - par.flight, uses .liftSlope [-] and .liftMax [-]
%
%   Outputs:
%       cl - lift coefficient [-]
%
%   ASSUMPTIONS:
%   1. Cl depends only on S (not on the Reynolds number).
%   2. Cl is never negative: no reverse Magnus effect.
%
%   Example:
%       run('parameters.m');
%       cl = liftCoefficient(0.2, par.flight)   % liftSlope*0.2 = 0.2 for the default values
%
%   See also: FLIGHTDYNAMICS

arguments
    S          (1,1) double {mustBeNonnegative}
    parFlight  (1,1) struct
end

requireFields(parFlight, ["liftSlope", "liftMax"], "liftCoefficient");

cl = min(parFlight.liftSlope * S, parFlight.liftMax);

end
