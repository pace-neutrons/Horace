classdef test_make_const_bin_boundaries < TestCase
    
    
    properties
    end
    %
    methods
        function obj = test_make_const_bin_boundaries(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_make_const_bin_boundaries';
            end
            obj = obj@TestCase(name);
        end
        function test_boundaries_with_zero(~)
            pbin = [1,0,10];
            range = [2,9];
            pref = 1;
            p=make_const_bin_boundaries(pbin,range,pref);
            assertEqual(numel(p),11);
            assertEqual(p',0.5:1:10.5);
            
            pbin = [-inf,0,10];
            p=make_const_bin_boundaries(pbin,range,pref);
            assertEqual(numel(p),10);
            assertEqual(p',1.5:1:10.5);
            
            pbin = [-inf,0,inf];
            p=make_const_bin_boundaries(pbin,range,pref);
            assertEqual(numel(p),9);
            assertEqual(p',1.5:1:9.5);
        end
                
        function test_boundaries_with_range(~)
            pbin = [1,1,10];
            range = [2,9];
            p=make_const_bin_boundaries(pbin,range);
            assertEqual(numel(p),11);
            assertEqual(p',0.5:1:10.5);
            
            pbin = [-inf,1,10];
            p=make_const_bin_boundaries(pbin,range);
            assertEqual(numel(p),10);
            assertEqual(p',1.5:1:10.5);
            
            pbin = [-inf,1,inf];
            p=make_const_bin_boundaries(pbin,range);
            assertEqual(numel(p),9);
            assertEqual(p',1.5:1:9.5);
        end
        
        function test_boundaries_simple(~)
            
            pbin = [1,1,10];
            p=make_const_bin_boundaries(pbin);
            assertEqual(numel(p),11);
            assertEqual(p',0.5:1:10.5)
            
            % p_des should be equal to pbin_initial (to within rounding errors)
            p_des = make_const_bin_boundaries_descr(p);
            assertEqual(p_des,pbin);
        end
    end
end