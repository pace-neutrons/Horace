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
        end
        
        function this=setUp(this)
            this.log_level = get(herbert_config,'log_level');
            set(herbert_config,'log_level',-1,'-buffer');
            this.initial_warn_state=warning('query', 'all');
        end
        function this=tearDown(this)
            set(herbert_config,'log_level',this.log_level,'-buffer');
            warning(this.initial_warn_state)
        end
        
        function fn=f_name(this,short_filename)
            fn = fullfile(this.test_data_path,short_filename);
        end
        
        % tests themself
        %CONSTRUCTOR:
        function test_wrong_first_argument(this)
            f = @()loader_nxspe(10);
            % should throw; first argument has to be a file name
            assertExceptionThrown(f,'A_LOADER:set_file_name');
        end
        function test_file_not_exist(this)
            f = @()loader_nxspe(f_name(this,'missing_file.nxspe'));
            % should throw; first argument has to be an existing file name
            % disable warning about escape sequences in warning on matlab
            % 2009
            ws = warning('off','MATLAB:printf:BadEscapeSequenceInFormat');
            
            assertExceptionThrown(f,'A_LOADER:set_file_name');
            warning(ws);
        end
        function test_non_supported_nxspe(this)
            nxpse_name = f_name(this,'currently_not_supported_NXSPE.nxspe');
            f = @()loader_nxspe(nxpse_name);
            % should throw; first argument has to be a file name with single
            % nxspe data structure in it
            assertExceptionThrown(f,'ISIS_UTILITES:invalid_argument');
        end
        
        function test_loader_nxspe_initated(this)
            nxspe_file = f_name(this,'MAP11014.nxspe');
            loader=loader_nxspe(nxspe_file);
            % should be OK and return correct file name and file location;
            %assertEqual(loader.root_nexus_dir,'/11014.spe');
            assertEqual(800,loader.efix);
            assertEqual(0,loader.psi);
            assertEqual(loader.file_name,f_name(this,'MAP11014.nxspe'));
        end
        % DEFINED FIELDS
        function test_emptyloader_nxspe_defines_nothing(this)
            loader=loader_nxspe();
            % if file is not defined, no data fields are defined either;
            fields = defined_fields(loader);
            assertTrue(isempty(fields));
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
            file_name = f_name(this,'MAP11014.nxspe');
            % loads only spe data
            [S,ERR,en,loader]=load_data(loader,file_name);
            Ei = loader.efix;
            psi= loader.psi;
            assertEqual(30*28160,numel(S))
            assertEqual(30*28160,numel(ERR))
            assertEqual(31,numel(en));
            assertEqual(800,Ei);
            assertEqual(0,psi);
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
            %assertEqual(loader.root_nexus_dir,'/11014.spe');
            f_par = fields(par);
            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},f_par)));
            assertTrue(all(ismember(f_par,{'filename','filepath','x2','phi','azim','width','height','group'})));
            assertEqual(28160,numel(par.x2))
        end
        %Load PAR from nxspe
        function test_loader_par_works(this)
            loader=loader_nxspe();
            
            if get(herbert_config,'log_level')<0
                warnStruct = warning('off', 'LOAD_NXSPE:old_version');
            end
            % loads only par data
            par_file = f_name(this,'MAP11014.nxspe');
            [par,loader]=load_par(loader,par_file);
            
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
            
            assertEqual(28160,numel(par.x2))
            assertEqual(28160,loader.n_detectors)
            %assertEqual(loader.root_nexus_dir,'/11014.spe');
            assertEqual(loader.file_name,f_name(this,'MAP11014.nxspe'));
            assertEqual(loader.det_par,par);
        end
        
        function test_warn_on_nxspe1_0(this)
            loader = loader_nxspe(f_name(this,'nxspe_version1_0.nxspe'));
            % should be OK and return correct file name and file location;
            %assertEqual(loader.root_nexus_dir,'/11014.spe');
            assertEqual(loader.file_name,f_name(this,'nxspe_version1_0.nxspe'));
            if get(herbert_config,'log_level')<0
                warnStruct = warning('off', 'LOAD_NXSPE:old_version');
            end
            % warnings are disabled when tests are run in some enviroments
            [par,loader]=load_par(loader,'-array');
            
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
            %             assertEqual(ndet,loader.n_detectors)
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
        % -----------
        function test_get_data_info(this)
            nxspe_file_name = fullfile(this.test_data_path,'MAP11014v2.nxspe');
            [ndet,en,file_name,ei,psi,nexus_dir,nxspe_ver]=loader_nxspe.get_data_info(nxspe_file_name);
            
            assertEqual([31,1],size(en));
            assertEqual(28160,ndet);
            assertEqual(nxspe_file_name,file_name);
            assertEqual(800,ei);
            assertEqual(20,psi);
            assertEqual('/11014.spe',nexus_dir);
            assertEqual('1.2',nxspe_ver);
        end
        
        function test_can_load_init_and_runinfo(this)
            spe_file_name = fullfile(this.test_data_path,'MAP10001.spe');
            nxspe_file_name = fullfile(this.test_data_path,'MAP11014.nxspe');
            
            
            [ok,fh]=loader_nxspe.can_load(spe_file_name);
            assertTrue(~ok);
            assertTrue(isempty(fh));
            
            [ok,fh]=loader_nxspe.can_load(nxspe_file_name);
            assertTrue(ok);
            assertTrue(~isempty(fh));
            
            la = loader_nxspe();
            la=la.init(nxspe_file_name,fh);
            
            [ndet,en,file_name,ei,psi]=loader_nxspe.get_data_info(nxspe_file_name);
            assertEqual(en,la.en);
            assertEqual(file_name,la.file_name);
            assertEqual(ei,la.efix);
            assertEqual(psi,la.psi);
            
            [ndet1,en1] = la.get_run_info();
            assertEqual(en,en1);
            assertEqual(ndet,ndet1);
        end
        function test_init_all(this)
            nxspe_file_name = fullfile(this.test_data_path,'MAP11014.nxspe');
            
            
            la = loader_nxspe();
            la=la.init(nxspe_file_name,'');
            
            [ndet,en]=la.get_run_info();
            assertEqual(28160,ndet);
            assertEqual(31,numel(en));
            
            
            par_file_name =fullfile(this.test_data_path,'demo_par.par');
            la=la.init(nxspe_file_name,par_file_name);
            
            [ndet,en]=la.get_run_info();
            assertEqual(28160,ndet);
            assertEqual(31,numel(en));
            
        end
        function test_load_and_init_all(this)
            nxspe_file_name = fullfile(this.test_data_path,'MAP11014.nxspe');
            par_file_name =fullfile(this.test_data_path,'demo_par.par');
            
            [ok,fh] = loader_nxspe.can_load(nxspe_file_name);
            assertTrue(ok);
            
            la = loader_nxspe();
            la=la.init(nxspe_file_name,par_file_name,fh);
            
            [ndet,en]=la.get_run_info();
            assertEqual(28160,ndet);
            assertEqual(31,numel(en));
            
            [par,la]=la.load_par('-nohor');
            [ndet,en1]=la.get_run_info();
            assertEqual(size(par,2),ndet);
            assertEqual(en,en1);
            
            assertEqual(1,is_loader_valid(la));
            
            la.par_file_name =fullfile(this.test_data_path,'wrong_demo_par_7Col.PAR');
            assertEqual(0,is_loader_valid(la));
            
            f = @()la.get_run_info();
            assertExceptionThrown(f,'A_LOADER:get_run_info');
        end
        
        function test_get_file_extension(this)
            fext=loader_nxspe.get_file_extension();
            
            assertEqual(fext{1},'.nxspe');
            assertEqual(1,numel(fext));
            
            descr = loader_nxspe.get_file_description();
            assertEqual('nexus spe files (MANTID): (*.nxspe)',descr);
        end
        function test_is_loader_valid(this)
            nxspe_file_name = fullfile(this.test_data_path,'MAP11014.nxspe');
            par_file_name =fullfile(this.test_data_path,'demo_par.par');
            
            la = loader_nxspe(nxspe_file_name,par_file_name );
            
            %f = @()get_run_info(loader);
            [ok,mess]=la.is_loader_valid();
            assertEqual(1,ok);
            assertEqual('',mess);
            
            la=la.load_data();
            [ok,mess]=la.is_loader_valid();
            assertEqual(1,ok);
            assertEqual('',mess);
            
            par1=la.load_par();
            
            [ok,mess]=la.is_loader_valid();
            assertEqual(1,ok);
            assertEqual('',mess);
            
            la.par_file_name='';
            assertTrue(isempty(la.det_par));
            
            [ok,mess]=la.is_loader_valid();
            assertEqual(1,ok);
            assertEqual('',mess);
            
            par=la.load_par();
            assertEqual(size(par1),size(par));
        end
        function test_all_fields_defined(this)
            nxspe_file_name = fullfile(this.test_data_path,'MAP11014.nxspe');
            par_file_name =fullfile(this.test_data_path,'demo_par.par');
            
            loader=loader_nxspe();
            fields = defined_fields(loader);
            assertTrue(isempty(fields));
            
            
            loader.par_file_name = par_file_name;
            fields = defined_fields(loader);
            assertTrue(any(ismember({'det_par','n_detectors'},fields)));
            
            loader.file_name =nxspe_file_name;
            fields = defined_fields(loader);
            assertTrue(any(ismember({'S','ERR','en','efix','psi','det_par','n_detectors'},fields)));
            
            loader.par_file_name ='';
            fields = defined_fields(loader);
            assertTrue(any(ismember({'S','ERR','en','efix','psi','det_par','n_detectors'},fields)));
            
            
        end
        function test_loader_nxspe_defines(this)
            loader = loader_nxspe(f_name(this,'MAP11014.nxspe'));
            fields = defined_fields(loader);
            assertEqual({'S','ERR','en','efix','psi','det_par','n_detectors'},fields);
        end
        
        
    end
end

