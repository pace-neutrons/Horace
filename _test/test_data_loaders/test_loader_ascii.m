classdef test_loader_ascii< TestCase
    properties 
        log_level;
        matlab_warning;
        test_data_path;
    end
    methods       
        % 
        function this=test_loader_ascii(name)
            this = this@TestCase(name);
            rootpath=fileparts(which('herbert_init.m'));
            this.test_data_path = fullfile(rootpath,'_test/common_data');
        end
        function this=setUp(this)
            this.log_level = get(herbert_config,'log_level');
            set(herbert_config,'log_level',-1,'-buffer');
            this.matlab_warning = warning ('off','all');
        end
        function this=tearDown(this)
            set(herbert_config,'log_level',this.log_level,'-buffer');            
            warning (this.matlab_warning);
        end
        
% CONSTRUCTOR:        
        % tests themself
        function test_wrong_first_argument(this)               
            f = @()loader_ascii(10);          
            % should throw; first argument has to be a file name
            assertExceptionThrown(f,'LOAD_ASCII:wrong_argument');
        end               
         
        function test_wrong_second_argument(this)               
            f = @()loader_ascii(fullfile(this.test_data_path,'some_spe_file_which_was_checked_before.spe'),10);          
            % should throw; third parameter has to be a file name
            assertExceptionThrown(f,'LOAD_ASCII:wrong_argument');
        end               
        function test_par_file_not_there(this)                 
              f = @()loader_ascii(fullfile(this.test_data_path,'some_spe_file_which_was_checked_before.spe'),...
                                  fullfile(this.test_data_path,'missing_par_file.par'));          
            % should throw; par file do not exist
            assertExceptionThrown(f,'CHECK_FILE_EXIST:wrong_argument');
        end       
        function test_spe_file_not_there(this)                           
            f = @()loader_ascii(fullfile(this.test_data_path,'missing_spe_file.spe'),...
                                fullfile(this.test_data_path,'demo_par.par'));          
            % should throw; par file do not exist
            assertExceptionThrown(f,'CHECK_FILE_EXIST:wrong_argument');
        end
        function test_loader_defined(this)                           
            ld = loader_ascii(fullfile(this.test_data_path,'MAP10001.spe'),...
                              fullfile(this.test_data_path,'demo_par.par'));          

            [fpath,fname,fext]= fileparts(ld.file_name);
            assertEqual([fname,fext],'MAP10001.spe');
            [fpath,fname,fext]= fileparts(ld.par_file_name);
            if ispc
                assertEqual([fname,fext],'demo_par.par');                            
            else
                assertEqual([fname,fext],'demo_par.PAR');                            
            end
        end        
% LOAD SPE        
        function test_load_spe(this)
            loader=loader_ascii(); 
            % loads only spe data
            [S,ERR,en,loader]=load_data(loader,fullfile(this.test_data_path,'MAP10001.spe'));
            assertEqual(30*28160,numel(S))
            assertEqual(30*28160,numel(ERR))      
            assertEqual(31,numel(en));
            [fpath,fname,fext]= fileparts(loader.file_name);            
            assertEqual([fname,fext],'MAP10001.spe')
        end
         function test_load_spe_undefined_throws(this)
            loader=loader_ascii(); 
            % define spe file loader from undefined spe file
            f = @()load_data(loader);
            assertExceptionThrown(f,'LOAD_ASCII:load_data');            
        end        
 
        function test_load_ASCII_par_binary(this)             
            loader=loader_ascii();
            
            old_state=get(herbert_config,'use_mex');
            set(herbert_config,'use_mex',1,'-buffer');
            [par,loader] = load_par(loader,fullfile(this.test_data_path,'demo_par.par'),'-horace');
            set(herbert_config,'use_mex',old_state,'-buffer');
            [fpath,fname,fext]= fileparts(loader.par_file_name);                        
            if ispc
                assertEqual([fname,fext],'demo_par.par');  
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end
            
            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));            
            assertEqual(28160,numel(par.x2))
            
            set(herbert_config,'use_mex',old_state,'-buffer');                       
        end
        function test_load_ASCII_par_matlab(this)             
            loader=loader_ascii();
            
            old_state=get(herbert_config,'use_mex');
            set(herbert_config,'use_mex',0,'-buffer');
            [par,loader] = load_par(loader,fullfile(this.test_data_path,'demo_par.par'),'-hor');
            set(herbert_config,'use_mex',old_state,'-buffer');

            [fpath,fname,fext] = fileparts(loader.par_file_name);     
            if ispc
                assertEqual([fname,fext],'demo_par.par');  
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end

            
            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));            
            assertEqual(28160,numel(par.x2))            
        end
% LOAD PAR forcing mex files     
        function test_wrong_n_columns_fails(this)               
            loader=loader_ascii();
            f = @()load_par(loader,fullfile(this.test_data_path,'wrong_demo_par_7Col.PAR'),'-hor');          
            use_mex=get(herbert_config,'use_mex_C');
            force_mex_if_use_mex=get(herbert_config,'force_mex_if_use_mex');   
            set(herbert_config,'use_mex_C',true,'force_mex_if_use_mex',true,'-buffer');            
            % should throw; par file has 7 columns
            assertExceptionThrown(f,'HORACE:get_par');
            set(herbert_config,'use_mex_C',use_mex,'force_mex_if_use_mex',force_mex_if_use_mex,'-buffer');                        

        end        
        function test_mslice_par(this)                       
            [par,loader]=load_par(loader_ascii,fullfile(this.test_data_path,'demo_par.par'));          
            assertEqual([6,28160],size(par));
            
            [fpath,fname,fext] = fileparts(loader.par_file_name);            
            if ispc
                assertEqual([fname,fext],'demo_par.par'); 
            else
                assertEqual([fname,fext],'demo_par.PAR');            
            end
        end 
% DEFINED FIELDS        
        function test_spe_fields_defined(this)
            loader=loader_ascii(fullfile(this.test_data_path,'spe_wrong.spe'));
            fields = defined_fields(loader);
            assertEqual({'S','ERR','en'},fields);
        end
       function test_par_fields_defined(this)
            loader=loader_ascii();
            [par,loader]=load_par(loader,fullfile(this.test_data_path,'demo_par.par'));
            fields = defined_fields(loader);
            assertEqual({'det_par'},fields);
            [fpath,fname,fext] = fileparts(loader.par_file_name);
            if ispc
                assertEqual([fname,fext],'demo_par.par');  
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end
            
       end
        function test_all_fields_defined(this)
            loader=loader_ascii(fullfile(this.test_data_path,'spe_wrong.spe'),...
                                fullfile(this.test_data_path,'demo_par.par'));
            fields = defined_fields(loader);
            assertEqual({'S','ERR','en','det_par'},fields);
        end     
%GET_RUN INFO:        
        function test_get_run_info_no_par_file(this)
            loader=loader_ascii(fullfile(this.test_data_path,'spe_info_correspondent2demo_par.spe'));
            % run info obtained from spe file
            [ndet,en,this]=get_run_info(loader);
            assertEqual(28160,ndet);
            assertEqual(31,numel(en));            
            assertEqual(this.n_detectors,ndet);
            assertTrue(isempty(this.det_par));
            assertTrue(isempty(this.par_file_name));            
        end             
        function test_get_run_info_wrong_par(this)
            loader=loader_ascii(fullfile(this.test_data_path,'spe_wrong.spe'),...
                                fullfile(this.test_data_path,'wrong_par.PAR'));
            f = @()get_run_info(loader);
            assertExceptionThrown(f,'LOADER_ASCII:problems_with_file');               
        end        
       function test_get_run_info_binary_par(this)
            loader=loader_ascii(fullfile(this.test_data_path,'spe_wrong.spe'),...
                                fullfile(this.test_data_path,'wrong_bin_par.par'));
            f = @()get_run_info(loader);
            assertExceptionThrown(f,'LOADER_ASCII:problems_with_file');               
        end            
        function test_get_run_info_wrong_spe(this)
            loader=loader_ascii(fullfile(this.test_data_path,'spe_wrong.spe'),...
                                fullfile(this.test_data_path,'demo_par.par'));
            f = @()get_run_info(loader);
            assertExceptionThrown(f,'LOADER_ASCII:problems_with_file');               
        end
        function test_get_run_info_inconsistent2spe(this)
            loader=loader_ascii(fullfile(this.test_data_path,'spe_info_insonsistent2demo_par.spe'),...
                                fullfile(this.test_data_path,'demo_par.par'));
            f = @()get_run_info(loader);
            assertExceptionThrown(f,'LOADER_ASCII:problems_with_file');                          
        end                
        function test_get_run_info_OK(this)
            SPE_file=fullfile(this.test_data_path,'spe_info_correspondent2demo_par.spe');
            PAR_file=fullfile(this.test_data_path,'demo_par.par');
            loader=loader_ascii(SPE_file,PAR_file);
            [ndet,en,loader]=get_run_info(loader);
            assertEqual(28160,ndet);
            assertEqual(31,numel(en));
            assertEqual(ndet,loader.n_detectors)
            assertEqual(en,loader.en);        
        end
% DEAL WITH NAN        
        function test_loader_ASCII_readsNAN(this)
        % reads symbolic NaN-s and agreed -1e+30 NaNs 
        % from ascii file and transforms them into ISO NaN in memory            
            loader=loader_ascii(fullfile(this.test_data_path,'spe_with_NANs.spe'));
            [S,ERR,en]=load_data(loader);
            % load all correctly
            assertEqual(size(S),[30,5]);
            assertEqual(size(S),size(ERR));            
            assertEqual(size(en),[31,1]);       
            % find ISO NaN-s
            mask=isnan(S);
            % check if they are all in right place, defined in 'spe_with_NANs.spe'
            assertEqual(mask(1:2,1),logical(ones(2,1)))
            assertEqual(mask(:,5),logical(ones(30,1)));
        end
        
    end
end

