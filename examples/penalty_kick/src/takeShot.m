function [result, traj, launch] = takeShot(shot, par)
% TAKESHOT Kick the ball: chain blocks 1 to 3 and return what happened.
%
%   [RESULT, TRAJ, LAUNCH] = TAKESHOT(SHOT, PAR) runs
%       kickImpact -> flightDynamics -> classifyShot
%   and returns the outcome of the shot, the path of the ball and the launch state.
%   It only passes data from block to block; the physics is in the blocks.
%
%   Inputs:
%       shot - struct with the five inputs of kickImpact (see there)
%       par  - the struct of parameters.m, with .ball, .kick, .flight and .goal
%
%   Outputs:
%       result - struct from classifyShot (.label, .yAtGoal, .zAtGoal, .flightTime)
%       traj   - struct from flightDynamics
%       launch - struct from kickImpact
%
%   Example:
%       run('parameters.m');
%       result = takeShot(par.shot, par);
%       disp(result.label)
%
%   See also: KICKIMPACT, FLIGHTDYNAMICS, CLASSIFYSHOT, PLOTSHOT

arguments
    shot (1,1) struct
    par  (1,1) struct
end

requireFields(par, ["ball", "kick", "flight", "goal"], "takeShot");

launch = kickImpact(shot, par.ball, par.kick);
traj   = flightDynamics(launch, par.ball, par.flight, par.goal);
result = classifyShot(traj, par.ball, par.goal);

end
