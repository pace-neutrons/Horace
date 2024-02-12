classdef test_replicate_array < TestCase
    % Test behaviour of replicate_array, replicate_iarray and replicate_logarray.
    % The original algorithms of thes functions have been superseded by the
    % Matlab intrinsic function repelem.
    
    methods
        %--------------------------------------------------------------------------
        % Test replicate_array
        %--------------------------------------------------------------------------
        function test_array_empty_v_empty_n (~)
            % Empty input array, empty n ==> zerp(0,1) output
            v = [];
            n = [];
            vout = replicate_array (v, n);
            assertEqual(vout, zeros(0,1));
        end
        
        function test_array_scalar_v_zero_n (~)
            % Output should be a column independent of shape of input
            v = 3;
            n = 0;
            vout = replicate_array (v, n);
            assertEqual(vout, zeros(0,1));
        end
        
        function test_array_scalar_v_scalar_n (~)
            % Output should be a column independent of shape of input
            v = 3;
            n = 2;
            vout = replicate_array (v, n);
            vout_ref = [3;3];
            assertEqual(vout, vout_ref);
        end
        
        function test_array_row_v_row_n (~)
            % Output should be a column independent of shape of input
            v = [3,1,5];
            n = [2,3,1];
            vout = replicate_array (v, n);
            vout_ref = [3;3;1;1;1;5];
            assertEqual(vout, vout_ref);
        end
        
        function test_array_col_v_row_n (~)
            % Output should be a column independent of shape of input
            v = [3;1;5];
            n = [2,3,1];
            vout = replicate_array (v, n);
            vout_ref = [3;3;1;1;1;5];
            assertEqual(vout, vout_ref);
        end
        
        function test_array_arr_v_arr_n (~)
            % Output should be a column independent of shape of input
            v = [3,1,5;...
                7,8,9];
            n = [2,3,1;...
                4,5,6];
            vout = replicate_array (v, n);
            vout_ref = [3;3;7;7;7;7;1;1;1;8;8;8;8;8;5;9;9;9;9;9;9];
            assertEqual(vout, vout_ref);
        end
        
        function test_array_n_all_zero (~)
            % As the repetitions of elements are all zeros, then output should
            % be zeros(0,1)
            v = [3,1,5];
            n = [0,0,0];
            vout = replicate_array (v, n);
            vout_ref = zeros(0,1);
            assertEqual(vout, vout_ref);
        end
        
        function test_array_n_first_zero (~)
            % Test case of first element of n is zero - so first element of v
            % does not appear in the output
            v = [3,1,5];
            n = [0,3,2];
            vout = replicate_array (v, n);
            vout_ref = [1;1;1;5;5];
            assertEqual(vout, vout_ref);
        end
        
        function test_array_n_last_zero (~)
            % Test case of last element of n is zero - so last element of v
            % does not appear in the output
            v = [3,1,5];
            n = [4,3,0];
            vout = replicate_array (v, n);
            vout_ref = [3;3;3;3;1;1;1];
            assertEqual(vout, vout_ref);
        end
        
        function test_array_n_mid_zero (~)
            % Test case of middle element of n is zero - so middle element of v
            % does not appear in the output
            v = [3,1,5];
            n = [4,0,2];
            vout = replicate_array (v, n);
            vout_ref = [3;3;3;3;5;5];
            assertEqual(vout, vout_ref);
        end
        
        function test_array_numel_v_numel_n_mismatch_ERROR (~)
            % Throw an error because the numbers of elements of v and n do not
            % match
            v = [3,1,5];
            n = [4,2];
            f = @()replicate_array (v, n);
            ME = assertExceptionThrown (f, 'HERBERT:replicate_array:invalid_argument');
            assertTrue(contains(ME.message, ...
                'The number of elements in input array ''v'' (3) is different from'))
        end
        
        
        %--------------------------------------------------------------------------
        % Test replicate_iarray
        %--------------------------------------------------------------------------
        function test_iarray_empty_v_empty_n (~)
            % Empty input array, empty n ==> zerp(0,1) output
            v = [];
            n = [];
            vout = replicate_iarray (v, n);
            assertEqual(vout, zeros(0,1));
        end
        
        function test_iarray_scalar_v_zero_n (~)
            % Output should be a column independent of shape of input
            v = 3;
            n = 0;
            vout = replicate_array (v, n);
            assertEqual(vout, zeros(0,1));
        end
        
        function test_iarray_scalar_v_scalar_n (~)
            % Output should be a column independent of shape of input
            v = 3;
            n = 2;
            vout = replicate_array (v, n);
            vout_ref = [3;3];
            assertEqual(vout, vout_ref);
        end
        
        function test_iarray_row_v_row_n (~)
            % Output should be a column independent of shape of input
            v = [3,1,5];
            n = [2,3,1];
            vout = replicate_iarray (v, n);
            vout_ref = [3;3;1;1;1;5];
            assertEqual(vout, vout_ref);
        end
        
        function test_iarray_col_v_row_n (~)
            % Output should be a column independent of shape of input
            v = [3;1;5];
            n = [2,3,1];
            vout = replicate_iarray (v, n);
            vout_ref = [3;3;1;1;1;5];
            assertEqual(vout, vout_ref);
        end
        
        function test_iarray_arr_v_arr_n (~)
            % Output should be a column independent of shape of input
            v = [3,1,5;...
                7,8,9];
            n = [2,3,1;...
                4,5,6];
            vout = replicate_iarray (v, n);
            vout_ref = [3;3;7;7;7;7;1;1;1;8;8;8;8;8;5;9;9;9;9;9;9];
            assertEqual(vout, vout_ref);
        end
        
        function test_iarray_n_all_zero (~)
            % As the repetitions of elements are all zeros, then output should
            % be zeros(0,1)
            v = [3,1,5];
            n = [0,0,0];
            vout = replicate_iarray (v, n);
            vout_ref = zeros(0,1);
            assertEqual(vout, vout_ref);
        end
        
        function test_iarray_n_first_zero (~)
            % Test case of first element of n is zero - so first element of v
            % does not appear in the output
            v = [3,1,5];
            n = [0,3,2];
            vout = replicate_iarray (v, n);
            vout_ref = [1;1;1;5;5];
            assertEqual(vout, vout_ref);
        end
        
        function test_iarray_n_last_zero (~)
            % Test case of last element of n is zero - so last element of v
            % does not appear in the output
            v = [3,1,5];
            n = [4,3,0];
            vout = replicate_iarray (v, n);
            vout_ref = [3;3;3;3;1;1;1];
            assertEqual(vout, vout_ref);
        end
        
        function test_iarray_n_mid_zero (~)
            % Test case of middle element of n is zero - so middle element of v
            % does not appear in the output
            v = [3,1,5];
            n = [4,0,2];
            vout = replicate_iarray (v, n);
            vout_ref = [3;3;3;3;5;5];
            assertEqual(vout, vout_ref);
        end
        
        function test_iarray_numel_v_numel_n_mismatch_ERROR (~)
            % Throw an error because the numbers of elements of v and n do not
            % match
            v = [3,1,5];
            n = [4,2];
            f = @()replicate_iarray (v, n);
            ME = assertExceptionThrown (f, 'HERBERT:replicate_iarray:invalid_argument');
            assertTrue(contains(ME.message, ...
                'The number of elements in input array ''iv'' (3) is different from'))
        end
        
        %--------------------------------------------------------------------------
        % Test replicate_logarray
        %--------------------------------------------------------------------------
        function test_logarray_empty_v_empty_n (~)
            % Empty input array, empty n ==> logical size [0,1] output
            % Note: the output has class 'logical' even though input is 'double'
            v = [];
            n = [];
            vout = replicate_logarray (v, n);
            assertEqual(vout, false(0,1));
        end
        
        function test_logarray_scalar_v_zero_n (~)
            % Output should be a column independent of shape of input
            v = true;
            n = 0;
            vout = replicate_array (v, n);
            assertEqual(vout, false(0,1));
        end
        
        function test_logarray_scalar_v_scalar_n (~)
            % Output should be a column independent of shape of input
            v = true;
            n = 2;
            vout = replicate_array (v, n);
            vout_ref = [true; true];
            assertEqual(vout, vout_ref);
        end
        
        function test_logarray_row_numeric_v_row_n (~)
            % Input is numeric is fine - converted to logical
            % Output should be a column independent of shape of input
            v = [5, 0, 4];
            n = [2,3,1];
            vout = replicate_logarray (v, n);
            vout_ref = [true; true; false; false; false; true];
            assertEqual(vout, vout_ref);
        end
        
        function test_logarray_row_v_row_n (~)
            % Output should be a column independent of shape of input
            v = [true, false, true];
            n = [2,3,1];
            vout = replicate_logarray (v, n);
            vout_ref = [true; true; false; false; false; true];
            assertEqual(vout, vout_ref);
        end
        
        function test_logarray_col_v_row_n (~)
            % Output should be a column independent of shape of input
            v = [true; false; true];
            n = [2,3,1];
            vout = replicate_logarray (v, n);
            vout_ref = [true; true; false; false; false; true];
            assertEqual(vout, vout_ref);
        end
        
        function test_logarray_arr_v_arr_n (~)
            % Output should be a column independent of shape of input
            v = [true, false, true;...
                false, true, false];
            n = [2,3,1;...
                4,5,6];
            vout = replicate_logarray (v, n);
            vout_ref = [true(2,1); false(4,1); false(3,1); true(5,1); true(1,1); false(6,1)];
            assertEqual(vout, vout_ref);
        end
        
        function test_logarray_n_all_zero (~)
            % As the repetitions of elements are all zeros, then output should
            % be logical size [0,1]
            v = [true, false, true];
            n = [0,0,0];
            vout = replicate_logarray (v, n);
            vout_ref = false(0,1);
            assertEqual(vout, vout_ref);
        end
        
        function test_logarray_n_first_zero (~)
            % Test case of first element of n is zero - so first element of v
            % does not appear in the output
            v = [true, false, true];
            n = [0,3,2];
            vout = replicate_logarray (v, n);
            vout_ref = [false(3,1); true(2,1)];
            assertEqual(vout, vout_ref);
        end
        
        function test_logarray_n_last_zero (~)
            % Test case of last element of n is zero - so last element of v
            % does not appear in the output
            v = [true, false, true];
            n = [4,3,0];
            vout = replicate_logarray (v, n);
            vout_ref = [true(4,1); false(3,1)];
            assertEqual(vout, vout_ref);
        end
        
        function test_logarray_n_mid_zero (~)
            % Test case of middle element of n is zero - so middle element of v
            % does not appear in the output
            v = [true, false, true];
            n = [4,0,2];
            vout = replicate_logarray (v, n);
            vout_ref = [true(4,1); true(2,1)];
            assertEqual(vout, vout_ref);
        end
        
        function test_logarray_numel_v_numel_n_mismatch_ERROR (~)
            % Throw an error because the numbers of elements of v and n do not
            % match
            v = [true, false, true];
            n = [4,2];
            f = @()replicate_logarray (v, n);
            ME = assertExceptionThrown (f, 'HERBERT:replicate_logarray:invalid_argument');
            assertTrue(contains(ME.message, ...
                'The number of elements in input array ''v'' (3) is different from'))
        end
    end
end

