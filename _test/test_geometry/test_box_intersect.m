classdef test_box_intersect < TestCase
    %
    properties
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_box_intersect(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_box_intersect';                
            end            
            self = self@TestCase(name);            
         end
        
        %--------------------------------------------------------------------------
        function test_intersect_box2D(~)
            % 
            cp = box_intersect([0,0;1,1]',[1,1;2,2]');
            assertEqual(cp,[1;1]);
        end

        %--------------------------------------------------------------------------
    end
end
