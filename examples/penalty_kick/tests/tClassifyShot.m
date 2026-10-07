classdef tClassifyShot < matlab.unittest.TestCase
% TCLASSIFYSHOT Verify block 3 (outcome of the shot) on a table of boundary cases.
%
%   PHYSICAL CONTEXT:
%   Block 3 judges the shot when the ball centre crosses the goal plane: the ball
%   is a disc of radius R at (y, z) and the goal is a frame of two posts and a
%   crossbar (decision D11). The label must be unique (R6), change exactly where
%   the disc starts to touch the frame, and not depend on the side.
%
%   Geometry used: opening |y| <= W/2, z <= H; posts and crossbar of square section
%   w; ball radius R. Cases sit 1e-6 m on either side of each boundary.
%
%   Run:
%       results = runtests('tests/tClassifyShot.m');
%
%   See also: CLASSIFYSHOT, LOADTESTPARAMS

    properties
        par    % parameters of parameters.m, adapted to the case
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

        %% ─── R6: one label, boundaries where the geometry says ────────────

        function R6_boundariesOfTheFrame(testCase)
            R = testCase.par.ball.radius_m;      W = testCase.par.goal.width_m;
            H = testCase.par.goal.height_m;      w = testCase.par.goal.postWidth_m;
            e = 1e-6;                                            % [m] distance from the boundary
            zMid = 1.0;                                          % [m] mid-height, away from the bar
            %        y             z              expected
            cases = {0,            1.0,           "GOAL"; ...
                     W/2-R-e,      zMid,          "GOAL"; ...
                     W/2-R+e,      zMid,          "POST"; ...
                     W/2+w+R-e,    zMid,          "POST"; ...
                     W/2+w+R+e,    zMid,          "WIDE"; ...
                     0,            H-R-e,         "GOAL"; ...
                     0,            H-R+e,         "CROSSBAR"; ...
                     0,            H+w+R-e,       "CROSSBAR"; ...
                     0,            H+w+R+e,       "HIGH"; ...
                     W/2,          H,             "POST"};       % corner: tie-break is POST
            for i = 1:size(cases, 1)
                result = classifyShot(testCase.trajAtGoal(cases{i, 1}, cases{i, 2}), ...
                    testCase.par.ball, testCase.par.goal);
                testCase.verifyEqual(result.label, cases{i, 3}, ...
                    sprintf('y = %.6f, z = %.6f', cases{i, 1}, cases{i, 2}));
            end
        end

        function R6_farOutsideIsWideOrHigh(testCase)
            % Above the bar level but beside the posts: WIDE; above the bar between them: HIGH.
            W = testCase.par.goal.width_m;  H = testCase.par.goal.height_m;
            w = testCase.par.goal.postWidth_m;
            result = classifyShot(testCase.trajAtGoal(W/2+w+1, H+w+1), testCase.par.ball, testCase.par.goal);
            testCase.verifyEqual(result.label, "WIDE");
            result = classifyShot(testCase.trajAtGoal(0, H+w+1), testCase.par.ball, testCase.par.goal);
            testCase.verifyEqual(result.label, "HIGH");
        end

        function R6_groundBeforeThePlaneIsShort(testCase)
            traj = testCase.trajAtGoal(0, 0.5);
            traj.endReason = "ground";
            traj.position(1, end) = 7;
            result = classifyShot(traj, testCase.par.ball, testCase.par.goal);
            testCase.verifyEqual(result.label, "SHORT");
            testCase.verifyTrue(isnan(result.yAtGoal) && isnan(result.zAtGoal), ...
                'A shot that never reaches the plane has no position there.');
        end

        function R6_labelIsMirrorSymmetric(testCase)
            rng(2);                                              % seeded: reproducible
            for i = 1:200
                y = 6*rand - 3;  z = 3.5*rand;                   % [m] inside and around the frame
                a = classifyShot(testCase.trajAtGoal( y, z), testCase.par.ball, testCase.par.goal);
                b = classifyShot(testCase.trajAtGoal(-y, z), testCase.par.ball, testCase.par.goal);
                testCase.verifyEqual(a.label, b.label, sprintf('y = %.4f, z = %.4f', y, z));
            end
        end

        function R6_resultCarriesPositionAndTime(testCase)
            traj = testCase.trajAtGoal(1.5, 1.2);
            result = classifyShot(traj, testCase.par.ball, testCase.par.goal);
            testCase.verifyEqual([result.yAtGoal, result.zAtGoal], [1.5, 1.2], 'AbsTol', 0);
            testCase.verifyEqual(result.flightTime, traj.t(end), 'AbsTol', 0);
        end

        %% ─── R7: failures the assertions promise ──────────────────────────

        function R7_missingParameterIsReportedByName(testCase)
            goal = rmfield(testCase.par.goal, 'postWidth_m');
            testCase.verifyError(@() classifyShot(testCase.trajAtGoal(0, 1), testCase.par.ball, goal), ...
                'PenaltyKick:requireFields:MissingParameter');
        end

        function R7_unknownEndReasonIsRejected(testCase)
            traj = testCase.trajAtGoal(0, 1);
            traj.endReason = "lost";
            testCase.verifyError(@() classifyShot(traj, testCase.par.ball, testCase.par.goal), ...
                'PenaltyKick:classifyShot:UnknownEndReason');
        end

    end

    methods (Access = private)

        function traj = trajAtGoal(testCase, y, z)
            % Minimal trajectory whose last sample is the ball centre at the goal plane.
            d = testCase.par.goal.penaltyDistance_m;
            traj.t         = [0, 0.5];
            traj.position  = [0, d; 0, y; testCase.par.ball.radius_m, z];
            traj.velocity  = [20, 20; 0, 0; 0, 0];
            traj.spin      = [0; 0; 0];
            traj.endReason = "goalPlane";
        end

    end
end
