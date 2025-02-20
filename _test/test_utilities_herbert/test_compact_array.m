classdef test_compact_array < TestCase
    properties
    end
    methods
        function obj = test_compact_array(varargin)
            if nargin<1
                name = 'test_compact_array';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        %
        %
        function test_get_subobj_one_missing(~)
            uval = {10,20,30};
            nuidx = {4,[1,3],[2,5,6]};
            ca = compact_array(nuidx,uval);
            
            cas = ca.get_subobj([2,4,5]);
            assertEqual(cas.uniq_val,{10,30})
            assertEqual(cas.nunq_idx,{4,[2,5]})            
        end
        
        function test_get_subobj_all_included(~)
            uval = {10,20,30};
            nuidx = {4,[1,3],[2,5,6]};
            ca = compact_array(nuidx,uval);
            
            cas = ca.get_subobj([1,2,4,5]);
            assertEqual(cas.uniq_val,{10,20,30})
            assertEqual(cas.nunq_idx,{4,1,[2,5]})            
        end

        function test_get(~)
            uval = {10,20,30};
            nuidx = {4,[1,3],[2,5,6]};
            ca = compact_array(nuidx,uval);
            
            val = ca.get(1:6);
            assertEqual(val,{20,30,20,10,30,30})
        end
        
        function test_get_lidx(~)
            uval = {10,20,30};
            nuidx = {4,[1,3],[2,5,6]};
            ca = compact_array(nuidx,uval);
            lidx = ca.get_lidx();
            assertEqual(lidx,[2,3,2,1,3,3])
        end

        function test_non_empty_constructor(~)
            uval = {1,2,3};
            nuidx = {4,[1,3],[2,5,6]};
            ca = compact_array(nuidx,uval);
            assertEqual(ca.n_unique,3);
            assertEqual(ca.nunq_idx,nuidx);
            assertEqual(ca.uniq_val,uval);
        end
        function test_empty_constructor_with_cells(~)
            ca = compact_array({},{});
            assertEqual(ca.n_unique,0);
            assertTrue(isempty(ca.nunq_idx));
            assertTrue(isempty(ca.uniq_val));
        end       
        function test__empty_constructor(~)
            ca = compact_array();
            assertEqual(ca.n_unique,0);
            assertTrue(isempty(ca.nunq_idx));
            assertTrue(isempty(ca.uniq_val));
        end
    end
end