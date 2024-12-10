classdef test_replace_inf_range < TestCase
    properties
    end
    methods
        function obj = test_replace_inf_range(varargin)
            if nargin<1
                name = 'test_replace_inf_range';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        %
        function test_replace_inf_range_working(~)
            epss = double(eps('single'));
            range = [...
                -1 , -inf,-inf,0;...
                inf,   1,  inf,0];
            expected = [...
                -1 ,    1-epss,-epss,0;...
                -1+epss,1,      epss,0];

            res = replace_inf_range(range);

            assertEqual(res,expected);
        end
    end
end