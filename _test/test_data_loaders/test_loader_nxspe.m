classdef test_loader_nxspe< TestCase
    properties 
        log_level;
        test_data_path;  
        initial_warn_state;
    end
    methods       
        % 
        function this=test_loader_nxspe(name)
            this = this@TestCase(name);
            rootpath=fileparts(which('herbert_init.m'));
            this.test_data_path = fullfile(rootpath,'_test/common_data');           
            this.initial_warn_state=warning('query', 'all');
        end
        function delete(this)
              warning(this.initial_warn_state)
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
%CONSTRUCTOR:        
        function test_wrong_first_argument(this)               
            f = @()loader_nxspe(10);          
            % should throw; first argument has to be a file name
            assertExceptionThrown(f,'LOAD_NXSPE:invalid_argument');
        end               
        function test_file_not_exist(this)               
            f = @()loader_nxspe(f_name(this,'missing_file.nxspe'));          
            % should throw; first argument has to be an existing file name
            assertExceptionThrown(f,'CHECK_FILE_EXIST:wrong_argument');
        end               
        function test_non_supported_nxspe(this)               
            f = @()loader_nxspe(f_name(this,'currently_not_supported_NXSPE.nxspe '));          
            % should throw; first argument has to be a file name with single
            % nxspe data structure in it
            assertExceptionThrown(f,'ISIS_UTILITES:invalid_argument');
        end    
       
        function test_loader_nxspe_initated(this)               
            loader=loader_nxspe(f_name(this,'MAP11014.nxspe'));          
            % should be OK and return correct file name and file location; 
            assertEqual(loader.root_nexus_dir,'/11014.spe');
            assertEqual(loader.file_name,f_name(this,'MAP11014.nxspe'));            
        end  
% DEFINED FIELDS        
         function test_emptyloader_nxspe_defines_nothing(this)
             loader=loader_nxspe();
             % if file is not defined, no data fields are defined either;
             fields = defined_fields(loader);
             assertTrue(isempty(fields));
         end 
         function test_loader_nxspe_defines(this)
             loader = loader_nxspe(f_name(this,'MAP11014.nxspe'));
             fields = defined_fields(loader);
             assertEqual({'S','ERR','en','efix','psi','det_par'},fields);
         end  
%LOAD_DATA         
         function test_emptyload_throw(this)
             loader=loader_nxspe();
             f = @()load_data(loader);
              % input file name is not defined
             assertExceptionThrown(f,'LOAD_NXSPE:invalid_argument');
         end        
         
         function test_loader_nxspe_works(this)
             loader=loader_nxspe(); 
             % loads only spe data
             [S,ERR,en,loader]=load_data(loader,f_name(this,'MAP11014.nxspe'));
             Ei = loader.efix;
             psi= loader.psi;
             assertEqual(30*28160,numel(S))
             assertEqual(30*28160,numel(ERR))      
             assertEqual(31,numel(en));
             assertEqual(800,Ei);             
             assertEqual(0,psi);               
             assertEqual(loader.root_nexus_dir,'/11014.spe');
             assertEqual(loader.file_name,f_name(this,'MAP11014.nxspe'));            
             assertEqual(psi,loader.psi);
             assertEqual(Ei,loader.efix);             
             assertEqual(en,loader.en);                          
         end
        function test_loader_nxspe_constr(this)
             loader=loader_nxspe(f_name(this,'MAP11014.nxspe')); 
             % loads only spe data
             [S,ERR,en,loader]=load_data(loader);
              Ei = loader.efix;
              psi= loader.psi;
              
              if get(herbert_config,'log_level')<0
                warnStruct = warning('off', 'LOAD_NXSPE:old_version');
              end
              
                  
             % ads par data and return it as horace data
             [par,loader]=load_par(loader,'-horace');             
            % MAP11014.nxspe is version 1.1 nxspe file
            if get(herbert_config,'log_level')>-1
                    warnStruct = warning('query', 'last');
                    msgid_integerCat = warnStruct.identifier;
                    assertEqual('LOAD_NXSPE:old_version',msgid_integerCat);                
            end
             
             
             % warning about old nxspe should still be generated in other
             % places
            if get(herbert_config,'log_level')<0
                warning(warnStruct);
            end
             
            
             
             assertEqual(30*28160,numel(S))
             assertEqual(30*28160,numel(ERR))      
             assertEqual(31,numel(en));
             assertEqual(800,Ei);             
             assertEqual(0,psi);               
             assertEqual(loader.root_nexus_dir,'/11014.spe');

            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));            
            assertEqual(28160,numel(par.x2))
        end
%Load PAR from nxspe        
        function test_loader_par_works(this)
             loader=loader_nxspe(); 

            if get(herbert_config,'log_level')<0
               warnStruct = warning('off', 'LOAD_NXSPE:old_version');
            end
            % loads only par data            
            [par,loader]=load_par(loader,f_name(this,'MAP11014.nxspe'));
            
            % MAP11014.nxspe is version 1.1 nxspe file
            if get(herbert_config,'log_level')>-1
                    warnStruct = warning('query', 'last');
                    msgid_integerCat = warnStruct.identifier;
                    assertEqual('LOAD_NXSPE:old_version',msgid_integerCat);                
            end

             
             % warning about old nxspe should still be generated
            if get(herbert_config,'log_level')<0
                warning(warnStruct);
            end
                          
             assertEqual([6,28160],size(par))             
             assertEqual(28160,loader.n_detectors)      
             assertEqual(loader.root_nexus_dir,'/11014.spe');
             assertEqual(loader.file_name,f_name(this,'MAP11014.nxspe'));
             assertEqual(loader.det_par,par);
        end         
        
        function test_warn_on_nxspe1_0(this)
            loader = loader_nxspe(f_name(this,'nxspe_version1_0.nxspe'));
            % should be OK and return correct file name and file location; 
            assertEqual(loader.root_nexus_dir,'/11014.spe');
            assertEqual(loader.file_name,f_name(this,'nxspe_version1_0.nxspe'));
            if get(herbert_config,'log_level')<0
               warnStruct = warning('off', 'LOAD_NXSPE:old_version');
            end
            % warnings are disabled when tests are run in some enviroments
            [par,loader]=load_par(loader);   

            if get(herbert_config,'log_level')>-1
                    warnStruct = warning('query', 'last');
                    msgid_integerCat = warnStruct.identifier;
                    assertEqual('LOAD_NXSPE:old_version',msgid_integerCat);                
            end
            
            
            % warning about old nxspe should still be generated
            if get(herbert_config,'log_level')<0
                warning(warnStruct);
            end
        % correct detectors and par array are still loaded from old par file
             assertEqual([6,5],size(par))
             assertEqual(5,loader.n_detectors)
             
        end
        
%GET_RUNINFO        
       function test_get_runinfo(this)
             loader=loader_nxspe(f_name(this,'MAP11014.nxspe')); 
             % loads only partial spe data
             [ndet,en,loader]=get_run_info(loader);
             
             assertEqual(31,numel(en));                         
             assertEqual(28160,ndet)

             assertEqual(en,loader.en);                         
             assertEqual(ndet,loader.n_detectors)
       end       
% DEAL WITH NAN        
        function test_loader_NXSPE_readsNAN(this)
            % reads binary NaN in memory and transforms -1e+30 into ISO NaN
            % in memory
            loader=loader_nxspe(f_name(this,'test_nxspe_withNANS.nxspe'));
            [S,ERR,en]=load_data(loader);
            assertEqual(size(S),[30,5]);
            assertEqual(size(S),size(ERR));            
            assertEqual(size(en),[31,1]);       
            mask=isnan(S);
            assertEqual(mask(:,1:2),logical(ones(30,2)))
            assertEqual(mask(1:2,5),logical([1;1]));
        end       
    end
end

