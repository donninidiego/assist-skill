function tl = plotShot(traj, result, par)
% PLOTSHOT Draw one shot: path in 3D next to the view from above.
%
%   TL = PLOTSHOT(TRAJ, RESULT, PAR) starts a tiled layout of two tiles in the
%   current figure: the path of the ball with the goal in 3D, and the same path
%   seen from above (the tiles carry no title of their own: it would collide with
%   the subtitle). The title gives the outcome and the flight time; the subtitle
%   says that the aerodynamic coefficients are illustrative (decision D9), because
%   until they come from a source no figure may suggest otherwise.
%
%   The outcome marker is green for GOAL and red for anything else (true / false).
%
%   Inputs:
%       traj   - struct from flightDynamics (.position [3xN] m, .endReason)
%       result - struct from classifyShot (.label, .flightTime)
%       par    - struct of parameters.m, uses .goal and .ball
%
%   Outputs:
%       tl - the tiled layout, to let the caller change the title
%
%   Example:
%       run('parameters.m');
%       [result, traj] = takeShot(par.shot, par);
%       plotShot(traj, result, par);
%
%   See also: DRAWGOAL, TAKESHOT

arguments
    traj   (1,1) struct
    result (1,1) struct
    par    (1,1) struct
end

requireFields(par, ["goal", "ball"], "plotShot");
requireFields(result, ["label", "flightTime"], "plotShot");

p = traj.position;                                          % [m] ball centre, world frame
d = par.goal.penaltyDistance_m;  W = par.goal.width_m;  H = par.goal.height_m;  w = par.goal.postWidth_m;   % [m]
if result.label == "GOAL"
    endColor = [0.10 0.55 0.20];                            % [-] green: true
else
    endColor = [0.75 0.15 0.15];                            % [-] red: false
end

tl = tiledlayout(1, 2, 'TileSpacing', 'loose');

% --- 3D view -------------------------------------------------------------
ax1 = nexttile;  hold(ax1, 'on');
drawGoal(ax1, par.goal);
plot3(ax1, p(1, :), p(2, :), p(3, :), '-', 'Color', [0.15 0.15 0.15], 'LineWidth', 1.5);
plot3(ax1, p(1, end), p(2, end), p(3, end), 'o', 'MarkerFaceColor', endColor, ...
    'MarkerEdgeColor', 'none', 'MarkerSize', 8);
daspect(ax1, [1 1 1]);  view(ax1, 35, 20);  grid(ax1, 'on');
xlim(ax1, [0 d + 1]);  ylim(ax1, (W/2 + w + 1)*[-1 1]);  zlim(ax1, [0 H + w + 1]);
xlabel(ax1, 'x towards the goal [m]');  ylabel(ax1, 'y, left [m]');  zlabel(ax1, 'z, up [m]');

% --- view from above -----------------------------------------------------
ax2 = nexttile;  hold(ax2, 'on');
plot(ax2, [d d], [-W/2 W/2], '-', 'Color', [0.45 0.45 0.45], 'LineWidth', 4);   % goal mouth
plot(ax2, 0, 0, 'k.', 'MarkerSize', 14);                                         % penalty mark
plot(ax2, p(1, :), p(2, :), '-', 'Color', [0.15 0.15 0.15], 'LineWidth', 1.5);
plot(ax2, p(1, end), p(2, end), 'o', 'MarkerFaceColor', endColor, ...
    'MarkerEdgeColor', 'none', 'MarkerSize', 8);
axis(ax2, 'equal');  grid(ax2, 'on');
xlim(ax2, [0 d + 1]);  ylim(ax2, (W/2 + w + 1)*[-1 1]);
xlabel(ax2, 'x towards the goal [m]  (seen from above)');  ylabel(ax2, 'y, left [m]');

title(tl, sprintf('%s   (flight %.2f s)', result.label, result.flightTime));
subtitle(tl, 'Drag and lift coefficients are illustrative (decision D9), not measured values');

end
