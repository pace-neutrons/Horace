classdef test_loader_ascii< TestCase
    properties 
    end
    methods       
        % 
        function this=test_loader_ascii(name)
            this = this@TestCase(name);
        end
% CONSTRUCTOR:        
        % tests themself
        function test_wrong_first_argument(this)               
            f = @()loader_ascii(10);          
            % should throw; first argument has to be a file name
            assertExceptionThrown(f,'LOAD_ASCII:wrong_argument');
        end               
         
        function test_wrong_second_argument(this)               
            f = @()loader_ascii('some_spe_file_which_was_checked_before.spe',10);          
            % should throw; third parameter has to be a file name
            assertExceptionThrown(f,'LOAD_ASCII:wrong_argument');
        end               
        function test_par_file_not_there(this)                 
              f = @()loader_ascii('some_spe_file_which_was_checked_before.spe','missing_par_file.par');          
            % should throw; par file do not exist
            assertExceptionThrown(f,'CHECK_FILE_EXIST:wrong_argument');
        end       
        function test_spe_file_not_there(this)                           
            f = @()loader_ascii('missing_spe_file.spe','demo_par.par');          
            % should throw; par file do not exist
            assertExceptionThrown(f,'CHECK_FILE_EXIST:wrong_argument');
        end
        function test_loader_defined(this)                           
            ld = loader_ascii('MAP10001.spe','demo_par.par');          
            % should throw; par file do not exist
            assertEqual(ld.file_name,'MAP10001.spe');
            if ispc
                assertEqual(ld.par_file_name,'demo_par.par');                            
            else
                assertEqual(ld.par_file_name,'demo_par.PAR');                            
            end
        end        
% LOAD SPE        
        function test_load_spe(this)
            loader=loader_ascii(); 
            % loads only spe data
            [S,ERR,en,loader]=load_data(loader,'MAP10001.spe');
            assertEqual(30*28160,numel(S))
            assertEqual(30*28160,numel(ERR))      
            assertEqual(31,numel(en));
            assertEqual(loader.file_name,'MAP10001.spe')
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
            set(herbert_config,'use_mex',1);
            [par,loader] = load_par(loader,'demo_par.par','-horace');
            set(herbert_config,'use_mex',old_state);
            assertEqual(loader.par_file_name,'demo_par.par');            
            
            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));            
            assertEqual(28160,numel(par.x2))
            
        end
        function test_load_ASCII_par_matlab(this)             
            loader=loader_ascii();
            
            old_state=get(herbert_config,'use_mex');
            set(herbert_config,'use_mex',0);
            [par,loader] = load_par(loader,'demo_par.par','-hor');
            set(herbert_config,'use_mex',old_state);
            assertEqual(loader.par_file_name,'demo_par.par');            
            
            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));            
            assertEqual(28160,numel(par.x2))            
        end
% LOAD PAR        
        function test_wrong_n_columns_fails(this)               
             loader=loader_ascii();
          
            f = @()load_par(loader,'wrong_demo_par_7Col.PAR','-hor');          
            % should throw; par file has 7 columns
            assertExceptionThrown(f,'LOAD_ASCII:wrong_file_format');
        end        
        function test_mslice_par(this)                       
            [par,loader]=load_par(loader_ascii,'demo_par.par');          
            assertEqual([6,28160],size(par));
            assertEqual(loader.par_file_name,'demo_par.par');            
        end 
% DEFINED FIELDS        
        function test_spe_fields_defined(this)
            loader=loader_ascii('spe_wrong.spe');
            fields = defined_fields(loader);
            assertEqual({'S','ERR','en'},fields);
        end
       function test_par_fields_defined(this)
            loader=loader_ascii();
            [par,loader]=load_par(loader,'demo_par.par');
            fields = defined_fields(loader);
            assertEqual({'det_par'},fields);
            assertEqual(loader.par_file_name,'demo_par.par');
       end
        function test_all_fields_defined(this)
            loader=loader_ascii('spe_wrong.spe','demo_par.par');
            fields = defined_fields(loader);
            assertEqual({'S','ERR','en','det_par'},fields);
        end     
%GET_RUN INFO:        
        function test_get_run_info_no_par_file(this)
            loader=loader_ascii('spe_info_correspondent2demo_par.spe');
            f = @()get_run_info(loader);
            assertExceptionThrown(f,'LOADER_ASCII:problems_with_file');               
        end             
        function test_get_run_info_wrong_par(this)
            loader=loader_ascii('spe_wrong.spe','wrong_par.PAR');
            f = @()get_run_info(loader);
            assertExceptionThrown(f,'LOADER_ASCII:problems_with_file');               
        end        
       function test_get_run_info_binary_par(this)
            loader=loader_ascii('spe_wrong.spe','wrong_bin_par.par');
            f = @()get_run_info(loader);
            assertExceptionThrown(f,'LOADER_ASCII:problems_with_file');               
        end            
        function test_get_run_info_wrong_spe(this)
            loader=loader_ascii('spe_wrong.spe','demo_par.par');
            f = @()get_run_info(loader);
            assertExceptionThrown(f,'LOADER_ASCII:problems_with_file');               
        end
        function test_get_run_info_inconsistent2spe(this)
            loader=loader_ascii('spe_info_insonsistent2demo_par.spe','demo_par.par');
            f = @()get_run_info(loader);
            assertExceptionThrown(f,'LOADER_ASCII:problems_with_file');                          
        end                
        function test_get_run_info_OK(this)
            SPE_file= 'spe_info_correspondent2demo_par.spe';
            PAR_file='demo_par.par';
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
            loader=loader_ascii('spe_with_NANs.spe');
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

