classdef test_a_loader< TestCase
    %
    %

    properties
        test_data_path;
    end
    methods
        %
        function this=test_a_loader(name)
            if nargin<1
                name = 'test_a_loader';
            end
            this = this@TestCase(name);
            pths = horace_paths;
            this.test_data_path = paths.test_common;
        end

        function test_abstract_methods(~)
            al=a_loader_tester();

            f = @()al.can_load('some_file_name');
            assertExceptionThrown(f,'A_LOADER:abstract_method_called');

            %f = @()al.get_file_extension();
            %assertExceptionThrown(f,'A_LOADER:abstract_method_called');

            f = @()al.load_data('new_fileName');
            assertExceptionThrown(f,'A_LOADER:abstract_method_called');
            %

            f = @()al.get_data_info();
            assertExceptionThrown(f,'A_LOADER:abstract_method_called');

            f = @()al.init('data_file_name');
            assertExceptionThrown(f,'A_LOADER:abstract_method_called');

        end
        %
        function test_constructors(this)
            par_file = fullfile(this.test_data_path,'demo_par.par');
            al1=a_loader_tester(par_file);

            [~,fn,fext]=fileparts(al1.par_file_name);
            assertEqual('demo_par',fn);
            assertTrue(strcmpi('.par',fext));

            ldr = al1.detpar_loader;
            assertTrue(isa(ldr,'asciipar_loader'));

            assertEqual(al1.n_detectors,28160);

            [par,al1]=al1.load_par();
            assertEqual({'det_par','n_det_in_par'},al1.defined_fields());

            al2 = a_loader_tester(al1);

            assertEqual(par,al2.det_par);
            assertEqual({'det_par','n_det_in_par'},al2.defined_fields());

            % clear par loader.
            al1.par_file_name = '';
            ldr = al1.detpar_loader;
            assertTrue(isempty(ldr));

            assertTrue(isempty(al1.n_detectors));
            % select nxspe loader
            par_file = fullfile(this.test_data_path,'MAP11014.nxspe');

            al1.par_file_name = par_file;
            [~,fn,fext]=fileparts(al1.par_file_name);
            assertEqual('MAP11014',fn);
            assertTrue(strcmpi('.nxspe',fext));

            ldr = al1.detpar_loader;
            assertTrue(isa(ldr,'nxspepar_loader'));
            assertEqual(al1.n_detectors,28160);

        end
        %
        function test_constructors0(~)
            al=a_loader_tester();

            assertTrue(isempty(al.par_file_name));
            assertTrue(isempty(al.file_name));

            assertTrue(isempty(al.S));
            assertTrue(isempty(al.ERR));
            assertTrue(isempty(al.en));
            assertTrue(isempty(al.n_detectors));
        end

        function test_set_data_file_abstract(this)
            par_file = fullfile(this.test_data_path,'map_4to1_jul09.par');
            %
            al=a_loader_tester();
            al.par_file_name = par_file;

            [~,fn,fext]=fileparts(al.par_file_name);
            assertEqual('map_4to1_jul09',fn);
            assertEqual('.par',fext);
            assertEqual(36864,al.n_detectors);

            spe_file  = fullfile(this.test_data_path,'MAP10001.spe');
            % file_name set method overloaded to not set any file
            % for abstract loader
            al.file_name = spe_file;
            % the tester expects and accepts the file with extension alf
            % (fake)
            % such file does not exisit and file with detecots only is
            % invalid
            assertFalse(al.isvalid);

            function set_spe_file(cli,file)
                cli.file_name = file;
            end


            f=@(fn)set_spe_file(al,fn);
            spe_file  = fullfile(tmp_dir(),'abstract_test_file.altf');
            fl = fopen(spe_file,'w');
            fclose(fl);
            clob = onCleanup(@()delete(spe_file));

            assertExceptionThrown(@()f(spe_file),'A_LOADER:abstract_method_called');

        end
        %
        function test_setters_getters(~)
            al=a_loader_tester();
            al = al.set_defined_fields({'S','ERR','en','n_detectors'});
            al.S = ones(3,5);
            assertFalse(al.isvalid);
            al = al.check_combo_arg();
            assertFalse(al.isvalid)

            assertEqual(al.reason_for_invalid, ...
                'ill defined Signal: size(Signal) ~= size(ERR)');
            assertTrue(isempty(al.ERR));
            assertTrue(isempty(al.en));
            assertEqual(5,al.n_detectors);
            assertEqual({'S','n_detectors'},al.defined_fields());

            al.ERR = zeros(3,5);
            assertFalse(al.isvalid);
            assertEqual(al.reason_for_invalid,...
                'ill defined en: size(en) ~= size(S,1)+1 or size(en) ~= size(S,1)');

            assertTrue(isempty(al.en));
            assertEqual(5,al.n_detectors);
            assertEqual({'S','ERR','n_detectors'},al.defined_fields());

            en1=(1:4);
            al.en = en1';

            assertEqual(ones(3,5),al.S);
            assertEqual(zeros(3,5),al.ERR);
            assertEqual(en1',al.en);
            assertEqual(5,al.n_detectors);
            assertEqual({'S','ERR','en','n_detectors'},al.defined_fields());
            assertFalse(al.isvalid) % still invalid as no detector information
            assertEqual(al.reason_for_invalid,'load_par undefined')

            al.S=[];
            assertTrue(isempty(al.S));
            assertTrue(isempty(al.ERR));
            assertTrue(isempty(al.en));
            assertTrue(isempty(al.n_detectors));
            assertTrue(al.isvalid) % empty object is valid

        end


        function test_delete(~)
            al=a_loader_tester();

            al.S = zeros(10,100);
            al.ERR = zeros(10,100);
            al.en=(1:11);

            assertEqual(zeros(10,100),al.S);
            assertEqual(zeros(10,100),al.ERR);
            assertEqual((1:11)',al.en);
            assertEqual(100,al.n_detectors);

            al=al.delete();
            assertTrue(isempty(al.S));
            assertTrue(isempty(al.ERR));
            assertTrue(isempty(al.det_par));
            assertTrue(isempty(al.n_detectors));

        end
        function test_is_loader_defined(this)


            lt = a_loader_tester();

            %f = @()get_run_info(loader);
            [ok,mess]=lt.is_loader_valid();
            assertEqual(-1,ok);
            assertEqual('loader undefined',mess);
            lt.S = ones(5,3);

            [ok,mess]=lt.is_loader_valid();
            assertEqual(0,ok);
            assertEqual('size(S) ~= size(ERR)',mess);


            lt.ERR = zeros(5,3);
            [ok,mess]=lt.is_loader_valid();
            assertEqual(0,ok);
            assertEqual('size(en) ~=size(S,1)+1 || size(en) ~=size(S,1)',mess);

            lt.en = ones(6,1);
            [ok,mess]=lt.is_loader_valid();
            assertEqual(-1,ok);
            assertEqual('load_par undefined',mess);

            par_file = fullfile(this.test_data_path,'demo_par.par');
            lt.par_file_name = par_file;
            [ok,mess]=lt.is_loader_valid();

            assertEqual(0,ok);
            assertTrue(strncmp('inconsistent data and par file',mess,30));

            lt.S = ones(5,28160);
            lt.ERR = zeros(5,28160);
            [ok,mess]=lt.is_loader_valid();
            assertEqual(1,ok);
            assertTrue(isempty(mess));

        end

        function test_defined_fields(this)
            al=a_loader_tester();
            assertTrue(isempty(al.defined_fields()));
        end

        function test_get_run_info(this)
            al=a_loader_tester();
            f = @()al.get_run_info();
            assertExceptionThrown(f,'A_LOADER:runtime_error');

            par_file = fullfile(this.test_data_path,'demo_par.par');
            al.par_file_name = par_file;
            f = @()al.get_run_info();
            assertExceptionThrown(f,'A_LOADER:runtime_error');

        end

        function test_save_nxspe(this)
            lt = a_loader_tester();
            lt.S=ones(5,3);
            lt.ERR = zeros(5,3);
            lt.en = 1:6;
            lt.det_par = ones(6,6);

            test_file = fullfile(tmp_dir,'save_nxspe_testfile2.nxspe');
            %test_file = 'save_nxspe_testfile.nxspe';
            %            test_file = 'save_nxspe_testfile.nxspe';
            if is_file(test_file)
                delete(test_file);
            end
            f=@()lt.saveNXSPE(test_file,10,3);
            assertExceptionThrown(f,'HERBERT:a_loader:runtime_error');

            lt.det_par = ones(6,3);

            lt.saveNXSPE(test_file,10,3);

            lstor = loader_nxspe(test_file);
            lstor = lstor.load();

            assertEqual(lt.n_detectors,lstor.n_detectors);
            assertEqual(lt.S,lstor.S);
            assertEqual(lt.ERR,lstor.ERR);
            assertEqual(lt.en,lstor.en);
            assertEqual(10,lstor.efix);
            assertEqual(3,lstor.psi);

            det_load = lstor.det_par;
            det_old  = lt.det_par;
            assertEqual(det_load.phi,det_old.phi);
            assertEqual(det_load.azim,det_old.azim);
            assertEqual(det_load.x2,det_old.x2);

            delete(test_file);
        end
        function test_rewrite_nxspe(~)
            lt = a_loader_tester();
            lt.S=ones(5,3);
            lt.ERR = zeros(5,3);
            lt.en = 1:6;
            lt.det_par = ones(6,3);

            test_file = fullfile(tmp_dir,'save_nxspe_testfile1');
            real_file = [test_file,'.nxspe'];
            %test_file = 'save_nxspe_testfile.nxspe';
            %            test_file = 'save_nxspe_testfile.nxspe';
            if is_file(real_file)
                delete(real_file);
            end
            lt.saveNXSPE(test_file,10,3,'w');
            % it looks like clear bug in hdf 1.6 for Matlab 2008b which
            % does not release file after hdf write. Because of this, the
            % file can not be overwritten until Matlab is shut down.
            % it looks like Matlab/hdf bug as higher Matlab versions do not
            % have such problem
            if matlab_version_num()>7.07
                f=@()lt.saveNXSPE(test_file,10,3);
                assertExceptionThrown(f,'A_LOADER:invalid_argument');

                f=@()lt.saveNXSPE(test_file,10,3,'a');
                assertExceptionThrown(f,'A_LOADER:invalid_argument');

                lt.saveNXSPE(test_file,10,3,'w');
            end

            lstor = loader_nxspe(real_file);
            lstor = lstor.load();

            assertEqual(lt.n_detectors,lstor.n_detectors);
            assertEqual(lt.S,lstor.S);
            assertEqual(lt.ERR,lstor.ERR);
            assertEqual(lt.en,lstor.en);
            assertEqual(10,lstor.efix);
            assertEqual(3,lstor.psi);

            det_load = lstor.det_par;
            det_old  = lt.det_par;
            assertEqual(det_load.phi,det_old.phi);
            assertEqual(det_load.azim,det_old.azim);
            assertEqual(det_load.x2,det_old.x2);

            delete(real_file);
        end
    end
end
