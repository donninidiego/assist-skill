function drawImpactPoint(ax, shot, maxOffset, opts)
% DRAWIMPACTPOINT Ball seen from behind the kick, with the impact point and the admissible circle.
%
%   DRAWIMPACTPOINT(AX, SHOT, MAXOFFSET) draws the outline of the ball (radius 1), the
%   dashed circle of admissible impact points (radius MAXOFFSET) and a dot at the impact
%   point. The view is from behind the kick: the left of the kick is on the left of the
%   picture, so the horizontal axis is reversed.
%
%   Inputs:
%       ax        - axes to draw into
%       shot      - struct with .offsetLateral (left of centre positive) and .offsetVertical
%                   (above centre positive), both [-] as a fraction of the ball radius
%       maxOffset - par.kick.maxOffset [-], radius of the admissible circle
%       'Labels'  - write title and axis labels (true). False leaves them out, for small tiles
%
%   Example:
%       run('parameters.m');
%       tiledlayout(1, 1);  drawImpactPoint(nexttile, par.shot, par.kick.maxOffset);
%
%   See also: DRAWVERDICT, ANIMATESHOT, KICKIMPACT

arguments
    ax        (1,1) matlab.graphics.axis.Axes
    shot      (1,1) struct
    maxOffset (1,1) double {mustBePositive}
    opts.Labels (1,1) logical = true
end

requireFields(shot, ["offsetLateral", "offsetVertical"], "drawImpactPoint");

t = linspace(0, 2*pi, 200);
hold(ax, 'on');
plot(ax, cos(t), sin(t), 'k-', 'LineWidth', 1.5);                                  % ball outline, radius 1
plot(ax, maxOffset*cos(t), maxOffset*sin(t), '--', 'Color', [0.6 0.6 0.6]);        % limit of admissible offsets
plot(ax, [-1 1], [0 0], ':', 'Color', [0.6 0.6 0.6]);
plot(ax, [0 0], [-1 1], ':', 'Color', [0.6 0.6 0.6]);
plot(ax, shot.offsetLateral, shot.offsetVertical, 'o', 'MarkerFaceColor', [0.15 0.15 0.15], ...
    'MarkerEdgeColor', 'none', 'MarkerSize', 9);                                   % impact point
axis(ax, 'equal');  set(ax, 'XDir', 'reverse');                                    % left of the kick appears on the left
xlim(ax, [-1.1 1.1]);  ylim(ax, [-1.1 1.1]);
if opts.Labels
    xlabel(ax, 'lateral offset [R], left of centre positive');  ylabel(ax, 'vertical offset [R]');
    title(ax, 'Impact point, seen from behind');
else
    set(ax, 'XTick', [], 'YTick', []);
end

end
