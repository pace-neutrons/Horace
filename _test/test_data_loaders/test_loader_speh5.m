classdef test_loader_speh5< TestCase
    properties 
        test_data_path;              
        log_level;
    end
    methods       
        % 
           
        function this=test_loader_speh5(name)
            this = this@TestCase(name);
            [~,tdp] = herbert_root();
            this.test_data_path = tdp;
        end
        function this=setUp(this)
            this.log_level = get(herbert_config,'log_level');
            set(herbert_config,'log_level',-1,'-buffer');
        end
        function this=tearDown(this)
            set(herbert_config,'log_level',this.log_level,'-buffer');
        end
        
        
        function fn=f_name(this,short_filename)
            fn = fullfile(this.test_data_path,short_filename);
        end
        
        % tests themself
        function test_wrong_first_argument(this)               
            f = @()loader_speh5(10);          
            % should throw; first argument has to be a file name
            assertExceptionThrown(f,'A_LOADER:set_file_name');
        end               
         function test_file_not_exist(this)               
             f = @()loader_speh5(f_name(this,'missing.spe_h5'));
             % disable warning about escape sequences in warning on matlab
             % 2009
             ws = warning('off','MATLAB:printf:BadEscapeSequenceInFormat');
             % should throw; file not exist             
              assertExceptionThrown(f,'A_LOADER:set_file_name');
              warning(ws);
              
         end                              
         function test_file_exist_but_not_hdf5(this)               
             f = @()loader_speh5(f_name(this,'wrong.spe_h5'));          
             % should throw; third parameter has to be a file name
             assertExceptionThrown(f,'FIND_DATASET_INFO:invalid_file');
         end               
   
       function test_load_speh5(this)
             speh5_file = f_name(this,'MAP11020.spe_h5 ');
             loader=loader_speh5(); 
             % loads only spe data
             [S,ERR,en,loader]=load_data(loader,speh5_file);
             %assertEqual(2,loader.speh5_version);                          
              
             assertEqual(30*28160,numel(S))
             assertEqual(30*28160,numel(ERR))      
             assertEqual(31,numel(en));
             assertElementsAlmostEqual(786.9,loader.efix);             
         
       end
        function test_load_speh5_undefined_throws(this)
            loader=loader_speh5(); 
            % define spe_h5 file loader from undefined spe file
            f = @()load_data(loader);
            assertExceptionThrown(f,'LOAD_SPEH5:load_data');            
        end          
        function test_all_fields_defined(this)
            spe_file = f_name(this,'MAP11020.spe_h5');
            loader=loader_speh5(spe_file);
            fields = defined_fields(loader);
            assertEqual({'S','ERR','en','n_detectors','efix'},fields);
        end                 
        function test_all_fields_undefined(this)
            loader=loader_speh5();
            fields = defined_fields(loader);
            assertTrue(isempty(fields));

            speh5_file = f_name(this,'MAP11020.spe_h5 ');
            loader.file_name =speh5_file;
            fields = defined_fields(loader);
            assertTrue(any(ismember({'S','ERR','en','n_detectors','efix'},fields)));
            
            
            par_file = f_name(this,'demo_par.PAR');
            loader.par_file_name = par_file;
            fields = defined_fields(loader);            
            assertTrue(any(ismember({'S','ERR','en','efix','det_par','n_detectors'},fields)));            
        end                 
%RUN_INFO
        function test_runinfo_ok(this)
            loader=loader_speh5(f_name(this,'MAP11020.spe_h5'));
            loader.det_par = ones(6,28160);
            [ndet,en,loader] = get_run_info(loader);
            assertEqual(28160,ndet);
            assertEqual(en,loader.en);
%            assertEqual(ndet,loader.n_detectors);            
            assertEqual(31,numel(loader.en));            
        end       
        
    end
end

