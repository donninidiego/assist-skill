classdef tTakeShot < matlab.unittest.TestCase
% TTAKESHOT Verify the chain of blocks 1-3 end to end.
%
%   PHYSICAL CONTEXT:
%   takeShot only passes data from block to block, so its tests check what the
%   chain delivers: a plausible flight time for the default shot (the impulse gives
%   about 24 m/s, the goal is 11 m away, so about 0.46 s plus a little drag), a
%   label for every shot, and a different result when the impact point changes.
%
%   Run:
%       results = runtests('tests/tTakeShot.m');
%
%   See also: TAKESHOT, LOADTESTPARAMS

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

        function R8_defaultShotFlightTimeIsPlausible(testCase)
            [result, traj, launch] = takeShot(testCase.par.shot, testCase.par);
            testCase.verifyGreaterThan(result.flightTime, 0.4);
            testCase.verifyLessThan(result.flightTime, 0.6);
            testCase.verifyEqual(traj.t(end), result.flightTime, 'AbsTol', 0);
            testCase.verifyEqual(launch.speedEquivalent, ...
                testCase.par.shot.impulse/testCase.par.ball.mass_kg, 'RelTol', 1e-12);
        end

        function R6_everyShotGetsOneLabel(testCase)
            labels = ["GOAL", "POST", "CROSSBAR", "WIDE", "HIGH", "SHORT"];
            rng(3);                                              % seeded: reproducible
            k = testCase.par.kick;
            for i = 1:25
                shot.offsetLateral  = (2*rand - 1)*k.maxOffset/sqrt(2);
                shot.offsetVertical = (2*rand - 1)*k.maxOffset/sqrt(2);
                shot.impulse        = k.impulseRange_Ns(1) + rand*diff(k.impulseRange_Ns);
                shot.aimAzimuth     = k.azimuthRange_deg(1) + rand*diff(k.azimuthRange_deg);
                shot.aimElevation   = k.elevationRange_deg(1) + rand*diff(k.elevationRange_deg);
                result = takeShot(shot, testCase.par);
                testCase.verifyEqual(nnz(result.label == labels), 1, ...
                    'Exactly one label must match.');
            end
        end

        function R4_impactPointChangesTheResult(testCase)
            shotA = testCase.par.shot;  shotA.offsetLateral = -0.5;
            shotB = testCase.par.shot;  shotB.offsetLateral = +0.5;
            a = takeShot(shotA, testCase.par);
            b = takeShot(shotB, testCase.par);
            testCase.verifyNotEqual(a.yAtGoal, b.yAtGoal, 'The impact point must matter.');
        end

        function R7_missingBlockOfParametersIsReportedByName(testCase)
            parNoGoal = rmfield(testCase.par, 'goal');
            testCase.verifyError(@() takeShot(testCase.par.shot, parNoGoal), ...
                'PenaltyKick:requireFields:MissingParameter');
        end

    end
end
