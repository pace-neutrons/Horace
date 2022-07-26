classdef test_rundata_get< TestCase
    %
    %

    properties
        the_run; % some defined rundata class instance
        run2_work_with = []; % the copy of sample run to modify by particular tests
        log_level;
        test_data_path;
    end
    methods
        function fn=f_name(this,short_filename)
            fn = fullfile(this.test_data_path,short_filename);
        end

        %
        function this=test_rundata_get(name)
            this = this@TestCase(name);
            % define default rundata class instance
            pths = horace_paths;
            this.test_data_path = pths.test_common;

            this.the_run = rundata(fullfile(this.test_data_path,'MAP11014.nxspe'));
            % from 01/04/2017 rundata needs minimal non-default oriented lattice to use
            % get_rundata method if lattice is not defined in the file
            this.the_run.lattice = oriented_lattice([3,4,5],[90,90,80]);
        end
        function this=setUp(this)
            this.log_level = get(herbert_config,'log_level');
            set(herbert_config,'log_level',-1,'-buffer');
            this.run2_work_with = this.the_run;

        end
        function this=tearDown(this)
            set(herbert_config,'log_level',this.log_level,'-buffer');
            this.run2_work_with = [];
        end


        % tests themself
        function test_undefined_loader(~)
            % empty rundata class instance can not provide data
            f = @()get_rundata(rundata);
            assertExceptionThrown(f,'HERBERT:get_rundata:invalid_argument');
        end
        function test_wrong_input_key(this)
            % you provide non-symbol key or data modifier
            f = @()get_rundata(this.run2_work_with,10);
            assertExceptionThrown(f,'HERBERT:get_rundata:invalid_argument');
        end
        function test_non_existing_input_key(this)
            % you ask to provide non-existing data modifier
            f = @()get_rundata(this.run2_work_with,'-not_known_key','-somshit');
            assertExceptionThrown(f,'HERBERT:get_rundata:invalid_argument');
        end
        function test_non_existing_input_field(this)
            % you ask to return non-existing data fields
            f = @()get_rundata(this.run2_work_with,'S','-hor','bla_bla','beee','S','-nonan','ERR');
            assertExceptionThrown(f,'HERBERT:get_rundata:invalid_argument');
        end
        function this=test_load_nxspe_fields(this)
            % this form asks for all run data to be obtained;
            [S,Err,en,efix,psi,detectors]=get_rundata( ...
                this.run2_work_with,'S','ERR','en','efix','psi','det_par');

            assertEqual(size(S,1),size(en,1)-1);
            assertEqual(size(S),size(Err));
            assertEqual(800,efix);
            assertEqual(0,psi);
            assertEqual(numel(detectors.phi),size(S,2));
        end
        function this=test_load_nxspe_all_fields(this)
            % this form asks for all present in file run data to be obtained;
            data =get_rundata(this.run2_work_with);
            fi = fieldnames(data);
            assertTrue(any(ismember({'efix','en','S','ERR','det_par'},fi)));
        end
        function this=test_load_nxspe_par(this)
            % this form asks for all run data to be obtained;
            % and detectors returned as horace structure
            dp =get_rundata(this.run2_work_with,'det_par');
            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(dp))));
            assertTrue(all(ismember(fields(dp),{'filename','filepath','x2','phi','azim','width','height','group'})));
        end

        function test_not_all_requested_data_present(this)
            % this form asks for all run data to be obtained;
            f = @()get_rundata(this.run2_work_with,'-nonan');
            % but not all data describing the crystall are present in nxspe
            assertExceptionThrown(f,'HERBERT:get_rundata:invalid_argument');
        end



        function test_transform2rad_struct(this)
            % asks to transform some known fields into radians
            ds.alatt  =[1;1;1];
            ds.angdeg=[90;90;90];
            ds.omega=20;
            ds.psi  =30;
            ds.gl   =40;
            ds.gs   =50;

            run=rundata(f_name(this,'MAP11014.nxspe'),ds);

            data=get_rundata(run,'alatt','omega','psi','gl','gs','-rad');

            assertEqual(ds.alatt',  data.alatt);
            assertEqual(data.omega,ds.omega*pi/180);
            assertEqual(data.psi,  ds.psi*pi/180);
            assertEqual(data.gl,   ds.gl*pi/180);
            assertEqual(data.gs,   ds.gs*pi/180);
        end

        function test_transform2rad_cells(this)
            ds.alatt=[1;1;1];
            ds.angdeg=[90;90;90];
            ds.omega=20;
            ds.psi  =30;
            ds.gl   =40;
            ds.gs   =50;

            run=rundata(f_name(this,'MAP11014.nxspe'),ds);

            [alatt,omega,psi,gl,gs]=get_rundata(run,'alatt','omega','psi','gl','gs','-rad');

            assertEqual(ds.alatt',alatt);
            assertEqual(omega,ds.omega*pi/180);
            assertEqual(psi,ds.psi*pi/180);
            assertEqual(gl, ds.gl*pi/180);
            assertEqual(gs, ds.gs*pi/180);
        end
        function test_get_struct(this)
            % form asking for single data field returns single data field
            ds.alatt=[1;1;1];
            ds.angdeg=90;
            ds.omega=20;
            ds.psi  =30;
            ds.gl   =40;
            ds.gs   =50;

            run=rundata(f_name(this,'MAP11014.nxspe'),ds);

            alatt=get_rundata(run,'alatt');

            assertTrue(~isstruct(alatt));
            assertEqual(ds.alatt',alatt);
        end
        function test_get_this(this)
            % form loads data in class iteslf rather then into guest structure
            ds.alatt=[1;1;1];
            ds.angdeg=90;
            ds.omega=20;
            ds.psi  =30;
            ds.gl   =40;
            ds.gs   =50;

            run=rundata(f_name(this,'MAP11014.nxspe'),ds);

            run=get_rundata(run,'-this');

            assertTrue(isa(run,'rundata'));
            assertEqual(ds.alatt',run.lattice.alatt);
        end
        function test_get_data_struct(this)
            % form returns a structure
            ds.alatt=1;
            ds.angdeg=90;
            ds.omega=20;
            ds.psi  =30;
            ds.gl   =40;
            ds.gs   =50;

            run=rundata(f_name(this,'MAP11014.nxspe'),ds);

            run=get_rundata(run);

            assertTrue(isstruct(run));
            assertEqual([1,1,1],run.alatt);
            assertEqual([90,90,90],run.angdeg);

        end
        function test_this_nonc_with_rad(this)
            % inconsistent data mofifiers
            f = @()get_rundata(this.run2_work_with,'-this','-rad','gl','gs');
            assertExceptionThrown(f,'HERBERT:get_rundata:invalid_argument');
        end
        function test_this_nonc_with_nonan(this)
            % inconsistent data mofifiers
            f = @()get_rundata(this.run2_work_with,'-this','-nonan','gl','gs','S','det_par');
            assertExceptionThrown(f,'HERBERT:get_rundata:invalid_argument');
        end
        function test_this_nonc_with_hor(this)
            % -hor modifies det_par only so this is incompartible with -hor and
            % det_par
            f = @()get_rundata(this.run2_work_with,'-this','-hor','gl','gs','det_par');
            assertExceptionThrown(f,'HERBERT:get_rundata:invalid_argument');
        end
        function test_this_nonan_without_sighal(this)
            % inconsistent data mofifiers
            f = @()get_rundata(this.run2_work_with,'-nonan','gl','gs','det_par');
            assertExceptionThrown(f,'HERBERT:get_rundata:invalid_argument');
        end

        function test_suppress_nan(this)
            % this form asks for all run data to be obtained in class
            run=get_rundata(this.run2_work_with,'-this');

            [S,ERR,det]=get_rundata(run,'-nonan','S','ERR','det_par','en');
            assertEqual(size(S),[30,26495]);
            assertEqual(size(S),size(ERR));
            assertEqual(size(S,2),numel(det.azim));

        end
        function test_full_get(this)
            spe_file = {fullfile(this.test_data_path,'MAP10001.spe'),...
                fullfile(this.test_data_path,'MAP11014.nxspe')};
            par_file = fullfile(this.test_data_path,'demo_par.PAR');
            en_sample=[0:5:150]';
            lat= oriented_lattice(4.3,[90,90,90],1,...
                [1,0,0],[0,1,0]);
            run_files = rundata.gen_runfiles(spe_file,par_file,800,1,lat);

            [efix,en,emode,ndet,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs,det]=...
                get_rundata(run_files{1},...
                'efix','en','emode','n_detectors','alatt','angdeg','u','v', ...
                'psi','omega','dpsi','gl','gs','det_par',...
                '-rad');


            assertEqual(800,efix);
            assertEqual(1,emode);
            assertEqual(en_sample,en);
            assertEqual([4.3,4.3,4.3],alatt);
            % depending on policy decided for angdeg
            % currently angdeg is always degree
            assertEqual([90,90,90],angdeg);
            %assertEqual(deg2rad([90,90,90]),angdeg);
            assertEqual(28160,ndet);
            assertEqual([1,0,0],u);
            assertEqual([0,1,0],v);
            assertEqual(deg2rad(1),psi);
            assertEqual(0,omega);
            assertEqual(0,dpsi);
            assertEqual(0,gl);
            assertEqual(0,gs);
        end


        function test_error(this)
            % to test errors, whcuch seems ere observed
            spefile = fullfile(this.test_data_path,'MAP10001.spe');
            parfile = fullfile(this.test_data_path,'demo_par.PAR');

            r=rundata(spefile,parfile,'efix',45,'psi',-32, ...
                'angdeg',[91,92,93],'alatt',[4.5,4.6,4.7]);
            gg=get_rundata(r,'det_par');
            gg1 = get_par(parfile);

            ok=equal_to_tol(gg,gg1,1.e-5);
            assertTrue(ok);


            angdeg = get_rundata(r,'angdeg','-rad');
            % currently angdeg is always degrees
            %assertEqual([91,92,93]*(pi/180),angdeg);
            assertEqual([91,92,93],angdeg);

        end
    end
end
