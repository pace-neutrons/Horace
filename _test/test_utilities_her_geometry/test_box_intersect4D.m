classdef test_box_intersect4D < TestCase
    % This test is insufficient. Its very difficult to derive where the
    % points are intersecting in 4D
    properties
        rot4Dz = @(theta)([cosd(theta),-sind(theta),0,0;...
            sind(theta),cosd(theta),0,0;...
            0,0,1,0;...
            0,0,0,1])        
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_box_intersect4D(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_box_intersect4D';
            end
            self = self@TestCase(name);
        end
        %--------------------------------------------------------------------------
        function test_intersect_box4D_non_zero_based_box(~)
            %
            cp = box_intersect([-1,-1,-1,-1;1,1,1,1]',...
                [-1,-1,-1,-1;1,1,-1,-1;1,1,-1,1;1,1,1,1]');
            assertEqual(cp,[-1,-1,-1,-1;1,1,-1,-1;...
                -1,-1, 1,-1; 1, 1, 1,-1;...
                -1,-1,-1, 1; 1, 1,-1, 1;...
                -1,-1, 1, 1; 1, 1, 1, 1]');
        end
        
        
        function test_intersect_box4D_parallel_inside(~)
            %
            cp = box_intersect([0,0,0,0;1,1,1,1]',...
                [0.5,0.5,0,0;0.5,1,0,0;0.5,0.5,0.5,0]');
            % got the whole qube in the 4D space
            assertEqual(cp,[0,0,0,0; 1,0,0,0; 0,1,0,0; 1,1,0,0;...
                0,0,1,0; 1,0,1,0; 0,1,1,0,;1,1,1,0]');
        end
        
        function test_intersect_box4D_parallel_outside(~)
            %
            cp = box_intersect([0,0,0;1,1,1]',[2,0,0;2,2,0;2,0,2]');
            assertTrue(isempty(cp));
        end
        function test_intersect_box4D_in2points_degenerated(~)
            %
            cp = box_intersect([0,0,0,0;1,1,1,1]',...
                [1,1,1,1;1,1,1,0;1,0,1,1]');
            % got another qube in the 3D space
            assertEqual(cp,[0,0,0,0; 0,1,0,0; 1,0,1,0; 1,1,1,0;...
                0,0,0,1; 0,1,0,1; 1,0,1,1;1,1,1,1]');
        end
        function test_intersect_box4D_full_box_representation(obj)
            box = expand_box(-ones(1,4)/sqrt(2),ones(1,4)/sqrt(2));
            box = obj.rot4Dz(-45)*box;
            sq2 = sqrt(2)/2;
            %
            cp = box_intersect(box,[0,0,0,0;1/2,1/2,0,0;0,0,1,0;0,0,0,1]');
            assertElementsAlmostEqual(cp,[-1/2,-1/2,-sq2,-sq2;1/2,1/2,-sq2,-sq2;...
                -1/2,-1/2,sq2,-sq2;-1/2,-1/2,-sq2,sq2;...
                 1/2, 1/2,sq2,-sq2; 1/2, 1/2,-sq2,sq2;...                
                -1/2,-1/2,sq2,sq2;1/2,1/2,sq2,sq2]');
        end
        
        %--------------------------------------------------------------------------
    end
end
