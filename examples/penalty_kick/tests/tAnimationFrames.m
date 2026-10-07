classdef tAnimationFrames < matlab.unittest.TestCase
% TANIMATIONFRAMES Verify the frame generator of the slow-motion animation (R10).
%
%   PHYSICAL CONTEXT:
%   The animation shows the ball at evenly spaced instants of the real flight,
%   played slower than real time (par.animation.slowMotion) at par.animation.framesPerSecond.
%   The first frame must be the launch, the last frame the end of the path, the
%   number of frames and the playback duration must follow from the two parameters,
%   and the spin angle accumulated at the end must be |omega| times the flight time.
%
%   Expected values are arithmetic: playback duration = T / slowMotion, frames =
%   ceil(duration * fps) + 1, final angle = |omega| T.
%
%   Run:
%       results = runtests('tests/tAnimationFrames.m');
%
%   See also: ANIMATIONFRAMES, TAKESHOT, LOADTESTPARAMS

    properties
        par    % parameters of parameters.m
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

        function R10_firstAndLastFrameAreTheEndsOfThePath(testCase)
            [~, traj] = takeShot(testCase.par.shot, testCase.par);
            frames = animationFrames(traj, testCase.par.animation);
            testCase.verifyEqual(frames.position(:, 1),   traj.position(:, 1),   'AbsTol', 1e-12);
            testCase.verifyEqual(frames.position(:, end), traj.position(:, end), 'AbsTol', 1e-12);
            testCase.verifyEqual(frames.time(1), 0);
            testCase.verifyEqual(frames.time(end), traj.t(end), 'AbsTol', 1e-12);
        end

        function R10_frameCountAndDurationFollowTheParameters(testCase)
            [~, traj] = takeShot(testCase.par.shot, testCase.par);
            a = testCase.par.animation;
            frames = animationFrames(traj, a);
            duration = traj.t(end) / a.slowMotion;                        % [s] playback time
            testCase.verifyEqual(numel(frames.time), ceil(duration*a.framesPerSecond) + 1);
            testCase.verifyEqual(size(frames.position, 2), numel(frames.time));
            testCase.verifyEqual(frames.playbackSeconds, duration, 'RelTol', 1e-12);
            testCase.verifyEqual(frames.framesPerSecond, a.framesPerSecond);
        end

        function R10_framesStayOnThePath(testCase)
            [~, traj] = takeShot(testCase.par.shot, testCase.par);
            frames = animationFrames(traj, testCase.par.animation);
            testCase.verifyGreaterThanOrEqual(diff(frames.position(1, :)), 0, 'x must not go back.');
            for i = 1:3
                lo = min(traj.position(i, :));  hi = max(traj.position(i, :));
                testCase.verifyGreaterThanOrEqual(frames.position(i, :), lo - 1e-12);
                testCase.verifyLessThanOrEqual(frames.position(i, :), hi + 1e-12);
            end
        end

        function R10_spinAngleAndAxis(testCase)
            [~, traj, launch] = takeShot(testCase.par.shot, testCase.par);
            frames = animationFrames(traj, testCase.par.animation);
            testCase.verifyEqual(frames.spinAngle(end), norm(launch.spin)*traj.t(end), 'RelTol', 1e-12);
            testCase.verifyEqual(frames.spinAxis, launch.spin/norm(launch.spin), 'AbsTol', 1e-12);
            testCase.verifyEqual(norm(frames.spinAxis), 1, 'AbsTol', 1e-12);
        end

        function R10_zeroSpinGivesZeroAngleAndAFiniteAxis(testCase)
            shot = testCase.par.shot;  shot.offsetLateral = 0;  shot.offsetVertical = 0;
            [~, traj] = takeShot(shot, testCase.par);
            frames = animationFrames(traj, testCase.par.animation);
            testCase.verifyEqual(frames.spinAngle, zeros(size(frames.time)), 'AbsTol', 0);
            testCase.verifyTrue(all(isfinite(frames.spinAxis)) && abs(norm(frames.spinAxis) - 1) < 1e-12);
        end

        function R7_nonPositiveSlowMotionIsRejected(testCase)
            [~, traj] = takeShot(testCase.par.shot, testCase.par);
            a = testCase.par.animation;  a.slowMotion = 0;
            testCase.verifyError(@() animationFrames(traj, a), 'PenaltyKick:animationFrames:InvalidParameter');
        end

        function R7_missingParameterIsReportedByName(testCase)
            [~, traj] = takeShot(testCase.par.shot, testCase.par);
            a = rmfield(testCase.par.animation, 'framesPerSecond');
            testCase.verifyError(@() animationFrames(traj, a), 'PenaltyKick:requireFields:MissingParameter');
        end

    end
end
