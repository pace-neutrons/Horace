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
        function test_insertion_in_optimized(~)
            n_keys = 100;
            base_key = 10+round(rand(1,10*n_keys)*(10*n_keys-1));
            base_key = unique(base_key);
            n_keys = numel(base_key);
            val = 1:n_keys;

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

        function test_optimization(~)
            n_keys = 100;
            base_key = 10+round(rand(1,10*n_keys)*(10*n_keys-1));
            base_key = unique(base_key);
            n_keys = numel(base_key);
            val = 1:n_keys;

            fm = fast_map(base_key,val);
            fmop = fm;
            fmop.optimized = true;
            for i=1:n_keys
                assertEqual(fm.get(base_key(i)),fmop.get(base_key(i)));
            end
        end
        %------------------------------------------------------------------
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
            fm = fast_map(1:10,val );
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
end