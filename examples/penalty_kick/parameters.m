% PARAMETERS  All parameters of the penalty_kick example, in one struct PAR.
%
%   Values only, each with its unit and a short label. Meaning, consumer and
%   constraints of every field live in docs (PARAMETERS.md).
%
%   Functions of the model receive the sub-structs they need (for example
%   kickImpact(shot, par.ball, par.kick)) and have no internal defaults: to
%   change a parameter, change PAR here or in a script before the call.
%
%   Frame (D10): origin on the ground at the penalty mark, x to the goal, y to
%   the left looking at the goal, z up. The ball centre starts at (0, 0, radius).
%
%   Usage:
%       run('parameters.m');   % creates the struct par in the caller
%
% See also: KICKIMPACT, FLIGHTDYNAMICS, CLASSIFYSHOT, REQUIREFIELDS

% Start from scratch at every run: in a second run in the same session (or in
% the Live Editor) fields of an earlier version would otherwise survive.
par = struct();

%% 1. BALL (Laws of the Game: circumference 68-70 cm, mass 410-450 g)
par.ball.mass_kg       = 0.43;     % [kg] ball mass
par.ball.radius_m      = 0.11;     % [m] ball radius (circumference 0.69 m)
par.ball.inertiaFactor = 2/3;      % [-] I = inertiaFactor * m * R^2 (2/3 = thin spherical shell)

%% 2. KICK (limits of the admissible shots; our choices, not measurements)
par.kick.maxOffset         = 0.8;        % [-] largest impact offset, fraction of radius (a foot cannot hit the very edge)
par.kick.impulseRange_Ns   = [3 15];     % [N s] admissible impulse magnitude [min max] (3 -> 7 m/s, 15 -> 35 m/s)
par.kick.azimuthRange_deg  = [-45 45];   % [deg] admissible aim azimuth [min max], towards +y positive
par.kick.elevationRange_deg = [1 60];    % [deg] admissible aim elevation [min max], upwards positive (0 would start the ball into the ground)

%% 3. FLIGHT (ILLUSTRATIVE coefficients, not from a source: decision D9)
par.flight.gravity_ms2     = 9.81;   % [m/s^2] gravitational acceleration
par.flight.airDensity_kgm3 = 1.2;    % [kg/m^3] air density
par.flight.dragCoeff       = 0.25;   % [-] drag coefficient Cd, constant. ILLUSTRATIVE (D9)
par.flight.liftSlope       = 0.5;    % [-] Cl = liftSlope * S for small spin parameter S. ILLUSTRATIVE (D9); 1.0 saturated at offset 0.2 and flattened the demo
par.flight.liftMax         = 0.35;   % [-] upper bound of Cl. ILLUSTRATIVE (D9)
par.flight.tMax_s          = 10;     % [s] longest flight accepted before an error
par.flight.relTol          = 1e-9;   % [-] relative tolerance of ode45
par.flight.absTol          = 1e-10;  % [m, m/s] absolute tolerance of ode45
par.flight.outputStep_s    = 0.005;  % [s] spacing of the samples returned in the trajectory

%% 4. GOAL (Laws of the Game)
par.goal.penaltyDistance_m = 11;     % [m] distance from the penalty mark to the goal line
par.goal.width_m           = 7.32;   % [m] distance between the inner edges of the posts
par.goal.height_m          = 2.44;   % [m] ground to the lower edge of the crossbar
par.goal.postWidth_m       = 0.12;   % [m] side of the square section of posts and crossbar

%% 5. DEFAULT SHOT (starting point of the demo section "Your shot")
par.shot.offsetLateral  = -0.2;      % [-] impact point along the kick's left axis, fraction of radius (positive = left of centre)
par.shot.offsetVertical = -0.1;      % [-] impact point along the kick's up axis, fraction of radius (positive = above centre)
par.shot.impulse        = 10.5;      % [N s] impulse magnitude J (about 24 m/s for this ball)
par.shot.aimAzimuth     = 0;         % [deg] aim azimuth, towards +y positive
par.shot.aimElevation   = 8;         % [deg] aim elevation, upwards positive

%% 6. ANIMATION OF THE TRAJECTORY (only drawing, no physics)
par.animation.slowMotion      = 0.2;       % [-] playback speed relative to real time (0.2 = five times slower)
par.animation.framesPerSecond = 30;        % [1/s] frames shown per second of playback
par.animation.ballDrawScale   = 4;         % [-] the ball is drawn this many times larger than its real radius, to be visible
