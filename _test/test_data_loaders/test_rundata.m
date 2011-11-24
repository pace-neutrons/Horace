classdef test_rundata< TestCase
% 
% $Revision$ ($Date$)
%
    
    properties 
    end
    methods       
        % 
        function this=test_rundata(name)
            this = this@TestCase(name);
        end
        % tests themself
        function test_wrong_first_argument_has_to_be_fileName(this)               
            f = @()rundata(10);            
            assertExceptionThrown(f,'RUNDATA:invalid_argument');
        end               
        function test_defaultsOK_andFixed(this)                           
            nn=numel(fields(rundata));           
            % 19 fields by default;
            assertEqual(19,nn);
        end                       
       function test_build_from_spe(this)               
            f = @()rundata(spe());            
            assertExceptionThrown(f,'RUNDATA:not_implemented');
        end               
       function test_build_from_wrong_struct(this)               
           a.x=10;
           a.y=20;
           f = @()rundata(a);            
           assertExceptionThrown(f,'RUNDATA:invalid_argument');
       end        
       function test_build_from_good_struct(this)               
            a.efix=10;
            a.psi=2;
            dat=rundata(a);            
            assertEqual({dat.psi,dat.efix},{2,10});
       end    
     
       function test_build_from_Other_rundata(this)               
           ro = rundata();
           rn = rundata(ro);            
           assertEqual(ro,rn);
       end         
       
       function test_wrong_file_extension(this)               
            f = @()rundata('file.unspported_extension');            
            assertExceptionThrown(f,'CHECK_FILE_EXIST:wrong_argument');
       end
      function test_file_not_found(this)               
            f = @()rundata('not_existing_file.spe');            
            assertExceptionThrown(f,'CHECK_FILE_EXIST:wrong_argument');
      end       
      
      function test_spe_file_loader_in_use(this)               
         % define necessary parameters
          ds.efix=200;
          ds.psi=2;
          ds.alatt=[1;1;1];
          ds.angldeg=[90;90;90];
 
           run=rundata('MAP10001.spe','demo_par.PAR',ds);            
           fl=get(run,'loader');
           assertTrue(isa(fl,'loader_ascii'));
           % the data above fully define the  run -- check it
           [is_undef,fields_to_load,fields_from_defaults,undef_fields]=check_run_defined(run);
           assertEqual(1,is_undef);
           assertTrue(isempty(undef_fields));  
           assertEqual(3,numel(fields_to_load));           
           assertTrue(all(ismember({'S','ERR','det_par'},fields_to_load)));
           assertEqual(4,numel(fields_from_defaults));                      
           assertTrue(all(ismember({'omega','dpsi','gl','gs'},fields_from_defaults)));  
      end                  
      function test_hdfh5_file_loader_in_use(this)                         
           run=rundata('MAP11020.spe_h5','demo_par.PAR','psi',2,'alatt',[1;1;1],'angldeg',[90;90;90]);            
           fl=get(run,'loader');
           assertTrue(isa(fl,'loader_speh5'));
           % hdf5 file reader loads par files by the constructor
           % the data above fully define the  run
           [is_undef,fields_to_load,fields_from_defaults,undef_fields]=check_run_defined(run);
           assertEqual(1,is_undef);
           assertTrue(isempty(undef_fields));  
           
           assertEqual(3,numel(fields_to_load));
           assertTrue(all(ismember({'S','ERR','efix'},fields_to_load)));
           assertEqual(4,numel(fields_from_defaults));
           assertTrue(all(ismember({'omega','dpsi','gl','gs'},fields_from_defaults)));  
           
      end              
      function test_not_all_fields_defined(this)               
           run=rundata('MAP11020.spe_h5','demo_par.PAR','efix',200.);   
           % run is not defined fully (properly)
           [is_undef,fields_to_load,fields_from_defaults,undef_fields]=check_run_defined(run);
           assertEqual(2,is_undef);    
           % missing fields
           assertEqual(3,numel(undef_fields));           
           assertTrue(all(ismember({'alatt','angldeg','psi'},undef_fields))); 
           % and these fields can be retrieved
           assertEqual(2,numel(fields_to_load));                      
           assertTrue(all(ismember({'S','ERR'},fields_to_load)));
           assertEqual(4,numel(fields_from_defaults));                                 
           assertTrue(all(ismember({'omega','dpsi','gl','gs'},fields_from_defaults)));            
      end                    
      function test_all_fields_defined_powder(this)             
          % checks different option of private function
          % what_fields_are_needed()
           run=rundata('MAP11020.spe_h5','demo_par.PAR','efix',200.);   
           % run is not defined fully (properly) for crystal
           run.is_crystal=false;
           % but is sufficient for powder
           [is_undef,fields_to_load,fields_from_defaults,undef_fields]=check_run_defined(run);
           assertEqual(1,is_undef);    
           % missing fields
           assertTrue(isempty(undef_fields));           
           % and these fields can be retrieved from file
           assertEqual(2,numel(fields_to_load));           
           assertTrue(all(ismember({'S','ERR'},fields_to_load)));
           assertTrue(isempty(fields_from_defaults));            
      end                    
      
      function test_get_signalFromASCII(this)
         % define necessary parameters
           ds.efix=200;
           ds.psi=2;
           ds.alatt=[1;1;1];
           ds.angldeg=[90;90;90];
 
           run=rundata('MAP10001.spe','demo_par.PAR',ds); 
           %run is fully defined
           run.omega=20; % let's change the omega value;
           [is_undef,fields_to_load,fields_from_defaults,undef_fields]=check_run_defined(run);
           assertEqual(1,is_undef);    
           assertTrue(isempty(undef_fields));       
           assertTrue(all(ismember({'dpsi','gl','gs'},fields_from_defaults)));            
           assertTrue(all(ismember({'S','ERR','det_par'},fields_to_load)));               
           
           [S,Err,en]=get_signal(run);
           assertEqual([30,28160],size(S));
           assertEqual([30,28160],size(Err));   
           assertEqual([31,1],size(en));              
      end
      
       function test_nxspe_file_loader_in_use(this)               
            ds.alatt=[1;1;1];
            ds.angldeg=[90;90;90];
  
            run=rundata('MAP11014.nxspe',ds);            
            fl=get(run,'loader');
            assertTrue(isa(fl,'loader_nxspe'));
        %run is fully defined
           [is_undef,fields_to_load,fields_from_defaults,undef_fields]=check_run_defined(run);
           assertEqual(1,is_undef);    
           assertTrue(isempty(undef_fields));   
           assertTrue(all(ismember({'S','ERR','efix','det_par','psi'},fields_to_load)));         
           assertTrue(all(ismember({'omega','dpsi','gl','gs'},fields_from_defaults)));               
   
       end  
       function test_modify_par_file_load(this)
          run=rundata('MAP11014.nxspe');
          assertTrue(isempty(run.det_par));
          run=rundata(run,'par_file_name','demo_par.PAR');
          
          assertEqual(28160,run.n_detectors);
          assertEqual([6,28160],size(run.det_par));          
       end
       function test_modify_par_file_empty(this)
          run=rundata();
          run=rundata(run,'par_file_name','demo_par.PAR','data_file_name','MAP11020.spe_h5','psi',2);
          
          assertEqual(28160,run.n_detectors);
          assertEqual([6,28160],size(run.det_par));          
          assertEqual(2,run.psi);
       end
       function test_modify_data_file_load_makes_par_wrong(this)
           % a rundata class instanciated from nxspe which makes det_par
           % defined
          run=rundata('MAP11014.nxspe');
          assertTrue(isempty(run.det_par));

          % we change the initial file name to spe, which does not have
          % information about par data
          sp.data_file_name='MAP10001.spe';
          f = @()rundata(run,sp);
          assertExceptionThrown(f,'RUNDATA:invalid_argument');          
       end
       function default_rundata_type(this)
          run=rundata();
          assertEqual(run.is_crystal,get(rundata_config,'is_crystal'));
       end
  
       

    end
end

