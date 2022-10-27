classdef test_disp2str< TestCase

    methods
        function obj = test_disp2str(~)
            obj@TestCase('test_disp2str');
        end
        function test_cell(~)
            pat = {1,2,3};
            out = disp2str(pat);
            if verLessThan('Matlab','9.10')
                assertEqual(out,'[1]    [2]    [3]');
            else
                assertEqual(out,'{[1]}    {[2]}    {[3]}');
            end
        end

        function test_array(~)
            pat = [1,2,3];
            out = disp2str(pat);
            assertEqual(out,'1     2     3');
        end
        function test_whitespaces_removed(~)

            pat = 'abcdefg103040506';

            out = disp2str([' ',pat,'  ']);
            assertEqual(out, pat)
        end
    end

end
