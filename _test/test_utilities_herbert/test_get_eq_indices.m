classdef test_get_eq_indices < TestCase

    properties
    end

    methods

        function obj = test_get_eq_indices(~)
            obj = obj@TestCase('test_get_eq_indices');
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function test_mixed_arrays(~)
            val1 = 1:5;
            val2 = 1:4;
            val3 = 5;
            val ={val1,val2,val3,val2,val2,val3};

            idx = calc_idx_for_eq_to_tol(val,[1.e-8,1.e-8]);
            assertTrue(iscell(idx));
            assertEqual(numel(idx),3);
            assertEqual(idx{1},1);
            assertEqual(idx{2},[2,4,5]);
            assertEqual(idx{3},[3,6]);
        end
        function test_different_arrays(~)
            val1 = 1:5;
            val2 = 1:4;
            val3 = 5;
            val ={val1,val2,val3};

            idx = calc_idx_for_eq_to_tol(val,[1.e-8,1.e-8]);
            assertTrue(iscell(idx));
            assertEqual(numel(idx),3);
            assertEqual(idx{1},1);
            assertEqual(idx{2},2);
            assertEqual(idx{3},3);
        end
        %------------------------------------------------------------------
        function test_more_mixed_values(~)
            val1 = 5*ones(1,3);
            val2 = 6*ones(1,3);
            val = [num2cell(val1),num2cell(val2),num2cell(val1),num2cell(val2)];

            idx = calc_idx_for_eq_to_tol(val,[1.e-8,1.e-8]);
            assertTrue(iscell(idx));
            assertEqual(numel(idx),2);
            assertEqual(idx{1},[1:3,7:9]);
            assertEqual(idx{2},[4:6,10:12]);
        end
        function test_mixed_values(~)
            val1 = 5*ones(1,5);
            val2 = 6*ones(1,5);
            val = [num2cell(val1),num2cell(val2)];

            idx = calc_idx_for_eq_to_tol(val,[1.e-8,1.e-8]);
            assertTrue(iscell(idx));
            assertEqual(numel(idx),2);
            assertEqual(idx{1},1:5);
            assertEqual(idx{2},6:10);
        end
        function test_all_samle_values(~)
            val = 10*ones(1,10);
            val = num2cell(val);

            idx = calc_idx_for_eq_to_tol(val,[1.e-8,1.e-8]);
            assertTrue(iscell(idx));
            assertEqual(numel(idx),1);
            assertEqual(idx{1},1:10);
        end
        function test_all_difr_values(~)
            val = 1:10;
            val = num2cell(val);

            idx = calc_idx_for_eq_to_tol(val,[1.e-8,1.e-8]);
            assertTrue(iscell(idx));
            assertEqual(numel(idx),10);
            assertEqual(idx,val);
        end
    end
end
