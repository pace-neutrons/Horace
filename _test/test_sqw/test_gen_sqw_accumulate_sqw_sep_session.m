classdef test_gen_sqw_accumulate_sqw_sep_session < TestCaseWithSave
    % Series of tests of gen_sqw and associated functions Optionally writes
    % results to output file
    %   >> runtests test_gen_sqw_accumulate_sqw          % Compares with
    %   previously saved results in test_gen_sqw_accumulate_sqw_output.mat
    %                                                    % in the same
    %                                                    folder as this
    %                                                    function
    %   >>tc=test_gen_sqw_accumulate_sqw ('save')  % Stores sample
    %   >>tc.save()                                %results into tmp folder
    %
    % Reads previously created test data sets. Reads previously created
    % test data sets.
    properties
        test_data_path;
        test_functions_path;
        par_file;
        nfiles_max=6;
        
        pars;
        scale;
        
        proj;
        gen_sqw_par={};
        % files;
        spe_file={[]};
        
        skip_tests=false;
        instrum
        sample
    end
    methods(Static)
        function new_names = rename_file_list(input_list,new_ext)
            % change extension for list of files
            if ~iscell(input_list)
                input_list = {input_list};
            end
            new_names = cell(1,numel(input_list));
            for i=1:numel(input_list)
                fls = input_list{i};
                [fpath,fn,~] = fileparts(fls);
                flt = fullfile(fpath,[fn,new_ext]);
                new_names{i} = flt;
                if exist(fls,'file')==2
                    movefile(fls,flt,'f');
                end
            end
        end
        
    end
    
    methods
        function this=test_gen_sqw_accumulate_sqw_sep_session(varargin)
            % Series of tests of gen_sqw and associated functions
            % Optionally writes results to output file
            %
            %   >> test_gen_sqw_accumulate_sqw          % Compares with
            %   previously saved results in
            %   test_gen_sqw_accumulate_sqw_output.mat
            %                                           % in the same
            %                                           folder as this
            %                                           function
            %   >> test_gen_sqw_accumulate_sqw ('save') % Save to
            %   test_multifit_horace_1_output.mat
            %
            % Reads previously created test data sets.
            
            % onstructocr
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            
            this = this@TestCaseWithSave(name,fullfile(fileparts(mfilename('fullpath')),'test_gen_sqw_accumulate_sqw_output.mat'));
            %if ispc
            %    this.tol= 1.e-6;
            %else
            %    this.tol = 1.e-3;
            %end
            
            
            % do overloading mex/nomex
            hc = hor_config();
            sess_state = hc.accum_in_separate_process;
            comb_state = hc.use_mex_for_combine;
            co = onCleanup(@()set(hor_config,'accum_in_separate_process',sess_state,'use_mex_for_combine',comb_state));
            hc.accum_in_separate_process = true;
            hc.use_mex_for_combine = true;
            
            if ~hc.accum_in_separate_process
                warning('TEST_GEN_SQW_ACC_SQW:multisession_mode',' multisession mode can not be enablesd');
                if ~hc.use_mex_for_combine % nothing to do, this mode can not be enabled
                    this.skip_tests=true;
                end
            else
                this.skip_tests=false;
            end
            
            
            % do other initialization
            this.comparison_par={ 'min_denominator', 0.01, 'ignore_str', 1};
            this.tol = 1.e-5;
            this.test_functions_path=fullfile(fileparts(which('horace_init.m')),'_test/common_functions');
            
            addpath(this.test_functions_path);
            
            % build test file names
            this.spe_file=cell(1,this.nfiles_max);
            for i=1:this.nfiles_max
                this.spe_file{i}=fullfile(tempdir,['gen_sqw_acc_sqw_spe',num2str(i),'.nxspe']);
            end
            
            %this.par_file=fullfile(this.results_path,'96dets.par');
            this.par_file=fullfile(this.results_path,'gen_sqw_96dets.nxspe');
            
            
            % initiate test parameters
            en=cell(1,this.nfiles_max);
            efix=zeros(1,this.nfiles_max);
            psi=zeros(1,this.nfiles_max);
            omega=zeros(1,this.nfiles_max);
            dpsi=zeros(1,this.nfiles_max);
            gl=zeros(1,this.nfiles_max);
            gs=zeros(1,this.nfiles_max);
            for i=1:this.nfiles_max
                efix(i)=35+0.5*i;                       % different ei for each file
                en{i}=0.05*efix(i):0.2+i/50:0.95*efix(i);  % different energy bins for each file
                psi(i)=90-i+1;
                omega(i)=10+i/2;
                dpsi(i)=0.1+i/10;
                gl(i)=3-i/6;
                gs(i)=2.4+i/7;
            end
            psi=90:-1:90-this.nfiles_max+1;
            
            emode=1;
            alatt=[4.4,5.5,6.6];
            angdeg=[100,105,110];
            u=[1.02,0.99,0.02];
            v=[0.025,-0.01,1.04];
            
            this.gen_sqw_par={en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs};
            
            this.pars=[1000,8,2,4,0];  % [Seff,SJ,gap,gamma,bkconst]
            this.scale=0.3;
            
        end
        %
        function [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this,varargin)
            if nargin>1
                n_elem = varargin{1};
                if numel(n_elem) >1
                    select = n_elem;
                else
                    select = 1:n_elem;
                end
            else
                n_elem = numel(this.gen_sqw_par{1});
                select = 1:n_elem;
            end
            en =this.gen_sqw_par{1}(select);
            efix=this.gen_sqw_par{2}(select);
            emode=this.gen_sqw_par{3};
            alatt=this.gen_sqw_par{4};
            angdeg=this.gen_sqw_par{5};
            u=this.gen_sqw_par{6};
            v=this.gen_sqw_par{7};
            psi=this.gen_sqw_par{8}(select);
            omega=this.gen_sqw_par{9}(select);
            dpsi=this.gen_sqw_par{10}(select);
            gl=this.gen_sqw_par{11}(select);
            gs=this.gen_sqw_par{12}(select);
        end
        %
        function [skip,sess_state,comb_state]=setup_multi_mode(this)
            if this.skip_tests
                skip = true;
                return
            end
            hc = hor_config();
            sess_state = hc.accum_in_separate_process;
            comb_state = hc.use_mex_for_combine;
            hc.accum_in_separate_process = true;
            hc.use_mex_for_combine = true;
            %
            skip= false;
        end
        %
        function this=build_test_files(this)
            
            %% =====================================================================================================================
            % Make instrument and sample
            % =====================================================================================================================
            wmod=IX_moderator('AP2',12,35,'ikcarp',[3,25,0.3],'',[],0.12,0.12,0.05,300);
            wap=IX_aperture(-2,0.067,0.067);
            wchop=IX_fermi_chopper(1.8,600,0.1,1.3,0.003);
            instrument_ref.moderator=wmod;
            instrument_ref.aperture=wap;
            instrument_ref.fermi_chopper=wchop;
            sample_ref=IX_sample('PCSMO',true,[1,1,0],[0,0,1],'cuboid',[0.04,0.05,0.02],1.6,300);
            
            instrument=repmat(instrument_ref,1,this.nfiles_max);
            for i=1:numel(instrument)
                instrument(i).IX_fermi_chopper.frequency=100*i;
            end
            this.instrum = instrument;
            this.sample  = sample_ref;
            
            sample_1=sample_ref;
            sample_2=sample_ref;
            sample_2.temperature=350;
            
            
            %% =====================================================================================================================
            % Make spe files
            % =====================================================================================================================
            % for the purposes of consistency, test files have to be always
            % generated by single thread, as multithreading causes pixels
            % permutation within a bin, and then random function adds
            % various amout of noise to various detectors according to the
            % ordering
            hc = hor_config();
            um = hc.use_mex;
            hc.use_mex = false;
            
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            for i=1:this.nfiles_max
                if ~exist(this.spe_file{i},'file')
                    simulate_spe_testfunc (en{i}, this.par_file,this.spe_file{i}, @sqw_sc_hfm_testfunc, this.pars, this.scale,...
                        efix(i), emode, alatt, angdeg, u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i));
                end
            end
            hc.use_mex = um;
            
            this=add_to_files_cleanList(this,this.spe_file{:});
        end
        %
        function this=test_gen_sqw(this)
            %-------------------------------------------------------------
            [skip,sess_state,comb_state]=this.setup_multi_mode();
            if skip
                return
            end
            co = onCleanup(@()set(hor_config,'accum_in_separate_process',sess_state,'use_mex_for_combine',comb_state));
            %-------------------------------------------------------------
            %hc = hor_config; hc.use_mex_for_combine=false;
            %hc.accum_in_separate_process=false; hc.threads = 8;
            
            
            % build test files if they have not been build
            this=build_test_files(this);
            % generate the names of the output sqw files
            
            sqw_file=cell(1,this.nfiles_max);
            for i=1:this.nfiles_max
                sqw_file{i}=fullfile(tempdir,['test_gen_sqw_multisession',num2str(i),'.sqw']);    % output sqw file
            end
            
            sqw_file_123456=fullfile(tempdir,'sqw_123456_multisession.sqw');             % output sqw file
            sqw_file_145623=fullfile(tempdir,'sqw_145623_multisession.sqw');            % output sqw file
            if ~this.want_to_save_output
                cleanup_obj1=onCleanup(@()rm_files(this,sqw_file_123456,sqw_file_145623,sqw_file{:}));
            end
            %% ---------------------------------------
            % Test gen_sqw ---------------------------------------
            
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            %hc.threads = 1;
               
            
            [dummy,grid,urange1]=gen_sqw (this.spe_file, '', sqw_file_123456, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            %hc.accum_in_separate_process=0;
            [dummy,grid,urange2]=gen_sqw (this.spe_file([1,4,5,6,2,3]), '', sqw_file_145623, efix([1,4,5,6,2,3]), emode, alatt, angdeg, u, v, psi([1,4,5,6,2,3]), omega([1,4,5,6,2,3]), dpsi([1,4,5,6,2,3]), gl([1,4,5,6,2,3]), gs([1,4,5,6,2,3]));
            
            assertElementsAlmostEqual(urange1,urange2,'relative',1.e-6);
            
            % Make some cuts: ---------------
            this.proj.u=[1,0,0.1]; this.proj.v=[0,0,1];
            
                      
            
            % Check cuts from gen_sqw output with spe files in a different
            % order are the same
            [ok,mess,dummy_w1,w1b]=is_cut_equal(sqw_file_123456,sqw_file_145623,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output with spe files in a different order are not the same: ',mess]);
            
            w1a=cut_sqw(sqw_file_123456,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);            
            % Test against saved or store to save later
            this=test_or_save_variables(this,w1a,w1b,'convert_old_classes',true);
            
            
        end
        %
        function this=test_wrong_params_gen_sqw(this)
            %-------------------------------------------------------------
            [skip,sess_state,comb_state]=this.setup_multi_mode();
            if skip
                return
            end
            co = onCleanup(@()set(hor_config,'accum_in_separate_process',sess_state,'use_mex_for_combine',comb_state));
            %-------------------------------------------------------------
            
            sqw_file_15456=fullfile(tempdir,'sqw_123456_multisession.sqw');  % output sqw file which should never be created
            
            this=build_test_files(this);
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            try
                gen_sqw (this.spe_file([1,5,4,5,6]), '', sqw_file_15456, efix([1,5,4,5,6]), emode, alatt, angdeg, u, v, psi([1,5,4,5,6]), omega([1,5,4,5,6]), dpsi([1,5,4,5,6]), gl([1,5,4,5,6]), gs([1,5,4,5,6]), 'replicate');
                ok=false;
            catch
                ok=true;
            end
            [fpath,fname]=fileparts(this.spe_file{5});
            delete(fullfile(fpath,[fname,'_2.tmp']));
            assertTrue(ok,'Should have failed because of repeated spe file name and parameters');
        end
        %
        function this=test_accumulate_sqw14(this)
            %-------------------------------------------------------------
            [skip,sess_state,comb_state]=this.setup_multi_mode();
            if skip
                return
            end
            co = onCleanup(@()set(hor_config,'accum_in_separate_process',sess_state,'use_mex_for_combine',comb_state));
            %-------------------------------------------------------------
            
            
            
            % build test files if they have not been build
            this=build_test_files(this);
            sqw_file_accum=fullfile(tempdir,['test_sqw_accum_sqw14_multisession.sqw']);
            sqw_file_14=fullfile(tempdir,['test_sqw_14_multisession.sqw']);    % output sqw file
            
            
            if ~this.want_to_save_output
                cleanup_obj1=onCleanup(@()rm_files(this,sqw_file_14,sqw_file_accum));
            end
            % --------------------------------------- Test accumulate_sqw
            % ---------------------------------------
            
            % Create some sqw files against which to compare the output of
            % accumulate_sqw
            % ---------------------------------------------------------------------------
            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            
            [dummy,dummy,urange14]=gen_sqw (this.spe_file([1,4]), '', sqw_file_14, efix([1,4]), emode, alatt, angdeg, u, v, psi([1,4]), omega([1,4]), dpsi([1,4]), gl([1,4]), gs([1,4]));
            
            % Now use accumulate sqw ----------------------
            this.proj.u=u;
            this.proj.v=v;
            
            spe_accum={this.spe_file{1},'','',this.spe_file{4}};
            [dummy,dummy,acc_urange14]=accumulate_sqw (spe_accum, '', sqw_file_accum,efix(1:4), ...
                emode, alatt, angdeg, u, v, psi(1:4), omega(1:4), dpsi(1:4), gl(1:4), gs(1:4),'clean');
            
            
            if not(this.want_to_save_output)
                assertElementsAlmostEqual(urange14,acc_urange14,'relative',1.e-2)
            end
            
            [ok,mess,w2_14]=is_cut_equal(sqw_file_14,sqw_file_accum,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same',mess]);
            
            % Test against saved or store to save later
            this=test_or_save_variables(this,w2_14,'convert_old_classes',true);
            
            
        end
        %
        function this=test_accumulate_and_combine1to4(this)
            %-------------------------------------------------------------
            [skip,sess_state,comb_state]=this.setup_multi_mode();
            hc = hor_config();
            co1 = onCleanup(@()set(hor_config,'accum_in_separate_process',sess_state,'use_mex_for_combine',comb_state));
            hc.use_mex_for_combine = true;
            hc.accum_in_separate_process = false;
            % only if use_mex_for_combine is true, this test verifies
            % correct workflow.
            use_mex_for_combine = hc.use_mex_for_combine;
            if skip || ~use_mex_for_combine
                return
            end
            
            %-------------------------------------------------------------
            
            % build test files if they have not been build
            this=build_test_files(this);
            sqw_file_accum=fullfile(tempdir,'test_accumulate_and_combine14.sqw'); % output sqw file
            
            if ~this.want_to_save_output
                co2=onCleanup(@()rm_files(this,sqw_file_accum));
            end
            
            spe_names = this.spe_file([1,4,5,6]);
            for i=1:numel(spe_names)
                [fp,fn,~] = fileparts(spe_names{i});
                if exist(fullfile(fp,[fn,'.tmp']),'file') == 2
                    delete(fullfile(fp,[fn,'.tmp']));
                end
            end
            
            new_names = test_gen_sqw_accumulate_sqw_sep_session.rename_file_list(spe_names(3:4),'.tnxs');
            co3 = onCleanup(@()test_gen_sqw_accumulate_sqw_sep_session.rename_file_list(new_names,'.nxspe'));
            
            % --------------------------------------- Test accumulate_sqw
            % ---------------------------------------
            
            % Create some sqw files against which to compare the output of
            % accumulate_sqw
            % ---------------------------------------------------------------------------
            [~,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this,[1,4,5,6]);
            
            % Now use accumulate sqw ----------------------
            [~,~,urange]=accumulate_sqw(spe_names, '', sqw_file_accum, ...
                efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            
            test_gen_sqw_accumulate_sqw_sep_session.rename_file_list(new_names{1},'.nxspe');
            
            [~,~,urange_all]=accumulate_sqw(spe_names, '', sqw_file_accum, ...
                efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            
            assertElementsAlmostEqual(urange,urange_all,'relative',1.e-4)
            
            test_gen_sqw_accumulate_sqw_sep_session.rename_file_list(new_names{2},'.nxspe');
            [~,~,urange_all]=accumulate_sqw(spe_names, '', sqw_file_accum, ...
                efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            assertElementsAlmostEqual(urange,urange_all,'relative',1.e-4)
            
            %----------------------------
            this.proj.u=u;
            this.proj.v=v;
            w2_1456=cut_sqw(sqw_file_accum,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            
            % Test against saved or store to save later
            this=test_or_save_variables(this,w2_1456,'convert_old_classes',true);
            
        end
        
        function this=test_accumulate_sqw1456(this)
            %-------------------------------------------------------------
            [skip,sess_state,comb_state]=this.setup_multi_mode();
            if skip
                return
            end
            co = onCleanup(@()set(hor_config,'accum_in_separate_process',sess_state,'use_mex_for_combine',comb_state));
            %-------------------------------------------------------------
            
            
            % build test files if they have not been build
            this=build_test_files(this);
            sqw_file_accum=fullfile(tempdir,'test_sqw_accum_sqw1456_multisession.sqw');
            sqw_file_1456=fullfile(tempdir,'test_sqw_1456_multisession.sqw');                   % output sqw file
            
            if ~this.want_to_save_output
                cleanup_obj1=onCleanup(@()rm_files(this,sqw_file_1456,sqw_file_accum));
            end
            % --------------------------------------- Test accumulate_sqw
            % ---------------------------------------
            
            % Create some sqw files against which to compare the output of
            % accumulate_sqw
            % ---------------------------------------------------------------------------
            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            
            [dummy,dummy,urange1456]=gen_sqw (this.spe_file([1,4,5,6]), '',sqw_file_1456, efix([1,4,5,6]), emode, alatt, angdeg, u, v,...
                psi([1,4,5,6]), omega([1,4,5,6]), dpsi([1,4,5,6]), gl([1,4,5,6]), gs([1,4,5,6]));
            
            
            % Now use accumulate sqw ----------------------
            this.proj.u=u;
            this.proj.v=v;
            
            spe_accum={this.spe_file{1},'','',this.spe_file{4},this.spe_file{5},this.spe_file{6}};
            [dummy,dummy,acc_urange1456]=accumulate_sqw (spe_accum, '', sqw_file_accum,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            
            % This is actually bad as urange is not really close
            if ~this.want_to_save_output
                assertElementsAlmostEqual(urange1456,acc_urange1456,'relative',4.e-2);
            end
            [ok,mess,w2_1456]=is_cut_equal(sqw_file_1456,sqw_file_accum,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same: ',mess])
            
            % Test against saved or store to save later
            this=test_or_save_variables(this,w2_1456,'convert_old_classes',true);
            
        end
        %
        function this=test_accumulate_sqw11456(this)
            %-------------------------------------------------------------
            [skip,sess_state,comb_state]=this.setup_multi_mode();
            if skip
                return
            end
            co = onCleanup(@()set(hor_config,'accum_in_separate_process',sess_state,'use_mex_for_combine',comb_state));
            %-------------------------------------------------------------
            
            
            % build test files if they have not been build
            this=build_test_files(this);
            sqw_file_accum=fullfile(tempdir,'test_sqw_acc_sqw11456_multisession.sqw');
            sqw_file_11456=fullfile(tempdir,'test_sqw_11456_multisession.sqw');                   % output sqw file
            
            
            if ~this.want_to_save_output
                cleanup_obj1=onCleanup(@()rm_files(this,sqw_file_11456,sqw_file_accum));
            end
            % --------------------------------------- Test accumulate_sqw
            % ---------------------------------------
            
            % Create some sqw files against which to compare the output of
            % accumulate_sqw
            % ---------------------------------------------------------------------------
            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            
            
            [dummy,dummy,urange]=gen_sqw (this.spe_file([1,1,4,5,6]), '', sqw_file_11456, efix([1,3,4,5,6]), ...
                emode, alatt, angdeg, u, v, psi([1,3,4,5,6]), omega([1,3,4,5,6]), dpsi([1,3,4,5,6]), gl([1,3,4,5,6]), gs([1,3,4,5,6]), 'replicate');
            
            
            % Now use accumulate sqw ----------------------
            this.proj.u=u;
            this.proj.v=v;
            
            % Repeat a file with 'replicate'
            spe_accum={this.spe_file{1},'',this.spe_file{1},this.spe_file{4},this.spe_file{5},this.spe_file{6}};
            accumulate_sqw (spe_accum, '', sqw_file_accum,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 'replicate');
            [ok,mess,w2_11456]=is_cut_equal(sqw_file_11456,sqw_file_accum,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same',mess]);
            % Test against saved or store to save later
            this=test_or_save_variables(this,w2_11456,'convert_old_classes',true);
            
            
            if this.want_to_save_output
                return;
            end
            
            % Accumulate nothing:
            spe_accum={this.spe_file{1},'',this.spe_file{1},this.spe_file{4},this.spe_file{5},this.spe_file{6}};
            accumulate_sqw (spe_accum, '', sqw_file_accum, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 'replicate');
            [ok,mess]=is_cut_equal(sqw_file_11456,sqw_file_accum,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same: ',mess]);
        end
        %
        function test_worker(this)
            mis = MPI_State.instance();
            mis.is_tested = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));
            
            
            this= build_test_files(this);
            
            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            ds.efix=efix(1);
            ds.emode =emode;
            ds.psi=psi(1);
            ds.omega=omega(1);
            ds.dpsi = dpsi(1);
            ds.gl = gl(1);
            ds.gs = gs(1);
            ds.alatt=alatt;
            ds.angdeg=angdeg;
            ds.u = u;
            ds.v = v;
            
            job_par_fun = @(run,fname,instr,samp)(gen_sqw_files_job.pack_job_pars(...
                run,fname,instr,samp,...
                [50,50,50,50],[-1.5,-2.1,-0.5,0;0,0,0.5,35]));
            
            %
            [path,file] = fileparts(this.spe_file{1});
            tmp_file1 = fullfile(path,[file,'.tmp']);
            run1=rundatah(this.spe_file{1},ds);
            
            
            %
            [path,file] = fileparts(this.spe_file{2});
            tmp_file2 = fullfile(path,[file,'.tmp']);
            ds.psi=psi(1);
            run2=rundatah(this.spe_file{1},ds);
            runs = {run1;run2};
            tmpf = {tmp_file1,tmp_file2};
            samp = [this.sample,this.sample];
            
            intst = this.instrum(1:2);
            job_param_list = cellfun(job_par_fun,...
                runs',tmpf,num2cell(intst),num2cell(samp),...
                'UniformOutput', true);
            
            
            jd = JobDispatcher('test_gen_sqw_sep_ses_worker');
            [~,~,wc]=jd.split_and_register_jobs(job_param_list,1);
            
            worker('gen_sqw_files_job',wc{1});
            
            assertTrue(exist(tmp_file1,'file')==2);
            assertTrue(exist(tmp_file2,'file')==2);
            delete(tmp_file1);
            delete(tmp_file2);
            [ok,err,mes] = jd.receive_message(1,'completed');
            assertTrue(ok);
            assertTrue(isempty(err));
            res = mes.payload;
            assertEqual(res.grid_size,[50 50 50 50]);
            assertElementsAlmostEqual(res.urange,...
                [-1.5000 -2.1000 -0.5000 0;0 0 0.5000 35.0000]);
            %
            jd.clear_all_messages();
        end
        
        function test_do_job(this)
            %
            
            this= build_test_files(this);
            
            
            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            ds.efix=efix(1);
            ds.emode =emode;
            ds.psi=psi(1);
            ds.omega=omega(1);
            ds.dpsi = dpsi(1);
            ds.gl = gl(1);
            ds.gs = gs(1);
            ds.alatt=alatt;
            ds.angdeg=angdeg;
            ds.u = u;
            ds.v = v;
            [path,file] = fileparts(this.spe_file{1});
            tmp_file = fullfile(path,[file,'.tmp']);
            
            run=rundatah(this.spe_file{1},ds);
            
            
            job_par_fun = @(run,fname,instr,samp)(gen_sqw_files_job.pack_job_pars(...
                run,fname,instr,samp,...
                [50,50,50,50],[-1.5,-2.1,-0.5,0;0,0,0.5,35]));
            
            job_param = job_par_fun(run,tmp_file,this.instrum(1),this.sample);
            
            je = gen_sqw_files_job('test_gen_sqw_sep_ses_do_job');
            clob = onCleanup(@()(je.clear_all_messages()));
            je.do_job(job_param);
            
            assertTrue(exist(tmp_file,'file')==2);
            delete(tmp_file);
            
        end
        
        
    end
end
