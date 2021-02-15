classdef test_4D_ort < TestCase
    % Test verifies, that the vector, produced
    % by the normal4D routine is indeed orthogonal to the
    % 3D hyper-plain, defined by the input parameters of the routine.
    properties
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_4D_ort(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_4D_ort';
            end
            self = self@TestCase(name);
        end
        %--------------------------------------------------------------------------
        function test_ort_rnd2_correct(~)
            e1=[0.5;0.1;10;4];
            e2=[2;5;7;9];
            e3=[11;5;12;7];
            ort4 = normal4D([e1,e2,e3]);
            assertTrue(abs(e1'*ort4)<4e-14);
            assertTrue(abs(e2'*ort4)<4e-14);
            assertTrue(abs(e3'*ort4)<4e-14);
        end
        
        function test_ort_rnd1_correct(~)
            e1=[1;0;0;0];
            e2=[0;1;0;0];
            e3=[0;0;1;1];
            a1 = 0.1*e1+0.5*e2+0.7*e3;
            a2 = 0.7*e1+0.2*e2+0.9*e3;
            a3 = 0.2*e1+0.2*e2+0.4*e3;
            ort4 = normal4D([a1,a2,a3]);
            assertTrue(abs(a1'*ort4)<4*eps);
            assertTrue(abs(a2'*ort4)<4*eps);
            assertTrue(abs(a3'*ort4)<4*eps);
        end
        
        function test_ort4_correct(~)
            e1=[1;0;0;0];
            e2=[0;1;0;0];
            e3=[0;0;1;0];
            ort4 = normal4D([e1,e2,e3]);
            assertTrue(abs(e1'*ort4)<4*eps);
            assertTrue(abs(e2'*ort4)<4*eps);
            assertTrue(abs(e3'*ort4)<4*eps);
        end
        
        function test_ort3_correct(~)
            e1=[1;0;0;0];
            e2=[0;1;0;0];
            e3=[0;0;0;1];
            ort4 = normal4D([e1,e2,e3]);
            assertTrue(abs(e1'*ort4)<4*eps);
            assertTrue(abs(e2'*ort4)<4*eps);
            assertTrue(abs(e3'*ort4)<4*eps);
        end
        
        function test_ort2_correct(~)
            e1=[1;0;0;0];
            e2=[0;0;1;0];
            e3=[0;0;0;1];
            ort4 = normal4D([e1,e2,e3]);
            assertTrue(abs(e1'*ort4)<4*eps);
            assertTrue(abs(e2'*ort4)<4*eps);
            assertTrue(abs(e3'*ort4)<4*eps);
        end
        
        function test_ort1_correct(~)
            e1=[0;1;0;0];
            e2=[0;0;1;0];
            e3=[0;0;0;1];
            ort4 = normal4D([e1,e2,e3]);
            assertTrue(abs(e1'*ort4)<4*eps);
            assertTrue(abs(e2'*ort4)<4*eps);
            assertTrue(abs(e3'*ort4)<4*eps);
        end
        function test_parallel_throws(~)
            e1=[0;1;0;0];
            e2=[0;0;1;0];
            e3=[0;0;1;0];
            assertExceptionThrown(@()normal4D([e1,e2,e3]),...
                'ORHTO_4D:invalid_argument');
        end
        function test_invalid_argument_throws(~)
            e1=[0;1;0];
            e2=[0;0;1];
            e3=[0;0;1];
            assertExceptionThrown(@()normal4D([e1,e2,e3]),...
                'ORHTO_4D:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
    end
end
