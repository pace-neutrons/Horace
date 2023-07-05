classdef test_nxspepar_loader < TestCase
    properties
        test_data_path;
    end

    methods

        function this=test_nxspepar_loader(name)
            if nargin<1
                name = 'test_nxspepar_loader';
            end
            this = this@TestCase(name);
            pths = horace_paths;
            this.test_data_path = pths.test_common;
        end

        function test_constr_missing_file_throws(~)
            par_file = 'missing_par_file.nxspe';
            clOb = set_temporary_warning('off','HERBERT:nxspepar_loader:invalid_argument');
            pl = nxspepar_loader(par_file);
            [~,mess_id]=lastwarn;
            assertEqual(mess_id,'HERBERT:nxspepar_loader:invalid_argument');

            assertExceptionThrown(@()load_par(pl),...
                'HERBERT:nxspepar_loader:invalid_argument');
        end

        function test_constructors(this)
            par_file = fullfile(this.test_data_path,'MAP11014.nxspe');
            al1=nxspepar_loader(par_file);

            assertEqual(al1.n_det_in_par,28160);

            [~,fn,fext]=fileparts(al1.par_file_name);
            assertEqual('MAP11014',fn);
            assertTrue(strcmpi('.nxspe',fext));

            [nexus_dir,nexus_info] = al1.get_nxspe_info();
            assertEqual(nexus_dir,'/11014.spe')
            assertTrue(isstruct(nexus_info));
            assertEqual(nexus_info.Filename,al1.par_file_name);

            [par,al1]=al1.load_par();

            al2 = nxspepar_loader(al1);

            assertEqual(par,al2.det_par);
        end

        function test_set_par_file(this)
            par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');

            al=nxspepar_loader();
            al.par_file_name = par_file;

            [~,fn,fext]=fileparts(al.par_file_name);
            assertEqual('MAP11014v2',fn);
            assertEqual('.nxspe',fext);

            assertEqual(28160,al.n_det_in_par);
        end

        function test_load_par_fails(this)
            al=nxspepar_loader();
            f = @()al.load_par();
            assertExceptionThrown(f,'HERBERT:nxspepar_loader:invalid_argument');

            f = @()al.load_par('arg1','arg2');
            assertExceptionThrown(f,'HERBERT:nxspepar_loader:invalid_argument');

            if get(hor_config,'log_level')>-1
                par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');
                % deprecated option '-hor'
                par=al.load_par(par_file,'-hor');
                [wmess,wID] = lastwarn;
                assertEqual('NXSPEPAR_LOADER:deprecated_option',wID);
                mess_part='option -horace is deprecated';
                assertTrue(strncmp(mess_part,wmess,numel(mess_part)));
            end

        end

        function test_to_from_struct_det_in_mem(obj)
            par_file = fullfile(obj.test_data_path,'MAP11014v2.nxspe');
            al = nxspepar_loader(par_file);
            [det,al] = al.load_par();
            det.x2(1)=1;
            al.det_par = det;

            str = al.to_struct();

            al_rec = serializable.from_struct(str);

            assertFalse(isempty(al_rec.det_par));
            assertEqual(al.to_bare_struct,al_rec.to_bare_struct)
        end

        function test_to_from_struct_no_det_in_mem(obj)
            par_file = fullfile(obj.test_data_path,'MAP11014v2.nxspe');
            al = nxspepar_loader(par_file);
            str = al.to_struct();

            al_rec = serializable.from_struct(str);

            assertTrue(isempty(al_rec.det_par));
            assertEqual(al,al_rec)
        end

        function test_load_nxspe_par(this)
            al=nxspepar_loader();
            par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');

            [par,al] = al.load_par(par_file);

            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));
            assertEqual(28160,numel(par.x2))
            assertEqual(28160,al.n_det_in_par)

            [~,fname,fext] = fileparts(al.par_file_name);
            assertEqual([fname,fext],'MAP11014v2.nxspe');
        end

        function test_mslice_par(this)
            al=nxspepar_loader();
            par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');

            [par,al]=al.load_par(par_file,'-nohor');
            assertEqual([6,28160],size(par));

            [~,fname,fext] = fileparts(al.par_file_name);
            assertEqual([fname,fext],'MAP11014v2.nxspe');
        end

        function test_par_fron_cache_in_correct_format(this)
            al=nxspepar_loader();
            par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');

            [par,al]=al.load_par(par_file,'-nohor');
            assertEqual([6,28160],size(par));

            [~,fname,fext] = fileparts(al.par_file_name);
            assertEqual([fname,fext],'MAP11014v2.nxspe');
            % here we are loading data from cache, not reading the file
            % itself.
            [par,al]=al.load_par(par_file,'-nohor');
            assertEqual([6,28160],size(par));
        end

        function test_get_par_info(this)

            par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');
            ndet = nxspepar_loader.get_par_info(par_file);
            assertEqual(28160,ndet)

            f=@()nxspepar_loader.get_par_info('non_existing_file');
            assertExceptionThrown(f,'HERBERT:a_detpar_loader:invalid_argument');

            other_file_name = fullfile(this.test_data_path,'demo_par.par');
            f=@()nxspepar_loader.get_par_info(other_file_name);
            assertExceptionThrown(f,'HERBERT:a_detpar_loader:invalid_argument');

        end

        function test_set_par(this)
            par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');
            al=nxspepar_loader(par_file);

            assertEqual(28160,al.n_det_in_par);
            assertTrue(isempty(al.det_par));

            al.par_file_name = '';
            assertTrue(isempty(al.n_det_in_par));

            al.par_file_name = par_file;
            assertEqual(28160,al.n_det_in_par);

            [par,al] = al.load_par();
            assertEqual(par,al.det_par);

            al.det_par = ones(6,10);
            assertEqual(10,al.n_det_in_par);
            assertTrue(isempty(al.par_file_name));

            al.det_par = [];
            assertTrue(isempty(al.n_det_in_par));
            assertTrue(isempty(al.par_file_name));
        end

        function test_par_file_defines(this)
            al=nxspepar_loader();
            assertTrue(isempty(al.loader_define()));

            par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');
            al.par_file_name = par_file;
            assertEqual({'det_par','n_det_in_par'},al.loader_define());


            al.par_file_name = '';
            assertTrue(isempty(al.loader_define()));

            [~,al] = al.load_par(par_file);
            assertEqual({'det_par','n_det_in_par'},al.loader_define());

            al.par_file_name = '';
            assertEqual({'det_par','n_det_in_par'},al.loader_define());
        end

        function test_init_using_nxspepar(this)

            par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');

            [ndet,nxspe_version,nexus_dir,NXspeInfo]=...
                nxspepar_loader.get_par_info(par_file);
            assertEqual(ndet,28160);

            al=nxspepar_loader();
            al = al.set_nxspe_info(nexus_dir,NXspeInfo,nxspe_version);
            assertEqual(al.n_det_in_par,28160);
            assertTrue(isempty(al.det_par));
            assertEqual(al.par_file_name,par_file);

            al1 = nxspepar_loader(par_file);
            assertEqual(al1.n_det_in_par,28160);
            assertTrue(isempty(al.det_par));
            assertEqual(al.par_file_name,par_file);

            det1 = al.load_par();
            det2 = al1.load_par();

            assertEqual(det1,det2);
        end

        function test_init_using_nxspepar2(this)

            par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');

            al=nxspepar_loader(par_file);
            assertEqual(al.n_det_in_par,28160);
            assertTrue(isempty(al.det_par));
            assertEqual(al.par_file_name,par_file);

            [nexus_dir,nexus_info,nxspe_ver] = al.get_nxspe_info();

            al1 = nxspepar_loader();
            al1 = al1.set_nxspe_info(nexus_dir,nexus_info,nxspe_ver);
            assertEqual(al1.n_det_in_par,28160);
            assertTrue(isempty(al1.det_par));
            assertEqual(al1.par_file_name,par_file);

            det1 = al.load_par();
            det2 = al1.load_par();

            assertEqual(det1,det2);
        end


        function test_det_info_contained_and_array(this)
            par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');
            al = nxspepar_loader(par_file);
            [det,al] = al.load_par();
            det_initial = det;

            det.x2(1:10)=-1;
            al.det_par = det;

            % loader contained
            [~,al]=al.load_par(par_file);
            assertEqual(al.det_par.x2,det.x2);


            [det,al]=al.load_par(par_file,'-f','-array');
            assertEqual(al.det_par.x2,det_initial.x2);
            assertEqual(det,get_hor_format(det_initial));
        end
    end
end
