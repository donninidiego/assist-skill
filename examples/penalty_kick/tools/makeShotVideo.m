% MAKESHOTVIDEO  Record the slow-motion animation of three kicks as a GIF.
%
%   Run it from anywhere: it finds the project from its own location, runs three shots
%   through the same chain as the demo (takeShot) and records what animateShot draws:
%   the impact point on the ball, the flight with the spinning ball, the verdict.
%   The values of each shot are written on the frames, as a viewer of the demo would set
%   them with the five sliders of step 4.
%
%   Output (folder media/ of the project):
%       penalty_kick_demo.gif   embedded in the README (every second frame, 15 frames/s)
%
%   The GIF is inspired by the Live Script, not a capture of the Live Editor: the sliders
%   themselves are controls of the Live Editor and appear only there.
%
%   The shots are our own picks for the picture (impact point as a fraction of R, impulse
%   in N s, angles in deg); they are not parameters of the model.
%
% See also: ANIMATESHOT, TAKESHOT

here = fileparts(mfilename('fullpath'));
root = fileparts(here);
addpath(genpath(fullfile(root, 'src')));
run(fullfile(root, 'parameters.m'));                       % creates par

% name, changes to the reference shot par.shot
clips = {"your shot (demo default)", struct('offsetLateral', -0.3, 'offsetVertical', -0.3, 'impulse', 11, 'aimAzimuth', -2, 'aimElevation', 11); ...
         "strong side spin, aimed 12 deg left", struct('offsetLateral', -0.6, 'offsetVertical', 0, 'aimAzimuth', 12); ...
         "hit above the centre (topspin)",       struct('offsetVertical', 0.3)};

outDir = fullfile(root, 'media');
if ~isfolder(outDir), mkdir(outDir); end
gifFile = fullfile(outDir, 'penalty_kick_demo.gif');
if isfile(gifFile), delete(gifFile); end

figSize = [820 300];                                       % [px] width, height of every frame
gifStride = 2;                                             % keep every second frame in the GIF
gifDelay = gifStride / par.animation.framesPerSecond;      % [s] time each kept frame stays on screen
holdSeconds = 1.0;                                         % [s] last frame is held, to read the verdict
% One fixed palette for the whole GIF: a GIF reuses the palette of its first frame for the following ones, and the first frame
% (before the verdict) is all grey, so a palette made frame by frame would lose the green and the red of the verdict.
t = linspace(0, 1, 24)';                                                    % [-] white to full colour
greyMap  = repmat(linspace(0, 1, 64)', 1, 3);
greenMap = 1 - t*(1 - [0.10 0.55 0.20]);                                     % tints of the GOAL green
redMap   = 1 - t*(1 - [0.75 0.15 0.15]);                                     % tints of the red of the other outcomes
gifMap   = [greyMap; greenMap; redMap];

for iClip = 1:size(clips, 1)
    shot = par.shot;
    for field = string(fieldnames(clips{iClip, 2}))'
        shot.(field) = clips{iClip, 2}.(field);
    end
    [result, traj] = takeShot(shot, par);
    fig = figure('Visible', 'off', 'Position', [100 100 figSize], 'Color', 'w');
    caption = annotation(fig, 'textbox', [0 0 1 0.1], 'LineStyle', 'none', 'HorizontalAlignment', 'center', ...
        'String', sprintf('%s:  impact (%+.2f, %+.2f) R   impulse %.1f N s   aim %+.0f deg azimuth, %.0f deg elevation', ...
        clips{iClip, 1}, shot.offsetLateral, shot.offsetVertical, shot.impulse, shot.aimAzimuth, shot.aimElevation));
    caption.FontSize = 10;
    capture = @(index, total) recordFrame(fig, index, gifStride, gifDelay, gifFile, gifMap);
    animateShot(shot, traj, result, par, RealTime=false, OnFrame=capture);
    nHold = round(holdSeconds * par.animation.framesPerSecond);
    for k = 1:nHold                                        % hold the final picture, with the verdict
        recordFrame(fig, k, gifStride, gifDelay, gifFile, gifMap);
    end
    fprintf('clip %d: %s -> %s\n', iClip, clips{iClip, 1}, result.label);
    close(fig);
end
info = dir(gifFile);
fprintf('GIF %.1f MB written to %s\n', info.bytes/1e6, outDir);

function recordFrame(fig, index, gifStride, gifDelay, gifFile, gifMap)
% RECORDFRAME Append the current picture of fig to the GIF, every gifStride-th frame.
    if mod(index - 1, gifStride) ~= 0, return; end
    image = print(fig, '-RGBImage', '-r96');
    indexed = rgb2ind(image, gifMap, 'nodither');
    if isfile(gifFile)
        imwrite(indexed, gifMap, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', gifDelay);
    else
        imwrite(indexed, gifMap, gifFile, 'gif', 'WriteMode', 'overwrite', 'DelayTime', gifDelay, 'LoopCount', inf);   % loop count only on the first frame
    end
end
