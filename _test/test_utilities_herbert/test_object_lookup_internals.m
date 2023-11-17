classdef test_object_lookup_internals < TestCase
    % Test of utility functions e.g. for parsing that are defined
    % in the @object_lookup folder

    methods
        %--------------------------------------------------------------------------
        function obj = test_object_lookup_internals (name)
            obj@TestCase(name);
        end
        
        %--------------------------------------------------------------------------
        function test_parse_split_first_element_only (~)
            % Test first element true only
            split = exposed_object_lookup.parse_split (2, 'split', 1);
            assertEqual (split, [true, false]);
        end
        
        function test_parse_split_second_element_only (~)
            % Test second element true only
            split = exposed_object_lookup.parse_split (2, 'spl', 2);
            assertEqual (split, [false, true]);
        end
        
        function test_parse_split_all_elements (~)
            % Test all elements true
            split = exposed_object_lookup.parse_split (3, 'spl');
            assertEqual (split, [true, true, true]);
        end
        
        function test_parse_split_invalid_keyword (~)
            % Invalid option
            f = @()exposed_object_lookup.parse_split (2, 'spla', [1]);
            assertExceptionThrown (f, 'HERBERT:parse_split:invalid_argument');
        end
        
        function test_parse_split_out_of_range_split_request (~)
            % iargs = [1,3] refers to argument index 3 when maximum is 2
            f = @()exposed_object_lookup.parse_split (2, 'split', [1,3]);
            assertExceptionThrown (f, 'HERBERT:parse_split:invalid_argument');
        end
        
        function test_parse_split_repeated_split_request (~)
            % iargs = [1,1] has a repeated argument
            f = @()exposed_object_lookup.parse_split (2, 'split', [1,1]);
            assertExceptionThrown (f, 'HERBERT:parse_split:invalid_argument');
        end
        
        function test_parse_split_output_is_row (~)
            % Test output is a row vector even if iargs has a different size array
            split = exposed_object_lookup.parse_split (4, 'split', [4;1;3]);
            assertEqual (split, [true, false, true, true]);
        end
        
        %--------------------------------------------------------------------------
        function test_parse_eval_method_ind_func (~)
            % ind and func only
            ind_in = [11,13,14];
            func_in = @sin;
            [ind, ielmts, func, args, split] = exposed_object_lookup.parse_eval_method ...
                (ind_in, func_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, []);
            assertEqual (func, func_in);
            assertEqual (args, cell(1,0));
            assertEqual (split, false(1,0));
        end
        
        function test_parse_eval_method_ind_ielmts_func (~)
            % ind, ielmts and func
            ind_in = [11,13,14];
            ielmts_in = [5,16,3];
            func_in = @sin;
            [ind, ielmts, func, args, split] = exposed_object_lookup.parse_eval_method ...
                (ind_in, ielmts_in, func_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, ielmts_in);
            assertEqual (func, func_in);
            assertEqual (args, cell(1,0));
            assertEqual (split, false(1,0));
        end
        
        function test_parse_eval_method_ind_func_arg (~)
            % ind, func, p1; check that spots no ielmts given
            ind_in = [11,13,14];
            func_in = @sin;
            p1_in = {5,true};
            [ind, ielmts, func, args, split] = exposed_object_lookup.parse_eval_method ...
                (ind_in, func_in, p1_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, []);
            assertEqual (func, func_in);
            assertEqual (args, {p1_in});
            assertEqual (split, false);
        end
        
        function test_parse_eval_method_ind_split_func (~)
            % ind, ielmts, 'split', func, ...
            ind_in = [11,13,14];
            ielmts_in = [5,16,3];
            func_in = @sin;
            p1_in = rand(2,3);
            p2_in = rand(2,5,3);
            [ind, ielmts, func, args, split] = exposed_object_lookup.parse_eval_method ...
                (ind_in, ielmts_in, 'split', func_in, p1_in, p2_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, ielmts_in);
            assertEqual (func, func_in);
            assertEqual (args, {p1_in, p2_in});
            assertEqual (split, [true, true]);
        end
        
        function test_parse_eval_method_ind_split_isplit_func (~)
            % ind, 'split', iarg, func, ...
            ind_in = [11,13,14];
            ielmts_in = [5,16,3];
            iargs_in = [1,3];
            func_in = @sin;
            p1_in = rand(2,3);
            p2_in = rand(2,5,3);
            p3_in = rand(2,5,3);
            [ind, ielmts, func, args, split] = exposed_object_lookup.parse_eval_method ...
                (ind_in, ielmts_in, 'split', iargs_in, func_in, p1_in, p2_in, p3_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, ielmts_in);
            assertEqual (func, func_in);
            assertEqual (args, {p1_in, p2_in, p3_in});
            assertEqual (split, [true, false, true]);
        end
        
        function test_parse_eval_method_ind_ielmts_split_isplit_func_args (~)
            % ind, ielmts, 'split', iarg, func, ...
            ind_in = [11,13,14];
            iargs_in = [1,3];
            func_in = @sin;
            p1_in = rand(2,3);
            p2_in = rand(2,5,3);
            p3_in = rand(2,5,3);
            [ind, ielmts, func, args, split] = exposed_object_lookup.parse_eval_method ...
                (ind_in, 'split', iargs_in, func_in, p1_in, p2_in, p3_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, []);
            assertEqual (func, func_in);
            assertEqual (args, {p1_in, p2_in, p3_in});
            assertEqual (split, [true, false, true]);
        end
        
        function test_parse_eval_method_err_noArguments (~)
            % No input arguments
            f = @()exposed_object_lookup.parse_eval_method ();
            assertExceptionThrown (f, 'HERBERT:parse_eval_method:invalid_argument');
        end
        
        function test_parse_eval_method_err_noFunc (~)
            % No function handle - throw error
            ind_in = [11,13,14];
            ielmts_in = [5,16,3];
            func_in = @sin;
            % No failure:
            exposed_object_lookup.parse_eval_method ...
                (ind_in, ielmts_in, func_in);
            % Remove func_in: should fail
            f = @()exposed_object_lookup.parse_eval_method ...
                (ind_in, ielmts_in);
            assertExceptionThrown (f, 'HERBERT:parse_eval_method:invalid_argument');
        end
        
        function test_parse_eval_method_err_ind_ielmts_sizeMismatch (~)
            % ind and ielmts have different sizes - throw error
            ind_in = [11,13,14];
            ielmts_in = [5,16];
            func_in = @sin;
            % Remove func_in: should fail
            f = @()exposed_object_lookup.parse_eval_method ...
                (ind_in, ielmts_in, func_in);
            assertExceptionThrown (f, 'HERBERT:parse_eval_method:invalid_argument');
        end
        
        function test_parse_eval_method_err_missingKeyword (~)
            % ind, ielmts, iarg, func, ... : error as forgot 'split'
            ind_in = [11,13,14];
            ielmts_in = [5,16,3];
            iargs_in = [1,3];
            func_in = @sin;
            p1_in = rand(2,3);
            p2_in = rand(2,5,3);
            p3_in = rand(2,5,3);
            f = @()exposed_object_lookup.parse_eval_method ...
                (ind_in, ielmts_in, iargs_in, func_in, p1_in, p2_in, p3_in);
            assertExceptionThrown (f, 'HERBERT:parse_split:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
    end
    
end
