function traj = flightDynamics(launch, parBall, parFlight, parGoal)
% FLIGHTDYNAMICS Path of the spinning ball under gravity, drag and the Magnus force.
%
%   TRAJ = FLIGHTDYNAMICS(LAUNCH, PARBALL, PARFLIGHT, PARGOAL) integrates the
%   motion of the ball centre from the launch state until the ball reaches the
%   goal plane or falls back to the ground, whichever comes first.
%
%   PHYSICAL CONTEXT:
%   Three forces act on the ball. Gravity pulls it down. The air resists the
%   motion (drag), always against the velocity and growing with its square.
%   Because the ball spins, the air also pushes it sideways (Magnus force),
%   perpendicular to both the spin axis and the velocity: backspin lifts the ball,
%   side spin curves it. The Magnus force is perpendicular to the velocity, so it
%   changes the direction of the ball but does no work.
%
%       m dv/dt = -m g z^ - (1/2) rho Cd A |v| v + (1/2) rho Cl A |v|^2 (omega^ x v^)
%
%   with A = pi R^2 the cross-section, omega^ and v^ unit vectors, and Cl from
%   liftCoefficient as a function of S = R|omega|/|v|. The spin is held constant.
%
%   THEORY:
%   T2 (forces on a spinning ball). Goff & Carre (2010) and Goff et al. (2017) are
%   the sources for the form of the coefficients; the values used here are
%   ILLUSTRATIVE (decision D9). The assertions below exist because a flight with
%   no event within tMax_s would return a truncated path that block 3 would
%   misjudge.
%
%   Inputs:
%       launch    - struct, as returned by kickImpact: .position [3x1] m,
%                   .velocity [3x1] m/s, .spin [3x1] rad/s (world frame)
%       parBall   - par.ball, uses .mass_kg [kg], .radius_m [m]
%       parFlight - par.flight, uses .gravity_ms2 [m/s^2], .airDensity_kgm3 [kg/m^3],
%                   .dragCoeff [-], .liftSlope [-], .liftMax [-], .tMax_s [s],
%                   .relTol [-], .absTol [m, m/s], .outputStep_s [s]
%       parGoal   - par.goal, uses .penaltyDistance_m [m] (goal plane x = d)
%
%   Outputs:
%       traj - struct with fields
%                  .t         time samples [1xN] s, spaced by outputStep_s, last = event time
%                  .position  ball centre [3xN] m, world frame
%                  .velocity  [3xN] m/s, world frame
%                  .spin      omega [3x1] rad/s, constant
%                  .endReason "goalPlane" or "ground"
%
%   ASSUMPTIONS:
%   1. Spin constant along the flight (no decay).
%   2. Cd constant: the drop of Cd at higher speed (drag crisis) is not modelled.
%   3. Cl depends only on S. No wind. The ground is the plane z = R.
%   4. The flight ends at x = d going forward, or at z = R going down.
%
%   Example:
%       run('parameters.m');
%       launch = kickImpact(par.shot, par.ball, par.kick);
%       traj = flightDynamics(launch, par.ball, par.flight, par.goal);
%       plot3(traj.position(1,:), traj.position(2,:), traj.position(3,:))
%
%   See also: KICKIMPACT, CLASSIFYSHOT, LIFTCOEFFICIENT, ODE45

arguments
    launch    (1,1) struct
    parBall   (1,1) struct
    parFlight (1,1) struct
    parGoal   (1,1) struct
end

requireFields(launch, ["position", "velocity", "spin"], "flightDynamics");
requireFields(parBall, ["mass_kg", "radius_m"], "flightDynamics");
requireFields(parFlight, ["gravity_ms2", "airDensity_kgm3", "dragCoeff", "liftSlope", ...
    "liftMax", "tMax_s", "relTol", "absTol", "outputStep_s"], "flightDynamics");
requireFields(parGoal, "penaltyDistance_m", "flightDynamics");

R = parBall.radius_m;                       % [m]
d = parGoal.penaltyDistance_m;              % [m] goal plane x = d
omega = launch.spin(:);                     % [rad/s]

k.mass    = parBall.mass_kg;                % [kg]
k.radius  = R;                              % [m]
k.area    = pi*R^2;                         % [m^2] cross-section
k.gravity = parFlight.gravity_ms2;          % [m/s^2]
k.rho     = parFlight.airDensity_kgm3;      % [kg/m^3]
k.cd      = parFlight.dragCoeff;            % [-]
k.flight  = parFlight;                      % passed on to liftCoefficient

y0   = [launch.position(:); launch.velocity(:)];          % [m; m/s]
opts = odeset('RelTol', parFlight.relTol, 'AbsTol', parFlight.absTol, ...
    'Events', @(~, y) flightEvents(y, R, d));
sol  = ode45(@(~, y) [y(4:6); ballAcceleration(y(4:6), omega, k)], ...
    [0, parFlight.tMax_s], y0, opts);

assert(~isempty(sol.ie), 'PenaltyKick:flightDynamics:NoEvent', ...
    ['[flightDynamics] the ball neither reached the goal plane nor the ground within ' ...
    '%.1f s: a truncated path would be misjudged.'], parFlight.tMax_s);

tEnd = sol.x(end);                                         % [s] time of the terminal event
t    = 0:parFlight.outputStep_s:tEnd;
if tEnd - t(end) > eps(tEnd)
    t(end+1) = tEnd;                                       % always end exactly on the event
end
y = deval(sol, t);

traj.t         = t;
traj.position  = y(1:3, :);
traj.velocity  = y(4:6, :);
traj.spin      = omega;
endNames       = ["ground", "goalPlane"];                  % event 1 = ground, event 2 = goal plane
traj.endReason = endNames(sol.ie(end));

end

function a = ballAcceleration(v, omega, k)
% BALLACCELERATION Acceleration of the ball centre [m/s^2] for velocity v and spin omega.
speed = norm(v);                                           % [m/s]
a = [0; 0; -k.gravity] ...                                 % gravity
    - (k.rho * k.cd * k.area / (2*k.mass)) * speed * v;    % drag
omegaNorm = norm(omega);                                   % [rad/s]
if omegaNorm > 0 && speed > 0                              % without spin the Magnus force is zero
    S  = k.radius * omegaNorm / speed;                     % [-] spin parameter
    cl = liftCoefficient(S, k.flight);                     % [-]
    a  = a + (k.rho * k.area * cl / (2*k.mass)) * speed * cross(omega/omegaNorm, v);   % Magnus
end
end

function [value, isterminal, direction] = flightEvents(y, R, d)
% FLIGHTEVENTS Ground (z = R, going down) and goal plane (x = d, going forward).
value      = [y(3) - R; y(1) - d];
isterminal = [1; 1];
direction  = [-1; +1];
end
