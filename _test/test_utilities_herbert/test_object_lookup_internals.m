classdef test_object_lookup_internals < TestCaseWithSave
    % Test of utility function for e.g. parsing that are defined
    % in the @objec_lookup folder
    
    properties
        
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_object_lookup_internals (name)
            obj@TestCaseWithSave(name);
            
            obj.save()
        end
        
        %--------------------------------------------------------------------------
        function test_parse_split_1 (~)
            % Test first element true only
            split = object_lookup.test_gateway ('parse_split', 2, 'split', [1]);
            assertEqual (split, [true, false]);
        end
        
        function test_parse_split_2 (~)
            % Test second element true only
            split = object_lookup.test_gateway ('parse_split', 2, 'spl', [2]);
            assertEqual (split, [false, true]);
        end
        
        function test_parse_split_3 (~)
            % Test second element true only
            split = object_lookup.test_gateway ('parse_split', 3, 'spl');
            assertEqual (split, [true, true, true]);
        end
        
        function test_parse_split_4 (~)
            % Invalid option
            f = @()object_lookup.test_gateway ('parse_split', 2, 'spla', [1]);
            assertExceptionThrown (f, 'HERBERT:parse_rand_ind:invalid_argument');
        end
        
        function test_parse_split_5 (~)
            % iargs = [1,3] refers to argument index 3 when maximum is 2
            f = @()object_lookup.test_gateway ('parse_split', 2, 'split', [1,3]);
            assertExceptionThrown (f, 'HERBERT:parse_rand_ind:invalid_argument');
        end
        
        function test_parse_split_6 (~)
            % iargs = [1,1] has a repeated argument
            f = @()object_lookup.test_gateway ('parse_split', 2, 'split', [1,1]);
            assertExceptionThrown (f, 'HERBERT:parse_rand_ind:invalid_argument');
        end
        
        function test_parse_split_7 (~)
            % Test output is a row vector even if iargs has a different size array
            split = object_lookup.test_gateway ('parse_split', 4, 'split', [4;1;3]);
            assertEqual (split, [true, false, true, true]);
        end
        
        %--------------------------------------------------------------------------
        function test_parse_rand_ind_1 (~)
            % ind and randfunc only
            ind_in = [11,13,14];
            randfunc_in = @sin;
            [ind, ielmts, randfunc, args, split] = object_lookup.test_gateway ...
                ('parse_rand_ind', ind_in, randfunc_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, []);
            assertEqual (randfunc, randfunc_in);
            assertEqual (args, cell(1,0));
            assertEqual (split, false(1,0));
        end
        
        function test_parse_rand_ind_2 (~)
            % ind, ielmts and randfunc
            ind_in = [11,13,14];
            ielmts_in = [5,16,3];
            randfunc_in = @sin;
            [ind, ielmts, randfunc, args, split] = object_lookup.test_gateway ...
                ('parse_rand_ind', ind_in, ielmts_in, randfunc_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, ielmts_in);
            assertEqual (randfunc, randfunc_in);
            assertEqual (args, cell(1,0));
            assertEqual (split, false(1,0));
        end
        
        function test_parse_rand_ind_3 (~)
            % ind, randfunc, p1; check that spots no ielmts given
            ind_in = [11,13,14];
            randfunc_in = @sin;
            p1_in = {5,true};
            [ind, ielmts, randfunc, args, split] = object_lookup.test_gateway ...
                ('parse_rand_ind', ind_in, randfunc_in, p1_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, []);
            assertEqual (randfunc, randfunc_in);
            assertEqual (args, {p1_in});
            assertEqual (split, false);
        end
        
        function test_parse_rand_ind_4 (~)
            % ind, ielmts, 'split', randfunc, ...
            ind_in = [11,13,14];
            ielmts_in = [5,16,3];
            randfunc_in = @sin;
            p1_in = rand(2,3);
            p2_in = rand(2,5,3);
            [ind, ielmts, randfunc, args, split] = object_lookup.test_gateway ...
                ('parse_rand_ind', ind_in, ielmts_in, 'split', randfunc_in, p1_in, p2_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, ielmts_in);
            assertEqual (randfunc, randfunc_in);
            assertEqual (args, {p1_in, p2_in});
            assertEqual (split, [true, true]);
        end
        
        function test_parse_rand_ind_5 (~)
            % ind, 'split', iarg, randfunc, ...
            ind_in = [11,13,14];
            ielmts_in = [5,16,3];
            iargs_in = [1,3];
            randfunc_in = @sin;
            p1_in = rand(2,3);
            p2_in = rand(2,5,3);
            p3_in = rand(2,5,3);
            [ind, ielmts, randfunc, args, split] = object_lookup.test_gateway ...
                ('parse_rand_ind', ind_in, ielmts_in, 'split', iargs_in, randfunc_in, p1_in, p2_in, p3_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, ielmts_in);
            assertEqual (randfunc, randfunc_in);
            assertEqual (args, {p1_in, p2_in, p3_in});
            assertEqual (split, [true, false, true]);
        end
        
        function test_parse_rand_ind_6 (~)
            % ind, ielmts, 'split', iarg, randfunc, ...
            ind_in = [11,13,14];
            iargs_in = [1,3];
            randfunc_in = @sin;
            p1_in = rand(2,3);
            p2_in = rand(2,5,3);
            p3_in = rand(2,5,3);
            [ind, ielmts, randfunc, args, split] = object_lookup.test_gateway ...
                ('parse_rand_ind', ind_in, 'split', iargs_in, randfunc_in, p1_in, p2_in, p3_in);
            assertEqual (ind, ind_in);
            assertEqual (ielmts, []);
            assertEqual (randfunc, randfunc_in);
            assertEqual (args, {p1_in, p2_in, p3_in});
            assertEqual (split, [true, false, true]);
        end
        
        function test_parse_rand_ind_err_1 (~)
            % No input arguments
            f = @()object_lookup.test_gateway ...
                ('parse_rand_ind');
            assertExceptionThrown (f, 'HERBERT:parse_rand_ind:invalid_argument');
        end
        
        function test_parse_rand_ind_err_2 (~)
            % No function handle - throw error
            ind_in = [11,13,14];
            ielmts_in = [5,16,3];
            f = @()object_lookup.test_gateway ...
                ('parse_rand_ind', ind_in, ielmts_in);
            assertExceptionThrown (f, 'HERBERT:parse_rand_ind:invalid_argument');
        end
        
        function test_parse_rand_ind_err_3 (~)
            % ind and ielmts have different sizes - throw error
            ind_in = [11,13,14];
            ielmts_in = [5,16];
            f = @()object_lookup.test_gateway ...
                ('parse_rand_ind', ind_in, ielmts_in);
            assertExceptionThrown (f, 'HERBERT:parse_rand_ind:invalid_argument');
        end
        
        function test_parse_rand_ind_err_4 (~)
            % ind, ielmts, iarg, randfunc, ... : error as forgot 'split'
            ind_in = [11,13,14];
            ielmts_in = [5,16,3];
            iargs_in = [1,3];
            randfunc_in = @sin;
            p1_in = rand(2,3);
            p2_in = rand(2,5,3);
            p3_in = rand(2,5,3);
            f = @()object_lookup.test_gateway ...
                ('parse_rand_ind', ind_in, ielmts_in, iargs_in, randfunc_in, p1_in, p2_in, p3_in);
            assertExceptionThrown (f, 'HERBERT:parse_rand_ind:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
    end
    
end
