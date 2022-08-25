classdef test_asciipar_loader< TestCase
    properties
        test_data_path;
        test_par_file = 'demo_par.par';
        EXPECTED_DET_NUM = 28160
    end
    methods
        %
        function obj=test_asciipar_loader(name)
            obj = obj@TestCase(name);
            pths = horace_paths;
            obj.test_data_path = pths.test_common;
        end

        function test_constructors(obj)
            par_file = 'missing_par_file.par';
            f = @()asciipar_loader(par_file);
            assertExceptionThrown(f,'HERBERT:asciipar_loader:invalid_argument');

            par_file = fullfile(obj.test_data_path,obj.test_par_file);
            al1=asciipar_loader(par_file);


            [~,fn,fext]=fileparts(al1.par_file_name);
            assertEqual('demo_par',fn);
            assertTrue(strcmpi('.par',fext));

            [par,al1]=al1.load_par();

            al2 = asciipar_loader(al1);

            assertEqual(par,al2.det_par);
        end
        function test_set_par_file(obj)
            par_file = fullfile(obj.test_data_path,'map_4to1_jul09.par');
            %
            al=asciipar_loader();
            al.par_file_name = par_file;

            [~,fn,fext]=fileparts(al.par_file_name);
            assertEqual('map_4to1_jul09',fn);
            assertEqual('.par',fext);

            assertEqual(36864,al.n_det_in_par);
        end

        function test_load_par_fails(obj)
            al=asciipar_loader();
            f = @()al.load_par();
            assertExceptionThrown(f,'HERBERT:asciipar_loader:invalid_argument');

            f = @()al.load_par('arg1','arg2');
            assertExceptionThrown(f,'HERBERT:asciipar_loader:invalid_argument');

            if get(herbert_config,'log_level')>-1
                par_file = fullfile(obj.test_data_path,'map_4to1_jul09.par');
                % deprecated option '-hor'
                par=al.load_par(par_file,'-hor');
                [wmess,wID] = lastwarn;
                assertEqual('ASCIIPAR_LOADER:deprecated_option',wID);
                mess_part='option -horace is deprecated';
                assertTrue(strncmp(mess_part,wmess,numel(mess_part)));
            end

        end

        function test_load_ASCII_par_binary(obj)
            al=asciipar_loader();
            par_file = fullfile(obj.test_data_path,obj.test_par_file);

            old_state=get(herbert_config,'use_mex');
            set(herbert_config,'use_mex',1,'-buffer');
            [par,al] = al.load_par(par_file);
            set(herbert_config,'use_mex',old_state,'-buffer');

            [~,fname,fext]= fileparts(al.par_file_name);
            if ispc
                assertEqual([fname,fext],obj.test_par_file);
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end

            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));
            assertEqual(obj.EXPECTED_DET_NUM,numel(par.x2))
            assertEqual(obj.EXPECTED_DET_NUM,al.n_det_in_par)

            set(herbert_config,'use_mex',old_state,'-buffer');
        end

        function test_load_ASCII_par_matlab(obj)
            al=asciipar_loader();
            par_file = fullfile(obj.test_data_path,obj.test_par_file);

            old_state=get(herbert_config,'use_mex');
            set(herbert_config,'use_mex',0,'-buffer');
            [par,al] = al.load_par(par_file);
            set(herbert_config,'use_mex',old_state,'-buffer');

            [~,fname,fext] = fileparts(al.par_file_name);
            if ispc
                assertEqual([fname,fext],obj.test_par_file);
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end

            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));
            assertEqual(obj.EXPECTED_DET_NUM,numel(par.x2))
            assertEqual(obj.EXPECTED_DET_NUM,al.n_det_in_par)
        end
        % LOAD PAR forcing mex files
        function test_wrong_n_columns_fails(obj)
            al=asciipar_loader();
            par_file = fullfile(obj.test_data_path,'wrong_demo_par_7Col.PAR');

            f = @()al.load_par(par_file);
            use_mex=get(herbert_config,'use_mex');
            force_mex_if_use_mex=get(herbert_config,'force_mex_if_use_mex');
            set(herbert_config,'use_mex',true,'force_mex_if_use_mex',true,'-buffer');
            % should throw; par file has 7 columns
            assertExceptionThrown(f,'ASCIIPAR_LOADER:load_par');
            set(herbert_config,'use_mex',use_mex,'force_mex_if_use_mex',force_mex_if_use_mex,'-buffer');

        end
        function test_mslice_par(obj)
            al=asciipar_loader();
            par_file = fullfile(obj.test_data_path,obj.test_par_file);

            [par,al]=al.load_par(par_file,'-nohor');
            assertEqual([6,obj.EXPECTED_DET_NUM],size(par));

            [fpath,fname,fext] = fileparts(al.par_file_name);
            if ispc
                assertEqual([fname,fext],obj.test_par_file);
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end
        end
        function test_get_par_info(obj)

            par_file = fullfile(obj.test_data_path,'demo_par.PAR');
            ndet = asciipar_loader.get_par_info(par_file);
            assertEqual(obj.EXPECTED_DET_NUM,ndet)

            f=@()asciipar_loader.get_par_info('non_existing_file');
            assertExceptionThrown(f,'HERBERT:asciipar_loader:invalid_argument');

            other_file_name = fullfile(obj.test_data_path,'MAP11014.nxspe');
            f=@()asciipar_loader.get_par_info(other_file_name);
            assertExceptionThrown(f,'HERBERT:asciipar_loader:invalid_argument');

        end

        function test_set_par(obj)
            par_file = fullfile(obj.test_data_path,obj.test_par_file);
            al=asciipar_loader(par_file);

            assertEqual(obj.EXPECTED_DET_NUM,al.n_det_in_par);
            assertTrue(isempty(al.det_par));

            al.par_file_name = '';
            assertTrue(isempty(al.n_det_in_par));

            al.par_file_name = par_file;
            assertEqual(obj.EXPECTED_DET_NUM,al.n_det_in_par);

            [par,al] = al.load_par();
            assertEqual(par,al.det_par);

            al.det_par = ones(6,10);
            assertEqual(10,al.n_det_in_par);
            assertTrue(isempty(al.par_file_name));

            al.det_par = [];
            assertTrue(isempty(al.n_det_in_par));
            assertTrue(isempty(al.par_file_name));
        end
        function test_par_file_defines(obj)
            al=asciipar_loader();
            assertTrue(isempty(al.loader_define()));

            par_file = fullfile(obj.test_data_path,obj.test_par_file);
            al.par_file_name = par_file;
            assertEqual({'det_par','n_det_in_par'},al.loader_define());


            al.par_file_name = '';
            assertTrue(isempty(al.loader_define()));

            [det,al] = al.load_par(par_file);
            assertEqual({'det_par','n_det_in_par'},al.loader_define());

            al.par_file_name = '';
            assertEqual({'det_par','n_det_in_par'},al.loader_define());
        end

        function test_det_info_contained_and_array(obj)
            par_file = fullfile(obj.test_data_path,obj.test_par_file);
            al = asciipar_loader(par_file);
            [det,al] = al.load_par();
            det_initial = det;

            det.x2(1:10)=-1;
            al.det_par = det;

            % loader contained
            [dummy,al]=al.load_par(par_file);
            assertEqual(al.det_par.x2,det.x2);


            [det,al]=al.load_par(par_file,'-f','-array');
            assertEqual(al.det_par.x2,det_initial.x2);
            assertEqual(det,get_hor_format(det_initial));
        end
        function test_load_phx_matlab(obj)
            hcfg=herbert_config();
            current = hcfg.use_mex;
            c = onCleanup(@()set(hcfg,'use_mex',current));
            hcfg.use_mex = false;

            phx_file = fullfile(obj.test_data_path,'map_4to1_jul09.phx');
            par_file = fullfile(obj.test_data_path,'map_4to1_jul09.par');
            al = asciipar_loader(phx_file);

            [det,al] = al.load_par('-nohor');
            al.par_file_name  = par_file;
            [detp,al] = al.load_par('-nohor');

            assertElementsAlmostEqual(det(2,:),detp(2,:),'relative',1.e-4);
            assertElementsAlmostEqual(det(3,:),detp(3,:),'relative',1.e-4);

        end
        function test_load_phx_as_par_mex(obj)
            hcfg=herbert_config();
            current = hcfg.use_mex;
            c = onCleanup(@()set(hcfg,'use_mex',current));
            hcfg.use_mex = true;

            phx_file = fullfile(obj.test_data_path,'map_4to1_jul09.phx');
            par_file = fullfile(obj.test_data_path,'map_4to1_jul09.par');
            al = asciipar_loader(phx_file);

            [det,al] = al.load_par('-nohor');
            hor_par = al.det_par;
            al.par_file_name  = par_file;
            [detp] = al.load_par('-nohor');

            % test return from memory
            al.det_par = hor_par;
            det2 = al.load_par('-nohor');
            assertElementsAlmostEqual(det(2,:),detp(2,:),'relative',1.e-4);
            assertElementsAlmostEqual(det(3,:),detp(3,:),'relative',1.e-4);
            % phx file does not contain correct L2 values to read par from phx correctly
            assertElementsAlmostEqual(det(4,:),(10/6)*detp(4,:),'absolute',1.e-2);
            assertElementsAlmostEqual(det(5,:),(10/6)*detp(5,:),'absolute',1.e-2);

            assertElementsAlmostEqual(det2,det,'relative',1.e-8);
        end
        function test_load_phx_mex(obj)
            hcfg=herbert_config();
            current = hcfg.use_mex;
            c = onCleanup(@()set(hcfg,'use_mex',current));
            hcfg.use_mex = true;

            phx_file = fullfile(obj.test_data_path,'map_4to1_jul09.phx');
            par_file = fullfile(obj.test_data_path,'map_4to1_jul09.par');
            al = asciipar_loader(phx_file);

            [det,al] = al.load_par('-getphx');
            hor_par = al.det_par;
            al.par_file_name  = par_file;
            [detp] = al.load_par('-getphx');

            % test return from memory
            al.det_par = hor_par;
            det2 = al.load_par('-getphx');


            assertElementsAlmostEqual(det(2,:),detp(2,:),'relative',1.e-4);
            assertElementsAlmostEqual(det(3,:),detp(3,:),'relative',1.e-4);
            assertElementsAlmostEqual(det(4,:),detp(4,:),'relative',1.e-2);
            assertElementsAlmostEqual(det(5,:),detp(5,:),'relative',1.e-2);

            assertElementsAlmostEqual(det,det2,'relative',1.e-8);
        end
        function test_to_from_struct_det_in_mem(obj)
            phx_file = fullfile(obj.test_data_path,'map_4to1_jul09.phx');
            al = asciipar_loader(phx_file);
            [det,al] = al.load_par();
            det.x2(1)=1;
            al.det_par = det;

            str = al.to_struct();

            al_rec = serializable.from_struct(str);

            assertFalse(isempty(al_rec.det_par));
            assertEqual(al,al_rec)
        end

        function test_to_from_struct_no_det_in_mem(obj)
            phx_file = fullfile(obj.test_data_path,'map_4to1_jul09.phx');
            al = asciipar_loader(phx_file);
            str = al.to_struct();

            al_rec = serializable.from_struct(str);

            assertTrue(isempty(al_rec.det_par));
            assertEqual(al,al_rec)
        end

        function test_load_phx_nomex(obj)
            hcfg=herbert_config();
            current = hcfg.use_mex;
            c = onCleanup(@()set(hcfg,'use_mex',current));
            hcfg.use_mex = false;

            phx_file = fullfile(obj.test_data_path,'map_4to1_jul09.phx');
            par_file = fullfile(obj.test_data_path,'map_4to1_jul09.par');
            al = asciipar_loader(phx_file);

            [det,al] = al.load_par('-getphx');
            al.par_file_name  = par_file;
            [detp] = al.load_par('-getphx');
            assertElementsAlmostEqual(det(2,:),detp(2,:),'relative',1.e-4);
            assertElementsAlmostEqual(det(3,:),detp(3,:),'relative',1.e-4);
            assertElementsAlmostEqual(det(4,:),detp(4,:),'relative',1.e-2);
            assertElementsAlmostEqual(det(5,:),detp(5,:),'relative',1.e-2);
        end
    end
end
