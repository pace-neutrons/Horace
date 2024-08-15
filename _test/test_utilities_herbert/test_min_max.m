classdef test_min_max < TestCase
    properties
    end
    methods
        function obj = test_min_max(varargin)
            if nargin<1
                name = 'test_min_max';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        function test_minmax_working(~)
            td = rand(5,10);
            ref_res = [min(td,[],2),max(td,[],2)];
            
            res = min_max(td);
            assertEqual(size(res),[5,2]);
            assertEqual(res,ref_res);
        end
        
    end
end