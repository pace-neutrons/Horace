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
        function test_expand_box(~)
            % 
        end

        %--------------------------------------------------------------------------
    end
end
