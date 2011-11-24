classdef test_loader_nxspe< TestCase
    properties 
    end
    methods       
        % 
        function this=test_loader_nxspe(name)
            this = this@TestCase(name);
        end
        % tests themself
%CONSTRUCTOR:        
        function test_wrong_first_argument(this)               
            f = @()loader_nxspe(10);          
            % should throw; first argument has to be a file name
            assertExceptionThrown(f,'LOAD_NXSPE:invalid_argument');
        end               
        function test_file_not_exist(this)               
            f = @()loader_nxspe('missing_file.nxspe');          
            % should throw; first argument has to be an existing file name
            assertExceptionThrown(f,'CHECK_FILE_EXIST:wrong_argument');
        end               
        function test_non_supported_nxspe(this)               
            f = @()loader_nxspe('currently_not_supported_NXSPE.nxspe ');          
            % should throw; first argument has to be a file name with single
            % nxspe data structure in it
            assertExceptionThrown(f,'ISIS_UTILITES:invalid_argument');
        end               
        function test_loader_nxspe_initated(this)               
            loader=loader_nxspe('MAP11014.nxspe');          
            % should be OK and return correct file name and file location; 
            assertEqual(loader.root_nexus_dir,'/11014.spe');
            assertEqual(loader.file_name,'MAP11014.nxspe');            
        end               
% DEFINED FIELDS        
         function test_emptyloader_nxspe_defines_nothing(this)
             loader=loader_nxspe();
             % if file is not defined, no data fields are defined either;
             fields = defined_fields(loader);
             assertTrue(isempty(fields));
         end 
         function test_loader_nxspe_defines(this)
             loader = loader_nxspe('MAP11014.nxspe');
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
             [S,ERR,en,loader]=load_data(loader,'MAP11014.nxspe');
             Ei = loader.efix;
             psi= loader.psi;
             assertEqual(30*28160,numel(S))
             assertEqual(30*28160,numel(ERR))      
             assertEqual(31,numel(en));
             assertEqual(800,Ei);             
             assertEqual(0,psi);               
             assertEqual(loader.root_nexus_dir,'/11014.spe');
             assertEqual(loader.file_name,'MAP11014.nxspe');            
             assertEqual(psi,loader.psi);
             assertEqual(Ei,loader.efix);             
             assertEqual(en,loader.en);                          
         end
        function test_loader_par_works(this)
             loader=loader_nxspe(); 
             % loads only spe data
             [par,loader]=load_par(loader,'MAP11014.nxspe');
             assertEqual([6,28160],size(par))
             assertEqual(28160,loader.n_detectors)      
             assertEqual(loader.root_nexus_dir,'/11014.spe');
             assertEqual(loader.file_name,'MAP11014.nxspe');
             assertEqual(loader.det_par,par);
        end         
        function test_loader_nxspe_constr(this)
             loader=loader_nxspe('MAP11014.nxspe'); 
             % loads only spe data
             [S,ERR,en,loader]=load_data(loader);
              Ei = loader.efix;
              psi= loader.psi;
                  
             % ads par data and return it as horace data
             [par,loader]=load_par(loader,'-horace');             
             
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
%GET_RUNINFO        
       function test_get_runinfo(this)
             loader=loader_nxspe('MAP11014.nxspe'); 
             % loads only spe data
             [ndet,en,loader]=get_run_info(loader);
             
             assertEqual(31,numel(en));                         
             assertEqual(28160,ndet)

             assertEqual(en,loader.en);                         
             assertEqual(ndet,loader.n_detectors)
       end       
% DEAL WITH NAN        
        function test_loader_NXSPE_readsNAN(this)
            loader=loader_nxspe('test_nxspe_withNANS.nxspe');
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

