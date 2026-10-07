function tl = animateShot(shot, traj, result, par, opts)
% ANIMATESHOT Slow-motion animation of the shot with the spinning ball, and the verdict at the end.
%
%   TL = ANIMATESHOT(SHOT, TRAJ, RESULT, PAR) starts a tiled layout of three views in the
%   current figure: the impact point on the ball, the flight in 3D, and the goal seen
%   from the kicker. The flight is played in slow motion (par.animation.slowMotion) with
%   the ball turning about its spin axis at the rate of the model; the third view shows
%   the verdict when the ball arrives. In the Live Editor the output figure updates as the
%   animation runs, so the section plays like a short video.
%
%   PHYSICAL CONTEXT:
%   The picture has no physics of its own: it replays the path of block 2 at the instants
%   chosen by animationFrames and draws the pattern of the ball rotated by |omega|*t about
%   the spin axis, so backspin, topspin and side spin can be told apart. The ball is drawn
%   par.animation.ballDrawScale times larger than it is: at its real size it would be a
%   dot in an 11 m scene.
%
%   Inputs:
%       shot       - the shot that was kicked (for the impact point view)
%       traj       - struct from flightDynamics
%       result     - struct from classifyShot
%       par        - struct of parameters.m, uses .ball .kick .goal .animation
%       'RealTime' - pace the playback with pause so that it takes T/slowMotion seconds (true).
%                    False draws the frames as fast as possible, for recording
%       'OnFrame'   - function handle f(index, total) called after each frame is drawn (none). Used by
%                    tools/makeShotVideo.m to capture the frames
%
%   Outputs:
%       tl - the tiled layout
%
%   ASSUMPTIONS:
%   1. Same frame as the model (D10): x to the goal, y to the left, z up.
%   2. The coefficients behind the path are illustrative (decision D9): the subtitle says so.
%
%   Example:
%       run('parameters.m');
%       [result, traj] = takeShot(par.shot, par);
%       animateShot(par.shot, traj, result, par);
%
%   See also: ANIMATIONFRAMES, DRAWIMPACTPOINT, DRAWVERDICT, DRAWGOAL, TAKESHOT

arguments
    shot   (1,1) struct
    traj   (1,1) struct
    result (1,1) struct
    par    (1,1) struct
    opts.RealTime (1,1) logical = true
    opts.OnFrame  = []
end

assert(isempty(opts.OnFrame) || isa(opts.OnFrame, 'function_handle'), 'PenaltyKick:animateShot:InvalidOnFrame', ...
    '[animateShot] OnFrame must be a function handle f(index, total) or empty.');
requireFields(par, ["ball", "kick", "goal", "animation"], "animateShot");
requireFields(par.animation, ["slowMotion", "framesPerSecond", "ballDrawScale"], "animateShot");

ink = [0.15 0.15 0.15];  green = [0.10 0.55 0.20];  red = [0.75 0.15 0.15];    % [-] RGB
ballR = par.ball.radius_m * par.animation.ballDrawScale;                       % [m] drawn radius of the ball
frames = animationFrames(traj, par.animation);

tl = tiledlayout(1, 4, 'TileSpacing', 'compact');
drawImpactPoint(nexttile(1), shot, par.kick.maxOffset, Labels=false);
title(nexttile(1), 'Impact point', 'FontSize', 10);

ax = nexttile(2, [1 2]);  hold(ax, 'on');
drawGoal(ax, par.goal);
trail     = plot3(ax, NaN, NaN, NaN, '-', 'Color', ink, 'LineWidth', 1.5);
endMarker = plot3(ax, NaN, NaN, NaN, 'o', 'MarkerSize', 16, 'LineWidth', 2.5, 'Color', ink);
[xs, ys, zs] = sphere(16);
spherePoints = ballR * [xs(:)'; ys(:)'; zs(:)'];                               % [m] ball centred at the origin
pattern = mod(floor((0:16)'/2) + floor((0:16)/2), 2) + 1;                      % [-] checker pattern, two colours
ball = surf(ax, xs, ys, zs, pattern, 'EdgeColor', 'none', 'CDataMapping', 'direct');
colormap(ax, [0.95 0.95 0.95; 0.15 0.15 0.15]);
daspect(ax, [1 1 1]);  view(ax, 35, 20);  grid(ax, 'on');
xlim(ax, [-0.5, par.goal.penaltyDistance_m + 1]);
ylim(ax, (par.goal.width_m/2 + par.goal.postWidth_m + 1)*[-1 1]);
zlim(ax, [0, par.goal.height_m + par.goal.postWidth_m + 1]);
xlabel(ax, 'x towards the goal [m]');  ylabel(ax, 'y, left [m]');  zlabel(ax, 'z, up [m]');

axVerdict = nexttile(4);
title(axVerdict, 'Verdict', 'FontSize', 10);
set(axVerdict, 'XTick', [], 'YTick', []);

title(tl, 'Kick...');
subtitle(tl, sprintf('Ball drawn %g times larger; aerodynamic coefficients illustrative (D9)', ...
    par.animation.ballDrawScale));

secondsPerFrame = frames.playbackSeconds / max(numel(frames.time) - 1, 1);     % [s]
t0 = tic;
for iFrame = 1:numel(frames.time)
    wait = (iFrame - 1)*secondsPerFrame - toc(t0);
    if opts.RealTime && wait > 0, pause(wait); end
    p = frames.position;
    trail.XData = p(1, 1:iFrame);  trail.YData = p(2, 1:iFrame);  trail.ZData = p(3, 1:iFrame);
    axisUnit = frames.spinAxis;  angle = frames.spinAngle(iFrame);             % rotation about the spin axis (Rodrigues)
    K = [0 -axisUnit(3) axisUnit(2); axisUnit(3) 0 -axisUnit(1); -axisUnit(2) axisUnit(1) 0];
    q = (eye(3) + sin(angle)*K + (1 - cos(angle))*(K*K)) * spherePoints + p(:, iFrame);
    ball.XData = reshape(q(1, :), size(xs));
    ball.YData = reshape(q(2, :), size(xs));
    ball.ZData = reshape(q(3, :), size(xs));
    drawnow limitrate;
    if ~isempty(opts.OnFrame)
        drawnow;
        opts.OnFrame(iFrame, numel(frames.time));                              % for recording the frames
    end
end

if result.label == "GOAL", c = green; else, c = red; end
endMarker.XData = traj.position(1, end);  endMarker.YData = traj.position(2, end);
endMarker.ZData = traj.position(3, end);  endMarker.Color = c;
cla(axVerdict);
drawVerdict(axVerdict, result, par, Labels=false, BallScale=par.animation.ballDrawScale);
title(tl, sprintf('%s   (flight %.2f s, shown %.0f times slower)', result.label, result.flightTime, 1/par.animation.slowMotion));
drawnow;

end
