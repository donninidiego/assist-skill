function result = classifyShot(traj, parBall, parGoal)
% CLASSIFYSHOT What happened to the shot: GOAL, POST, CROSSBAR, WIDE, HIGH or SHORT.
%
%   RESULT = CLASSIFYSHOT(TRAJ, PARBALL, PARGOAL) judges the shot at the instant
%   the ball centre crosses the goal plane, or labels it SHORT if the ball fell
%   to the ground first.
%
%   PHYSICAL CONTEXT:
%   At the goal plane the ball is a disc of radius R centred at (y, z). The goal
%   is a frame: two posts and a crossbar, each of square section w, around an
%   opening of width W and height H. The disc is judged against the frame
%   (decision D11), mirrored in y so that the left and right posts are one case:
%
%       GOAL      the disc lies entirely inside the opening: |y| <= W/2 - R and z <= H - R
%       POST      else, the disc overlaps a post:  |y| in [W/2, W/2+w],  z in [0, H+w]
%       CROSSBAR  else, the disc overlaps the bar: |y| <= W/2+w,         z in [H, H+w]
%       WIDE      else, |y| > W/2 + w
%       HIGH      else (above the bar, between the posts)
%       SHORT     the ball reached the ground before the goal plane
%
%   "Overlaps" means the distance from the centre to the rectangle is less than R.
%   Where the disc touches both a post and the crossbar (the corner), the label is
%   POST: an arbitrary tie-break, declared.
%
%   THEORY:
%   T3 (plane geometry of D11). The assertion below exists because any other end
%   reason would leave the position at the plane undefined.
%
%   Inputs:
%       traj    - struct, as returned by flightDynamics: .t [1xN] s, .position [3xN] m,
%                 .endReason "goalPlane" or "ground"
%       parBall - par.ball, uses .radius_m [m]
%       parGoal - par.goal, uses .width_m [m], .height_m [m], .postWidth_m [m]
%
%   Outputs:
%       result - struct with fields
%                    .label      "GOAL" | "POST" | "CROSSBAR" | "WIDE" | "HIGH" | "SHORT"
%                    .yAtGoal    ball centre y at the goal plane [m] (NaN for SHORT)
%                    .zAtGoal    ball centre z at the goal plane [m] (NaN for SHORT)
%                    .flightTime time of the last sample [s]
%
%   ASSUMPTIONS:
%   1. The shot is judged at one instant, as a disc: the ball is a sphere, so its
%      cross-section at the plane is a disc.
%   2. No rebound: POST and CROSSBAR are reported, the ball does not bounce.
%   3. Posts and crossbar have a square section of side postWidth_m; the opening is
%      measured between the inner edges of the posts and from the ground to the lower
%      edge of the crossbar (Laws of the Game).
%   4. World frame (D10): y to the left, z up; the goal is centred on y = 0.
%
%   Example:
%       run('parameters.m');
%       launch = kickImpact(par.shot, par.ball, par.kick);
%       traj   = flightDynamics(launch, par.ball, par.flight, par.goal);
%       result = classifyShot(traj, par.ball, par.goal);
%       result.label
%
%   See also: FLIGHTDYNAMICS, TAKESHOT

arguments
    traj    (1,1) struct
    parBall (1,1) struct
    parGoal (1,1) struct
end

requireFields(traj, ["t", "position", "endReason"], "classifyShot");
requireFields(parBall, "radius_m", "classifyShot");
requireFields(parGoal, ["width_m", "height_m", "postWidth_m"], "classifyShot");
assert(any(traj.endReason == ["goalPlane", "ground"]), 'PenaltyKick:classifyShot:UnknownEndReason', ...
    '[classifyShot] endReason "%s" is neither "goalPlane" nor "ground": the position at the goal plane is undefined.', ...
    traj.endReason);

result.flightTime = traj.t(end);                            % [s]

if traj.endReason == "ground"
    result.label   = "SHORT";
    result.yAtGoal = NaN;
    result.zAtGoal = NaN;
    return
end

y = traj.position(2, end);  z = traj.position(3, end);      % [m] ball centre at the goal plane
result.yAtGoal = y;
result.zAtGoal = z;

R = parBall.radius_m;  W = parGoal.width_m;  H = parGoal.height_m;  w = parGoal.postWidth_m;   % [m]
yAbs = abs(y);                                              % mirror: left and right posts are one case

if yAbs <= W/2 - R && z <= H - R
    result.label = "GOAL";
elseif rectDistance(yAbs, z, W/2, W/2 + w, 0, H + w) < R
    result.label = "POST";
elseif rectDistance(yAbs, z, 0, W/2 + w, H, H + w) < R
    result.label = "CROSSBAR";
elseif yAbs > W/2 + w
    result.label = "WIDE";
else
    result.label = "HIGH";
end

end

function dist = rectDistance(y, z, yMin, yMax, zMin, zMax)
% RECTDISTANCE Distance [m] from the point (y, z) to the rectangle [yMin yMax] x [zMin zMax] (0 inside).
dist = hypot(max([yMin - y, 0, y - yMax]), max([zMin - z, 0, z - zMax]));
end
