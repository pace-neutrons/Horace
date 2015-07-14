classdef test_spher_cut_proj<TestCase
    % The test class to verify how projection works
    %
    properties
    end
    
    methods
        function this=test_spher_cut_proj(name)
            this=this@TestCase(name);
        end
        function test_constructor(this)
            proj = spher_proj();
            assertEqual(proj.ex,'u-aligned')
            assertEqual(proj.ez,'w-aligned')
            assertElementsAlmostEqual(proj.ucentre,[0;0;0])
            
            S.type = '.';
            S.subs  = 'ucentre';
            f=@()subsasgn(proj,S,10);
            assertExceptionThrown(f,'SPHER_PROJ:invalid_argument')
            
            proj.ucentre = [0,1,0];
            assertElementsAlmostEqual(proj.ucentre,[0;1;0])
            
            proj = spher_proj([1;0;1]);
            assertElementsAlmostEqual(proj.ucentre,[1;0;1])
        end
    end
end