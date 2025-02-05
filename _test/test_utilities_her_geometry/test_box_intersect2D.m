classdef test_box_intersect2D < TestCase
    %
    properties
        rot2D = @(theta)([cosd(theta),-sind(theta);sind(theta),cosd(theta)])        
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_box_intersect2D(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_box_intersect2D';                
            end            
            self = self@TestCase(name);            
        end
        %--------------------------------------------------------------------------
        function test_intersect_box2D_edge_parallel_coincide(~)
            % 
            cp = box_intersect([0,0;1,1]',[0,0;0,1]');
            assertEqual(cp,[0,0;0,1]');
        end
        
        function test_intersect_box2D_parallel_inside(~)
            % 
            cp = box_intersect([0,0;1,1]',[0.5,0.5;0.5,1]');
            assertEqual(cp,[0.5,0;0.5,1]');
        end
        
        function test_intersect_box2D_parallel_outside(~)
            % 
            cp = box_intersect([0,0;1,1]',[2,0;2,1]');
            assertTrue(isempty(cp));
        end
        function test_intersect_box2D_2pointsDir1(~)
            % 
            cp = box_intersect([0,0;1,1]',[1/2,0;1,1/2]');
            assertEqual(cp,[1/2,0;1,1/2]');
        end        
        function test_intersect_box2D_full_box_representation(obj)
            box = expand_box(-ones(1,2)/sqrt(2),ones(1,2)/sqrt(2));
            box = obj.rot2D(-45)*box;

            % 
            cp = box_intersect(box,[1/2,0;0,1/2]');
            assertElementsAlmostEqual(cp,[3/4,-1/4;-1/4,3/4]');
        end        
        
        function test_intersect_box2D_2points(~)
            % 
            cp = box_intersect([0,0;1,1]',[1/2,0;0,1/2]');
            assertEqual(cp,[1/2,0;0,1/2]');
        end        
        function test_intersect_box2D_non_zero_based_box(~)
            % 
            cp = box_intersect([-1,-1;1,1]',[-1,-1;1,1]');
            assertEqual(cp,[-1,-1;1,1]');
        end        
        
        function test_intersect_box2D_in2points_degenerated(~)
            % 
            cp = box_intersect([0,0;1,1]',[1,1;2,2]');
            assertEqual(cp,[0,0;1,1]');
        end

        %--------------------------------------------------------------------------
    end
end
