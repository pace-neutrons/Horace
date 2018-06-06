classdef gen_sqw_accumulate_sqw_MPI_common_test < MPI_Test_Common & TestCaseWithSave
    % Series of tests of gen_sqw and associated functions
    % generated using multiple matlab workers.
    %
    % Optionally writes results to output file to compare with previously
    % saved sample test results
    %---------------------------------------------------------------------
    % Usage:
    %
    %1) Normal usage:
    % Run all unit tests and compare their results with previously saved
    % results stored in test_gen_sqw_accumulate_sqw_output.mat file
    % located in the same folder as this function:
    %
    %>>runtests test_gen_sqw_accumulate_sqw_sep_session
    %---------------------------------------------------------------------
    %2) Run particular test case from the suite:
    %
    %>>tc = test_gen_sqw_accumulate_sqw_sep_session();
    %>>tc.test_[particular_test_name] e.g.:
    %>>tc.test_accumulate_sqw14();
    %or
    %>>tc.test_gen_sqw();
    %---------------------------------------------------------------------
    %3) Generate test file to store test results to compare with them later
    %   (it stores test results into tmp folder.)
    %
    %>>tc=test_gen_sqw_accumulate_sqw_sep_session('save');
    %>>tc.save():
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
        
        instrum
        sample
        initial_config;        
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
        function this=gen_sqw_accumulate_sqw_MPI_common_test(pool_type_name,test_class_name)
            % The constructor for class, which is the common part of all
            % MPI-based gen_sqw system tests.
            % 
            % Should be used as 
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
            
            
            this = this@MPI_Test_Common(pool_type_name);           
            this = this@TestCaseWithSave(test_class_name,fullfile(fileparts(mfilename('fullpath')),'test_gen_sqw_accumulate_sqw_output.mat'));

            this = store_initial_config(this);
            
            % do overloading mex/nomex
            hpc = hpc_config();
            hpc.accum_in_separate_process = true;
            hpc.use_mex_for_combine = true;
            
            if ~hpc.accum_in_separate_process
                warning('TEST_GEN_SQW_ACC_SQW:multisession_mode',' multi-session mode can not be enablesd');
                if ~hpc.use_mex_for_combine % nothing to do, this mode can not be enabled
                    this.ignore_test=true;
                end
            else
                this.ignore_test=false;
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
            
            results_path = fileparts(this.test_results_file);            
            %this.par_file=fullfile(this.results_path,'96dets.par');
            this.par_file=fullfile(results_path,'gen_sqw_96dets.nxspe');
            
            
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
            % build test files if they have not been build
            this=build_test_files(this);
             
        end
        %
        function this = store_initial_config(this)
                hc = hor_config;
                hpc = hpc_config;
                this.initial_config = struct('hc',hc.get_data_to_store(),'hpc',hpc.get_data_to_store());
        end
        function restore_hor_config(obj)
            hc = hor_config;
            hpc = hpc_config;
            set(hc,obj.initial_config.hc);
            set(hpc,obj.initial_config.hpc);            
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
        function skip=setup_multi_mode(this)
            if this.ignore_tests
                skip = true;
                return
            end
            hc = hpc_config();
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
            um = hc.get_data_to_store;
            clob = onCleanup(@()set(hc,um));
            hc.use_mex = false; % so use Matlab single thread to generate source sqw files
            
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            for i=1:this.nfiles_max
                if ~exist(this.spe_file{i},'file')
                    simulate_spe_testfunc (en{i}, this.par_file,this.spe_file{i}, @sqw_sc_hfm_testfunc, this.pars, this.scale,...
                        efix(i), emode, alatt, angdeg, u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i));
                end
            end
            
            this=add_to_files_cleanList(this,this.spe_file{:});
        end
        %
        function this=test_gen_sqw(this,varargin)
            %-------------------------------------------------------------
            skip=this.setup_multi_mode();
            co=onCleanup(@()this.restore_hor_config());
            if skip
                return
            end
            if nargin> 1
                % running in single test method mode.
                this.setUp();
                co1 = onCleanup(@()this.tearDown());
            end
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
            if ~this.save_output
                cleanup_obj1=onCleanup(@()this.delete_files(sqw_file_123456,sqw_file_145623,sqw_file{:}));
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
            this=save_or_test_variables(this,w1a,w1b);
            
            
        end
        %
        function this=test_accumulate_sqw14(this)
            %-------------------------------------------------------------
            skip=this.setup_multi_mode();
            co=onCleanup(@()this.restore_hor_config());
            if skip
                return
            end
            %-------------------------------------------------------------
            
            
            
            
            sqw_file_accum=fullfile(tempdir,'test_sqw_accum_sqw14_multisession.sqw');
            sqw_file_14=fullfile(tempdir,'test_sqw_14_multisession.sqw');    % output sqw file
            cleanup_obj1=onCleanup(@()this.delete_files(sqw_file_14,sqw_file_accum));
            
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
            
            
            if not(this.save_output)
                assertElementsAlmostEqual(urange14,acc_urange14,'relative',1.e-2)
            end
            
            [ok,mess,w2_14]=is_cut_equal(sqw_file_14,sqw_file_accum,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same',mess]);
            
            % Test against saved or store to save later
            this=this.save_or_test_variables(w2_14);
            
            
        end
        %
        function this=test_accumulate_and_combine1to4(this)
            %-------------------------------------------------------------
            skip=this.setup_multi_mode();
            co=onCleanup(@()this.restore_hor_config());
            if skip
                return
            end            
            %-------------------------------------------------------------
            
            % build test files if they have not been build
            this=build_test_files(this);
            sqw_file_accum=fullfile(tempdir,'test_accumulate_and_combine14.sqw'); % output sqw file
            
            if ~this.save_output
                co2=onCleanup(@()this.delete_files(sqw_file_accum));
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
            this=save_or_test_variables(this,w2_1456);
            
        end
        
        function this=test_accumulate_sqw1456(this)
            %-------------------------------------------------------------
            skip=this.setup_multi_mode();
            co=onCleanup(@()this.restore_hor_config());
            if skip
                return
            end
            %-------------------------------------------------------------
            
            
            % build test files if they have not been build
            this=build_test_files(this);
            sqw_file_accum=fullfile(tempdir,'test_sqw_accum_sqw1456_multisession.sqw');
            sqw_file_1456=fullfile(tempdir,'test_sqw_1456_multisession.sqw');                   % output sqw file
            
            if ~this.save_output
                cleanup_obj1=onCleanup(@()this.delete_files(sqw_file_1456,sqw_file_accum));
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
            if ~this.save_output
                assertElementsAlmostEqual(urange1456,acc_urange1456,'relative',4.e-2);
            end
            [ok,mess,w2_1456]=is_cut_equal(sqw_file_1456,sqw_file_accum,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same: ',mess])
            
            % Test against saved or store to save later
            this=save_or_test_variables(this,w2_1456);
            
        end
        %
        function this=test_accumulate_sqw11456(this)
            %-------------------------------------------------------------
            skip=this.setup_multi_mode();
            co=onCleanup(@()this.restore_hor_config());
            if skip
                return
            end
            %-------------------------------------------------------------
            
            
            % build test files if they have not been build
            this=build_test_files(this);
            sqw_file_accum=fullfile(tempdir,'test_sqw_acc_sqw11456_multisession.sqw');
            sqw_file_11456=fullfile(tempdir,'test_sqw_11456_multisession.sqw');                   % output sqw file
            cleanup_obj1=onCleanup(@()this.delete_files(sqw_file_11456,sqw_file_accum));
            
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
            this=save_or_test_variables(this,w2_11456);
            
            
            if this.save_output
                return;
            end
            
            % Accumulate nothing:
            spe_accum={this.spe_file{1},'',this.spe_file{1},this.spe_file{4},this.spe_file{5},this.spe_file{6}};
            accumulate_sqw (spe_accum, '', sqw_file_accum, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 'replicate');
            [ok,mess]=is_cut_equal(sqw_file_11456,sqw_file_accum,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same: ',mess]);
        end        
        %
    end
end
