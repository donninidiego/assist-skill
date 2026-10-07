%[text] # Penalty kick: step by step
%[text] This demo kicks a football at a goal and follows the chain of blocks **one step at a time**. It is a deliberately silly example, written to show the `/assist` workflow on something small. Every step has the same parts:
%[text] 1. the **inputs**: what is fed into the block, before any effect is shown;
%[text] 2. the **run**: the block is called with the sub-structs of `par` it needs;
%[text] 3. the **result**: a figure and a printed numeric check;
%[text] 4. the **entry into the next block**: how the output is used downstream. \
%[text] The last step, **Your shot**, is yours: five **sliders** choose where to hit the ball and how hard, and the kick is replayed in slow motion with the ball spinning.
%[text] **Run time:** about 5 s for the whole script (4.3 s measured on 2026-10-07 when it was run from the command window), of which 2.5 s are the slow-motion animation of step 4; the total is printed at the end of the file. Every number printed below is measured, not assumed.
%[text] **Caution:** the drag and lift coefficients are *illustrative* (decision D9). They give plausible shapes, not predictions of real kicks.
%[text:tableOfContents]{"heading":"Contents"}
%%
%[text] ## The idea on one page
%[text] The foot gives the ball an **impulse** $ J $ (a force acting for a very short time) in the direction $ \\hat{\\mathbf{d}} $ it is moving. If the line of the impulse goes through the centre of the ball, the ball only translates. If it passes at a distance $ \\mathbf{r} $ from the centre, the impulse also has a moment about the centre and the ball starts to **spin**:
%[text] $ m\\,\\mathbf{v}\_0 = J\\,\\hat{\\mathbf{d}}, \\qquad I\\,\\mathbf{\\omega}\_0 = \\mathbf{r} \\times J\\,\\hat{\\mathbf{d}}, \\qquad I = \\frac{2}{3}\\,m R^2 $
%[text] In flight, gravity pulls the ball down, the air resists it (**drag**) and, because it spins, the air also pushes it sideways (the **Magnus force**, perpendicular to both the spin axis and the velocity):
%[text] $ m\\,\\dot{\\mathbf{v}} = -m g\\,\\hat{\\mathbf{z}} - \\frac{1}{2}\\rho\\, C\_d A\\, |\\mathbf{v}|\\,\\mathbf{v} + \\frac{1}{2}\\rho\\, C\_l A\\, |\\mathbf{v}|^2\\,(\\hat{\\mathbf{\\omega}} \\times \\hat{\\mathbf{v}}) $
%[text] Finally the shot is judged where the ball crosses the goal plane. The chain of blocks:
%[text:table]
%[text] | Block | Folder | Role |
%[text] | --- | --- | --- |
%[text] | 1 `kickImpact` | `src/1_kick` | impact point and strength to velocity and spin |
%[text] | 2 `flightDynamics` | `src/2_flight` | path under gravity, drag and Magnus |
%[text] | 3 `classifyShot` | `src/3_outcome` | GOAL, POST, CROSSBAR, WIDE, HIGH or SHORT |
%[text] | 4 `animateShot`, `drawImpactPoint`, `drawVerdict` | `src/4_visualization` | figures only |
%[text:table]
%[text] **Frame:** origin on the ground at the penalty mark, $ x $ towards the goal, $ y $ to the left looking at the goal, $ z $ up. The ball centre starts at height $ R $.
%%
%[text] ## Setup
%[text] `par` (created by `parameters.m`) holds all parameters, in sub-structs that follow the chain. You may change values in `parameters.m`; the demo reads them from there.
tStart = tic;
% The Live Editor does not change the current folder: parameters.m is searched from pwd, which must be examples/ or the project root.
repoRoot = fileparts(pwd);
if ~isfile(fullfile(repoRoot, 'parameters.m'))
    cand = {pwd, fileparts(pwd)};
    ok   = cellfun(@(d) isfile(fullfile(d, 'parameters.m')), cand);
    assert(any(ok), 'Current folder not recognized: set the project examples/ folder as current folder.');
    repoRoot = cand{find(ok, 1)};
end
addpath(genpath(fullfile(repoRoot, 'src')));   % every folder of src/ at once
run(fullfile(repoRoot, 'parameters.m'));       % (re)builds the struct par from the parameters file
%%
%[text] ## Step 1: the kick (block 1)
%[text] **Idea.** Where the foot touches the ball sets the spin; how hard it hits sets the speed. The impact point is given as a fraction of the radius, seen from behind the kick: *lateral* positive to the left of the centre, *vertical* positive above it.
%[text] **Inputs first.** The reference shot `par.shot`, used in steps 1 to 3.
shot = par.shot;                               % reference shot, from parameters.m
fprintf('[Step1] impact point: lateral %+.2f R, vertical %+.2f R\n', shot.offsetLateral, shot.offsetVertical); %[output:98975cbb]
fprintf('[Step1] impulse J = %.1f N s, aim: azimuth %.1f deg, elevation %.1f deg\n', shot.impulse, shot.aimAzimuth, shot.aimElevation); %[output:102f2b7c]
%[text] **Run.**
launch = kickImpact(shot, par.ball, par.kick);
fprintf('[Step1] launch speed |v0| = J/m = %.2f m/s\n', launch.speedEquivalent); %[output:027d8e8d]
fprintf('[Step1] spin omega0 = [%.1f %.1f %.1f] rad/s, |omega0| = %.1f rev/s\n', launch.spin, norm(launch.spin)/(2*pi)); %[output:26ada53d]
%[text] **Result.** The impact point on the ball, and the three components of the spin it produced.
tiledlayout(1, 2);
drawImpactPoint(nexttile, shot, par.kick.maxOffset);
ax = nexttile;
bar(ax, 1:3, launch.spin, 'FaceColor', [0.45 0.45 0.45]);
xticks(ax, 1:3);  xticklabels(ax, {'x (roll)', 'y (negative: backspin)', 'z (positive: curls left)'});
ylabel(ax, 'spin component [rad/s]');  title(ax, 'Spin produced');
%[text] **How it enters the next block.** `launch` (position, velocity, spin) is the initial state of the flight.
%[text] **What to observe:** the dot sits below and to the right of the centre of the circle, and the bars show a negative y component (backspin, which lifts the ball) and a positive z component (a spin that curls the ball to the left). If the dot were above the centre the y component would turn positive.
%[text] **Numeric checks (printed).** A hit through the centre must give exactly zero spin (R1); the momentum and the spin must satisfy $ m\\,v\_0 = J $ and $ |\\mathbf{\\omega}\_0| = R\\,J\\,|\\mathrm{offset}| / I $ (R5).
shotCentre = shot;  shotCentre.offsetLateral = 0;  shotCentre.offsetVertical = 0;
launchCentre = kickImpact(shotCentre, par.ball, par.kick);
fprintf('[Check R1] centred hit: |spin| = %g rad/s (expected exactly 0)\n', norm(launchCentre.spin)); %[output:59abe867]
assert(norm(launchCentre.spin) == 0, 'A hit through the centre must give zero spin.');
inertia      = par.ball.inertiaFactor * par.ball.mass_kg * par.ball.radius_m^2;                      % [kg m^2]
spinExpected = par.ball.radius_m * shot.impulse * hypot(shot.offsetLateral, shot.offsetVertical) / inertia;   % [rad/s]
fprintf('[Check R5] |spin| = %.4f rad/s, expected R*J*|offset|/I = %.4f rad/s\n', norm(launch.spin), spinExpected); %[output:438daa56]
fprintf('[Check R5] m*|v0| = %.6f N s, J = %.6f N s\n', par.ball.mass_kg*norm(launch.velocity), shot.impulse); %[output:4f8f1a6f]
assert(abs(norm(launch.spin) - spinExpected) < 1e-9*spinExpected, 'Spin magnitude differs from the theory.');
assert(abs(par.ball.mass_kg*norm(launch.velocity) - shot.impulse) < 1e-9*shot.impulse, 'Momentum differs from the impulse.');
%%
%[text] ## Step 2: the flight (block 2)
%[text] **Idea.** Add the forces one at a time to see what each does: first no air at all, then drag only, then drag and Magnus. All three start from the same `launch`.
%[text] **Inputs first.** The same launch state, and three versions of `par.flight` that differ only in the coefficients.
flightVacuum = par.flight;  flightVacuum.dragCoeff = 0;  flightVacuum.liftSlope = 0;  flightVacuum.liftMax = 0;   % no air
flightDrag   = par.flight;  flightDrag.liftSlope = 0;    flightDrag.liftMax = 0;                                  % drag only
%[text] **Run.**
trajVacuum = flightDynamics(launch, par.ball, flightVacuum, par.goal);
trajDrag   = flightDynamics(launch, par.ball, flightDrag, par.goal);
trajFull   = flightDynamics(launch, par.ball, par.flight, par.goal);
%[text] **Result.** Side view and view from above of the three paths, up to the goal plane.
tiledlayout(1, 2);
ax1 = nexttile;  hold(ax1, 'on');
plot(ax1, trajVacuum.position(1, :), trajVacuum.position(3, :), '--', 'Color', [0.65 0.65 0.65], 'LineWidth', 1.5);
plot(ax1, trajDrag.position(1, :),   trajDrag.position(3, :),   '-.', 'Color', [0.40 0.40 0.40], 'LineWidth', 1.5);
plot(ax1, trajFull.position(1, :),   trajFull.position(3, :),   '-',  'Color', [0.10 0.10 0.10], 'LineWidth', 1.5);
yline(ax1, par.goal.height_m, ':', 'crossbar', 'LabelHorizontalAlignment', 'left');
xline(ax1, par.goal.penaltyDistance_m, ':', 'goal plane');
grid(ax1, 'on');  xlabel(ax1, 'x towards the goal [m]');  ylabel(ax1, 'z, up [m]');  title(ax1, 'Side view');
legend(ax1, {'no air', 'drag only', 'drag and Magnus'}, 'Location', 'northwest');
ax2 = nexttile;  hold(ax2, 'on');
plot(ax2, trajVacuum.position(1, :), trajVacuum.position(2, :), '--', 'Color', [0.65 0.65 0.65], 'LineWidth', 1.5);
plot(ax2, trajDrag.position(1, :),   trajDrag.position(2, :),   '-.', 'Color', [0.40 0.40 0.40], 'LineWidth', 1.5);
plot(ax2, trajFull.position(1, :),   trajFull.position(2, :),   '-',  'Color', [0.10 0.10 0.10], 'LineWidth', 1.5);
xline(ax2, par.goal.penaltyDistance_m, ':', 'goal plane');
grid(ax2, 'on');  xlabel(ax2, 'x towards the goal [m]');  ylabel(ax2, 'y, left [m]');  title(ax2, 'Seen from above');
%[text] **Numbers at the goal plane** (one row per case):
cases = {"no air", trajVacuum; "drag only", trajDrag; "drag and Magnus", trajFull};
rows  = cellfun(@(t) [t.t(end), t.position(2:3, end)', norm(t.velocity(:, end))], cases(:, 2), 'UniformOutput', false);
rows  = vertcat(rows{:});
disp(table(string(cases(:, 1)), rows(:, 1), rows(:, 2), rows(:, 3), rows(:, 4), 'VariableNames', ... %[output:group:2a42ee77] %[output:5c337516]
    {'case', 'time_s', 'y_m', 'z_m', 'speed_ms'})); %[output:group:2a42ee77] %[output:5c337516]
fprintf('[Step2] drag changes the height at the goal plane by %+.3f m and the speed by %+.2f m/s\n', ... %[output:group:9931f0fe] %[output:951972c1]
    trajDrag.position(3, end) - trajVacuum.position(3, end), norm(trajDrag.velocity(:, end)) - norm(trajVacuum.velocity(:, end))); %[output:group:9931f0fe] %[output:951972c1]
fprintf('[Step2] Magnus changes the lateral position by %+.3f m and the height by %+.3f m\n', ... %[output:group:3fa22ccb] %[output:118fcd13]
    trajFull.position(2, end) - trajDrag.position(2, end), trajFull.position(3, end) - trajDrag.position(3, end)); %[output:group:3fa22ccb] %[output:118fcd13]
%[text] **How it enters the next block.** `trajFull` (the full model) is judged in step 3.
%[text] **What to observe:** the grey dashed path (no air) is the reference parabola; the other two are the same shot with air. The printed differences say what drag and Magnus each did. The lateral position is zero for the first two cases and non-zero only with Magnus, because without spin there is nothing to push the ball sideways.
%[text] **Numeric checks (printed).** Without air the range must equal the analytic parabola (R2); with the Magnus force alone the mechanical energy must be conserved, because that force does no work (R3).
goalFar      = par.goal;  goalFar.penaltyDistance_m = 100;                   % far goal: the ground ends the flight
trajRange    = flightDynamics(launch, par.ball, flightVacuum, goalFar);
rangeNumeric = hypot(trajRange.position(1, end), trajRange.position(2, end));                   % [m]
rangeTheory  = 2*hypot(launch.velocity(1), launch.velocity(2))*launch.velocity(3)/par.flight.gravity_ms2;   % [m] 2 vh vz / g
fprintf('[Check R2] range without air: %.4f m, analytic 2*vh*vz/g = %.4f m, relative error %.1e\n', ... %[output:group:455b1d9a] %[output:6c2592cd]
    rangeNumeric, rangeTheory, abs(rangeNumeric - rangeTheory)/rangeTheory); %[output:group:455b1d9a] %[output:6c2592cd]
assert(abs(rangeNumeric - rangeTheory) < 1e-6*rangeTheory, 'Range without air must match the parabola.');
flightMagnus = par.flight;  flightMagnus.dragCoeff = 0;
trajMagnus   = flightDynamics(launch, par.ball, flightMagnus, par.goal);
energy       = mechanicalEnergy(trajMagnus, par);
fprintf('[Check R3] Magnus only: largest relative change of the mechanical energy %.1e (tolerance 1e-6)\n', max(abs(energy - energy(1)))/energy(1)); %[output:52ab07de]
assert(max(abs(energy - energy(1)))/energy(1) < 1e-6, 'The Magnus force must not change the mechanical energy.');
%%
%[text] ## Step 3: the verdict (block 3)
%[text] **Idea.** At the instant the centre of the ball crosses the goal plane, the ball is a disc of radius $ R $ and the goal is a frame of two posts and a crossbar. The disc is judged against the frame; if the ball landed first, the shot is SHORT.
%[text] **Inputs first.** The path of the full model and the goal geometry in `par.goal`.
%[text] **Run.**
result = classifyShot(trajFull, par.ball, par.goal);
fprintf('[Step3] outcome: %s, ball centre at the goal plane: y = %+.3f m, z = %.3f m\n', result.label, result.yAtGoal, result.zAtGoal); %[output:816c1beb]
%[text] **Result.** The goal seen from the kicker, with the ball at the instant it crosses the plane.
tiledlayout(1, 1);
drawVerdict(nexttile, result, par);
%[text] **What to observe:** the disc lies entirely inside the opening of the frame (green) for GOAL; a red disc touches or lies outside the frame. The disc is drawn at the true size of the ball.
%[text] **Every outcome.** Six shots, each with its own impact point, strength and aim. **Top row:** where the foot hits the ball, seen from behind (the dashed circle is the limit of admissible impact points). **Bottom row:** the verdict on the goal (the ball is drawn 4 times larger than real, so that it can be seen).
tour = struct('name', {"reference", "side spin|aim 12 deg", "side spin|aim 14 deg", "backspin|elev. 12 deg", "backspin|elev. 14 deg", "topspin|above centre"}, ...
              'change', {struct(), ...
                         struct('offsetLateral', -0.6, 'offsetVertical', 0, 'aimAzimuth', 12), ...
                         struct('offsetLateral', -0.6, 'offsetVertical', 0, 'aimAzimuth', 14), ...
                         struct('offsetVertical', -0.7, 'aimElevation', 12), ...
                         struct('offsetVertical', -0.7, 'aimElevation', 14), ...
                         struct('offsetVertical', 0.3)});
nTour = numel(tour);
tourShots = repmat(par.shot, 1, nTour);  tourResults = cell(1, nTour);
for i = 1:nTour
    s = par.shot;                                                       % every case starts from the reference shot
    for f = string(fieldnames(tour(i).change))'
        s.(f) = tour(i).change.(f);                                     % and changes only the inputs listed for it
    end
    tourShots(i) = s;
    tourResults{i} = takeShot(s, par);
end
tiledlayout(2, nTour, 'TileSpacing', 'compact');
for i = 1:nTour
    ax = nexttile(i);
    drawImpactPoint(ax, tourShots(i), par.kick.maxOffset, Labels=false);
    title(ax, strsplit(tour(i).name, '|'), 'FontSize', 8);
end
for i = 1:nTour
    drawVerdict(nexttile(nTour + i), tourResults{i}, par, Labels=false, BallScale=par.animation.ballDrawScale);
end
tourOutcome = cellfun(@(r) r.label, tourResults)';
disp([table(replace([tour.name]', '|', ' '), 'VariableNames', {'case'}), struct2table(tourShots(:)), ... %[output:group:53b15e6c] %[output:0b0db7c9]
    table(tourOutcome, cellfun(@(r) r.yAtGoal, tourResults)', cellfun(@(r) r.zAtGoal, tourResults)', ... %[output:0b0db7c9]
    'VariableNames', {'outcome', 'y_m', 'z_m'})]); %[output:group:53b15e6c] %[output:0b0db7c9]
if ~isequal(tourOutcome', ["GOAL", "POST", "WIDE", "CROSSBAR", "HIGH", "SHORT"])
    warning('The tour no longer shows the six outcomes in this order: the parameters changed, pick new values.');
end
%[text] **What to observe:** each column pairs the impact point (top) with what it did to the shot (bottom). A strong side spin aimed 12 or 14 degrees to the left curls the ball onto the post and then outside it; a strong backspin lifts it onto the crossbar and then over it; a hit above the centre gives topspin, and the ball dips and falls short. The table lists the inputs of each case.
%[text] **How it enters the next block.** Nothing: the verdict is the end of the chain. `takeShot` runs steps 1 to 3 in one call, as step 4 does.
%%
%[text] ## Step 4: your shot
%[text] Drag the five sliders. Releasing a slider re-runs this section, which kicks the ball and replays the flight in slow motion: the impact point on the ball, the flight with the ball turning, and the verdict on the goal. Changing the **impact point** changes the spin: below the centre gives backspin (the ball rises), above gives topspin (it dips), to the side curls it. Changing the **strength** changes the speed.
%[text] The slider limits are the admissible ranges of `par.kick` (a test checks that they match): offset up to 0.8 of the radius, impulse 3 to 15 N s, azimuth +/-45 deg, elevation 1 to 60 deg (our choices, not measurements). The two offset sliders can reach the corner of their square, which lies outside the circle of admissible impact points: then the point is moved onto the circle and the output says so.
myShot.offsetLateral  = -0.3;   % [-] impact point, left of centre positive, fraction of the radius %[control:slider:f4a1]{"position":[25,29]}
myShot.offsetVertical = -0.3;   % [-] impact point, above centre positive, fraction of the radius %[control:slider:7c2e]{"position":[25,29]}
myShot.impulse        = 11;     % [N s] strength of the kick (J/m gives the launch speed) %[control:slider:91d3]{"position":[25,27]}
myShot.aimAzimuth     = -2;     % [deg] aim to the left (+) or right (-) of the goal centre %[control:slider:3b8a]{"position":[25,27]}
myShot.aimElevation   = 11;     % [deg] aim above the ground %[control:slider:e60d]{"position":[25,27]}
requested = myShot;
myShot = clampImpactPoint(myShot, par.kick);   % two sliders can reach the corner of the square: move the point onto the admissible circle
if ~isequal(myShot, requested)
    fprintf('[Your shot] the impact point (%+.2f, %+.2f) R is outside the admissible circle (%.2f R): moved to (%+.2f, %+.2f) R\n', ...
        requested.offsetLateral, requested.offsetVertical, par.kick.maxOffset, myShot.offsetLateral, myShot.offsetVertical);
end
[myResult, myTraj, myLaunch] = takeShot(myShot, par);
animateShot(myShot, myTraj, myResult, par);
fprintf('[Your shot] outcome: %s\n', myResult.label); %[output:0ddeb9c5]
fprintf('[Your shot] launch speed %.1f m/s, spin %.1f rev/s, flight time %.2f s\n', myLaunch.speedEquivalent, norm(myLaunch.spin)/(2*pi), myResult.flightTime); %[output:2185aad7]
fprintf('[Your shot] ball centre at the goal plane: y = %+.2f m, z = %.2f m (goal: |y| < %.2f m, z < %.2f m, ball radius %.2f m)\n', ... %[output:group:12e82db1] %[output:3c2f139b]
    myResult.yAtGoal, myResult.zAtGoal, par.goal.width_m/2, par.goal.height_m, par.ball.radius_m); %[output:group:12e82db1] %[output:3c2f139b]
%[text] **What to observe:** the colour of the end marker (green for GOAL, red otherwise), the title and the right-hand picture agree with the printed outcome. A SHORT shot has no position at the goal plane (NaN).
%%
%[text] ## Result
%[text] The reference shot against your shot (run the section above first; the table shows the last kick):
disp(table(["reference"; "your shot"], [shot.impulse; myShot.impulse], [launch.speedEquivalent; myLaunch.speedEquivalent], ... %[output:group:58c2b5d1] %[output:5aa17fdb]
    [norm(launch.spin)/(2*pi); norm(myLaunch.spin)/(2*pi)], [result.label; myResult.label], ... %[output:5aa17fdb]
    [result.yAtGoal; myResult.yAtGoal], [result.zAtGoal; myResult.zAtGoal], 'VariableNames', ... %[output:5aa17fdb]
    {'shot', 'impulse_Ns', 'speed_ms', 'spin_revs', 'outcome', 'y_m', 'z_m'})); %[output:group:58c2b5d1] %[output:5aa17fdb]
fprintf('Total time: %.1f s\n', toc(tStart)); %[output:7c38d85d]
%%
%[text] ## Key points
%[text] - The impact point matters only through the spin: a centred hit gives exactly zero spin (checked in step 1).
%[text] - Without air the path is the analytic parabola; air and spin move it away from the parabola by the amounts printed in step 2.
%[text] - The Magnus force bends the path but does no work: the mechanical energy is conserved when it acts alone (checked in step 2).
%[text] - A shot is judged by one geometric rule at the goal plane, with six possible outcomes (step 3), and the impact point alone can turn a goal into a shot that falls short.
%[text] - The drag and lift coefficients are illustrative: the shapes are meaningful, the numbers are not predictions. \
%%
function energy = mechanicalEnergy(traj, par)
% MECHANICALENERGY Kinetic plus potential energy of the ball at every sample [J].
    energy = 0.5*par.ball.mass_kg*sum(traj.velocity.^2, 1) + par.ball.mass_kg*par.flight.gravity_ms2*traj.position(3, :);
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[control:slider:f4a1]
%   data: {"defaultValue":-0.3,"label":"Impact point, lateral (left +) [R]","max":0.8,"min":-0.8,"run":"Section","runOn":"ValueChanged","step":0.05}
%---
%[control:slider:7c2e]
%   data: {"defaultValue":-0.3,"label":"Impact point, vertical (above +) [R]","max":0.8,"min":-0.8,"run":"Section","runOn":"ValueChanged","step":0.05}
%---
%[control:slider:91d3]
%   data: {"defaultValue":11,"label":"Strength, impulse J [N s]","max":15,"min":3,"run":"Section","runOn":"ValueChanged","step":0.5}
%---
%[control:slider:3b8a]
%   data: {"defaultValue":-2,"label":"Aim, azimuth (left +) [deg]","max":45,"min":-45,"run":"Section","runOn":"ValueChanged","step":1}
%---
%[control:slider:e60d]
%   data: {"defaultValue":11,"label":"Aim, elevation [deg]","max":60,"min":1,"run":"Section","runOn":"ValueChanged","step":1}
%---
%[output:98975cbb]
%   data: {"dataType":"text","outputData":{"text":"[Step1] impact point: lateral -0.20 R, vertical -0.10 R\n","truncated":false}}
%---
%[output:102f2b7c]
%   data: {"dataType":"text","outputData":{"text":"[Step1] impulse J = 10.5 N s, aim: azimuth 0.0 deg, elevation 8.0 deg\n","truncated":false}}
%---
%[output:027d8e8d]
%   data: {"dataType":"text","outputData":{"text":"[Step1] launch speed |v0| = J\/m = 24.42 m\/s\n","truncated":false}}
%---
%[output:26ada53d]
%   data: {"dataType":"text","outputData":{"text":"[Step1] spin omega0 = [-9.3 -33.3 65.9] rad\/s, |omega0| = 11.9 rev\/s\n","truncated":false}}
%---
%[output:59abe867]
%   data: {"dataType":"text","outputData":{"text":"[Check R1] centred hit: |spin| = 0 rad\/s (expected exactly 0)\n","truncated":false}}
%---
%[output:438daa56]
%   data: {"dataType":"text","outputData":{"text":"[Check R5] |spin| = 74.4568 rad\/s, expected R*J*|offset|\/I = 74.4568 rad\/s\n","truncated":false}}
%---
%[output:4f8f1a6f]
%   data: {"dataType":"text","outputData":{"text":"[Check R5] m*|v0| = 10.500000 N s, J = 10.500000 N s\n","truncated":false}}
%---
%[output:5c337516]
%   data: {"dataType":"text","outputData":{"text":"          <strong>case<\/strong>           <strong>time_s<\/strong>      <strong>y_m<\/strong>        <strong>z_m<\/strong>      <strong>speed_ms<\/strong>\n    <strong>_________________<\/strong>    <strong>_______<\/strong>    <strong>______<\/strong>    <strong>_______<\/strong>    <strong>________<\/strong>\n\n    \"no air\"              0.4549         0    0.64092     24.204 \n    \"drag only\"           0.4899         0    0.53402     20.948 \n    \"drag and Magnus\"    0.49172    0.5145    0.78555     20.835 \n\n","truncated":false}}
%---
%[output:951972c1]
%   data: {"dataType":"text","outputData":{"text":"[Step2] drag changes the height at the goal plane by -0.107 m and the speed by -3.26 m\/s\n","truncated":false}}
%---
%[output:118fcd13]
%   data: {"dataType":"text","outputData":{"text":"[Step2] Magnus changes the lateral position by +0.515 m and the height by +0.252 m\n","truncated":false}}
%---
%[output:6c2592cd]
%   data: {"dataType":"text","outputData":{"text":"[Check R2] range without air: 16.7537 m, analytic 2*vh*vz\/g = 16.7537 m, relative error 2.1e-16\n","truncated":false}}
%---
%[output:52ab07de]
%   data: {"dataType":"text","outputData":{"text":"[Check R3] Magnus only: largest relative change of the mechanical energy 8.4e-15 (tolerance 1e-6)\n","truncated":false}}
%---
%[output:816c1beb]
%   data: {"dataType":"text","outputData":{"text":"[Step3] outcome: GOAL, ball centre at the goal plane: y = +0.515 m, z = 0.786 m\n","truncated":false}}
%---
%[output:0b0db7c9]
%   data: {"dataType":"text","outputData":{"text":"             <strong>case<\/strong>              <strong>offsetLateral<\/strong>    <strong>offsetVertical<\/strong>    <strong>impulse<\/strong>    <strong>aimAzimuth<\/strong>    <strong>aimElevation<\/strong>     <strong>outcome<\/strong>        <strong>y_m<\/strong>        <strong>z_m<\/strong>  \n    <strong>_______________________<\/strong>    <strong>_____________<\/strong>    <strong>______________<\/strong>    <strong>_______<\/strong>    <strong>__________<\/strong>    <strong>____________<\/strong>    <strong>__________<\/strong>    <strong>_______<\/strong>    <strong>_______<\/strong>\n\n    \"reference\"                    -0.2              -0.1          10.5           0              8         \"GOAL\"         0.5145    0.78555\n    \"side spin aim 12 deg\"         -0.6                 0          10.5          12              8         \"POST\"         3.6152      0.473\n    \"side spin aim 14 deg\"         -0.6                 0          10.5          14              8         \"WIDE\"         4.0628    0.45929\n    \"backspin elev. 12 deg\"        -0.2              -0.7          10.5           0             12         \"CROSSBAR\"    0.32743     2.4145\n    \"backspin elev. 14 deg\"        -0.2              -0.7          10.5           0             14         \"HIGH\"        0.33368     2.8204\n    \"topspin above centre\"         -0.2               0.3          10.5           0              8         \"SHORT\"           NaN        NaN\n\n","truncated":false}}
%---
%[output:0ddeb9c5]
%   data: {"dataType":"text","outputData":{"text":"[Your shot] outcome: GOAL\n","truncated":false}}
%---
%[output:2185aad7]
%   data: {"dataType":"text","outputData":{"text":"[Your shot] launch speed 25.6 m\/s, spin 23.6 rev\/s, flight time 0.48 s\n","truncated":false}}
%---
%[output:3c2f139b]
%   data: {"dataType":"text","outputData":{"text":"[Your shot] ball centre at the goal plane: y = +0.41 m, z = 1.98 m (goal: |y| < 3.66 m, z < 2.44 m, ball radius 0.11 m)\n","truncated":false}}
%---
%[output:5aa17fdb]
%   data: {"dataType":"text","outputData":{"text":"       <strong>shot<\/strong>        <strong>impulse_Ns<\/strong>    <strong>speed_ms<\/strong>    <strong>spin_revs<\/strong>    <strong>outcome<\/strong>      <strong>y_m<\/strong>        <strong>z_m<\/strong>  \n    <strong>___________<\/strong>    <strong>__________<\/strong>    <strong>________<\/strong>    <strong>_________<\/strong>    <strong>_______<\/strong>    <strong>_______<\/strong>    <strong>_______<\/strong>\n\n    \"reference\"       10.5        24.419       11.85      \"GOAL\"      0.5145    0.78555\n    \"your shot\"         11        25.581      23.555      \"GOAL\"     0.41087     1.9812\n\n","truncated":false}}
%---
%[output:7c38d85d]
%   data: {"dataType":"text","outputData":{"text":"Total time: 4.3 s\n","truncated":false}}
%---
