classdef tClampImpactPoint < matlab.unittest.TestCase
% TCLAMPIMPACTPOINT Verify that two independent sliders always give an admissible impact point.
%
%   PHYSICAL CONTEXT:
%   The impact point is chosen with two sliders, each within +/- maxOffset, but block 1
%   only accepts points inside the circle of radius maxOffset. A point in the corner of
%   the square must be moved radially onto the circle (its direction is kept), a point
%   inside must be left alone, and the result must never be refused by kickImpact: the
%   scaling could leave the norm one unit in the last place above the limit, which is
%   what the seeded random case guards against.
%
%   Run:
%       results = runtests('tests/tClampImpactPoint.m');
%
%   See also: CLAMPIMPACTPOINT, KICKIMPACT, LOADTESTPARAMS

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

        function R9_pointInsideTheCircleIsLeftAlone(testCase)
            shot = testCase.par.shot;  shot.offsetLateral = 0.3;  shot.offsetVertical = -0.4;   % norm 0.5
            testCase.verifyEqual(clampImpactPoint(shot, testCase.par.kick), shot);
        end

        function R9_pointOutsideIsMovedOntoTheCircleKeepingItsDirection(testCase)
            m = testCase.par.kick.maxOffset;
            shot = testCase.par.shot;  shot.offsetLateral = 0.8;  shot.offsetVertical = -0.4;      % norm 0.894 > 0.8
            out =clampImpactPoint(shot, testCase.par.kick);
            testCase.verifyEqual(hypot(out.offsetLateral, out.offsetVertical), m, 'AbsTol', 1e-12);
            testCase.verifyEqual(out.offsetVertical/out.offsetLateral, -0.5, 'AbsTol', 1e-12, ...
                'The direction of the offset must be kept.');
        end

        function R9_otherFieldsAreUntouched(testCase)
            shot = testCase.par.shot;  shot.offsetLateral = 0.8;  shot.offsetVertical = 0.8;
            out = clampImpactPoint(shot, testCase.par.kick);
            for f = ["impulse", "aimAzimuth", "aimElevation"]
                testCase.verifyEqual(out.(f), shot.(f));
            end
        end

        function R9_neverAboveTheLimitSoKickImpactAcceptsIt(testCase)
            % Regression: about 1 clamped point in 9 came out one ulp above maxOffset.
            m = testCase.par.kick.maxOffset;
            rng(5);
            for i = 1:3000
                shot = testCase.par.shot;
                shot.offsetLateral = (2*rand - 1)*m;  shot.offsetVertical = (2*rand - 1)*m;
                out = clampImpactPoint(shot, testCase.par.kick);
                testCase.assertLessThanOrEqual(hypot(out.offsetLateral, out.offsetVertical), m);
                kickImpact(out, testCase.par.ball, testCase.par.kick);          % must not raise
            end
        end

        function R7_missingParameterIsReportedByName(testCase)
            kick = rmfield(testCase.par.kick, 'maxOffset');
            testCase.verifyError(@() clampImpactPoint(testCase.par.shot, kick), ...
                'PenaltyKick:requireFields:MissingParameter');
        end

    end
end
