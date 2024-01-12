classdef test_str_make_cellstr < TestCase
    % Test of str_make_cellstr and str_make_cellstr_trim
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
            S@TestCase(name);
            
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
        end
        
        %-------------------------------------------------------------------
        function test_charArray (S)
            % Tests that a character array is stripped of trailing blanks
            [ok,cout] = str_make_cellstr(S.ch1);
            assertTrue(ok)
            assertEqual(cout, {deblank(S.ch1)})
        end
        
        %-------------------------------------------------------------------
        function test_multipleCharArrays (S)
            % Tests that output from multiple character array input is a column
            % cell array, and stripped of trailing (but not leading) blanks
            [ok,cout] = str_make_cellstr(S.ch1, S.ch2, S.ch3);
            assertTrue(ok)
            assertEqual(cout, S.carr_deblank)
        end
        
        %-------------------------------------------------------------------
        function test_multipleCharArrays_stringArray_cellstr (S)
            % Test multiple forms of input, and that string arrays and
            % cellstr are NOT stripped of trailing blanks, as Matlab behaviour
            % dictates
            [ok,cout] = str_make_cellstr([S.ch2; S.ch3], S.sarr, S.carr);
            assertTrue(ok)
            assertEqual(cout, [S.carr_deblank(2:3); S.carr'; S.carr'])
        end
        
        %-------------------------------------------------------------------
        function test_emptyTypes (~)
            % Test that empty character arrays, cellstr and strings result in
            % empty character arrays in a cell array (essentially a test of type
            % conversion)
            [ok,cout] = str_make_cellstr('', {}, {''}, "");
            assertTrue(ok)
            assertEqual(cout, {''; ''; ''})
        end
        
        %-------------------------------------------------------------------
        function test_char2D (~)
            % Test 2D character array
            ch2D = ['Hello     '; 'Mister Man'; '          '; '  Yellow  '];
            cout_ref = {'Hello'; 'Mister Man'; ''; '  Yellow'};
            [ok,cout] = str_make_cellstr(ch2D);
            assertTrue(ok)
            assertEqual(cout, cout_ref)
        end
        
        %-------------------------------------------------------------------
        function test_charArray_trim (S)
            % Tests str_make_cellstr_trim removes leading and trailing blanks
            % from a characater array
            [ok,cout] = str_make_cellstr_trim(S.ch3);
            assertTrue(ok)
            assertEqual(cout, {strtrim(S.ch3)})
        end
        
        %-------------------------------------------------------------------
        function test_multipleCharArrays_trim (S)
            % Tests str_make_cellstr_trim removes leading and trailing blanks
            % from multiple characater arrays
            [ok,cout] = str_make_cellstr_trim(S.ch1, S.ch2, S.ch3);
            assertTrue(ok)
            assertEqual(cout, S.carr_trim)
        end
        
        %-------------------------------------------------------------------
        function test_multipleCharArrays_stringArray_cellstr_trim (S)
            % Test multiple forms of input, and that string arrays and
            % cellstr ARE stripped of trailing blanks by str_make_cellstr_trim
            [ok,cout] = str_make_cellstr_trim([S.ch2; S.ch3], S.sarr, S.carr);
            assertTrue(ok)
            assertEqual(cout, [S.carr_trim(2:3); S.carr_trim; S.carr_trim])
        end
        
        %-------------------------------------------------------------------
        function test_emptyTypes_trim (~)
            % Test str_make_cellstr_trim deletes empty strings of the various
            % flavours
            [ok,cout] = str_make_cellstr_trim('', {}, {''}, "");
            assertTrue(ok)
            assertEqual(cout, cell(0,1))
        end
        
        %-------------------------------------------------------------------
        function test_char2D_trim (~)
            % Test 2D character array with str_make_cellstr_trim
            ch2D = ['Hello     '; 'Mister Man'; '          '; '  Yellow  '];
            cout_ref = {'Hello'; 'Mister Man'; 'Yellow'};
            [ok,cout] = str_make_cellstr_trim(ch2D);
            assertTrue(ok)
            assertEqual(cout, cout_ref)
        end
        
        %-------------------------------------------------------------------
    end
    
end
