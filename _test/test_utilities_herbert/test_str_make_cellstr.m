classdef test_str_make_cellstr < TestCaseWithSave
    % Test of str_make_cellstr
    properties
        ch1
        ch2
        ch3
        c1
        c2
        c3
        s1
        s2
        s3
        charr
        carr
        sarr
        
        carr_deblank
        carr_trim
    end
    
    methods
        %-------------------------------------------------------------------
        function S = test_str_make_cellstr (name)
            S@TestCaseWithSave(name);
            
            % Make some 1D character arrays
            S.ch1 = 'Hello     ';
            S.ch2 = 'Mister Man';
            S.ch3 = '  Yellow  ';
            
            % Make some cell arrays with a single 1D character array each
            S.c1 = cellstr(S.ch1);
            S.c2 = cellstr(S.ch2);
            S.c3 = cellstr(S.ch3);
            
            % Matlab strings
            S.s1 = string(S.ch1);
            S.s2 = string(S.ch2);
            S.s3 = string(S.ch3);
            
            % Arrays
            S.charr = [S.ch1; S.ch2; S.ch3];    % 2D character array
            S.carr = {S.ch1, S.ch2, S.ch3};     % 1x3 cell array
            S.sarr = [S.s1, S.s2, S.s3];        % 1x3 string array
            
            S.carr_deblank = deblank(S.carr');  % column
            S.carr_trim = strtrim(S.carr');     % column
            
            S.save()
        end
        
        %-------------------------------------------------------------------
        function test_1(S)
            [ok,cout] = str_make_cellstr(S.ch1);
            assertTrue(ok)
            assertEqual(cout, {deblank(S.ch1)})
        end
        
        %-------------------------------------------------------------------
        function test_2(S)
            [ok,cout] = str_make_cellstr(S.ch1, S.ch2, S.ch3);
            assertTrue(ok)
            assertEqual(cout, S.carr_deblank)
        end
        
        %-------------------------------------------------------------------
        function test_3(S)
            [ok,cout] = str_make_cellstr([S.ch2; S.ch3], S.sarr, S.carr);
            assertTrue(ok)
            assertEqual(cout, [S.carr_deblank(2:3); S.carr'; S.carr'])
        end
        
        %-------------------------------------------------------------------
        function test_4(S)
            [ok,cout] = str_make_cellstr('', {}, {''}, "");
            assertTrue(ok)
            assertEqual(cout,{''; ''; ''})
        end
        
        %-------------------------------------------------------------------
        function test_5(S)
            [ok,cout] = str_make_cellstr_trim(S.ch3);
            assertTrue(ok)
            assertEqual(cout, {strtrim(S.ch3)})
        end
        
        %-------------------------------------------------------------------
        function test_6(S)
            [ok,cout] = str_make_cellstr_trim(S.ch1, S.ch2, S.ch3);
            assertTrue(ok)
            assertEqual(cout, S.carr_trim)
        end
        
        %-------------------------------------------------------------------
        function test_7(S)
            [ok,cout] = str_make_cellstr_trim([S.ch2; S.ch3], S.sarr, S.carr);
            assertTrue(ok)
            assertEqual(cout, [S.carr_trim(2:3); S.carr_trim; S.carr_trim])
        end
        
        %-------------------------------------------------------------------
        function test_8(S)
            [ok,cout] = str_make_cellstr_trim('', {}, {''}, "");
            assertTrue(ok)
            assertEqual(cout,cell(0,1))
        end
        
        %-------------------------------------------------------------------
    end
    
end
