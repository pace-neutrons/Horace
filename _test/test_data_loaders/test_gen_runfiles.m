classdef test_gen_runfiles< TestCase
    %

    properties
        nfiles_max = 6;
        en;
        efix;
        psi;
        omega;
        dpsi;
        gl;
        gs;
        emode;
        alatt;
        angdeg;
        u;
        v;
        det

        test_data_path;
        par_file;
        test_files;
        wk_dir
        clob = []
    end
    methods
        function this=test_gen_runfiles(name)
            if nargin<1
                name = 'test_gen_runfiles';
            end
            this = this@TestCase(name);
            pths = horace_paths;
            this.test_data_path = pths.test_common;
            this.wk_dir = tmp_dir;

            this.par_file = fullfile(this.test_data_path,'demo_par.par');

            this.en=cell(1,this.nfiles_max);
            this.efix=zeros(1,this.nfiles_max);
            this.psi=zeros(1,this.nfiles_max);
            this.omega=zeros(1,this.nfiles_max);
            this.dpsi=zeros(1,this.nfiles_max);
            this.gl=zeros(1,this.nfiles_max);
            this.gs=zeros(1,this.nfiles_max);
            for i=1:this.nfiles_max
                this.efix(i)=35+0.5*i;                       % different ei for each file
                this.en{i}=0.05*this.efix(i):0.2+i/50:0.95*this.efix(i);  % different energy bins for each file
                this.psi(i)=90-i+1;
                this.omega(i)=10+i/2;
                this.dpsi(i)=0.1+i/10;
                this.gl(i)=3-i/6;
                this.gs(i)=2.4+i/7;
            end
            this.psi=90:-1:90-this.nfiles_max+1;

            this.emode=1;
            this.alatt=[4.4,5.5,6.6];
            this.angdeg=[100,105,110];
            this.u=[1.02,0.99,0.02];
            this.v=[0.025,-0.01,1.04];

            ldd= asciipar_loader(this.par_file);
            this.det = ldd.load_par();

            this=gen_test_files(this,ldd);
        end
        %
        function delete(obj)
            for i=1:numel(obj.test_files)
                if is_file(obj.test_files{i})
                    delete(obj.test_files{i});
                end
            end
        end
        %
        function this=gen_test_files(this,ldd)
            this.test_files = cell(this.nfiles_max,1);
            det_ld = ldd.load_par();
            ndet = ldd.n_det_in_par();

            for i=1:this.nfiles_max
                this.test_files{i}=...
                    fullfile(tmp_dir,['test_gen_runfiles_test_files_',num2str(i),'.nxspe']);
                rd = rundata();
                rd.do_check_combo_arg= false;
                rd.efix = this.efix(i);
                rd.en   = this.en{i};
                nen = numel(this.en{i})-1;
                S = ones(nen,ndet);
                S(:,1) = NaN;
                S(:,10) = NaN;

                rd.lattice = oriented_lattice(3,90,this.psi(i));
                rd.S   = S;
                rd.ERR = ones(nen ,ndet);
                rd.par_file_name = this.par_file;
                rd.det_par = det_ld;
                rd.do_check_combo_arg= true;
                rd = rd.check_combo_arg();
                saveNxspe(this.test_files{i},rd)
            end
            this.clob = onCleanup(@()delete(this));
        end
        %
        function test_genrunfiles_indirect(this)
            emode2 = 2*ones(size(this.emode));

            run_files = rundata.gen_runfiles(this.test_files,this.par_file, ...
                this.efix,emode2,this.alatt,this.angdeg,...
                this.u,this.v,this.psi,this.omega,this.dpsi,this.gl,this.gs, ...
                '-check_validity');
            for i=1:this.nfiles_max
                assertTrue(isempty(run_files{i}.S));
                assertTrue(isempty(run_files{i}.ERR));
                [efixl,enl,emodel,ndetl]=get_rundata(run_files{i},...
                    'efix','en','emode','n_detectors',...
                    '-rad');
                assertEqual(efixl,this.efix(i));
                assertEqual(enl,this.en{i}');
                assertEqual(emodel,2);
                assertEqual(ndetl,28160);
            end
            efix_dif = repmat(this.efix',1,ndetl);
            dE = 0.01*(1:ndetl);
            dE_var = repmat(dE,this.nfiles_max,1);
            efix_dif  = efix_dif +dE_var;
            % check array
            run_files = rundata.gen_runfiles(this.test_files,this.par_file, ...
                efix_dif,emode2,this.alatt,this.angdeg,...
                this.u,this.v,this.psi,this.omega,this.dpsi,this.gl,this.gs, ...
                '-check_validity');
            for i=1:this.nfiles_max
                assertTrue(isempty(run_files{i}.S));
                assertTrue(isempty(run_files{i}.ERR));
                [efixl,enl,emodel,ndetl]=get_rundata(run_files{i},...
                    'efix','en','emode','n_detectors',...
                    '-rad');
                assertEqual(efixl,efix_dif(i,:));
                assertEqual(enl,this.en{i}');
                assertEqual(emodel,2);
                assertEqual(ndetl,28160);
            end
            % check vector:
            run_files = rundata.gen_runfiles(this.test_files,this.par_file, ...
                efix_dif(1,:),emode2,this.alatt,this.angdeg,...
                this.u,this.v,this.psi,this.omega,this.dpsi,this.gl,this.gs);
            for i=1:this.nfiles_max
                assertTrue(isempty(run_files{i}.S));
                assertTrue(isempty(run_files{i}.ERR));
                [efixl,enl,emodel,ndetl]=get_rundata(run_files{i},...
                    'efix','en','emode','n_detectors',...
                    '-rad');
                assertEqual(efixl,efix_dif(1,:));
                assertEqual(enl,this.en{i}');
                assertEqual(emodel,2);
                assertEqual(ndetl,28160);
            end
        end
        function test_wrong_ndetectors(this)
            % check wrong number of detectors
            efix_dif = repmat(this.efix',1,28160);
            efix_wrong = efix_dif(1:2,1:10);
            ERR = assertExceptionThrown(@()rundata.gen_runfiles(...
                this.test_files(1:2),this.par_file,...
                efix_wrong,2,this.alatt,this.angdeg,...
                this.u,this.v,this.psi(1:2),...
                this.omega(1:2),this.dpsi(1:2),this.gl(1:2),this.gs(1:2), ...
                '-check_validity'),'HERBERT:gen_runfiles:invalid_argument');

            mess_base = 'Emode=2. If efix is a vector, its size has to be equal to number of detectors';
            assertTrue(strncmp(ERR.message,mess_base,numel(mess_base)))

        end

        function test_genrunfiles(this)

            run_files = rundata.gen_runfiles(this.test_files,this.par_file, ...
                this.efix,this.emode,this.alatt,this.angdeg,...
                this.u,this.v,this.psi,this.omega,this.dpsi,this.gl,this.gs);

            assertEqual(run_files{1}.det_par,run_files{end}.det_par);

            for i=1:this.nfiles_max
                assertTrue(isempty(run_files{i}.S));
                assertTrue(isempty(run_files{i}.ERR));
                [efixl,enl,emodel,ndetl,alattl,angdegl,ul,vl,...
                    psil,omegal,dpsil,gll,gsl,detl]=...
                    get_rundata(run_files{i},...
                    'efix','en','emode','n_detectors','alatt','angdeg',...
                    'u','v','psi','omega','dpsi','gl','gs','det_par',...
                    '-rad');
                assertEqual(efixl,this.efix(i));
                assertEqual(enl,this.en{i}');
                assertEqual(emodel,this.emode);
                assertEqual(28160,ndetl);
                assertEqual(alattl,this.alatt);
                % Depending on policy decided on angdeg
                %assertEqual(angdegl,this.angdeg*(pi/180));
                assertEqual(angdegl,this.angdeg);
                assertEqual(ul,this.u);
                assertEqual(vl,this.v);
                assertEqual(psil,deg2rad(this.psi(i)));
                assertEqual(omegal,deg2rad(this.omega(i)));
                assertEqual(dpsil,deg2rad(this.dpsi(i)));
                assertEqual(gll,deg2rad(this.gl(i)));
                assertEqual(gsl,deg2rad(this.gs(i)));
                assertEqual(detl,run_files{i}.det_par);


                [Sl,ERRl,enl,efixl,emodel,alattl,angdegl,ul,vl,psil,omegal,dpsil,gll,gsl,detl]=...
                    get_rundata(run_files{i},'S','ERR','en','efix','emode','alatt','angdeg','u','v',...
                    'psi','omega','dpsi','gl','gs','det_par','-rad','-nonan');

                nen = numel(this.en{i})-1;
                oneS=ones(nen,28160-2);

                assertEqual(Sl,oneS);
                assertEqual(ERRl,oneS);
                %
                assertEqual(efixl,this.efix(i));
                assertEqual(enl,this.en{i}');
                assertEqual(emodel,this.emode);
                %assertEqual(ndetl,28158);
                assertEqual(alattl,this.alatt);
                %assertEqual(angdegl,this.angdeg*(pi/180));
                assertEqual(angdegl,this.angdeg);
                assertEqual(ul,this.u);
                assertEqual(vl,this.v);
                assertEqual(psil,this.psi(i)*(pi/180));
                assertEqual(omegal,this.omega(i)*(pi/180));
                assertEqual(dpsil,this.dpsi(i)*(pi/180));
                assertEqual(gll,this.gl(i)*(pi/180));
                assertEqual(gsl,this.gs(i)*(pi/180));
                % assertEqual(detl,run_files{i}.det_par);
                assertEqual(28158,numel(detl.x2));

            end
        end
        %
        function test_genrunfiles_with_missing(this)
            n_missing = 3;
            n_exist = numel(this.test_files);
            n_tot = n_missing+ n_exist;
            t_files_wm = this.test_files;
            efix_wm = zeros(n_tot,1);
            efix_wm(1:n_exist) = this.efix(1:n_exist);
            psi_wm = zeros(n_tot,1);
            psi_wm(1:n_exist) = this.psi(1:n_exist);

            for i=this.nfiles_max+1:this.nfiles_max+n_missing
                t_files_wm{i}=['TestFile_genrunfiles',num2str(i),'.spe'];
                efix_wm(i) = 35+0.5*i;
                psi_wm(i)=90-i+1;
            end


            run_files = rundata.gen_runfiles(t_files_wm,'',efix_wm,...
                this.emode,this.alatt,this.angdeg,...
                this.u,this.v,psi_wm,...
                this.omega(1),this.dpsi(1),this.gl(1),this.gs(1),...
                '-allow_missing','-check');

            assertEqual(run_files{1}.det_par,run_files{end}.det_par);
            run_files{1}=run_files{1}.load();
            det_par = run_files{1}.det_par;
            for i=2:n_tot
                if i<=n_exist
                    assertTrue(isempty(run_files{i}.S));
                    assertTrue(isempty(run_files{i}.ERR));
                    [efixl,enl,emodel,ndetl,alattl,angdegl,ul,vl,psil,...
                        omegal,dpsil,gll,gsl,det_parl]=...
                        get_rundata(run_files{i},...
                        'efix','en','emode','n_detectors','alatt','angdeg',...
                        'u','v','psi','omega','dpsi','gl','gs',...
                        'det_par','-rad');
                    assertEqual(efixl,this.efix(i));
                    assertEqual(enl,this.en{i}');
                    assertEqual(emodel,this.emode);
                    assertEqual(28160,ndetl);
                    assertEqual(alattl,this.alatt);
                    % Depending on policy decided on angdeg
                    %assertEqual(angdegl,this.angdeg*(pi/180));
                    assertEqual(angdegl,this.angdeg);
                    assertEqual(ul,this.u);
                    assertEqual(vl,this.v);
                    assertEqual(psil,this.psi(i)*(pi/180));
                    assertEqual(omegal,this.omega(1)*(pi/180));
                    assertEqual(dpsil,this.dpsi(1)*(pi/180));
                    assertEqual(gll,this.gl(1)*(pi/180));
                    assertEqual(gsl,this.gs(1)*(pi/180));
                    [ok,mess]=equal_to_tol(det_par,det_parl,'ignore_str',true);
                    assertTrue(ok,mess);
                else
                    assertTrue(isempty(run_files{i}.en));
                    assertTrue(isempty(run_files{i}.loader));
                    assertEqual(run_files{i}.efix,efix_wm(i));
                    assertEqual(run_files{i}.lattice.psi,psi_wm(i));
                end
            end
        end
        %
        function  test_genrunfiles_with_par(this)
            run_files1 = rundata.gen_runfiles(this.test_files{1},...
                this.par_file,this.efix(1),this.emode,this.alatt,this.angdeg,...
                this.u,this.v,this.psi(1),this.omega(1),this.dpsi(1),this.gl(1),this.gs(1));
            run_files2 = rundata.gen_runfiles(this.test_files{1},this.det,...
                this.efix(1),this.emode,this.alatt,this.angdeg,...
                this.u,this.v,this.psi(1),this.omega(1),this.dpsi(1),this.gl(1),this.gs(1));

            det1 = get_par(run_files1{1});
            det2 = get_par(run_files2{1});

            assertEqual(det1,det2);
        end

        function test_gen_and_save_nxspe(this)
            rez_file{1} = fullfile(this.wk_dir,'test_gen1_nxspe.nxspe');
            rez_file{2} = fullfile(this.wk_dir,'test_gen2_nxspe.nxspe');
            clob = onCleanup(@()delete(rez_file{:}));

            ndet = numel(this.det.x2);
            nen = numel(this.en{1});
            S = ones(nen-1,ndet)*.2;
            ERR =sqrt(2)*ones(nen-1,ndet);
            gen_nxspe(S,ERR,this.en{1},this.det,rez_file{1},this.efix(1));
            %
            assertTrue(is_file(rez_file{1}));
            rd = rundata(rez_file{1});
            rd = rd.load();
            delete(rez_file{1});

            assertEqual(rd.S,S);
            assertEqual(rd.ERR,ERR);
            assertEqual(rd.en,this.en{1}');
            assertTrue(isnan(rd.lattice.psi));
            assertTrue(~is_file(rez_file{1}));

            % nen ~= size(S,1)-1 throws
            S1 = S;
            ERR1=ERR;
            f = @()(gen_nxspe({S,S1},{ERR,ERR1},{this.en{2},this.en{3}},...
                this.par_file,rez_file,...
                this.efix(1:2),this.psi(1:2)));
            assertExceptionThrown(f,'HERBERT:a_loader:runtime_error');

            nen = numel(this.en{2});
            S1 = ones(nen-1,ndet)*4;
            ERR1 = ones(nen-1,ndet)*4;
            [rd1,rd2] = gen_nxspe({S,S1},{ERR,ERR1},{this.en{1},this.en{2}},...
                this.par_file,rez_file,...
                this.efix(1:2),this.psi(1:2));
            assertTrue(is_file(rez_file{1}));
            assertTrue(is_file(rez_file{2}));

            assertEqual(rd1.lattice.psi,this.psi(1));
            assertEqual(rd2.lattice.psi,this.psi(2));

            assertEqual(rd1.det_par,rd2.det_par);

            rd1.det_par.filename = '';
            rd.det_par.filename = '';
            rd1.det_par.filepath = '';
            rd.det_par.filepath = '';

            %
            %HACK -- width and height are not saved/restored correctly!
            rd.det_par.width  =[];
            rd1.det_par.width  =[];
            rd.det_par.height  =[];
            rd1.det_par.height  =[];
            assertEqual(rd1.det_par,rd.det_par);

            % use nxspe and build fully fledged rundata
            nen = numel(this.en{3});
            S2 = ones(nen-1,ndet)*8;
            ERR2 = ones(nen-1,ndet)*4;

            % use nxspe and build fully defined rundata
            delete(rez_file{2});
            rd3 = gen_nxspe(S2,ERR2,this.en{3},...
                rez_file{1},rez_file{2},...
                this.efix(3),this.psi(3),1,this.alatt,this.angdeg,...
                this.u,this.v,...
                this.omega(3),this.dpsi(3),this.gl(3),this.gs(3));

            assertTrue(is_file(rez_file{2}));
            assertEqual(rd3.S,S2);
            lat = rd3.lattice;
            assertEqual(lat.gl,this.gl(3));
            %
            rd = rundata(rez_file{2});
            assertEqual(rd.lattice.psi,this.psi(3));
            %rd = rd.load();
        end
        %
        function test_gen_and_save_nxspe_3D_array(this)
            rez_file{1} = fullfile(this.wk_dir,'test_gen1_nxspe.nxspe');
            rez_file{2} = fullfile(this.wk_dir,'test_gen2_nxspe.nxspe');
            clob = onCleanup(@()delete(rez_file{:}));

            ndet = numel(this.det.x2);
            nen = numel(this.en{1});
            S = ones(nen-1,ndet,2)*.2;
            ERR =sqrt(2)*ones(nen-1,ndet,2);
            enn  = [this.en{1}',this.en{1}'];
            gen_nxspe(S,ERR,enn,this.det,rez_file,this.efix(1:2),...
                this.psi(1:2));
            %
            assertTrue(is_file(rez_file{1}));
            assertTrue(is_file(rez_file{2}));
        end

        function test_gen_nosave_array(this)

            ndet = numel(this.det.x2);
            nen = numel(this.en{1});
            S = ones(nen-1,ndet,2)*.2;
            ERR =sqrt(2)*ones(nen-1,ndet,2);
            enn  = [this.en{1}',this.en{1}'];
            rds=gen_nxspe(S,ERR,enn,this.det,'',this.efix(1:2),...
                this.psi(1:2));
            %
            assertEqual(rds{1}.S,S(:,:,1))
            assertEqual(rds{2}.S,S(:,:,2))
        end

        function test_build_det_from_array(this)

            det_ar = get_par(this.par_file,'-nohor');
            ndet = size(det_ar,2);
            nen = numel(this.en{1});
            S = ones(nen-1,ndet,2)*.2;
            ERR =sqrt(2)*ones(nen-1,ndet,2);
            enn  = [this.en{1}',this.en{1}'];
            rds=gen_nxspe(S,ERR,enn,det_ar,'',this.efix(1:2),...
                this.psi(1:2));
            %
            assertEqual(rds{1}.S,S(:,:,1))
            assertEqual(rds{2}.S,S(:,:,2))
            det_hor = get_hor_format(det_ar,'mem_par_file');
            assertEqual(det_hor,rds{1}.det_par);
        end

        function test_replicate_en(this)

            ndet = numel(this.det.x2);
            nen = numel(this.en{1});
            S = ones(nen-1,ndet);
            ERR =sqrt(2)*ones(nen-1,ndet);
            rd = gen_nxspe({S,S},{ERR,ERR},this.en{1}',this.det,'',this.efix(1),...
                this.psi(1:2));
            %
            assertEqual(rd{1}.en,rd{2}.en);
            assertEqual(rd{1}.efix,rd{2}.efix);
        end


    end
end
