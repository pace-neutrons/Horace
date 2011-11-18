classdef test_calc_projections<TestCase
% The test class which gets different transformation
%
% the purpose -- compare these transformations with Mantid transformations;
%    
    
    properties
    end
    
    methods
    function this=test_calc_projections(name)
            this=this@TestCase(name);
    end
    function test_transf1(this)
      alatt = [1,2,3];
      angdeg= [90,90,90];
      u=[1,0,0];
      v=[0,1,0];
      psi  =0;
      omega=0;
      dpsi =0;
      gl   =0;
      gs   =0;    
      efix = 10;
      emode= 1;
      data.S=ones(3,3);
      data.ERR=zeros(3,3);
      data.en=-1:2;
      data.en=data.en';
      det.filename='some_file';
      det.filepath='';
      det.x2  =ones(3,1);       
      det.phi  =[0,1,2];
      det.azim= [-1,0,1];
      det.width =ones(3,1)*0.1;
      det.height=ones(3,1)*0.1; 
  
      [u_to_rlu, ucoords]= get_test_calc_projections(sqw,...
                              efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);
                          
    end
    end
    
end

