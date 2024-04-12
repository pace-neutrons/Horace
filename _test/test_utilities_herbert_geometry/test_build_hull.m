classdef test_build_hull < TestCase
    properties
    end
    methods
        function obj = test_build_hull(varargin)
            if nargin<1
                name = 'test_build_hull';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end

        function test_build_hull_4D(~)
            hull = build_hull([-1,-2,-3,-4;2,3,4,4],[10,20,30,40]);
            xu = unique(hull(1,:));
            yu = unique(hull(2,:));
            zu = unique(hull(3,:));
            eu = unique(hull(4,:));
            assertEqual(xu,linspace(-1,2,10));
            assertEqual(yu,linspace(-2,3,20));
            assertEqual(zu,linspace(-3,4,30));
            assertEqual(eu,linspace(-4,4,40));
            % this blows my mind
            assertEqual(size(hull,2),2*(10*20*30+20*30*40+30*40*10+40*10*20))
        end
        function test_build_hull_3D(~)
            hull = build_hull([-1,-2,-3;2,3,4],[10,20,30]);
            xu = unique(hull(1,:));
            yu = unique(hull(2,:));
            zu = unique(hull(3,:));
            assertEqual(xu,linspace(-1,2,10));
            assertEqual(yu,linspace(-2,3,20));
            assertEqual(zu,linspace(-3,4,30));
            assertEqual(size(hull,2),2*(10*20+20*30+30*10))
        end
        function test_build_hull_2D(~)
            hull = build_hull([-1,-2;2,3],[10,20]);
            xu = unique(hull(1,:));
            yu = unique(hull(2,:));
            assertEqual(xu,linspace(-1,2,10));
            assertEqual(yu,linspace(-2,3,20));
            assertEqual(size(hull,2),2*(10+20))
        end
        function test_build_hull_1D(~)
            hul = build_hull([-1;2],10);
            assertEqual(hul,linspace(-1,2,10));
        end

    end
end