classdef tWalkthroughControls < matlab.unittest.TestCase
% TWALKTHROUGHCONTROLS Verify the sliders of the demo's "Your shot" section against par.kick (R9).
%
%   PHYSICAL CONTEXT:
%   A slider of the Live Editor keeps its limits in the file, where it cannot read
%   parameters.m. To avoid a second truth, this test reads the demo as text and checks
%   that there is one slider per input of the shot, that each tag points exactly at the
%   number it controls, that the limits are the admissible ranges of par.kick and that
%   the starting value lies inside them.
%
%   The format read here is the plain-text Live Code of MATLAB R2026a: a tag
%   %[control:slider:ID]{"position":[c1,c2]} at the end of the code line, and an
%   appendix entry %[control:slider:ID] with a data line holding the JSON.
%
%   Run:
%       results = runtests('tests/tWalkthroughControls.m');
%
%   See also: LOADTESTPARAMS, CLAMPIMPACTPOINT

    properties
        par       % parameters of parameters.m
        text      % demo file as text
        sliders   % struct array: variable, lineText, id, position, limits, step, value
    end

    methods (TestMethodSetup)
        function readDemo(testCase)
            testCase.par = loadTestParams();
            here = fileparts(mfilename('fullpath'));
            testCase.text = fileread(fullfile(here, '..', 'examples', 'PenaltyKickWalkthrough.m'));
            lines = splitlines(string(testCase.text));
            tagged = lines(contains(lines, '%[control:slider:'));
            s = struct('variable', {}, 'lineText', {}, 'id', {}, 'position', {}, 'limits', {}, 'step', {}, 'value', {});
            for i = 1:numel(tagged)
                tok = regexp(char(tagged(i)), '^(myShot\.\w+)\s*=.*%\[control:slider:(\w+)\]\{"position":\[(\d+),(\d+)\]\}\s*$', 'tokens', 'once');
                if isempty(tok), continue; end
                entry = regexp(testCase.text, ['%\[control:slider:' tok{2} '\]\s*\n%\s+data: (\{[^\n]*\})'], 'tokens', 'once');
                data = struct('min', NaN, 'max', NaN, 'step', NaN, 'defaultValue', NaN);
                if ~isempty(entry), data = jsondecode(entry{1}); end
                s(end+1) = struct('variable', tok{1}, 'lineText', char(tagged(i)), 'id', tok{2}, ...
                    'position', [str2double(tok{3}), str2double(tok{4})], 'limits', [data.min, data.max], ...
                    'step', data.step, 'value', data.defaultValue); %#ok<AGROW>
            end
            testCase.sliders = s;
        end
    end

    methods (Test)

        function R9_oneSliderPerInputOfTheShot(testCase)
            vars = string({testCase.sliders.variable});
            expected = "myShot." + ["offsetLateral", "offsetVertical", "impulse", "aimAzimuth", "aimElevation"];
            testCase.verifyEqual(sort(vars), sort(expected));
        end

        function R9_eachTagPointsAtTheNumberItControls(testCase)
            testCase.assertNumElements(testCase.sliders, 5, "The demo must contain the five sliders.");
            for s = testCase.sliders
                line = s.lineText;
                literal = line(s.position(1):s.position(2)-1);
                rhs = regexp(line, '=\s*(-?[0-9.]+)\s*;', 'tokens', 'once');
                testCase.verifyEqual(strtrim(literal), rhs{1}, [s.variable ': tag position does not match the number']);
                testCase.verifyEqual(str2double(literal), s.value, 'AbsTol', 1e-12, ...
                    [s.variable ': defaultValue differs from the number in the code']);
            end
        end

        function R9_limitsAreTheKickRangesOfParameters(testCase)
            testCase.assertNumElements(testCase.sliders, 5, "The demo must contain the five sliders.");
            k = testCase.par.kick;
            expected = struct('offsetLateral', k.maxOffset*[-1 1], 'offsetVertical', k.maxOffset*[-1 1], ...
                'impulse', k.impulseRange_Ns, 'aimAzimuth', k.azimuthRange_deg, 'aimElevation', k.elevationRange_deg);
            for s = testCase.sliders
                name = extractAfter(s.variable, 'myShot.');
                testCase.verifyEqual(s.limits, expected.(name), 'AbsTol', 1e-12, ...
                    [s.variable ': slider limits must equal the ranges in par.kick']);
                testCase.verifyGreaterThan(s.step, 0);
                testCase.verifyGreaterThanOrEqual(s.value, s.limits(1));
                testCase.verifyLessThanOrEqual(s.value, s.limits(2));
            end
        end

        function R9_aSliderRerunsTheSectionWhenReleased(testCase)
            testCase.assertNumElements(testCase.sliders, 5, "The demo must contain the five sliders.");
            for s = testCase.sliders
                entry = regexp(testCase.text, ['%\[control:slider:' s.id '\]\s*\n%\s+data: (\{[^\n]*\})'], 'tokens', 'once');
                data = jsondecode(entry{1});
                testCase.verifyEqual(string(data.run), "Section", [s.variable ': must re-run the section']);
                testCase.verifyEqual(string(data.runOn), "ValueChanged", [s.variable ': must run on release, not while dragging']);
            end
        end

    end
end
