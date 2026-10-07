classdef tExampleBlock < matlab.unittest.TestCase
% TEXAMPLEBLOCK Verify the example block against analytic values (test template).
%
%   PHYSICAL CONTEXT:
%   One test class per block, named t<Block>. The header says what the block
%   must guarantee and where the expected values come from. Here: the factor is
%   exactly gain at the preferred altitude, exactly 1 beyond the layer width,
%   and positive everywhere, which is the hypothesis the theory needs.
%
%   Expected values are analytic: k = 1 + (gain - 1) * max(0, 1 - t^2).
%
%   Run:
%       results = runtests('tests/tExampleBlock.m');
%
%   See also: EXAMPLEBLOCK, LOADTESTPARAMS

    properties
        par    % parameters of parameters.m, adapted to the case
        grid   % minimal grid struct
    end

    methods (TestClassSetup)
        function addSourcePath(~)
            here = fileparts(mfilename('fullpath'));
            addpath(genpath(fullfile(here, '..', 'src')));
        end
    end

    methods (TestMethodSetup)
        function buildGrid(testCase)
            testCase.par         = loadTestParams();
            d                    = testCase.par.domain;
            testCase.grid.z_levels       = (0:d.dz_m:d.max_altitude_m)';
            testCase.grid.ref_altitude_m = d.ref_altitude_m;
        end
    end

    methods (Test)

        %% ─── Values required by the theory ───────────────────────────────

        function factorEqualsGainAtPreferredAltitude(testCase)
            k = exampleBlock(testCase.grid, testCase.par.example);
            [~, i] = min(abs(testCase.grid.z_levels - testCase.grid.ref_altitude_m));
            testCase.verifyEqual(k(i), testCase.par.example.gain, 'AbsTol', 1e-12, ...
                'At the preferred altitude the factor must equal gain.');
        end

        function factorIsOneBeyondTheLayerWidth(testCase)
            k = exampleBlock(testCase.grid, testCase.par.example);
            far = abs(testCase.grid.z_levels - testCase.grid.ref_altitude_m) ...
                  >= testCase.par.example.width_m;
            testCase.verifyEqual(k(far), ones(nnz(far), 1), 'AbsTol', 1e-12, ...
                'Beyond width_m there must be no effect.');
        end

        function factorIsStrictlyPositive(testCase)
            ex = testCase.par.example;  ex.gain = 0.01;   % strongly penalizing layer
            k  = exampleBlock(testCase.grid, ex);
            testCase.verifyGreaterThan(k, 0, 'Condition K > 0 must hold.');
        end

        %% ─── Failures the assertions promise ─────────────────────────────

        function nonPositiveGainIsRejected(testCase)
            ex = testCase.par.example;  ex.gain = 0;
            testCase.verifyError(@() exampleBlock(testCase.grid, ex), ...
                'Project:exampleBlock:InvalidGain');
        end

        function missingParameterIsReportedByName(testCase)
            ex = rmfield(testCase.par.example, 'width_m');
            testCase.verifyError(@() exampleBlock(testCase.grid, ex), ...
                'Project:requireFields:MissingParameter');
        end

    end
end
