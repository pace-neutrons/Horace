classdef test_rundata_get< TestCase
% 
% $Revision:  $ ($Date:  $)
%
    
    properties 
        the_run;
    end
    methods       
        % 
        function this=test_rundata_get(name)
            this = this@TestCase(name);
            this.the_run = rundata('MAP11014.nxspe');
        end
        % tests themself
        function test_undefined_loader(this)               
            f = @()get_rundata(rundata);
            assertExceptionThrown(f,'RUNDATA:invalid_arguments');
        end                
        function test_wrong_input_key(this)               
            f = @()get_rundata(this.the_run,10);
            assertExceptionThrown(f,'RUNDATA:invalid_arguments');
        end               
       function test_non_existing_input_key(this)               
            f = @()get_rundata(this.the_run,'-not_known_key','-somshit');
            assertExceptionThrown(f,'RUNDATA:invalid_arguments');
       end               
       function test_non_existing_input_field(this)               
            f = @()get_rundata(this.the_run,'S','-hor','bla_bla','beee','S','-nonan','ERR');
            assertExceptionThrown(f,'RUNDATA:invalid_arguments');
       end               
       function test_not_all_requested_data_present(this)               
            % this form asks for all run data to be obtained;
            f = @()get_rundata(this.the_run,'-nonan');
            % but not all data describing the crystall are present in nxspe
            assertExceptionThrown(f,'RUNDATA:invalid_arguments');
       end     
       function this=test_load_nxspe_fields(this)               
            % this form asks for all run data to be obtained;
            [S,Err,en,efix,psi,detectors]=get_rundata(this.the_run,'S','ERR','en','efix','psi','det_par');
            
            assertEqual(size(S,1),size(en,1)-1);
            assertEqual(size(S),size(Err));            
            assertEqual(800,efix);
            assertEqual(0,psi);            
            assertEqual(size(detectors,2),size(S,2));
       end            
       function this=test_load_nxspe_all_fields(this)               
            % this form asks for all run data to be obtained;
             this.the_run.is_crystal=false;
             data =get_rundata(this.the_run);
             fi = fieldnames(data);
             assertTrue(any(ismember({'efix','en','S','ERR','det_par'},fi)));
       end            
       function this=test_load_nxspe_par(this)               
            % this form asks for all run data to be obtained;
             this.the_run.is_crystal=false;
             data =get_rundata(this.the_run,'det_par','-hor');
             dp   = data.det_par;
             assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(dp))));
             assertTrue(all(ismember(fields(dp),{'filename','filepath','x2','phi','azim','width','height','group'})));              
       end                    
       function test_suppress_nan(this)               
            % this form asks for all run data to be obtained;
             this.the_run.is_crystal=false;
             f = @()get_rundata(this.the_run,'-nonan');             
             assertExceptionThrown(f,'RUNDATA:not_implemented');
       end                    
  
    function test_transform2rad_struct(this)
           ds.alatt  =[1;1;1];
           ds.angldeg=[90;90;90];
           ds.omega=20;
           ds.psi  =30;           
           ds.gl   =40;                      
           ds.gs   =50;                                 
  
           run=rundata('MAP11014.nxspe',ds);     
           
           data=get_rundata(run,'alatt','omega','psi','gl','gs','-rad');
           
           assertEqual(ds.alatt,  data.alatt);
           assertEqual(data.omega,ds.omega*pi/180);           
           assertEqual(data.psi,  ds.psi*pi/180);           
           assertEqual(data.gl,   ds.gl*pi/180);           
           assertEqual(data.gs,   ds.gs*pi/180);                      
  
  
    end      
       
    function test_transform2rad_cells(this)
           ds.alatt=[1;1;1];
           ds.angldeg=[90;90;90];
           ds.omega=20;
           ds.psi  =30;           
           ds.gl   =40;                      
           ds.gs   =50;                                 
  
           run=rundata('MAP11014.nxspe',ds);     
           
           [alatt,omega,psi,gl,gs]=get_rundata(run,'alatt','omega','psi','gl','gs','-rad');
           
           assertEqual(ds.alatt,alatt);
           assertEqual(omega,ds.omega*pi/180);           
           assertEqual(psi,ds.psi*pi/180);           
           assertEqual(gl, ds.gl*pi/180);           
           assertEqual(gs, ds.gs*pi/180);                      
 
      end       
   
        

    end
end

