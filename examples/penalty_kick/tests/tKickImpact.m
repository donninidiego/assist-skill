classdef tKickImpact < matlab.unittest.TestCase
% TKICKIMPACT Verify block 1 (impulse and spin of the kick) against its relations.
%
%   PHYSICAL CONTEXT:
%   Block 1 turns "where and how hard the foot hits" into the ball's initial
%   velocity and spin. A centred hit must give no spin (R1). For any admissible
%   shot the linear momentum equals the impulse and the angular momentum equals
%   the moment of the impulse about the centre (R5). Out-of-range shots must be
%   refused, not simulated (R7).
%
%   Expected values are the relations m*v0 = J*d and I*omega0 = r x J*d, checked
%   through magnitude, perpendicularity and hand-derived signs, so the test does
%   not repeat the implementation.
%
%   Run:
%       results = runtests('tests/tKickImpact.m');
%
%   See also: KICKIMPACT, LOADTESTPARAMS

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

        %% ─── R1 and R5: relations required by the theory ──────────────────

        function R1_zeroOffsetGivesZeroSpin(testCase)
            shot = testCase.par.shot;
            shot.offsetLateral = 0;  shot.offsetVertical = 0;
            launch = kickImpact(shot, testCase.par.ball, testCase.par.kick);
            testCase.verifyEqual(launch.spin, [0; 0; 0], 'AbsTol', 0, ...
                'A hit through the centre must give exactly zero spin.');
        end

        function R5_randomShotsSatisfyImpulseAndSpinRelations(testCase)
            b = testCase.par.ball;  k = testCase.par.kick;
            inertia = b.inertiaFactor * b.mass_kg * b.radius_m^2;
            rng(1);                                            % seeded: reproducible
            for i = 1:20
                ang = 2*pi*rand;  rad = k.maxOffset*sqrt(rand);
                shot.offsetLateral  = rad*cos(ang);
                shot.offsetVertical = rad*sin(ang);
                shot.impulse        = k.impulseRange_Ns(1) + rand*diff(k.impulseRange_Ns);
                shot.aimAzimuth     = k.azimuthRange_deg(1) + rand*diff(k.azimuthRange_deg);
                shot.aimElevation   = k.elevationRange_deg(1) + rand*diff(k.elevationRange_deg);
                d = [cosd(shot.aimElevation)*cosd(shot.aimAzimuth); ...
                     cosd(shot.aimElevation)*sind(shot.aimAzimuth); ...
                     sind(shot.aimElevation)];                 % impulse direction, unit vector

                launch = kickImpact(shot, b, k);

                testCase.verifyEqual(b.mass_kg*launch.velocity, shot.impulse*d, ...
                    'AbsTol', 1e-12*shot.impulse, 'm*v0 must equal J*d.');
                expectedSpin = b.radius_m*shot.impulse*rad/inertia;
                testCase.verifyEqual(norm(launch.spin), expectedSpin, ...
                    'RelTol', 1e-10, '|omega0| must equal R*J*|offset|/I.');
                testCase.verifyLessThanOrEqual(abs(dot(launch.spin, d)), ...
                    1e-10*max(norm(launch.spin), eps), ...
                    'The spin axis must be perpendicular to the impulse.');
            end
        end

        function R5_signsOfSpinForStraightKick(testCase)
            % Aim along +x. Hand-derived: hit below the centre gives backspin
            % (omega along -y), hit right of the centre gives omega along +z.
            b = testCase.par.ball;  k = testCase.par.kick;
            k.elevationRange_deg(1) = 0;       % the derivation is exact for a kick along +x; parameters.m excludes 0 deg
            shot = testCase.par.shot;  shot.aimAzimuth = 0;  shot.aimElevation = 0;
            cases = {-0.5, 0, [0; -1; 0]; ...    % offsetVertical, offsetLateral, expected axis
                      0.5, 0, [0;  1; 0]; ...
                      0, -0.5, [0; 0;  1]; ...
                      0,  0.5, [0; 0; -1]};
            for i = 1:size(cases, 1)
                shot.offsetVertical = cases{i, 1};  shot.offsetLateral = cases{i, 2};
                launch = kickImpact(shot, b, k);
                axisSpin = launch.spin / norm(launch.spin);
                testCase.verifyEqual(axisSpin, cases{i, 3}, 'AbsTol', 1e-12, ...
                    'Wrong sign of the spin axis for this impact point.');
            end
        end

        function R5_launchPositionAndEquivalentSpeed(testCase)
            shot = testCase.par.shot;
            launch = kickImpact(shot, testCase.par.ball, testCase.par.kick);
            testCase.verifyEqual(launch.position, [0; 0; testCase.par.ball.radius_m], ...
                'AbsTol', 0, 'The ball must start on the mark with its centre at one radius.');
            testCase.verifyEqual(launch.speedEquivalent, shot.impulse/testCase.par.ball.mass_kg, ...
                'RelTol', 1e-12, 'speedEquivalent must be J/m.');
            testCase.verifyEqual(norm(launch.velocity), launch.speedEquivalent, 'RelTol', 1e-12);
        end

        %% ─── R7: failures the assertions promise ──────────────────────────

        function R7_offsetBeyondLimitIsRejected(testCase)
            shot = testCase.par.shot;
            shot.offsetLateral = testCase.par.kick.maxOffset;  shot.offsetVertical = 0.1;
            testCase.verifyError(@() kickImpact(shot, testCase.par.ball, testCase.par.kick), ...
                'PenaltyKick:kickImpact:OffsetOutOfRange');
        end

        function R7_impulseOutsideRangeIsRejected(testCase)
            shot = testCase.par.shot;
            for J = [0, testCase.par.kick.impulseRange_Ns(2) + 1]
                shot.impulse = J;
                testCase.verifyError(@() kickImpact(shot, testCase.par.ball, testCase.par.kick), ...
                    'PenaltyKick:kickImpact:ImpulseOutOfRange');
            end
        end

        function R7_aimOutsideRangeIsRejected(testCase)
            shot = testCase.par.shot;
            shot.aimElevation = -5;                            % into the ground
            testCase.verifyError(@() kickImpact(shot, testCase.par.ball, testCase.par.kick), ...
                'PenaltyKick:kickImpact:AimOutOfRange');
            shot = testCase.par.shot;
            shot.aimAzimuth = 90;                              % away from the goal
            testCase.verifyError(@() kickImpact(shot, testCase.par.ball, testCase.par.kick), ...
                'PenaltyKick:kickImpact:AimOutOfRange');
        end

        function R7_missingParameterIsReportedByName(testCase)
            kick = rmfield(testCase.par.kick, 'maxOffset');
            testCase.verifyError(@() kickImpact(testCase.par.shot, testCase.par.ball, kick), ...
                'PenaltyKick:requireFields:MissingParameter');
        end

    end
end
