classdef test_asciipar_loader< TestCase
    properties
        test_data_path;
    end
    methods
        %
        function this=test_asciipar_loader(name)
            this = this@TestCase(name);
            rootpath=fileparts(which('herbert_init.m'));
            this.test_data_path = fullfile(rootpath,'_test/common_data');
        end
        
        function test_constructors(this)
            par_file = 'missing_par_file.par';
            f = @()asciipar_loader(par_file);
            assertExceptionThrown(f,'ASCIIPAR_LOADER:set_par_file_name');
            
            par_file = fullfile(this.test_data_path,'demo_par.par');
            al1=asciipar_loader(par_file);
            
            
            [fp,fn,fext]=fileparts(al1.par_file_name);
            assertEqual('demo_par',fn);
            assertTrue(strcmpi('.par',fext));
            
            [par,al1]=al1.load_par();
            
            al2 = asciipar_loader(al1);
            
            assertEqual(par,al2.det_par);
        end
        function test_set_par_file(this)
            par_file = fullfile(this.test_data_path,'map_4to1_jul09.par');
            %
            al=asciipar_loader();
            al.par_file_name = par_file;
            
            [fp,fn,fext]=fileparts(al.par_file_name);
            assertEqual('map_4to1_jul09',fn);
            assertEqual('.par',fext);
            
            assertEqual(36864,al.n_detectors);
        end
        
        function test_load_par_fails(this)
            al=asciipar_loader();
            f = @()al.load_par();
            assertExceptionThrown(f,'ASCIIPAR_LOADER:load_par');
            
            f = @()al.load_par('arg1','arg2');
            assertExceptionThrown(f,'ASCIIPAR_LOADER:load_par');
            
            if get(herbert_config,'log_level')>-1
                par_file = fullfile(this.test_data_path,'map_4to1_jul09.par');
                % deprecated option '-hor'
                par=al.load_par(par_file,'-hor');
                [wmess,wID] = lastwarn;
                assertEqual('ASCIIPAR_LOADER:load_par',wID);
                mess_part='option -horace is deprecated';
                assertTrue(strncmp(mess_part,wmess,numel(mess_part)));
            end
            
        end
        
        function test_load_ASCII_par_binary(this)
            al=asciipar_loader();
            par_file = fullfile(this.test_data_path,'demo_par.par');
            
            old_state=get(herbert_config,'use_mex');
            set(herbert_config,'use_mex',1,'-buffer');
            [par,al] = al.load_par(par_file);
            set(herbert_config,'use_mex',old_state,'-buffer');
            
            [fpath,fname,fext]= fileparts(al.par_file_name);
            if ispc
                assertEqual([fname,fext],'demo_par.par');
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end
            
            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));
            assertEqual(28160,numel(par.x2))
            assertEqual(28160,al.n_detectors)
            
            set(herbert_config,'use_mex',old_state,'-buffer');
        end
        
        function test_load_ASCII_par_matlab(this)
            al=asciipar_loader();
            par_file = fullfile(this.test_data_path,'demo_par.par');
            
            old_state=get(herbert_config,'use_mex');
            set(herbert_config,'use_mex',0,'-buffer');
            [par,al] = al.load_par(par_file);
            set(herbert_config,'use_mex',old_state,'-buffer');
            
            [fpath,fname,fext] = fileparts(al.par_file_name);
            if ispc
                assertEqual([fname,fext],'demo_par.par');
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end
            
            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));
            assertEqual(28160,numel(par.x2))
            assertEqual(28160,al.n_detectors)
        end
        % LOAD PAR forcing mex files
        function test_wrong_n_columns_fails(this)
            al=asciipar_loader();
            par_file = fullfile(this.test_data_path,'wrong_demo_par_7Col.PAR');
            
            f = @()al.load_par(par_file);
            use_mex=get(herbert_config,'use_mex_C');
            force_mex_if_use_mex=get(herbert_config,'force_mex_if_use_mex');
            set(herbert_config,'use_mex_C',true,'force_mex_if_use_mex',true,'-buffer');
            % should throw; par file has 7 columns
            assertExceptionThrown(f,'ASCIIPAR_LOADER:load_par');
            set(herbert_config,'use_mex_C',use_mex,'force_mex_if_use_mex',force_mex_if_use_mex,'-buffer');
            
        end
        function test_mslice_par(this)
            al=asciipar_loader();
            par_file = fullfile(this.test_data_path,'demo_par.par');
            
            [par,al]=al.load_par(par_file,'-nohor');
            assertEqual([6,28160],size(par));
            
            [fpath,fname,fext] = fileparts(al.par_file_name);
            if ispc
                assertEqual([fname,fext],'demo_par.par');
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end
        end
        function test_get_par_info(this)
            
            par_file = fullfile(this.test_data_path,'demo_par.PAR');
            ndet = asciipar_loader.get_par_info(par_file);
            assertEqual(28160,ndet)
            
            f=@()asciipar_loader.get_par_info('non_existing_file');
            assertExceptionThrown(f,'ASCIIPAR_LOADER:get_par_info');
            
            other_file_name = fullfile(this.test_data_path,'MAP11014.nxspe');
            f=@()asciipar_loader.get_par_info(other_file_name);
            assertExceptionThrown(f,'ASCIIPAR_LOADER:get_par_info');
            
        end
        
        function test_set_par(this)
            par_file = fullfile(this.test_data_path,'demo_par.par');
            al=asciipar_loader(par_file);
            
            assertEqual(28160,al.n_detectors);
            assertTrue(isempty(al.det_par));
            
            al.par_file_name = '';
            assertTrue(isempty(al.n_detectors));
            
            al.par_file_name = par_file;
            assertEqual(28160,al.n_detectors);
            
            [par,al] = al.load_par();
            assertEqual(par,al.det_par);
            
            al.det_par = ones(6,10);
            assertEqual(10,al.n_detectors);
            assertTrue(isempty(al.par_file_name));
            
            al.det_par = [];
            assertTrue(isempty(al.n_detectors));
            assertTrue(isempty(al.par_file_name));
        end
        function test_par_file_defines(this)
            al=asciipar_loader();
            assertTrue(isempty(al.par_file_defines()));
            
            par_file = fullfile(this.test_data_path,'demo_par.par');
            al.par_file_name = par_file;
            assertEqual({'det_par','n_detectors'},al.par_file_defines());
            
            
            al.par_file_name = '';
            assertTrue(isempty(al.par_file_defines()));
            
            [det,al] = al.load_par(par_file);
            assertEqual({'det_par','n_detectors'},al.par_file_defines());
            
            al.par_file_name = '';
            assertEqual({'det_par','n_detectors'},al.par_file_defines());
        end
        
        function test_det_info_contained_and_array(this)
            par_file = fullfile(this.test_data_path,'demo_par.par');
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
        function test_load_phx_matlab(this)
            hcfg=herbert_config();
            current = hcfg.use_mex;
            c = onCleanup(@()set(hcfg,'use_mex',current));
            hcfg.use_mex = false;
            
            phx_file = fullfile(this.test_data_path,'map_4to1_jul09.phx');
            par_file = fullfile(this.test_data_path,'map_4to1_jul09.par');
            al = asciipar_loader(phx_file);
            
            [det,al] = al.load_par('-nohor');
            al.par_file_name  = par_file;
            [detp,al] = al.load_par('-nohor');
            
            assertElementsAlmostEqual(det(2,:),detp(2,:),'relative',1.e-4);
            assertElementsAlmostEqual(det(3,:),detp(3,:),'relative',1.e-4);
            
        end
        function test_load_phx_as_par_mex(this)
            hcfg=herbert_config();
            current = hcfg.use_mex_C;
            c = onCleanup(@()set(hcfg,'use_mex_C',current));
            hcfg.use_mex_C = true;
            
            phx_file = fullfile(this.test_data_path,'map_4to1_jul09.phx');
            par_file = fullfile(this.test_data_path,'map_4to1_jul09.par');
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
        function test_load_phx_mex(this)
            hcfg=herbert_config();
            current = hcfg.use_mex_C;
            c = onCleanup(@()set(hcfg,'use_mex_C',current));
            hcfg.use_mex_C = true;
            
            phx_file = fullfile(this.test_data_path,'map_4to1_jul09.phx');
            par_file = fullfile(this.test_data_path,'map_4to1_jul09.par');
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

        function test_load_phx_nomex(this)
            hcfg=herbert_config();
            current = hcfg.use_mex;
            c = onCleanup(@()set(hcfg,'use_mex',current));
            hcfg.use_mex = false;
            
            phx_file = fullfile(this.test_data_path,'map_4to1_jul09.phx');
            par_file = fullfile(this.test_data_path,'map_4to1_jul09.par');
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

