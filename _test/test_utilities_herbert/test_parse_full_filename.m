classdef test_parse_full_filename < TestCase
    % Test parse_full_filename utility
    %
    methods

        %------------------------------------------------------------------
        function test_parse_real_path(~)
            ts = mfilename('fullpath');
            refp = fileparts(ts);
            [fp,fn] = parse_full_filename(ts);

            assertTrue(ischar(fp));
            assertTrue(ischar(fn));
            assertEqual(fp,refp);
            assertEqual(fn,'test_parse_full_filename.sqw');
        end

        function test_not_a_path_throw(~)
            ts = 10;
            assertExceptionThrown(@()parse_full_filename(ts), ...
                'HERBERT:utilities:invalid_argument');
        end

        function test_multistring_throw(~)
            ts = ["filepath",filesep,"filename.tmp1"];
            assertExceptionThrown(@()parse_full_filename(ts), ...
                'HERBERT:utilities:invalid_argument');
        end

        function test_name_and_extension(~)
            ts = strjoin(["filepath","filename.tmp1"],filesep);
            [fp,fn] = parse_full_filename(ts);

            assertEqual(fp,'filepath');
            assertEqual(fn,'filename.tmp1');
        end

        function test_parse_simple_path(~)
            ts = strjoin(["filepath","filename"],filesep);
            [fp,fn] = parse_full_filename(ts);

            assertEqual(fp,'filepath');
            assertEqual(fn,'filename.sqw');
        end

        function test_parse_just_string(~)
            ts = "abcde";
            [fp,fn] = parse_full_filename(ts);

            assertTrue(isempty(fp));
            assertEqual(fn,'abcde.sqw');

        end
    end
end
