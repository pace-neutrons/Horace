classdef test_loader_nxspe< TestCase
    properties
        log_level;
        test_data_path;
        initial_warn_state;

        test_par_file = 'demo_par.par';
        EXPECTED_DET_NUM = 28160
    end
    methods
        %
        function obj=test_loader_nxspe(name)
            if nargin<1
                name = 'test_loader_nxspe';
            end
            obj = obj@TestCase(name);
            [~,tdp] = herbert_root();
            obj.test_data_path = tdp;
        end

        function obj=setUp(obj)
            obj.log_level = get(herbert_config,'log_level');
            set(herbert_config,'log_level',-1,'-buffer');
            obj.initial_warn_state=warning('query', 'all');
        end
        function obj=tearDown(obj)
            set(herbert_config,'log_level',obj.log_level,'-buffer');
            warning(obj.initial_warn_state)
        end

        function fn=f_name(obj,short_filename)
            fn = fullfile(obj.test_data_path,short_filename);
        end

        function test_to_from_struct_loader_in_memory(obj)
            nxspe_file = f_name(obj,'MAP11014.nxspe');
            par_file = fullfile(obj.test_data_path,obj.test_par_file);
            ld = loader_nxspe(nxspe_file,par_file);
            [S,ERR,en,ld] = ld.load_data();
            [par,ld] = ld.load_par();
            S(:,1) = 1;
            ERR(:,1) = 1;
            en(10) = 100;
            par.x2(1) = 10;
            ld.S = S;
            ld.ERR = ERR;
            ld.en = en;
            ld.det_par = par;

            str = ld.to_struct();
            ld_rec = serializable.from_struct(str);

            assertEqual(ld,ld_rec);
        end
        function test_saveload_loader_onfile(obj)
            nxspe_file = f_name(obj,'MAP11014.nxspe');
            ld = loader_nxspe(nxspe_file);
            en = ld.en;
            en(10)=100;
            ld.en = en;

            str = ld.saveobj();
            ld_rec = serializable.loadobj(str);

            assertEqual(ld,ld_rec);
        end

        function test_to_from_struct_loader_onfile(obj)
            nxspe_file = f_name(obj,'MAP11014.nxspe');
            par_file = f_name(obj,'MAP11014.nxspe');
            ld = loader_nxspe(nxspe_file,par_file);

            str = ld.to_struct();
            ld_rec = serializable.from_struct(str);

            assertEqual(ld,ld_rec);
        end


        % tests themself
        %CONSTRUCTOR:
        function test_wrong_first_argument(~)
            f = @()loader_nxspe(10);
            % should throw; first argument has to be a file name
            assertExceptionThrown(f,'HERBERT:a_loader:invalid_argument');
        end
        function test_file_not_exist(obj)
            f = @()loader_nxspe(f_name(obj,'missing_file.nxspe'));
            % should throw; first argument has to be an existing file name
            % disable warning about escape sequences in warning on matlab
            % 2009
            ws = warning('off','MATLAB:printf:BadEscapeSequenceInFormat');

            assertExceptionThrown(f,'HERBERT:nxspepar_loader:invalid_argument');
            warning(ws);
        end
        function test_non_supported_nxspe(obj)
            nxpse_name = f_name(obj,'currently_not_supported_NXSPE.nxspe');
            f = @()loader_nxspe(nxpse_name);
            % should throw; first argument has to be a file name with single
            % nxspe data structure in it
            assertExceptionThrown(f,'HERBERT:isis_utilities:invalid_argument');
        end

        function test_loader_nxspe_initated(obj)
            nxspe_file = f_name(obj,'MAP11014.nxspe');
            loader=loader_nxspe(nxspe_file);
            % should be OK and return correct file name and file location;
            %assertEqual(loader.root_nexus_dir,'/11014.spe');
            assertEqual(800,loader.efix);
            assertEqual(0,loader.psi);
            assertEqual(loader.file_name,f_name(obj,'MAP11014.nxspe'));
        end
        % DEFINED FIELDS
        function test_emptyloader_nxspe_defines_nothing(obj)
            loader=loader_nxspe();
            % if file is not defined, no data fields are defined either;
            fields = defined_fields(loader);
            assertTrue(isempty(fields));
        end
        %LOAD_DATA
        function test_emptyload_throw(obj)
            loader=loader_nxspe();
            f = @()load_data(loader);
            % input file name is not defined
            assertExceptionThrown(f,'LOAD_NXSPE:invalid_argument');
        end

        function test_loader_nxspe_works(obj)
            loader=loader_nxspe();
            file_name = f_name(obj,'MAP11014.nxspe');
            % loads only spe data
            [S,ERR,en,loader]=load_data(loader,file_name);
            Ei = loader.efix;
            psi= loader.psi;
            assertEqual(30*obj.EXPECTED_DET_NUM,numel(S))
            assertEqual(30*obj.EXPECTED_DET_NUM,numel(ERR))
            assertEqual(31,numel(en));
            assertEqual(800,Ei);
            assertEqual(0,psi);
            assertEqual(loader.file_name,f_name(obj,'MAP11014.nxspe'));
            assertEqual(psi,loader.psi);
            assertEqual(Ei,loader.efix);
            assertEqual(en,loader.en);
        end
        function test_loader_nxspe_constr(obj)
            loader=loader_nxspe(f_name(obj,'MAP11014.nxspe'));
            % loads only spe data
            [S,ERR,en,loader]=load_data(loader);
            Ei = loader.efix;
            psi= loader.psi;

            if get(herbert_config,'log_level')<0
                warnStruct = warning('off', 'LOADER_NXSPE:load_par');
            end


            % ads par data and return it as horace data
            par=load_par(loader,'-horace');
            % MAP11014.nxspe is version 1.1 nxspe file
            if get(herbert_config,'log_level')>-1
                warnStruct = warning('query', 'last');
                msgid_integerCat = warnStruct.identifier;
                assertEqual('LOADER_NXSPE:load_par',msgid_integerCat);
            end

            % warning about old nxspe should still be generated in other
            % places
            if get(herbert_config,'log_level')<0
                warning(warnStruct);
            end


            assertEqual(30*obj.EXPECTED_DET_NUM,numel(S))
            assertEqual(30*obj.EXPECTED_DET_NUM,numel(ERR))
            assertEqual(31,numel(en));
            assertEqual(800,Ei);
            assertEqual(0,psi);
            %assertEqual(loader.root_nexus_dir,'/11014.spe');
            f_par = fields(par);
            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},f_par)));
            assertTrue(all(ismember(f_par,{'filename','filepath','x2','phi','azim','width','height','group'})));
            assertEqual(obj.EXPECTED_DET_NUM,numel(par.x2))
        end
        %Load PAR from nxspe
        function test_loader_par_works(obj)
            loader=loader_nxspe();

            if get(herbert_config,'log_level')<0
                warnStruct = warning('off', 'LOAD_NXSPE:old_version');
            end
            % loads only par data
            par_file = f_name(obj,'MAP11014.nxspe');
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

            assertEqual(obj.EXPECTED_DET_NUM,numel(par.x2))
            assertEqual(obj.EXPECTED_DET_NUM,loader.n_detectors)
            %assertEqual(loader.root_nexus_dir,'/11014.spe');
            assertTrue(isempty(loader.file_name));
            assertEqual(loader.par_file_name,f_name(obj,'MAP11014.nxspe'));
            assertEqual(loader.det_par,par);
        end
        function test_load_phx_from_nxspe(obj)

            % loads only par data
            par_file = f_name(obj,'map5935_small.nxspe');
            loader=loader_nxspe(par_file);
            [nxpse_phx,loader]=loader.load_par('-getphx');

            loader.par_file_name = f_name(obj,'map_4to1_jul09.par');
            ascii_phx=loader.load_par('-getphx');


            difr=0.5*abs((nxpse_phx(1,:)-ascii_phx(1,:))./(nxpse_phx(1,:)+ascii_phx(1,:)));
            assertTrue(sum(difr>1.e-3)==0)
            difr=0.5*abs((nxpse_phx(2,:)-ascii_phx(2,:))./(nxpse_phx(2,:)+ascii_phx(2,:)));
            assertTrue(sum(difr>1.e-1)==0)
            %difr=0.5*abs((nxpse_phx(3,:)-ascii_phx(3,:))./(nxpse_phx(3,:)+ascii_phx(3,:)));
            %assertTrue(sum(difr>1.e-1)==0)
            % obj should be fixed one day
            %assertElementsAlmostEqual(nxpse_phx(4,:),ascii_phx(4,:),'relative',1.e-2);
            %assertElementsAlmostEqual(nxpse_phx(5,:),ascii_phx(5,:),'relative',1.e-4);
        end


        function test_warn_on_nxspe1_0(obj)
            loader = loader_nxspe(f_name(obj,'nxspe_version1_0.nxspe'));
            % should be OK and return correct file name and file location;
            %assertEqual(loader.root_nexus_dir,'/11014.spe');
            assertEqual(loader.file_name,f_name(obj,'nxspe_version1_0.nxspe'));
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
        function test_get_runinfo(obj)
            loader=loader_nxspe(f_name(obj,'MAP11014.nxspe'));
            % loads only partial spe data
            [ndet,en,loader]=get_run_info(loader);

            assertEqual(31,numel(en));
            assertEqual(obj.EXPECTED_DET_NUM,ndet)

            assertEqual(en,loader.en);
            %             assertEqual(ndet,loader.n_detectors)
        end
        % DEAL WITH NAN
        function test_loader_NXSPE_readsNAN(obj)
            % reads binary NaN in memory and transforms -1e+30 into ISO NaN
            % in memory
            loader=loader_nxspe(f_name(obj,'test_nxspe_withNANS.nxspe'));
            [S,ERR,en]=load_data(loader);
            assertEqual(size(S),[30,5]);
            assertEqual(size(S),size(ERR));
            assertEqual(size(en),[31,1]);
            mask=isnan(S);
            assertEqual(mask(:,1:2),logical(ones(30,2)))
            assertEqual(mask(1:2,5),logical([1;1]));
        end
        % -----------
        function test_get_data_info(obj)
            nxspe_file_name = fullfile(obj.test_data_path,'MAP11014v2.nxspe');
            [ndet,en,file_name,ei,psi,nexus_dir,nxspe_ver]=loader_nxspe.get_data_info(nxspe_file_name);

            assertEqual([31,1],size(en));
            assertEqual(obj.EXPECTED_DET_NUM,ndet);
            assertEqual(nxspe_file_name,file_name);
            assertEqual(800,ei);
            assertEqual(20,psi);
            assertEqual('/11014.spe',nexus_dir);
            assertEqual('1.2',nxspe_ver);
        end

        function test_can_load_init_and_runinfo(obj)
            spe_file_name = fullfile(obj.test_data_path,'MAP10001.spe');
            nxspe_file_name = fullfile(obj.test_data_path,'MAP11014.nxspe');


            [ok,mess]=loader_nxspe.can_load(spe_file_name);
            assertTrue(~ok);
            assertEqual(' The extension .spe of file: MAP10001 is not among supported extensions',mess);

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
        function test_init_all(obj)
            nxspe_file_name = fullfile(obj.test_data_path,'MAP11014.nxspe');


            la = loader_nxspe();
            la=la.init(nxspe_file_name,'');

            [ndet,en]=la.get_run_info();
            assertEqual(obj.EXPECTED_DET_NUM,ndet);
            assertEqual(31,numel(en));


            par_file_name =fullfile(obj.test_data_path,obj.test_par_file);
            la=la.init(nxspe_file_name,par_file_name);

            [ndet,en]=la.get_run_info();
            assertEqual(obj.EXPECTED_DET_NUM,ndet);
            assertEqual(31,numel(en));

        end
        function test_load_and_init_all(obj)
            nxspe_file_name = fullfile(obj.test_data_path,'MAP11014.nxspe');
            par_file_name =fullfile(obj.test_data_path,obj.test_par_file);

            [ok,fh] = loader_nxspe.can_load(nxspe_file_name);
            assertTrue(ok);

            la = loader_nxspe();
            la=la.init(nxspe_file_name,par_file_name,fh);

            [ndet,en]=la.get_run_info();
            assertEqual(obj.EXPECTED_DET_NUM,ndet);
            assertEqual(31,numel(en));

            [par,la]=la.load_par('-nohor');
            [ndet,en1]=la.get_run_info();
            assertEqual(size(par,2),ndet);
            assertEqual(en,en1);

            assertEqual(1,is_loader_valid(la));

            la.par_file_name =fullfile(obj.test_data_path,'wrong_demo_par_7Col.PAR');
            assertEqual(0,is_loader_valid(la));

            f = @()la.get_run_info();
            assertExceptionThrown(f,'A_LOADER:runtime_error');
        end

        function test_get_file_extension(obj)
            fext=loader_nxspe.get_file_extension();

            assertEqual(fext,'.nxspe');

            descr = loader_nxspe.get_file_description();
            assertEqual('nexus spe files (MANTID): (*.nxspe)',descr);
        end
        function test_is_loader_valid(obj)
            nxspe_file_name = fullfile(obj.test_data_path,'MAP11014.nxspe');
            par_file_name =fullfile(obj.test_data_path,obj.test_par_file);

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
            assertEqual(-1,ok);
            assertEqual(mess,'load_par undefined');

        end
        function test_all_fields_defined(obj)
            nxspe_file_name = fullfile(obj.test_data_path,'MAP11014.nxspe');
            par_file_name =fullfile(obj.test_data_path,obj.test_par_file);

            loader=loader_nxspe();
            fields = defined_fields(loader);
            assertTrue(isempty(fields));


            loader.par_file_name = par_file_name;
            fields = defined_fields(loader);
            assertTrue(any(ismember({'det_par','n_det_in_par'},fields)));

            loader.file_name =nxspe_file_name;
            fields = defined_fields(loader);
            assertTrue(any(ismember({'S','ERR','en','efix','psi','det_par','n_detectors','n_det_in_par'},fields)));

            loader.par_file_name ='';
            fields = defined_fields(loader);
            assertTrue(any(ismember({'S','ERR','en','efix','psi','det_par','n_detectors','n_det_in_par'},fields)));


        end
        function test_loader_nxspe_defines(obj)
            loader = loader_nxspe(f_name(obj,'MAP11014.nxspe'));
            fields = defined_fields(loader);
            assertEqual({'S','ERR','en','efix','psi','det_par','n_detectors','n_det_in_par'},fields);
        end
        %
        function test_load(obj)
            dat_file =f_name(obj,'MAP11014v2.nxspe');
            lx = loader_nxspe(dat_file);
            lx=lx.load();

            fields = defined_fields(lx);

            assertEqual({'S','ERR','en','efix','psi','det_par','n_detectors','n_det_in_par'},fields);
            assertEqual(lx.n_detectors,size(lx.S,2));
            assertEqual(numel(lx.en),size(lx.S,1)+1);
            S = lx.S;
            ERR = lx.ERR;
            det = lx.det_par;

            ndet = lx.n_detectors;
            nen =  numel(lx.en)-1;
            lx.S=ones(nen,ndet);
            lx = lx.load('-keep');
            assertEqual(ones(nen,ndet),lx.S);
            assertEqual(ERR,lx.ERR);
            assertEqual(det,lx.det_par);

            lx = lx.load_data();
            lx.ERR=ones(nen,ndet);
            assertEqual(S,lx.S);
            assertEqual(ones(nen,ndet),lx.ERR);
            assertEqual(det,lx.det_par);

            lx = lx.load_data();
            lx.det_par = ones(6,ndet);
            lx = lx.load('-keep');
            assertEqual(S,lx.S);
            assertEqual(ERR,lx.ERR);
            one_det = get_hor_format(ones(6,ndet));
            assertEqual(one_det ,lx.det_par);

            lx.S=[];
            lx = lx.load('-keep');
            assertEqual(S,lx.S);
            assertEqual(ERR,lx.ERR);
            assertEqual(one_det ,lx.det_par);
        end

    end
end

