classdef test_disp2str< TestCase

    methods
        function obj = test_disp2str(~)
            obj@TestCase('test_disp2str');
        end
        function test_truncate_ignored_on_short(~)
            ss = disp2str('abcde',60);
            assertEqual(ss,'abcde')
        end        
        function test_truncate_returns_provided(~)
            ss = disp2str(1:100,60,'constrained');
            assertEqual(ss, ...
                sprintf('%s\n%s','Columns 1 through 17',...
             '1     2     3     4     5     6     7  constrained'))
        end        
        function test_truncate_returns_default(~)
            ss = disp2str(1:100,60);
            assertEqual(ss, ...
                sprintf('%s\n%s','Columns 1 through 17',...
             '1     2     3     4     5     6     7  ...truncated.'))
        end
        function test_cell(~)
            pat = {1,2,3};
            out = disp2str(pat);
            if verLessThan('Matlab','9.9')
                assertEqual(out,'[1]    [2]    [3]');
            else
                assertEqual(out,'{[1]}    {[2]}    {[3]}');
            end
        end
        function test_matrix(~)
            mat = [1,2,3;4,5,6];
            ref = ['1     2     3',newline,'4     5     6'];
            out = disp2str(mat);
            assertEqual(out,ref);
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
