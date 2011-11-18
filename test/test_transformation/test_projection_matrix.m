classdef test_projection_matrix<TestCase
% The test class which gets different transformation
%
% the purpose -- compare these transformations with Mantid transformations;
%    
    properties
    end
    
    methods
        function this=test_projection_matrix(name)
            this=this@TestCase(name);
        end
     % tests themself
         function test_square(this)               
             alatt = [1,2,3];
             angdeg= [90,90,90];
             u=[1,0,0];
             v=[0,1,0];
             psi  =0;
             omega=0;
             dpsi =0;
             gl   =0;
             gs   =0;
            [spec_to_proj, u_to_rlu] = get_test_projection_matrix(sqw,alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            assertElementsAlmostEqual(diag(alatt),u_to_rlu*2*pi);
            assertElementsAlmostEqual(eye(3),spec_to_proj);            
         end           
         function test_rec(this)               
             alatt = [1,2,3];
             angdeg= [75,45,35];
             u=[1,0,0];
             v=[0,1,0];
             psi  =0;
             omega=0;
             dpsi =0;
             gl   =0;
             gs   =0;
            [spec_to_proj, u_to_rlu] = get_test_projection_matrix(sqw,alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            assertElementsAlmostEqual(eye(3),spec_to_proj);                     
         end                   
         function test_rec2(this)               
             alatt = [1,2,3];
             angdeg= [75,45,35];
             u=[1,0,0];
             v=[0,-1,0];
             psi  =0;
             omega=0;
             dpsi =0;
             gl   =0;
             gs   =0;
            [spec_to_proj, u_to_rlu] = get_test_projection_matrix(sqw,alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            aa=eye(3);
            aa(2,2)=-1;
            aa(3,3)=-1;            
            assertElementsAlmostEqual(aa,spec_to_proj);                      
         end                     
        function test_rec3(this)               
             alatt = [1,2,3];
             angdeg= [75,45,90];
             u=[1,1,0];
             v=[1,-1,0];
             psi  =0;
             omega=0;
             dpsi =0;
             gl   =0;
             gs   =0;
            [spec_to_proj, u_to_rlu] = get_test_projection_matrix(sqw,alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            aa=[0.9521 0.3058  0.0000;  0.3058   -0.9521    0.0000;   0         0   -1.000];
            assertElementsAlmostEqual(aa,spec_to_proj,'absolute',2E-4);           
           
        end                        
        function test_rec4(this)               
             alatt = [1,1,3];
             angdeg= [90,90,90];
             u=[1,1,0];
             v=[1,-1,0];
             psi  =0;
             omega=0;
             dpsi =0;
             gl   =0;
             gs   =0;
            [spec_to_proj, u_to_rlu] = get_test_projection_matrix(sqw,alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            aa=[sqrt(2)/2 sqrt(2)/2  0.0000;  sqrt(2)/2  -sqrt(2)/2    0.0000;   0         0   -1.000];
            assertElementsAlmostEqual(aa,spec_to_proj,'absolute',2E-4);                      
        end                             
        function test_PSI(this)               
             alatt = [1,1,1];
             angdeg= [90,90,90];
             u=[1,0,0];
             v=[0,1,0];
             psi  =20;
             omega=0;
             dpsi =0;
             gl   =0;
             gs   =0;
            [spec_to_proj, u_to_rlu] = get_test_projection_matrix(sqw,alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);                                     
            aa=[0.9397  0.3420  0;   -0.3420  0.9397  0;   0   0  1.0000];
            assertElementsAlmostEqual(aa,spec_to_proj,'absolute',2E-4);                      
        end                             
       function test_DPSI(this)               
             alatt = [1,1,1];
             angdeg= [90,90,90];
             u=[1,0,0];
             v=[0,1,0];
             psi  =0;
             omega=0;
             dpsi =20;
             gl   =0;
             gs   =0;
            [spec_to_proj, u_to_rlu] = get_test_projection_matrix(sqw,alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);                                     
            aa=[0.9397  0.3420  0;   -0.3420  0.9397  0;   0   0  1.0000];
            assertElementsAlmostEqual(aa,spec_to_proj,'absolute',2E-4);                      
    end                          
    function test_GL(this)               
             alatt = [1,1,1];
             angdeg= [90,90,90];
             u=[1,0,0];
             v=[0,1,0];
             psi  =0;
             omega=0;
             dpsi =0;
             gl   =20;
             gs   =0;
            [spec_to_proj, u_to_rlu] = get_test_projection_matrix(sqw,alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);                                                     
            aa=[0.9397 0 -0.3420; 0 1.0000 0;   0.3420 0  0.9397];
            assertElementsAlmostEqual(aa,spec_to_proj,'absolute',2E-4);                      
    end                      
    function test_GS(this)               
             alatt = [1,1,1];
             angdeg= [90,90,90];
             u=[1,0,0];
             v=[0,1,0];
             psi  =0;
             omega=0;
             dpsi =0;
             gl   =0;
             gs   =20;
            [spec_to_proj, u_to_rlu] = get_test_projection_matrix(sqw,alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);               
            aa=[1.0000 0 0; 0 0.9397 0.3420; 0   -0.3420    0.9397];
            assertElementsAlmostEqual(aa,spec_to_proj,'absolute',2E-4);                      
   end                      
   
 end    % METHODS
end

