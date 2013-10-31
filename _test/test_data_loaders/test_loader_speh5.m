classdef test_loader_speh5< TestCase
    properties 
        test_data_path;              
    end
    methods       
        % 
           
        function this=test_loader_speh5(name)
            this = this@TestCase(name);
            rootpath=fileparts(which('herbert_init.m'));
            this.test_data_path = fullfile(rootpath,'_test/common_data');                      
        end
        
        function fn=f_name(this,short_filename)
            fn = fullfile(this.test_data_path,short_filename);
        end
        
        % tests themself
        function test_wrong_first_argument(this)               
            f = @()loader_speh5(10);          
            % should throw; first argument has to be a file name
            assertExceptionThrown(f,'LOAD_SPEH5:wrong_argument');
        end               
         function test_file_not_exist(this)               
             f = @()loader_speh5(f_name(this,'missing.spe_h5'));          
             % should throw; file not exist
             assertExceptionThrown(f,'CHECK_FILE_EXIST:wrong_argument');             
         end                              
         function test_file_exist_but_not_hdf5(this)               
             f = @()loader_speh5(f_name(this,'wrong.spe_h5'));          
             % should throw; third parameter has to be a file name
             assertExceptionThrown(f,'LOAD_SPEH5:wrong_argument');
         end               
   
       function test_load_speh5(this)
             loader=loader_speh5(); 
             % loads only spe data
             [S,ERR,en,loader]=load_data(loader,f_name(this,'MAP11020.spe_h5 '));
              assertEqual(2,loader.speh5_version);                          
              
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
            loader=loader_speh5(f_name(this,'MAP11020.spe_h5'));
            fields = defined_fields(loader);
            assertEqual({'S','ERR','en','efix'},fields);
        end                 
        function test_all_fields_undefined(this)
            loader=loader_speh5();
            fields = defined_fields(loader);
            assertTrue(isempty(fields));
        end                 
%RUN_INFO
        function test_runinfo_ok(this)
            loader=loader_speh5(f_name(this,'MAP11020.spe_h5'));
            [ndet,en,loader] = get_run_info(loader);
            assertEqual(28160,ndet);
            assertEqual(en,loader.en);
            assertEqual(ndet,loader.n_detectors);            
            assertEqual(31,numel(loader.en));            
        end       
        
    end
end

