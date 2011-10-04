classdef testGoniometer < TestCase
    properties 
        goni;
        sampl;
    end
    methods       
        % 
        function this=testGoniometer(name)
            this = this@TestCase(name);
        end
        function setUp(this)
             this.goni     = goniometer(1,2,3,4,5);
             this.sampl = sample([2.87,2.87,2.87],[90,90,90]);
        end  
        function teadDown(this)
            delete(this.det);
            delete(this.sampl);            
        end
     %--------------------------------------------------------------------------
        function testAnglesInRadians(this)       
            ang2rad=pi/180;
            val=[this.goni.psi,this.goni.dpsi,this.goni.omega,this.goni.gl,this.goni.gs];
            assertElementsAlmostEqual(val,[1,2,3,4,5]*ang2rad);
        end
        %
        function testSetPsiInRad(this)
            this.goni = set_psi(this.goni,30);
            assertElementsAlmostEqual(this.goni.psi,30*pi/180);
        end
        function testGetProjMatrix(this)
            u=[1,0,0];
            v=[1,1,0];
            this.goni=reset(this.goni);
            [spec2proj,u2rlu] = calc_proj_matrix(this.goni,this.sampl,u,v);
            
        end
   
        
    end
end
