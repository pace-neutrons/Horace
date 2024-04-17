classdef test_expand_box < TestCase
    %
    properties
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_expand_box(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_expand_box';
            end
            self = self@TestCase(name);
        end
        
        %--------------------------------------------------------------------------
        function test_box4D(~)
            square=expand_box(zeros(1,4),ones(1,4));
            assertEqual(square,[...
                0,0,0,0; 1,0,0,0; 0,1,0,0; 1,1,0,0;...
                0,0,1,0; 1,0,1,0; 0,1,1,0; 1,1,1,0;...
                0,0,0,1; 1,0,0,1; 0,1,0,1; 1,1,0,1;...
                0,0,1,1; 1,0,1,1; 0,1,1,1; 1,1,1,1;...
                ]');
        end
        
        function test_box3D(~)
            square=expand_box(zeros(1,3),ones(1,3));
            assertEqual(square,[0,0,0; 1,0,0; 0,1,0; 1,1,0;...
                                0,0,1; 1,0,1; 0,1,1; 1,1,1]');
        end
        
        function test_box2D(~)
            square=expand_box(zeros(1,2),ones(1,2));
            assertEqual(square,[0,0;1,0;0,1;1,1]');
        end
        %--------------------------------------------------------------------------
        function test_too_small_dimensions_throws(~)
            f = @()expand_box(0,1);
            assertExceptionThrown(f,'GET_GEOMETRY:invalid_argument');
        end
        
        function test_too_big_dimensions_throws(~)
            f = @()expand_box(zeros(1,5),ones(1,5));
            assertExceptionThrown(f,'GET_GEOMETRY:invalid_argument');
        end
        
        function test_empty_throws(~)
            f = @()expand_box(zeros(1,3),zeros(1,3));
            assertExceptionThrown(f,'EXPAND_BOX:invalid_argument');
        end
        
        function test_maxmin_throws(~)
            f = @()expand_box(ones(1,3),zeros(1,3));
            assertExceptionThrown(f,'EXPAND_BOX:invalid_argument');
        end
        
        function test_matrix_throws(~)
            f = @()expand_box([1:3;1:3],[1:3;1:3]);
            assertExceptionThrown(f,'EXPAND_BOX:invalid_argument');
        end
        
        function test_invalid_shape_throws(~)
            f = @()expand_box(1:3,(1:3)');
            assertExceptionThrown(f,'EXPAND_BOX:invalid_argument');
        end
        function test_invalid_size_throws(~)
            f = @()expand_box(1:3,1:5);
            assertExceptionThrown(f,'EXPAND_BOX:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
    end
end
