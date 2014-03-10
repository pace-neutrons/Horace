classdef test_rundata< TestCase
    %
    % $Revision$ ($Date$)
    %
    
    properties
        log_level;
        test_data_path;
    end
    methods
        function fn=f_name(this,short_filename)
            fn = fullfile(this.test_data_path,short_filename);
        end
        
        %
        function this=test_rundata(name)
            this = this@TestCase(name);
            rootpath=fileparts(which('herbert_init.m'));
            this.test_data_path = fullfile(rootpath,'_test/common_data');
        end
        function this=setUp(this)
            this.log_level = get(herbert_config,'log_level');
            set(herbert_config,'log_level',-1,'-buffer');
        end
        function this=tearDown(this)
            set(herbert_config,'log_level',this.log_level,'-buffer');
        end
        
        % tests themself
        function test_wrong_first_argument_has_to_be_fileName(this)
            f = @()rundata(10);
            assertExceptionThrown(f,'PARSE_CONFIG_ARG:wrong_arguments');
        end
        function test_defaultsOK_andFixed(this)
            nn=numel(fields(rundata));
            % number of public fields by default;
            assertEqual(12,nn);
        end
        function test_build_from_wrong_struct(this)
            a.x=10;
            a.y=20;
            f = @()rundata(a);
            assertExceptionThrown(f,'RUNDATA:set_fields');
        end
        function test_build_from_good_struct(this)
            a.efix=10;
            a.psi=2;
            dat=rundata(a);
            assertEqual(dat.efix,10);
            assertEqual(dat.lattice.psi,2);
        end
        
        function test_build_from_Other_rundata(this)
            ro = rundata();
            rn = rundata(ro);
            assertEqual(ro,rn);
        end
        
        function test_wrong_file_extension(this)
            f = @()rundata(f_name(this,'file.unspported_extension'));
            ws=warning('off','MATLAB:printf:BadEscapeSequenceInFormat');
            assertExceptionThrown(f,'LOADERS_FACTORY:get_loader');
            warning(ws);
        end
        function test_file_not_found(this)
            f = @()rundata(f_name(this,'not_existing_file.spe'));
            ws=warning('off','MATLAB:printf:BadEscapeSequenceInFormat');
            assertExceptionThrown(f,'LOADERS_FACTORY:get_loader');
            warning(ws);
        end
        
        function test_spe_file_loader_in_use(this)
            % define necessary parameters
            ds.efix=200;
            ds.psi=2;
            ds.alatt=[1;1;1];
            ds.angdeg=[90;90;90];
            spe_file = f_name(this,'MAP10001.spe');
            par_file = f_name(this,'demo_par.PAR');
            run=rundata(spe_file,par_file ,ds);
            fl=run.loader();
            assertTrue(isa(fl,'loader_ascii'));
            % the data above fully define the  run -- check it
            [is_undef,fields_from_loader,undef_fields]=check_run_defined(run);
            assertEqual(1,is_undef);
            assertTrue(isempty(undef_fields));
            assertEqual(3,numel(fields_from_loader));
            assertTrue(all(ismember({'S','ERR','det_par'},fields_from_loader)));
            %             assertEqual(6,numel(fields_from_defaults));
            %             assertTrue(all(ismember({'omega','dpsi','gl','gs','u','v'},fields_from_defaults)));
        end
        function test_hdfh5_file_loader_in_use(this)
            spe_file = f_name(this,'MAP11020.spe_h5');
            par_file = f_name(this,'demo_par.PAR');
            run=rundata(spe_file,par_file,'psi',2,'alatt',[1;1;1],'angdeg',[90;90;90]);
            fl=get(run,'loader');
            assertTrue(isa(fl,'loader_speh5'));
            % hdf5 file reader loads par files by the constructor
            % the data above fully define the  run
            [is_undef,fields_to_load,undef_fields]=check_run_defined(run);
            assertEqual(1,is_undef);
            assertTrue(isempty(undef_fields));
            
            assertEqual(3,numel(fields_to_load));
            %            assertTrue(all(ismember({'S','ERR','efix','en','det_par'},fields_from_loader)));
            assertTrue(all(ismember({'S','ERR','det_par'},fields_to_load)));
            %             assertEqual(6,numel(fields_from_defaults));
            %             assertTrue(all(ismember({'omega','dpsi','gl','gs','u','v'},fields_from_defaults)));
            
        end
        function test_not_all_fields_defined_powder(this)
            run=rundata(f_name(this,'MAP11020.spe_h5'),f_name(this,'demo_par.PAR'),'efix',200.);
            % run is not defined fully (properly)
            [is_undef,fields_to_load,undef_fields]=check_run_defined(run);
            assertEqual(1,is_undef);
            % missing fields
             % and these fields can be retrieved
            assertEqual(3,numel(fields_to_load));
            assertTrue(all(ismember({'S','ERR','det_par'},fields_to_load)));
            %             assertEqual(6,numel(fields_from_defaults));
            %             assertTrue(all(ismember({'omega','dpsi','gl','gs','u','v'},fields_from_defaults)));
        end
         function test_not_all_fields_defined_crystal(this)
            run=rundata(f_name(this,'MAP11020.spe_h5'),f_name(this,'demo_par.PAR'),'efix',200.,'gl',1.);
            % run is not defined fully (properly)
            [is_undef,fields_to_load,undef_fields]=check_run_defined(run);
            assertEqual(2,is_undef);
            % missing fields
            assertEqual(3,numel(undef_fields));
            assertTrue(all(ismember({'alatt','angdeg','psi'},undef_fields)));
            % and these fields can be retrieved
            assertEqual(3,numel(fields_to_load));
            assertTrue(all(ismember({'S','ERR','det_par'},fields_to_load)));
            %             assertEqual(6,numel(fields_from_defaults));
            %             assertTrue(all(ismember({'omega','dpsi','gl','gs','u','v'},fields_from_defaults)));
        end     
        function test_all_fields_defined_powder(this)
            % checks different option of private function
            % what_fields_are_needed()
            run=rundata(f_name(this,'MAP11020.spe_h5'),f_name(this,'demo_par.PAR'),'efix',200.);
            % run is not defined fully (properly) for crystal
            run.is_crystal=false;
            % but is sufficient for powder
            [is_undef,fields_to_load,undef_fields]=check_run_defined(run);
            assertEqual(1,is_undef);
            % missing fields
            assertTrue(isempty(undef_fields));
            % and these fields can be retrieved from file
            assertEqual(3,numel(fields_to_load));
            assertTrue(all(ismember({'S','ERR','det_par'},fields_to_load)));
            %assertTrue(isempty(fields_from_defaults));
        end
        
        function test_get_signalFromASCII(this)
            % define necessary parameters
            ds.efix=200;
            ds.psi=2;
            ds.alatt=[1;1;1];
            ds.angdeg=[90;90;90];
            
            run=rundata(f_name(this,'MAP10001.spe'),f_name(this,'demo_par.PAR'),ds);
            %run is fully defined
            run.lattice.omega=20; % let's change the omega value;
            [is_undef,fields_to_load,undef_fields]=check_run_defined(run);
            assertEqual(1,is_undef);
            assertTrue(isempty(undef_fields));
            %assertTrue(all(ismember({'dpsi','gl','gs'},fields_from_defaults)));
            assertTrue(all(ismember({'S','ERR','det_par'},fields_to_load)));
            
            run = get_rundata(run,'-this');
            S = run.S;
            Err = run.ERR;
            en  = run.en;
            assertEqual([30,28160],size(S));
            assertEqual([30,28160],size(Err));
            assertEqual([31,1],size(en));
        end
        
        function test_nxspe_file_loader_in_use(this)
            ds.alatt=[1;1;1];
            ds.angdeg=[90;90;90];
            
            run=rundata(f_name(this,'MAP11014.nxspe'),ds);
            fl=get(run,'loader');
            assertTrue(isa(fl,'loader_nxspe'));
            %run is fully defined
            [is_undef,fields_to_load,undef_fields]=check_run_defined(run);
            assertEqual(1,is_undef);
            assertTrue(isempty(undef_fields));
            assertTrue(all(ismember({'S','ERR','det_par','psi'},fields_to_load)));
            %assertTrue(all(ismember({'omega','dpsi','gl','gs'},fields_from_defaults)));
            
        end
        function test_modify_par_file_load(this)
            data_file = f_name(this,'MAP11014.nxspe');
            run=rundata(data_file);
            par_file_name = f_name(this,'demo_par.PAR');
            assertTrue(isempty(run.det_par));
            run=rundata(run,'par_file_name',par_file_name);
            
            assertEqual(28160,run.n_detectors);
            det = get_par(run);
            assertEqual(28160,numel(det.phi));
        end
        function test_modify_par_file_empty(this)
            run=rundata();
            run=rundata(run,'par_file_name',f_name(this,'demo_par.PAR'),...
                'data_file_name',f_name(this,'MAP11020.spe_h5'),'psi',2);
            
            assertEqual(28160,run.n_detectors);
            det = get_par(run);
            assertEqual(28160,numel(det.x2));
            assertEqual(2,run.lattice.psi);
        end
        function test_modify_data_file_load_makes_par_wrong(this)
            % a rundata class instanciated from nxspe which makes det_par
            % defined
            run=rundata(f_name(this,'MAP11014.nxspe'));
            assertTrue(isempty(run.det_par));
            
            run = get_rundata(run,'det_par','-this');
            % we change the initial file name to spe, which does not have
            % information about par data
            run.data_file_name=f_name(this,'MAP10001.spe');
            
            assertTrue(isempty(run.det_par));
        end
        function default_rundata_type(this)
            run=rundata();
            assertEqual(run.is_crystal,get(rundata_config,'is_crystal'));
        end
        
        function this=test_subsref_S(this)
            run=rundata(f_name(this,'MAP11014.nxspe'));
            wr=warning('off','MATLAB:structOnObject');
            run_str = struct(run);
            assertTrue(isempty(run_str.S));
            run=get_rundata(run,'-this');
            S=run.S;
            assertTrue(~isempty(S));
            run_str = struct(run);
            assertEqual(S,run_str.S);
            warning(wr);
        end
        
        function test_save_rundata_nxspe(this)
            test_file = fullfile(tempdir,'test_save_rundata_nxspe.nxspe');
            if exist(test_file,'file')
                delete(test_file);
            end
            tf = memfile();
            tf.S=ones(10,28160);
            tf.ERR=ones(10,28160);
            tf.en = 1:11;
            tf.save('test_file');
            
            run=rundata('test_file.memfile');
            f=@()run.saveNXSPE(test_file);
            assertExceptionThrown(f,'A_LOADER:saveNXSPE');
            
            run.par_file_name = f_name(this,'demo_par.PAR');
            f=@()run.saveNXSPE(test_file);
            % efix has to be defined
            assertExceptionThrown(f,'A_LOADER:saveNXSPE');
            
            run.efix = 1;
            f=@()run.saveNXSPE(test_file);
            % efix has to be defined
            assertExceptionThrown(f,'A_LOADER:saveNXSPE');
            
            run.efix = 150;
            run=run.saveNXSPE(test_file,'w');
            
            ld = loader_nxspe(test_file);
            ld=ld.load();
            
            assertEqual(ld.efix,run.efix);
            assertEqual(ld.S,run.S);
            det1=ld.det_par;
            det2=run.det_par;
            assertEqual(det1.x2,det2.x2);
            assertEqual(det1.phi,det2.phi);
            assertEqual(det1.azim,det2.azim);
            assertEqual(det1.group,det2.group);
            assertTrue(isnan(ld.psi));
            
            if exist(test_file,'file')
                delete(test_file);
            end
            
        end
        
    end
end

