function drawVerdict(ax, result, par, opts)
% DRAWVERDICT Goal frame seen from the kicker, with the ball at the goal plane (to scale).
%
%   DRAWVERDICT(AX, RESULT, PAR) draws the two posts and the crossbar and, if the shot
%   reached the goal plane, the ball as a disc of its real radius at (y, z). The disc is
%   green for GOAL and red for anything else (true / false). For a SHORT shot the text
%   "the ball fell short" replaces the disc. The view is from the kicker: the left of the
%   goal is on the left of the picture.
%
%   Inputs:
%       ax       - axes to draw into
%       result   - struct from classifyShot (.label, .yAtGoal, .zAtGoal)
%       par      - struct of parameters.m, uses .ball.radius_m and .goal
%       'Labels'    - write title and axis labels (true). False leaves a short title only
%       'BallScale' - draw the ball this many times larger than real (1, true size). For small
%                      tiles, where a true-size ball would be a dot; the centre stays where it is
%
%   Example:
%       run('parameters.m');
%       result = takeShot(par.shot, par);
%       tiledlayout(1, 1);  drawVerdict(nexttile, result, par);
%
%   See also: DRAWIMPACTPOINT, CLASSIFYSHOT, DRAWGOAL

arguments
    ax     (1,1) matlab.graphics.axis.Axes
    result (1,1) struct
    par    (1,1) struct
    opts.Labels    (1,1) logical = true
    opts.BallScale (1,1) double {mustBePositive} = 1
end

requireFields(result, ["label", "yAtGoal", "zAtGoal"], "drawVerdict");
requireFields(par, ["ball", "goal"], "drawVerdict");

R = par.ball.radius_m;  W = par.goal.width_m;  H = par.goal.height_m;  w = par.goal.postWidth_m;   % [m]
frameGrey = [0.45 0.45 0.45];
hold(ax, 'on');
patch(ax, [W/2 W/2+w W/2+w W/2], [0 0 H+w H+w], frameGrey, 'EdgeColor', 'none');                    % left post
patch(ax, [-W/2 -W/2-w -W/2-w -W/2], [0 0 H+w H+w], frameGrey, 'EdgeColor', 'none');               % right post
patch(ax, [-W/2-w W/2+w W/2+w -W/2-w], [H H H+w H+w], frameGrey, 'EdgeColor', 'none');             % crossbar
plot(ax, [-W/2-w-0.5, W/2+w+0.5], [0 0], '-', 'Color', [0.75 0.75 0.75]);                           % ground
if result.label == "GOAL"
    discColor = [0.10 0.55 0.20];
else
    discColor = [0.75 0.15 0.15];
end
if ~isnan(result.yAtGoal)
    rectangle(ax, 'Position', [result.yAtGoal - R*opts.BallScale, result.zAtGoal - R*opts.BallScale, 2*R*opts.BallScale, 2*R*opts.BallScale], 'Curvature', [1 1], ...
        'FaceColor', discColor, 'EdgeColor', 'none');
else
    text(ax, 0, H/2, 'the ball fell short', 'HorizontalAlignment', 'center', 'FontSize', 8 + 4*opts.Labels);
end
axis(ax, 'equal');  set(ax, 'XDir', 'reverse');                                                     % left of the goal appears on the left
xlim(ax, [-W/2-w-0.5, W/2+w+0.5]);  ylim(ax, [-0.2, H+w+0.5]);
if opts.Labels
    xlabel(ax, 'y, left of the goal centre positive [m]');  ylabel(ax, 'z, up [m]');
    title(ax, sprintf('%s, seen from the kicker', result.label));
else
    set(ax, 'XTick', [], 'YTick', []);
    title(ax, char(result.label), 'FontSize', 10);
end

end
