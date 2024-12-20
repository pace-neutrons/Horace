classdef test_str_miscellaneous < TestCase
    % Test of str_is_cellstr
    
    methods
        %==========================================================================
        %   Test str_is_cellstr
        %==========================================================================
        function test_str_is_cellstr_empty (~)
            % Empty cell: is case of 'no character vector'
            [ok, n] = str_is_cellstr({});
            
            assertEqual (ok, true);
            assertEqual (n, zeros(0,0));
        end
        
        %--------------------------------------------------------------------------
        function test_str_is_cellstr_1by1_emptyChar (~)
            % Cell with empty character vector
            [ok, n] = str_is_cellstr({''});
            
            assertEqual (ok, true);
            assertEqual (n, 0);
        end
        
        %--------------------------------------------------------------------------
        function test_str_is_cellstr_1by1_charVector (~)
            % Cell with a single character vector
            [ok, n] = str_is_cellstr({'45'});
            
            assertEqual (ok, true);
            assertEqual (n, 2);
        end
        
        %--------------------------------------------------------------------------
        function test_str_is_cellstr_2by1_charVector (~)
            % Two elements of the cell array both character vectors
            [ok, n] = str_is_cellstr({'hello', 'sunshine'});
            
            assertEqual (ok, true);
            assertEqual (n, [5, 8]);
        end
        
        %--------------------------------------------------------------------------
        function test_str_is_cellstr_2by1_charVector_trailingBlanks (~)
            % Two elements of the cell array both character vectors, one with
            % trailing blanks (test that these are counted in output argument n
            [ok, n] = str_is_cellstr({'hello', 'sunshine  '});
            
            assertEqual (ok, true);
            assertEqual (n, [5, 10]);
        end
        
        %--------------------------------------------------------------------------
        function test_str_is_cellstr_3by1_charVectorAndNumeric (~)
            % Mix of valid and invalid elements of the cell array
            [ok, n] = str_is_cellstr({'hello', 45, 'sunshine'});
            
            assertEqual (ok, false);
            assertEqual (n, [5, NaN, 8],'-nan_equal');
        end
        
        %--------------------------------------------------------------------------
        function test_str_is_cellstr_1by1_notCellarray_numeric (~)
            % Cell with non-cellarray - numeric
            [ok, n] = str_is_cellstr(45);
            
            assertEqual (ok, false);
            assertEqual (n, NaN,'-nan_equal');
        end
        
        %--------------------------------------------------------------------------
        function test_str_is_cellstr_1by1_notCellarray_charVector (~)
            % Cell with non-cellarray character
            [ok, n] = str_is_cellstr('45');
            
            assertEqual (ok, false);
            assertEqual (n, NaN,'-nan_equal');
        end
        
        %--------------------------------------------------------------------------
        function test_str_is_cellstr_1by1_numeric (~)
            % Cell with cellarray with numeric
            [ok, n] = str_is_cellstr({45});
            
            assertEqual (ok, false);
            assertEqual (n, NaN,'-nan_equal');
        end
        
        %--------------------------------------------------------------------------
        function test_str_is_cellstr_1by1_cellarrayWithcharVector (~)
            % Cell with cellarray containing cellarray with a character vector
            [ok, n] = str_is_cellstr({{'45'}});
            
            assertEqual (ok, false);
            assertEqual (n, NaN,'-nan_equal');
        end
        
        %--------------------------------------------------------------------------
        function test_str_is_cellstr_1by1_charArray (~)
            % Cell with empty character vector
            [ok, n] = str_is_cellstr({['bad';'man']});
            
            assertEqual (ok, false);
            assertEqual (n, NaN,'-nan_equal');
        end
        
        %==========================================================================
        %   Test is_charVector
        %==========================================================================
        function test_is_charVector_null (~)
            % No input argument
            [ok, n] = is_charVector();
            
            assertEqual (ok, true(1,0));
            assertEqual (n, zeros(1,0));
        end
        
        %--------------------------------------------------------------------------
        function test_is_charVector_1arg_emptyChar (~)
            % Empty character array
            [ok, n] = is_charVector('');
            
            assertEqual (ok, true);
            assertEqual (n, 0);
        end
        
        %--------------------------------------------------------------------------
        function test_is_charVector_1arg_charVector (~)
            % Character vector
            [ok, n] = is_charVector('Peanuts');
            
            assertEqual (ok, true);
            assertEqual (n, 7);
        end
        
        %--------------------------------------------------------------------------
        function test_is_charVector_1arg_charArray (~)
            % Character array - should return false as not a character vector
            [ok, n] = is_charVector(['Hello ';'Mister']);
            
            assertEqual (ok, false);
            assertEqual (n, NaN,'-nan_equal');
        end
        
        %--------------------------------------------------------------------------
        function test_is_charVector_1arg_string (~)
            % Matlab string object. Should fail, as not a character vector
            [ok, n] = is_charVector("Peanuts");
            
            assertEqual (ok, false);
            assertEqual (n, NaN,'-nan_equal');
        end
        
        %--------------------------------------------------------------------------
        function test_is_charVector_1arg_cellWithcharVector (~)
            % Character vector in a cell - should fail, as not itself a
            % character vector
            [ok, n] = is_charVector({'Peanuts'});
            
            assertEqual (ok, false);
            assertEqual (n, NaN,'-nan_equal');
        end
        
        %--------------------------------------------------------------------------
        function test_is_charVector_4arg_multipleTypes (~)
            % Test operation of several of the types above as succesive
            % arguments
            [ok, n] = is_charVector('Peanuts', 35, '', "kernel", ['Hello ';'Mister']);
            
            assertEqual (ok, [true, false, true, false, false]);
            assertEqual (n, [7, NaN, 0, NaN, NaN],'-nan_equal');
        end
        
        %==========================================================================
        %   Test str_length
        %==========================================================================
        function test_str_length_emptyCharVector (~)
            % Empty character vector size [0,0]
            ch = '';
            Lstr = strlength(ch);
            L = str_length(ch);
            
            assertEqual (L, Lstr);
        end
        
        %--------------------------------------------------------------------------
        function test_str_length_empty1by0CharVector (~)
            % Empty character vector size [1,0]
            ch = 'a'; ch=ch(1:0);
            Lstr = strlength(ch);
            L = str_length(ch);
            
            assertEqual (L, Lstr);
        end
        
        %--------------------------------------------------------------------------
        function test_str_length_CharVector (~)
            % Single character vector
            ch = 'Turnip';
            Lstr = strlength(ch);
            L = str_length(ch);
            
            assertEqual (L, Lstr);
        end
        
        %--------------------------------------------------------------------------
        function test_str_length_CharVectorCellArray (~)
            % Two character vectors
            ch = {'Turnip', 'Peanuts'};
            Lstr = strlength(ch);
            L = str_length(ch);
            
            assertEqual (L, Lstr);
        end
        
        %--------------------------------------------------------------------------
        function test_str_length_MatlabString (~)
            % Single Matlab string
            ch = "Turnip";
            Lstr = strlength(ch);
            L = str_length(ch);
            
            assertEqual (L, Lstr);
        end
        
        %--------------------------------------------------------------------------
        function test_str_length_MatlabStringArray (~)
            % Array of two Matlab strings
            ch = ["Turnip", "Peanuts"];
            Lstr = strlength(ch);
            L = str_length(ch);
            
            assertEqual (L, Lstr);
        end
        
        %--------------------------------------------------------------------------
        function test_str_length_charArray (~)
            % 2D Character array - str_length and Matlab strlength should both
            % throw errors
            ch = ['Turnip '; 'Peanuts'];
            
            % Matlab intrinsic function should fail
            f = @()strlength(ch);
            ME = assertExceptionThrown(f, 'MATLAB:string:MustBeCharCellArrayOrString');
            assertTrue(contains(ME.message, 'First argument must be'))
            
            % Herbert function should also fail
            f = @()str_length(ch);
            ME = assertExceptionThrown(f, 'HERBERT:str_length:invalid_argument');
            assertTrue(contains(ME.message, 'First argument must be text.'))
        end
        
        %--------------------------------------------------------------------------
    end
end
