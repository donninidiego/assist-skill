function launch = kickImpact(shot, parBall, parKick)
% KICKIMPACT Initial velocity and spin of the ball from where and how hard it is kicked.
%
%   LAUNCH = KICKIMPACT(SHOT, PARBALL, PARKICK) turns the impact point on the
%   ball, the strength of the kick and the aim into the launch state of the
%   ball: position, velocity and angular velocity (spin).
%
%   PHYSICAL CONTEXT:
%   The foot gives the ball an impulse J (a force acting for a very short time)
%   in the direction d it is moving. If the line of the impulse passes through
%   the centre of the ball, the ball only translates. If it passes at a distance
%   r from the centre, the impulse also has a moment about the centre and the ball
%   starts to rotate: a hit below the centre gives backspin, a hit to the right of
%   the centre gives a counter-clockwise spin seen from above. The spin is what the
%   Magnus force in block 2 turns into a curved path.
%
%       v0     = J*d / m                          [m/s]
%       omega0 = (r x J*d) / I                    [rad/s]
%       I      = inertiaFactor * m * R^2          [kg m^2]  (2/3 for a thin shell)
%       r      = R*(oL*e_y + oV*e_z)              [m]       (offset in the kick frame)
%
%   Kick frame: d is the aim direction, e_y = (z x d)/|z x d| points to the left
%   of the kick, e_z = d x e_y points up. The part of r along d gives no moment
%   (it is parallel to J), so only the two offsets oL (lateral) and oV (vertical)
%   matter.
%
%   THEORY:
%   T1 (impulse and angular impulse of a rigid body). The assertions below exist
%   because an offset beyond the ball's edge has no physical meaning, and an aim
%   into the ground or away from the goal would make block 2 end at once.
%
%   Inputs:
%       shot    - struct with fields
%                     .offsetLateral  impact point to the left of centre [-] (fraction of R)
%                     .offsetVertical impact point above the centre [-] (fraction of R)
%                     .impulse        impulse magnitude J [N s]
%                     .aimAzimuth     aim azimuth, towards +y positive [deg]
%                     .aimElevation   aim elevation, upwards positive [deg]
%       parBall - par.ball, uses .mass_kg [kg], .radius_m [m], .inertiaFactor [-]
%       parKick - par.kick, uses .maxOffset [-], .impulseRange_Ns [N s],
%                 .azimuthRange_deg [deg], .elevationRange_deg [deg]
%
%   Outputs:
%       launch - struct with fields
%                    .position        ball centre [m], world frame [3x1]
%                    .velocity        v0 [m/s], world frame [3x1]
%                    .spin            omega0 [rad/s], world frame [3x1]
%                    .speedEquivalent |v0| = J/m [m/s], shown next to the impulse
%
%   ASSUMPTIONS:
%   1. The impulse has the foot's direction and friction is enough to transmit it
%      (decision D7). A frictionless normal impulse could never produce spin.
%   2. The ball is a rigid thin spherical shell and the contact is instantaneous.
%   3. The ball starts on the penalty mark, centre at one radius above the ground.
%   4. World frame (D10): x to the goal, y to the left, z up.
%
%   Example:
%       run('parameters.m');
%       launch = kickImpact(par.shot, par.ball, par.kick);
%       launch.spin   % small backspin and side spin for the default shot
%
%   See also: FLIGHTDYNAMICS, REQUIREFIELDS

arguments
    shot    (1,1) struct
    parBall (1,1) struct
    parKick (1,1) struct
end

requireFields(shot, ["offsetLateral", "offsetVertical", "impulse", ...
    "aimAzimuth", "aimElevation"], "kickImpact");
requireFields(parBall, ["mass_kg", "radius_m", "inertiaFactor"], "kickImpact");
requireFields(parKick, ["maxOffset", "impulseRange_Ns", "azimuthRange_deg", ...
    "elevationRange_deg"], "kickImpact");

offsetNorm = hypot(shot.offsetLateral, shot.offsetVertical);   % [-] distance of the impact point from the centre
assert(offsetNorm <= parKick.maxOffset, 'PenaltyKick:kickImpact:OffsetOutOfRange', ...
    ['[kickImpact] impact offset %.3f of the radius exceeds the allowed %.3f: ' ...
    'a hit near the edge of the ball is not a kick.'], offsetNorm, parKick.maxOffset);
assert(shot.impulse >= parKick.impulseRange_Ns(1) && shot.impulse <= parKick.impulseRange_Ns(2), ...
    'PenaltyKick:kickImpact:ImpulseOutOfRange', ...
    '[kickImpact] impulse %.2f N s is outside [%.1f, %.1f] N s.', ...
    shot.impulse, parKick.impulseRange_Ns(1), parKick.impulseRange_Ns(2));
assert(shot.aimAzimuth >= parKick.azimuthRange_deg(1) && shot.aimAzimuth <= parKick.azimuthRange_deg(2) ...
    && shot.aimElevation >= parKick.elevationRange_deg(1) && shot.aimElevation <= parKick.elevationRange_deg(2), ...
    'PenaltyKick:kickImpact:AimOutOfRange', ...
    ['[kickImpact] aim (azimuth %.1f, elevation %.1f deg) is outside the allowed ranges: ' ...
    'an aim into the ground or away from the goal would end the flight at once.'], ...
    shot.aimAzimuth, shot.aimElevation);

R = parBall.radius_m;                                          % [m]
m = parBall.mass_kg;                                           % [kg]
inertia = parBall.inertiaFactor * m * R^2;                     % [kg m^2]

az = shot.aimAzimuth;  el = shot.aimElevation;                 % [deg]
d  = [cosd(el)*cosd(az); cosd(el)*sind(az); sind(el)];         % [-] impulse direction, world frame
eY = cross([0; 0; 1], d);  eY = eY / norm(eY);                 % [-] left of the kick (el <= 60 deg, so norm > 0)
eZ = cross(d, eY);                                             % [-] up in the kick frame

r        = R * (shot.offsetLateral*eY + shot.offsetVertical*eZ);   % [m] impact point relative to the centre
impulse  = shot.impulse * d;                                       % [N s] impulse vector

launch.position        = [0; 0; R];
launch.velocity        = impulse / m;
launch.spin            = cross(r, impulse) / inertia;
launch.speedEquivalent = norm(launch.velocity);

end
