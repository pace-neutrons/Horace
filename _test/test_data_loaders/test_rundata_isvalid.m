classdef test_rundata_isvalid<TestCase

    properties
    end
    
    methods
      function this=test_rundata_isvalid(name)
            this = this@TestCase(name);
      end
      %
      function this=test_SERR(this)
          rd = rundata();
          rd.S = ones(3,5);
          assertTrue(isvalid(rd));
          rd.ERR=ones(4,7);
          [ok,mess]=isvalid(rd);
          assertFalse(ok);
          assertEqual(mess,'sizes S and ERR fields have to be equal');
          rd.ERR=zeros(3,5);
          [ok,mess]=isvalid(rd);  
          assertTrue(ok);          
          assertTrue(isempty(mess));          
      end
      function this = test_Sen(this)
          rd=rundata();
          rd.en = ones(5,1);
          assertTrue(isvalid(rd));
          rd.en = ones(1,5);
          [ok,mess,rd]=isvalid(rd);
          assertTrue(ok);
          assertTrue(isempty(mess));
          assertEqual(size(rd.en),[5,1]);
          
          rd.S = ones(3,5);
          [ok,mess]=isvalid(rd);
          assertFalse(ok);
          assertEqual(mess,'en field has 5 elements and signal has 3. This is inconcistent as energy fields desctibes enery bin boundaries for array of signals in this direction');
          
          rd.S = ones(4,5);
          assertTrue(isvalid(rd));
      end
      function this = test_enEfix(this)
          rd=rundata();
          rd.efix = 6;
          assertTrue(isvalid(rd));          
          
          rd.en=(1:10)';
          [ok,mess]=isvalid(rd);
          assertFalse(ok);
          assertEqual(mess,'Last energy transfer boundarty has to be smaller then efix. In reality: efix=6, e_transfer max=10');
          
          rd.en=(1:6)';
          assertTrue(isvalid(rd));                    
      end
      function this = test_det_par(this)
          rd=rundata();
          rd.det_par = ones(6,3);
          assertTrue(isvalid(rd));          
          
          rd.det_par = ones(5,3);
          [ok,mess]=isvalid(rd);
          assertFalse(ok);
          assertEqual(mess,'det_par field has to be a [6xndet] array, but has: 5 columns');
          
           rd.det_par = ones(6,10);
           rd.S       = ones(3,9);
           [ok,mess]=isvalid(rd);
           assertFalse(ok);
           assertEqual(mess,['Second dimension in det_par array has to coinside with the second dimension of signal array',...
                             ' In fact size(det_par,2)=10 and size(S,2)=9']);
          
           rd.S       = ones(3,10);
           assertTrue(isvalid(rd));                                        
      end
      function this = test_is_crystal(this)
          rd=rundata();
          rd.is_crystal = false;
          assertTrue(isvalid(rd));          

          rd.is_crystal = true;
          assertTrue(isvalid(rd));          
         
          rd.is_crystal = 3;
          [ok,mess]=isvalid(rd);
          assertFalse(ok);
          assertEqual(mess,'is_crystal has to be either true or false, is: 3');
      end
      function this = test_3vectors(this)
          rd=rundata();
          rd.u='a';
          [ok,mess]=isvalid(rd);          
          assertFalse(ok);
          assertEqual(mess,' field: u has to be numeric but it is not');
          
          rd.u=1;
          [ok,mess]=isvalid(rd);          
          assertFalse(ok);
          assertEqual(mess,' field: u has to be a vector with 3 elements but has: 1 element(s)');

          rd.u=[1,2,3];
          rd.v=[3;4;5];
          rd.alatt=1:3;
          rd.angldeg=(2:4)';
          [ok,mess]=isvalid(rd);          
          assertTrue(ok);
          assertEqual(mess,'');         
      end
      function this = test_1vectors(this)
          rd=rundata();
          rd.gl='a';
          [ok,mess]=isvalid(rd);          
          assertFalse(ok);
          assertEqual(mess,' field: gl has to be numeric but it is not');
          
          rd.gl=[1,2];
          [ok,mess]=isvalid(rd);          
          assertFalse(ok);
          assertEqual(mess,' field: gl has to have 1 element but has: 2 element(s)');

          rd.gl=0;
          rd.gs=1;
          rd.psi=1;
          rd.omega=10;
          rd.dpsi=-10;
          
          [ok,mess]=isvalid(rd);          
          assertTrue(ok);
          assertEqual(mess,'');         
      end      
     function this = test_degrees(this)
          rd=rundata();
          rd.gl=400;
          [ok,mess]=isvalid(rd);          
          assertFalse(ok);
          assertEqual(mess,' field: gl has to be an angular variable in deg but equal to: 400');
          
          rd.gl=0;
          rd.angldeg=[-400,0,0];
          [ok,mess]=isvalid(rd);          
          assertFalse(ok);
          assertEqual(mess,' field: angldeg has to be an angular variable in deg but equal to: -400    0    0');

          rd.angldeg=[45,90,50];
          [ok,mess]=isvalid(rd);                     
          assertTrue(ok);
          assertEqual(mess,'');                  
     end
     function this = test_LatticeCorrect(this)
          rd=rundata();

          rd.angldeg=[45,90,45];
          [ok,mess]=isvalid(rd);                     
          assertFalse(ok);
          assertEqual(mess,'field ''angldeg'' does not define correct 3D lattice');                  
     end

     
    end
    
end

