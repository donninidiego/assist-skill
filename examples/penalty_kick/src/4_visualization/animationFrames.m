function frames = animationFrames(traj, parAnimation)
% ANIMATIONFRAMES Instants, positions and spin angles for the slow-motion animation.
%
%   FRAMES = ANIMATIONFRAMES(TRAJ, PARANIMATION) picks evenly spaced instants of the real
%   flight, from the launch to the last sample of the path, and returns where the
%   ball is and how far it has turned at each of them.
%
%   PHYSICAL CONTEXT:
%   A kick that lasts half a second is too fast to follow, so the animation plays it
%   slowly: the real flight of duration T is shown in T/slowMotion seconds at
%   framesPerSecond frames per second. The ball turns about the fixed spin axis at
%   the constant rate |omega| of the model, so after the real time t its angle is
%   |omega|*t. This function only samples the path; it has no physics of its own.
%
%       duration = T / slowMotion                    [s] playback time
%       nFrames  = ceil(duration*fps) + 1            [-]
%       angle(t) = |omega| * t                       [rad]
%
%   THEORY:
%   None beyond block 2 (constant spin, T2). The assertions exist because a
%   non-positive speed or frame rate would give an infinite or empty animation.
%
%   Inputs:
%       traj   - struct from flightDynamics: .t [1xN] s, .position [3xN] m, .spin [3x1] rad/s
%       parAnimation - par.animation, uses .slowMotion [-] (> 0) and .framesPerSecond [1/s] (> 0)
%
%   Outputs:
%       frames - struct with fields
%                    .time            real flight time of each frame [1xM] s
%                    .position        ball centre at each frame [3xM] m
%                    .spinAxis        unit vector of the spin axis [3x1] (z if there is no spin)
%                    .spinAngle       angle turned since the launch [1xM] rad
%                    .playbackSeconds duration of the playback [s]
%                    .framesPerSecond frame rate of the playback [1/s]
%
%   ASSUMPTIONS:
%   1. The position between two samples of the path is linear (the samples are 5 ms apart).
%   2. The spin is constant along the flight (as in block 2).
%
%   Example:
%       run('parameters.m');
%       [~, traj] = takeShot(par.shot, par);
%       frames = animationFrames(traj, par.animation);
%       plot3(frames.position(1,:), frames.position(2,:), frames.position(3,:), '.')
%
%   See also: ANIMATESHOT, FLIGHTDYNAMICS

arguments
    traj   (1,1) struct
    parAnimation (1,1) struct
end

requireFields(traj, ["t", "position", "spin"], "animationFrames");
requireFields(parAnimation, ["slowMotion", "framesPerSecond"], "animationFrames");
assert(parAnimation.slowMotion > 0 && parAnimation.framesPerSecond > 0, 'PenaltyKick:animationFrames:InvalidParameter', ...
    '[animationFrames] slowMotion and framesPerSecond must be positive: otherwise the animation would be endless or empty.');

flightTime = traj.t(end);                                          % [s] real duration of the flight
duration   = flightTime / parAnimation.slowMotion;                       % [s] playback duration
nFrames    = ceil(duration * parAnimation.framesPerSecond) + 1;          % [-]

frames.time     = linspace(0, flightTime, nFrames);                % [s] real time of each frame
frames.position = interp1(traj.t, traj.position', frames.time, 'linear')';   % [m]

spinRate = norm(traj.spin);                                        % [rad/s]
if spinRate > 0
    frames.spinAxis = traj.spin(:) / spinRate;
else
    frames.spinAxis = [0; 0; 1];                                   % any axis: the angle is zero
end
frames.spinAngle       = spinRate * frames.time;                   % [rad]
frames.playbackSeconds = duration;
frames.framesPerSecond = parAnimation.framesPerSecond;

end
