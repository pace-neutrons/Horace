classdef test_sawtooth_iarray < TestCase
    % Test behaviour of Herbert utility function sawtooth_iarray.
    
    methods
        function test_sawtooth_iarray_empty_n (~)
            % Empty input array, empty n ==> zero(0,1) output
            n = [];
            vout = sawtooth_iarray (n);
            assertEqual(vout, zeros(0,1));
        end
        
        function test_sawtooth_iarray_zero_n (~)
            % Output should be zero(0,1)
            n = 0;
            vout = sawtooth_iarray (n);
            assertEqual(vout, zeros(0,1));
        end
        
        function test_sawtooth_iarray_scalar_n (~)
            % Output should be a column independent of shape of input
            n = 3;
            vout = sawtooth_iarray (n);
            vout_ref = [1;2;3];
            assertEqual(vout, vout_ref);
        end
        
        function test_sawtooth_iarray_row_n (~)
            % Output should be a column independent of shape of input
            n = [2,3,1];
            vout = sawtooth_iarray (n);
            vout_ref = [1;2;1;2;3;1];
            assertEqual(vout, vout_ref);
        end
        
        function test_sawtooth_iarray_col_n (~)
            % Output should be a column independent of shape of input
            n = [2;3;1];
            vout = sawtooth_iarray (n);
            vout_ref = [1;2;1;2;3;1];
            assertEqual(vout, vout_ref);
        end
        
        function test_sawtooth_iarray_arr_v_arr_n (~)
            % Output should be a column independent of shape of input
            n = [2,3,1;...
                4,5,6];
            vout = sawtooth_iarray (n);
            vout_ref = [1;2;1;2;3;4;1;2;3;1;2;3;4;5;1;1;2;3;4;5;6];
            assertEqual(vout, vout_ref);
        end
        
        function test_sawtooth_iarray_n_all_zero (~)
            % As the sawtooth lengths are all zeros, then output should
            % be zeros(0,1)
            n = [0,0,0];
            vout = sawtooth_iarray (n);
            vout_ref = zeros(0,1);
            assertEqual(vout, vout_ref);
        end
        
        function test_sawtooth_iarray_n_first_zero (~)
            % Test case of first element of n is zero
            n = [0,3,2];
            vout = sawtooth_iarray (n);
            vout_ref = [1;2;3;1;2];
            assertEqual(vout, vout_ref);
        end
        
        function test_sawtooth_iarray_n_last_zero (~)
            % Test case of last element of n is zero
            n = [4,3,0];
            vout = sawtooth_iarray (n);
            vout_ref = [1;2;3;4;1;2;3];
            assertEqual(vout, vout_ref);
        end
        
        function test_sawtooth_iarray_n_mid_zero (~)
            % Test case of middle element of n is zero
            n = [4,0,2];
            vout = sawtooth_iarray (n);
            vout_ref = [1;2;3;4;1;2];
            assertEqual(vout, vout_ref);
        end
                
        function test_sawtooth_iarray_real_n (~)
            % Reals rounded down to nearest integer
            n = 3.7;
            vout = sawtooth_iarray (n);
            vout_ref = [1;2;3];
            assertEqual(vout, vout_ref);
        end
                
        function test_sawtooth_iarray_real_n_ltZero (~)
            % Negative reals equivalent to zero
            n = -0.7;
            vout = sawtooth_iarray (n);
            assertEqual(vout, zeros(0,1));
        end
        
        function test_sawtooth_iarray_realArray_n (~)
            % Reals rounded down to nearest integer; array input that exercises
            % this in several cases
            n = [-0.7, 3.7, 2, 0, 4.0, -0.001];
            vout = sawtooth_iarray (n);
            vout_ref = [1;2;3;1;2;1;2;3;4];
            assertEqual(vout, vout_ref);
        end
                                
    end
end
