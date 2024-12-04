classdef test_help< TestCase
    % Verify if help which uses docify works regardless of Matlab version

    properties
    end
    methods
        %
        function this=test_help(name)
            if nargin<1
                name = 'test_help';
            end
            this = this@TestCase(name);

        end
        function test_help_works(~)
            if matlab_version_num() < 9.06
                ref_str = 'Reference page in Doc Center';
            else
                ref_str = 'Documentation for test_help';
            end
            ref_str = sprintf('%s\n%s\n%s',...
                'Verify if help which uses docify works regardless of Matlab version',...
                ref_str,...
                'doc test_help');
            actual_help = disp2str(help('test_help'));

            assertEqual(ref_str,actual_help)
        end

    end
end

