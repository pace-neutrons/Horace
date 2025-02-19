classdef test_fast_map < TestCase
    properties
    end
    methods
        function obj = test_fast_map(varargin)
            if nargin<1
                name = 'test_fast_map';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function test_get_all_val_opt_noopt_mode2_with_missing(obj)
            %
            [base_key,val] = build_test_key_values(obj,100);
            fm = fast_map(base_key(1:100),val(1:100));
            idx = randperm(200);
            base_key = base_key(idx);

            fm.optimized = false;

            val_n = fm.get_values_for_keys(base_key,false,2);
            fm.optimized = true;
            val_o = fm.get_values_for_keys(base_key,false,2);

            assertEqual(val_n,val_o);
        end

        function test_get_all_val_opt_noopt_mode1_with_missing(obj)
            %
            [base_key,val] = build_test_key_values(obj,200);
            fm = fast_map(base_key(1:100),val(1:100));

            idx = randperm(200);
            base_key = base_key(idx);

            fm.optimized = false;
            val_n = fm.get_values_for_keys(base_key,false,1);
            fm.optimized = true;
            val_o = fm.get_values_for_keys(base_key,false,1);

            assertEqualToTol(val_n,val_o,'-nan_equal');
        end
        %
        function test_get_all_val_opt_noopt_mode3(obj)
            %
            [base_key,val] = build_test_key_values(obj,100);

            fm = fast_map(base_key,val);
            fm.optimized = false;

            val_n = fm.get_values_for_keys(base_key,false,3);
            fm.optimized = true;
            val_o = fm.get_values_for_keys(base_key,false,3);

            assertEqual(val_n,val_o);
        end

        function test_get_all_val_opt_noopt_mode2(obj)
            %
            [base_key,val] = build_test_key_values(obj,100);

            fm = fast_map(base_key,val);
            fm.optimized = false;

            val_n = fm.get_values_for_keys(base_key,false,2);
            fm.optimized = true;
            val_o = fm.get_values_for_keys(base_key,false,2);

            assertEqual(val_n,val_o);
        end

        function test_get_all_val_opt_noopt_mode1(obj)
            %
            [base_key,val] = build_test_key_values(obj,100);

            fm = fast_map(base_key,val);
            fm.optimized = false;

            val_n = fm.get_values_for_keys(base_key,false,1);
            fm.optimized = true;
            val_o = fm.get_values_for_keys(base_key,false,1);

            assertEqual(val_n,val_o);
        end

        %------------------------------------------------------------------
        function test_build_uint64_map_from_constructor(~)
            keys= uint64([10,20,30]);
            val  = 1:3;
            fm = fast_map(keys,val);

            assertEqual(fm.KeyType,'uint64');
            assertEqual(fm.keys,keys);
            assertEqual(fm.values,val);
        end

        function test_set_different_key_type(~)
            fm = fast_map();
            fm.KeyType = uint64(1);
            fm = fm.add(10,1);

            assertEqual(fm.KeyType,'uint64');
            assertEqual(fm.keys,uint64(10));
            assertEqual(fm.values,1);
        end
        %------------------------------------------------------------------
        function test_get_all_val_for_keys_optimized_no_checks(obj)
            %
            [base_key,val] = build_test_key_values(obj,100);

            fm = fast_map(base_key,val);
            fm.optimized = true;

            valm = fm.get_values_for_keys(base_key,false);

            assertEqual(val,valm);
        end

        function test_get_all_val_for_keys_optimized_with_checks(obj)
            [base_key,val] = build_test_key_values(obj,100);

            fm = fast_map(base_key,val);
            fm.optimized = true;

            valm = fm.get_values_for_keys(base_key,false);

            assertEqual(val,valm);
        end

        function test_get_all_val_for_keys(obj)
            [base_key,val] = build_test_key_values(obj,100);

            fm = fast_map(base_key,val);
            valm = fm.get_values_for_keys(base_key);

            assertEqual(val,valm);
        end
        %------------------------------------------------------------------
        function test_insertion_in_optimized(obj)
            n_keys = 100;
            [base_key,val] = build_test_key_values(obj,n_keys);

            fm = fast_map(base_key,val);
            fm.optimized = true;

            fm = fm.add(base_key(1),n_keys+1);
            assertEqual(fm.get(base_key(1)),n_keys+1);
            assertTrue(fm.optimized);

            new_key = 10+10*n_keys;
            fm = fm.add(new_key,n_keys+2);
            assertEqual(fm.get(new_key ),n_keys+2);
            assertFalse(fm.optimized);
        end

        function test_optimization(obj)
            n_keys = 100;
            [base_key,val] = build_test_key_values(obj,n_keys);

            fm = fast_map(base_key,val);
            fm.optimized = false;
            fmop = fm;
            fmop.optimized = true;
            for i=1:n_keys
                assertEqual(fm.get(base_key(i)),fmop.get(base_key(i)));
            end
        end
        %------------------------------------------------------------------
        function test_map_loadobj(~)
            keys = uint32(1:10);
            keys = num2cell(keys);
            val = num2cell(10:-1:1);
            fm = fast_map(keys,val );

            struc = fm.to_struct();
            rec = serializable.loadobj(struc);

            assertEqual(fm,rec);
        end

        function test_fast_map_accepts_addition(~)
            keys = 10:-1:1;

            fm = fast_map();
            for i=1:10
                fm = fm.add(keys(i),i);
            end
            assertEqual(fm.keys,uint32(10:-1:1));
            assertEqual(fm.values,1:10);
        end
        %
        %
        function test_map_constrcutrion_from_cellarray(~)
            keys = uint32(1:10);
            keys = num2cell(keys);
            val = num2cell(10:-1:1);
            fm = fast_map(keys,val );
            assertEqual(fm.keys,uint32(1:10));
            assertEqual(fm.values,[val{:}]);

            for i=1:numel(val)
                assertEqual(fm.get(i),val{i});
            end

        end
        function test_fast_map_construction(~)
            val = 10:-1:1;
            fm = fast_map(uint32(1:10),val );
            assertEqual(fm.keys,uint32(1:10));
            assertEqual(fm.values,val);

            for i=1:numel(val)
                assertEqual(fm.get(i),val(i));
            end
        end
        function test_fast_map_empty_constructor(~)
            fm = fast_map();
            assertTrue(isempty(fm.keys));
            assertTrue(isempty(fm.values));
        end
    end
    methods(Access=protected)
        function [key,val] = build_test_key_values(~,n_keys)
            % generate bunch of random unique keys in some reasonable key range
            key = 10+round(rand(1,10*n_keys)*(10*n_keys-1));
            key = unique(key);
            n_keys = numel(key);
            % and build values expected for such keys in real life
            val = 1:n_keys;
        end
    end
end