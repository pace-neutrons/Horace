classdef test_ortho < TestCase
    properties
    end
    methods
        function obj = test_ortho(varargin)
            if nargin<1
                name = 'test_ortho';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        function test_ortho_throws_on_zero(~)        
            u = [0,0,0];
            assertExceptionThrown(@()ortho_vec(u), ...
                'HERBERT:ortho_vec:invalid_argument');
        end
        
        function test_ortho_1m22(~)        
            u = [1,-2,2];
            [v1,v2] = ortho_vec(u);
            
            assertEqual(u*v1',0,'Vectors are not orthogonal',[1.e-9,0]);
            assertEqual(u*v2',0,'Vectors are not orthogonal',[1.e-9,0]);            
            assertEqual(v1*v2',0,'Vectors are not orthogonal',[1.e-9,0]);                        
        end
        
        function test_ortho_0m20(~)        
            u = [0,-2,0];
            [v1,v2] = ortho_vec(u);
            
            assertEqual(u*v1',0,'Vectors are not orthogonal',[1.e-9,0]);
            assertEqual(u*v2',0,'Vectors are not orthogonal',[1.e-9,0]);            
            assertEqual(v1*v2',0,'Vectors are not orthogonal',[1.e-9,0]);                        
        end
        
        function test_ortho_110(~)        
            u = [1,0,0];
            [v1,v2] = ortho_vec(u);
            
            assertEqual(u*v1',0,'Vectors are not orthogonal',[1.e-9,0]);
            assertEqual(u*v2',0,'Vectors are not orthogonal',[1.e-9,0]);            
            assertEqual(v1*v2',0,'Vectors are not orthogonal',[1.e-9,0]);                        
        end
        
    end
end