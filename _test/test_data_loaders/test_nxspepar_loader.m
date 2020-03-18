classdef test_nxspepar_loader< TestCase
    properties
        test_data_path;
    end
    methods
        %
        function this=test_nxspepar_loader(name)
            if nargin<1
                name = 'test_nxspepar_loader';
            end
            this = this@TestCase(name);
            [~,tdp] = herbert_root();
            this.test_data_path = tdp;
        end
        
        function test_constructors(this)
            par_file = 'missing_par_file.nxspe';
            f = @()nxspepar_loader(par_file);
            assertExceptionThrown(f,'NXSPEPAR_LOADER:set_par_file_name');
            
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
            %
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
            assertExceptionThrown(f,'NXSPEPAR_LOADER:invalid_argument');
            
            f = @()al.load_par('arg1','arg2');
            assertExceptionThrown(f,'NXSPEPAR_LOADER:invalid_argument');
            
            if get(herbert_config,'log_level')>-1
                par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');
                % deprecated option '-hor'
                par=al.load_par(par_file,'-hor');
                [wmess,wID] = lastwarn;
                assertEqual('NXSPEPAR_LOADER:deprecated_option',wID);
                mess_part='option -horace is deprecated';
                assertTrue(strncmp(mess_part,wmess,numel(mess_part)));
            end
            
        end
        %
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
        %
        function test_get_par_info(this)
            
            par_file = fullfile(this.test_data_path,'MAP11014v2.nxspe');
            ndet = nxspepar_loader.get_par_info(par_file);
            assertEqual(28160,ndet)
            
            f=@()nxspepar_loader.get_par_info('non_existing_file');
            assertExceptionThrown(f,'NXSPEPAR_LOADER:invalid_argument');
            
            other_file_name = fullfile(this.test_data_path,'demo_par.par');
            f=@()nxspepar_loader.get_par_info(other_file_name);
            assertExceptionThrown(f,'NXSPEPAR_LOADER:invalid_argument');
            
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

