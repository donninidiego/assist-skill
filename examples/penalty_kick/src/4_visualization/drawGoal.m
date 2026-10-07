function drawGoal(ax, parGoal)
% DRAWGOAL Draw the goal frame, the penalty mark and the line between them in 3D.
%
%   DRAWGOAL(AX, PARGOAL) adds to the axes AX the two posts and the crossbar as
%   grey filled rectangles in the goal plane x = d, the penalty mark at the origin
%   and a thin line on the ground from the mark to the centre of the goal.
%
%   Frame (D10): origin at the penalty mark, x to the goal, y to the left, z up.
%   Posts and crossbar have a square section of side postWidth_m; the opening is
%   measured between the inner edges of the posts and under the crossbar.
%
%   Inputs:
%       ax      - axes to draw into
%       parGoal - par.goal, uses .penaltyDistance_m, .width_m, .height_m, .postWidth_m [m]
%
%   Example:
%       run('parameters.m');
%       tiledlayout(1, 1);  ax = nexttile;  hold(ax, 'on');
%       drawGoal(ax, par.goal);  view(ax, 35, 20);
%
%   See also: PLOTSHOT, REQUIREFIELDS

arguments
    ax      (1,1) matlab.graphics.axis.Axes
    parGoal (1,1) struct
end

requireFields(parGoal, ["penaltyDistance_m", "width_m", "height_m", "postWidth_m"], "drawGoal");

d = parGoal.penaltyDistance_m;  W = parGoal.width_m;  H = parGoal.height_m;  w = parGoal.postWidth_m;   % [m]
frameGrey = [0.45 0.45 0.45];                                       % [-] RGB of the frame
xs = d*ones(1, 4);                                                  % [m] all corners lie in the goal plane

fill3(ax, xs, [ W/2,  W/2+w,  W/2+w,  W/2], [0 0 H+w H+w], frameGrey, 'EdgeColor', 'none');    % left post
fill3(ax, xs, [-W/2, -W/2-w, -W/2-w, -W/2], [0 0 H+w H+w], frameGrey, 'EdgeColor', 'none');    % right post
fill3(ax, xs, [-W/2-w, W/2+w, W/2+w, -W/2-w], [H H H+w H+w], frameGrey, 'EdgeColor', 'none');  % crossbar
plot3(ax, [0 d], [0 0], [0 0], '-', 'Color', [0.75 0.75 0.75]);     % ground line, mark to goal
plot3(ax, 0, 0, 0, 'k.', 'MarkerSize', 14);                         % penalty mark

end
