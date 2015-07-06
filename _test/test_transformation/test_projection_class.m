classdef test_projection_class<TestCase
    % The test class to verify how projection works
    %
    properties
    end
    
    methods
        function this=test_projection_class(name)
            this=this@TestCase(name);
        end
        function test_constructor(this)
            proj = projection();
            assertEqual(proj.u,'dnd-X-aligned')
            assertEqual(proj.v,'dnd-Y-aligned')
            assertElementsAlmostEqual(proj.uoffset,[0;0;0;0])
            assertEqual(proj.type,'aaa')
            assertTrue(isempty(proj.w))
            
            f = @()projection([0,1,0]);
            assertExceptionThrown(f,'PROJAXES:invalid_argument');
            
            proj = projection([0,1,0],[1,0,0]);
            assertElementsAlmostEqual(proj.u,[0,1,0])
            assertElementsAlmostEqual(proj.v,[1,0,0])
            assertTrue(isempty(proj.w))
            
            prja = projaxes([1,0,0],[0,1,1],[0,-1,1]);
            proj = projection(prja);
            assertElementsAlmostEqual(proj.u,[1,0,0])
            assertElementsAlmostEqual(proj.v,[0,1,1])
            assertElementsAlmostEqual(proj.w,[0,-1,1])           
        end
        function test_set_u_transf(this)
            proj = projection();
            data = struct();
            data.alatt = [2,3,4];
            data.angdeg = [90,90,90];
            %
            data.u_to_rlu = eye(4); %(4x4)
            data.uoffset = zeros(1,4);      %(4x1)
            data.upix_to_rlu = eye(4);
            data.upix_offset = zeros(1,4);
            data.ulabel = {'a','b','c','d'};
            data.ulen = ones(4,1);        
            
            proj=proj.define_tranformation(data);
        end
        function test_set_can_mex_keep(this)
            proj = projection();
            assertTrue(proj.can_mex_cut);
            assertTrue(proj.can_keep_pixels);            
        end
    end
end