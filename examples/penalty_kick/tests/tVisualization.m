classdef tVisualization < matlab.unittest.TestCase
% TVISUALIZATION Smoke test of block 4: the plots run and draw what they promise.
%
%   PHYSICAL CONTEXT:
%   Block 4 only draws, so it has no requirement of its own. The test checks that
%   plotShot builds a two-tile layout (3D view and top view) from a real shot, that
%   the title carries the measured label, and that the subtitle declares the
%   coefficients illustrative (D9). Figures are created invisible and closed.
%
%   Run:
%       results = runtests('tests/tVisualization.m');
%
%   See also: PLOTSHOT, DRAWGOAL

    properties
        par
    end

    methods (TestClassSetup)
        function addSourcePath(~)
            here = fileparts(mfilename('fullpath'));
            addpath(genpath(fullfile(here, '..', 'src')));
        end
    end

    methods (TestMethodSetup)
        function loadParameters(testCase)
            testCase.par = loadTestParams();
        end
    end

    methods (Test)

        function plotShotBuildsTwoTilesWithMeasuredTitle(testCase)
            f = figure('Visible', 'off');
            testCase.addTeardown(@() close(f));
            [result, traj] = takeShot(testCase.par.shot, testCase.par);

            tl = plotShot(traj, result, testCase.par);

            testCase.verifyClass(tl, 'matlab.graphics.layout.TiledChartLayout');
            testCase.verifyEqual(numel(findobj(f, 'Type', 'axes')), 2);
            testCase.verifySubstring(string(tl.Title.String), result.label);
            testCase.verifySubstring(lower(string(tl.Subtitle.String)), "illustrative");
        end

        function drawImpactPointPutsTheDotWhereTheFootHits(testCase)
            f = figure('Visible', 'off');  testCase.addTeardown(@() close(f));
            ax = axes(f);
            shot = testCase.par.shot;  shot.offsetLateral = -0.4;  shot.offsetVertical = 0.25;
            drawImpactPoint(ax, shot, testCase.par.kick.maxOffset);
            dot = findobj(ax, 'Type', 'line', 'Marker', 'o');
            testCase.verifyEqual([dot.XData, dot.YData], [-0.4, 0.25]);
            testCase.verifyEqual(string(ax.XDir), "reverse", 'Left of the kick must appear on the left.');
        end

        function drawVerdictShowsTheBallToScaleAndSaysShortWhenItFellShort(testCase)
            f = figure('Visible', 'off');  testCase.addTeardown(@() close(f));
            ax = axes(f);
            [result, ~] = takeShot(testCase.par.shot, testCase.par);
            drawVerdict(ax, result, testCase.par);
            disc = findobj(ax, 'Type', 'rectangle');
            testCase.verifyEqual(disc.Position(3), 2*testCase.par.ball.radius_m, 'AbsTol', 1e-12);
            testCase.verifyEqual(numel(findobj(ax, 'Type', 'patch')), 3, 'Two posts and the crossbar.');
            ax2 = axes(figure('Visible', 'off'));  testCase.addTeardown(@() close(ax2.Parent));
            result.label = "SHORT";  result.yAtGoal = NaN;  result.zAtGoal = NaN;
            drawVerdict(ax2, result, testCase.par);
            testCase.verifyEmpty(findobj(ax2, 'Type', 'rectangle'));
            testCase.verifySubstring(string(findobj(ax2, 'Type', 'text').String), "short");
        end

        function drawVerdictCanEnlargeTheBallForSmallTilesKeepingItsCentre(testCase)
            f = figure('Visible', 'off');  testCase.addTeardown(@() close(f));
            ax = axes(f);
            [result, ~] = takeShot(testCase.par.shot, testCase.par);
            drawVerdict(ax, result, testCase.par, Labels=false, BallScale=4);
            disc = findobj(ax, 'Type', 'rectangle');
            R = testCase.par.ball.radius_m;
            testCase.verifyEqual(disc.Position(3), 8*R, 'AbsTol', 1e-12, 'The disc must be 4 times wider.');
            testCase.verifyEqual(disc.Position(1) + disc.Position(3)/2, result.yAtGoal, 'AbsTol', 1e-12, 'Same centre in y.');
            testCase.verifyEqual(disc.Position(2) + disc.Position(4)/2, result.zAtGoal, 'AbsTol', 1e-12, 'Same centre in z.');
        end

        function animateShotReportsEveryFrameAndCanSkipTheWaiting(testCase)
            f = figure('Visible', 'off');  testCase.addTeardown(@() close(f));
            [result, traj] = takeShot(testCase.par.shot, testCase.par);
            n = numel(animationFrames(traj, testCase.par.animation).time);
            setappdata(f, 'calls', []);
            tic;
            animateShot(testCase.par.shot, traj, result, testCase.par, RealTime=false, ...
                OnFrame=@(k, total) setappdata(f, 'calls', [getappdata(f, 'calls'), k*(total == n)]));
            elapsed = toc;
            testCase.verifyEqual(getappdata(f, 'calls'), 1:n, 'OnFrame must be called once per frame, in order, with the total.');
            testCase.verifyLessThan(elapsed, 0.6*traj.t(end)/testCase.par.animation.slowMotion, ...
                'Without real-time pacing the animation must run faster than its playback time.');
        end

        function animateShotEndsWithTheBallAtTheLastSample(testCase)
            f = figure('Visible', 'off');  testCase.addTeardown(@() close(f));
            p = testCase.par;  p.animation.slowMotion = 50;          % fast playback keeps the test short
            [result, traj] = takeShot(p.shot, p);
            tl = animateShot(p.shot, traj, result, p);
            testCase.verifyClass(tl, 'matlab.graphics.layout.TiledChartLayout');
            ball = findobj(f, 'Type', 'surface');
            centre = [mean([min(ball.XData(:)), max(ball.XData(:))]); mean([min(ball.YData(:)), max(ball.YData(:))]); ...
                mean([min(ball.ZData(:)), max(ball.ZData(:))])];
            testCase.verifyEqual(centre, traj.position(:, end), 'AbsTol', 1e-9);
            testCase.verifySubstring(string(tl.Title.String), result.label);
            testCase.verifySubstring(lower(string(tl.Subtitle.String)), "illustrative");
        end

        function plotShotAlsoDrawsAShortShot(testCase)
            f = figure('Visible', 'off');
            testCase.addTeardown(@() close(f));
            shot = testCase.par.shot;  shot.impulse = 4;  shot.aimElevation = 30;   % lands before the goal
            [result, traj] = takeShot(shot, testCase.par);
            testCase.assertEqual(result.label, "SHORT");

            tl = plotShot(traj, result, testCase.par);

            testCase.verifySubstring(string(tl.Title.String), "SHORT");
        end

    end
end
