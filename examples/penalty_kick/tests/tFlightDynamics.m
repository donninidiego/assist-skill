classdef tFlightDynamics < matlab.unittest.TestCase
% TFLIGHTDYNAMICS Verify block 2 (flight of the spinning ball) against analytic cases.
%
%   PHYSICAL CONTEXT:
%   Block 2 integrates gravity, drag and the Magnus force. Three limits are known
%   in closed form or by a conservation law: without air the path is a parabola
%   (R2); the Magnus force is perpendicular to the velocity and does no work, so
%   with Magnus only the mechanical energy is conserved (R3); drag only removes
%   energy. The sign of the lateral deflection must follow omega x v (R4).
%
%   Expected values: range v0^2 sin(2a)/g and apex (v0 sin a)^2/(2g) of the
%   parabola; E = m|v|^2/2 + m g z constant; mirror symmetry of the lateral
%   deflection for opposite lateral offsets.
%
%   Run:
%       results = runtests('tests/tFlightDynamics.m');
%
%   See also: FLIGHTDYNAMICS, KICKIMPACT, LOADTESTPARAMS

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

        %% ─── R2: no air, parabola ───────────────────────────────────────

        function R2_noAirGivesTheAnalyticParabola(testCase)
            p = testCase.par;
            p.flight.dragCoeff = 0;  p.flight.liftSlope = 0;  p.flight.liftMax = 0;
            p.goal.penaltyDistance_m = 100;               % far: the ground ends the flight
            v0 = 20;  a = 30;                             % [m/s], [deg]
            launch = testCase.makeLaunch(v0, a, [0; 0; 0], p.ball.radius_m);

            traj = flightDynamics(launch, p.ball, p.flight, p.goal);

            g = p.flight.gravity_ms2;
            testCase.verifyEqual(traj.endReason, "ground");
            testCase.verifyEqual(traj.position(1, end), v0^2*sind(2*a)/g, 'RelTol', 1e-6, ...
                'Range must be v0^2 sin(2a)/g without air.');
            testCase.verifyEqual(max(traj.position(3, :)) - p.ball.radius_m, ...
                (v0*sind(a))^2/(2*g), 'RelTol', 1e-3, ...
                'Apex height must be (v0 sin a)^2/(2g) without air.');
        end

        %% ─── R3: Magnus does no work ────────────────────────────────────

        function R3_magnusOnlyConservesMechanicalEnergy(testCase)
            p = testCase.par;
            p.flight.dragCoeff = 0;
            launch = testCase.makeLaunch(20, 10, [0; -100; 50], p.ball.radius_m);

            traj = flightDynamics(launch, p.ball, p.flight, p.goal);

            E = testCase.energy(traj, p);
            testCase.verifyLessThanOrEqual(max(abs(E - E(1))) / E(1), 1e-6, ...
                'Magnus is perpendicular to the velocity: it cannot change the energy.');
        end

        function R3_magnusOnlyWithoutGravityKeepsSpeedConstant(testCase)
            p = testCase.par;
            p.flight.dragCoeff = 0;  p.flight.gravity_ms2 = 0;
            launch = testCase.makeLaunch(20, 10, [0; -100; 50], p.ball.radius_m);

            traj = flightDynamics(launch, p.ball, p.flight, p.goal);

            speed = vecnorm(traj.velocity, 2, 1);
            testCase.verifyLessThanOrEqual(max(abs(speed - speed(1))) / speed(1), 1e-6);
        end

        function R3_zeroSpinGivesNoMagnusAndNoNaN(testCase)
            p = testCase.par;
            launch = testCase.makeLaunch(20, 10, [0; 0; 0], p.ball.radius_m);
            withLift = flightDynamics(launch, p.ball, p.flight, p.goal);
            p.flight.liftSlope = 0;  p.flight.liftMax = 0;
            noLift = flightDynamics(launch, p.ball, p.flight, p.goal);

            testCase.verifyFalse(any(isnan(withLift.position), 'all'), 'Zero spin must not give NaN.');
            testCase.verifyEqual(withLift.position, noLift.position, 'AbsTol', 0, ...
                'With zero spin the lift coefficient must have no effect.');
        end

        %% ─── Drag only removes energy ───────────────────────────────────

        function dragOnlyNeverIncreasesEnergy(testCase)
            p = testCase.par;
            p.flight.liftSlope = 0;  p.flight.liftMax = 0;
            launch = testCase.makeLaunch(25, 10, [0; 0; 0], p.ball.radius_m);

            traj = flightDynamics(launch, p.ball, p.flight, p.goal);

            E = testCase.energy(traj, p);
            testCase.verifyLessThanOrEqual(max(diff(E)), 1e-9*E(1), ...
                'Drag can only remove mechanical energy.');
            testCase.verifyLessThan(E(end), E(1), 'Drag must remove some energy.');
        end

        %% ─── R4: direction of the curve (end to end with block 1) ─────────

        function R4_offsetSideSetsTheDirectionOfTheCurve(testCase)
            p = testCase.par;
            shot = struct('offsetLateral', 0, 'offsetVertical', 0, 'impulse', 10.5, ...
                'aimAzimuth', 0, 'aimElevation', 10);

            yStraight = testCase.lateralAtGoal(shot, p);
            shot.offsetLateral = -0.5;   yRight = testCase.lateralAtGoal(shot, p);   % right of centre
            shot.offsetLateral = +0.5;   yLeft  = testCase.lateralAtGoal(shot, p);   % left of centre

            testCase.verifyLessThan(abs(yStraight), 1e-10, 'A centred straight kick must not drift sideways.');
            testCase.verifyGreaterThan(yRight, 0, 'Hit right of centre: counter-clockwise spin, curve to the left (+y).');
            testCase.verifyLessThan(yLeft, 0, 'Hit left of centre: clockwise spin, curve to the right (-y).');
            testCase.verifyEqual(yRight, -yLeft, 'RelTol', 1e-6, 'Opposite offsets must mirror each other.');
        end

        %% ─── Goal plane and failures ────────────────────────────────────

        function R2_defaultShotEndsAtTheGoalPlane(testCase)
            p = testCase.par;
            launch = kickImpact(p.shot, p.ball, p.kick);

            traj = flightDynamics(launch, p.ball, p.flight, p.goal);

            testCase.verifyEqual(traj.endReason, "goalPlane");
            testCase.verifyEqual(traj.position(1, end), p.goal.penaltyDistance_m, 'AbsTol', 1e-6);
            testCase.verifyEqual(traj.t(1), 0);
            testCase.verifyEqual(size(traj.position), size(traj.velocity));
        end

        function R7_noEventWithinTMaxIsAnError(testCase)
            p = testCase.par;
            p.flight.tMax_s = 0.01;
            launch = kickImpact(p.shot, p.ball, p.kick);
            testCase.verifyError(@() flightDynamics(launch, p.ball, p.flight, p.goal), ...
                'PenaltyKick:flightDynamics:NoEvent');
        end

        function R7_missingParameterIsReportedByName(testCase)
            p = testCase.par;
            flight = rmfield(p.flight, 'dragCoeff');
            launch = kickImpact(p.shot, p.ball, p.kick);
            testCase.verifyError(@() flightDynamics(launch, p.ball, flight, p.goal), ...
                'PenaltyKick:requireFields:MissingParameter');
        end

    end

    methods (Access = private)

        function launch = makeLaunch(~, speed, elevationDeg, spin, radius)
            % Launch state built by hand, so these tests do not depend on block 1.
            launch.position        = [0; 0; radius];
            launch.velocity        = speed * [cosd(elevationDeg); 0; sind(elevationDeg)];
            launch.spin            = spin;
            launch.speedEquivalent = speed;
        end

        function E = energy(~, traj, p)
            % Mechanical energy per sample, relative to the ground [J].
            E = 0.5*p.ball.mass_kg*sum(traj.velocity.^2, 1) ...
                + p.ball.mass_kg*p.flight.gravity_ms2*traj.position(3, :);
        end

        function y = lateralAtGoal(testCase, shot, p)
            launch = kickImpact(shot, p.ball, p.kick);
            traj   = flightDynamics(launch, p.ball, p.flight, p.goal);
            testCase.assertEqual(traj.endReason, "goalPlane", 'The test shot must reach the goal plane.');
            y = traj.position(2, end);
        end

    end
end
