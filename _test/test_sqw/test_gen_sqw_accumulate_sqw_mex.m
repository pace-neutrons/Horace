classdef test_gen_sqw_accumulate_sqw_mex < TestCaseWithSave
    % Series of tests of gen_sqw and associated functions
    % Optionally writes results to output file
    %
    %   >> runtests test_gen_sqw_accumulate_sqw    % Compares with previously saved results in test_gen_sqw_accumulate_sqw_output.mat
    %                                              % in the same folder as this function
    %
    %   >>tc=test_gen_sqw_accumulate_sqw ('save')  % Store sample
    %   >>tc.save()                                % results into tmp folder
    %
    % Reads previously created test data sets.
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
        
        % overloaded properties
        mex_mode = true;
        prefix = 'mex'
        skip_tests=false;
    end
    
    methods
        function this=test_gen_sqw_accumulate_sqw_mex(varargin)
            % Series of tests of gen_sqw and associated functions
            % Optionally writes results to output file
            %
            %   >> test_gen_sqw_accumulate_sqw          % Compares with previously saved results in test_gen_sqw_accumulate_sqw_output.mat
            %                                           % in the same folder as this function
            %   >>tc=test_gen_sqw_accumulate_sqw ('save')
            %  >>tc.save()                              % Save to test_multifit_horace_1_output.mat
            %
            % Reads previously created test data sets.
            
            % onstructocr
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            if nargin > 1
                pref = varargin{2};
            else
                pref = 'mex';
            end           
            this = this@TestCaseWithSave(name,fullfile(fileparts(mfilename('fullpath')),'test_gen_sqw_accumulate_sqw_output.mat'));
            
            %if ispc
            %    this.tol= 1.e-6;
            %else
            %    this.tol = 1.e-3;
            %end
            
            
            % do overloading mex/nomex
            this.prefix = pref;
            if strcmp(pref,'mex')
                this.mex_mode = true;
                [mess,n_errors]=check_horace_mex();
                if n_errors>0
                    this.skip_tests=true;
                    warnings('TEST_GEN_SQW_ACC_SQW:mex_mode',' mex mode disabled as mex code does not work, Err: %s',mess);
                else
                    this.skip_tests=false;
                end
                
            else
                this.mex_mode = false;
                this.skip_tests=false;
            end
            this.errmessage_prefix = ['Test with ',pref];
            
            
            % do other initialization
            this.comparison_par={ 'min_denominator', 0.01, 'ignore_str', 1};
            this.tol = 1.e-5;
            this.test_functions_path=fullfile(fileparts(which('horace_init.m')),'_test/common_functions');
            
            addpath(this.test_functions_path);
            
            % build test file names
            this.spe_file=cell(1,this.nfiles_max);
            for i=1:this.nfiles_max
                this.spe_file{i}=fullfile(tempdir,['gen_sqw_acc_sqw_spe_',pref,num2str(i),'.nxspe']);
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
        function [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this,varargin)
            en =this.gen_sqw_par{1};
            efix=this.gen_sqw_par{2};
            emode=this.gen_sqw_par{3};
            alatt=this.gen_sqw_par{4};
            angdeg=this.gen_sqw_par{5};
            u=this.gen_sqw_par{6};
            v=this.gen_sqw_par{7};
            psi=this.gen_sqw_par{8};
            omega=this.gen_sqw_par{9};
            dpsi=this.gen_sqw_par{10};
            gl=this.gen_sqw_par{11};
            gs=this.gen_sqw_par{12};
            if nargin>1
                np = varargin{1};
                en = en(1:np);
                efix = efix(1:np);
                psi = psi(1:np);
                omega = omega(1:np);
                dpsi = dpsi(1:np);
                gl = gl(1:np);
                gs = gs(1:np);
            end
        end
        %
        function [skip,cur_mex,pref,acsp,umc]=setup_mex_mode(this,varargin)
            hc = hor_config;
            pref = this.prefix;
            skip = false;
            if this.skip_tests
                skip = true;
                cur_mex = false;
                return
            else
                cur_mex = hc.use_mex;
                hc.saveable=false;
                if nargin>1
                    hc.use_mex = varargin{1};
                else
                    hc.use_mex=this.mex_mode;
                end
            end
            acsp=hc.accum_in_separate_process;
            umc= hc.use_mex_for_combine;
        end
        function this=build_test_files(this,varargin)
            %-------------------------------------------------------------
            [skip,cur_mex,pref,acsp,umc]=this.setup_mex_mode(varargin{:});
            if skip
                return
            end
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',cur_mex,'accum_in_separate_process',acsp,'use_mex_for_combine',umc));
            if nargin>1
                spe_files = varargin{2};
            else
                spe_files = this.spe_file;
            end
            %-------------------------------------------------------------
            
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
            
            sample_1=sample_ref;
            sample_2=sample_ref;
            sample_2.temperature=350;
            
            
            %% =====================================================================================================================
            % Make spe files
            % =====================================================================================================================
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            for i=1:numel(spe_files)
                if ~exist(spe_files{i},'file')
                    simulate_spe_testfunc (en{i}, this.par_file,spe_files{i}, @sqw_sc_hfm_testfunc, this.pars, this.scale,...
                        efix(i), emode, alatt, angdeg, u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i));
                end
            end
            this=add_to_files_cleanList(this,spe_files{:});
        end
        function this=test_gen_sqw(this)
            %-------------------------------------------------------------
            [skip,cur_mex,pref,acsp,umc]=this.setup_mex_mode();
            if skip
                return
            end
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',cur_mex,'accum_in_separate_process',acsp,'use_mex_for_combine',umc));
            set(hor_config,'accum_in_separate_process',false,'use_mex_for_combine',false);
            %-------------------------------------------------------------
            
            
            % build test files if they have not been build
            this=build_test_files(this);
            % generate the names of the output sqw files
            sqw_file=cell(1,this.nfiles_max);
            for i=1:this.nfiles_max
                sqw_file{i}=fullfile(tempdir,['test_gen_sqw_',pref,num2str(i),'.sqw']);    % output sqw file
            end
            
            sqw_file_123456=fullfile(tempdir,['sqw_123456',pref,'.sqw']);             % output sqw file
            sqw_file_145623=fullfile(tempdir,['sqw_145623',pref,'.sqw']);            % output sqw file
            if ~this.want_to_save_output
                cleanup_obj1=onCleanup(@()rm_files(this,sqw_file_123456,sqw_file_145623,sqw_file{:}));
            end
            %% ---------------------------------------
            % Test gen_sqw
            % ---------------------------------------
            
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            for i=1:this.nfiles_max
                gen_sqw (this.spe_file(i), '', sqw_file{i}, efix(i), emode, alatt, angdeg, u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i),[3,3,3,3]);
            end
            
            
            [dummy,grid,urange1]=gen_sqw (this.spe_file, '', sqw_file_123456, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            
            [dummy,grid,urange2]=gen_sqw (this.spe_file([1,4,5,6,2,3]), '', sqw_file_145623, efix([1,4,5,6,2,3]), emode, alatt, angdeg, u, v, psi([1,4,5,6,2,3]), omega([1,4,5,6,2,3]), dpsi([1,4,5,6,2,3]), gl([1,4,5,6,2,3]), gs([1,4,5,6,2,3]));
            
            assertElementsAlmostEqual(urange1,urange2,'relative',1.e-6);
            
            % Make some cuts:
            % ---------------
            this.proj.u=[1,0,0.1]; this.proj.v=[0,0,1];
            
            % Check cuts from each sqw individually, and the single combined sqw file are the same
            [ok,mess,w1a,w1ref]=is_cut_equal(sqw_file_123456,sqw_file,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Combining cuts from each individual sqw file and the cut from the combined sqw file not the same ',mess]);
            % Test against saved or store to save later
            this=test_or_save_variables(this,w1ref,w1a,'convert_old_classes');
            
            
            % Check cuts from gen_sqw output with spe files in a different order are the same
            [ok,mess,dummy_w1,w1b]=is_cut_equal(sqw_file_123456,sqw_file_145623,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,'Cuts from gen_sqw output with spe files in a different order are not the same');
            % Test against saved or store to save later
            this=test_or_save_variables(this,w1ref,w1b,'convert_old_classes');
            
            
        end
        function this=test_wrong_params_gen_sqw(this)
            %-------------------------------------------------------------
            [skip,cur_mex,pref,acsp,umc]=this.setup_mex_mode();
            if skip
                return
            end
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',cur_mex,'accum_in_separate_process',acsp,'use_mex_for_combine',umc));
            set(hor_config,'accum_in_separate_process',false,'use_mex_for_combine',false);
            %-------------------------------------------------------------
            
            sqw_file_15456=fullfile(tempdir,['sqw_123456',pref,'.sqw']);  % output sqw file which should never be created
            
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
        function this=test_wrong_params_accum_sqw(this)
            %-------------------------------------------------------------
            [skip,cur_mex,pref]=this.setup_mex_mode();
            if skip
                return
            end
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',cur_mex));
            %-------------------------------------------------------------
            sqw_file_accum=fullfile(tempdir,['sqw_accum',pref,'.sqw']);  % output sqw file which should never be created
            
            
            this=build_test_files(this);
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            
            % Repeat a file
            spe_accum={this.spe_file{1},'',this.spe_file{5},this.spe_file{4},this.spe_file{5},this.spe_file{6}};
            try
                accumulate_sqw (spe_accum, '', sqw_file_accum,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
                ok=false;
            catch
                ok=true;
            end
            assertTrue(ok,'Should have failed because of repeated spe file name');
            
        end
        
        function this=test_accumulate_sqw14(this)
            %-------------------------------------------------------------
            [skip,cur_mex,pref,acsp,umc]=this.setup_mex_mode();
            if skip
                return
            end
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',cur_mex,'accum_in_separate_process',acsp,'use_mex_for_combine',umc));
            set(hor_config,'accum_in_separate_process',false,'use_mex_for_combine',false);
            %-------------------------------------------------------------
            
            
            
            % build test files if they have not been build
            this=build_test_files(this);
            sqw_file_accum=fullfile(tempdir,['test_sqw_accum_sqw14',pref,'.sqw']);
            sqw_file_14=fullfile(tempdir,['test_sqw_14',pref,'.sqw']);    % output sqw file
            
            
            if ~this.want_to_save_output
                cleanup_obj1=onCleanup(@()rm_files(this,sqw_file_14,sqw_file_accum));
            end
            % ---------------------------------------
            % Test accumulate_sqw
            % ---------------------------------------
            
            % Create some sqw files against which to compare the output of accumulate_sqw
            % ---------------------------------------------------------------------------
            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            
            [dummy,dummy,urange14]=gen_sqw (this.spe_file([1,4]), '', sqw_file_14, efix([1,4]), emode, alatt, angdeg, u, v, psi([1,4]), omega([1,4]), dpsi([1,4]), gl([1,4]), gs([1,4]));
            
            % Now use accumulate sqw
            % ----------------------
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
            this=test_or_save_variables(this,w2_14,'convert_old_classes');
            
            
        end
        
        function this=test_accumulate_sqw1456(this)
            %-------------------------------------------------------------
            [skip,cur_mex,pref,acsp,umc]=this.setup_mex_mode();
            if skip
                return
            end
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',cur_mex,'accum_in_separate_process',acsp,'use_mex_for_combine',umc));
            set(hor_config,'accum_in_separate_process',false,'use_mex_for_combine',false);
            %-------------------------------------------------------------
            
            
            % build test files if they have not been build
            this=build_test_files(this);
            sqw_file_accum=fullfile(tempdir,['test_sqw_accum_sqw1456',pref,'.sqw']);
            sqw_file_1456=fullfile(tempdir,['test_sqw_1456',pref,'.sqw']);                   % output sqw file
            
            if ~this.want_to_save_output
                cleanup_obj1=onCleanup(@()rm_files(this,sqw_file_1456,sqw_file_accum));
            end
            % ---------------------------------------
            % Test accumulate_sqw
            % ---------------------------------------
            
            % Create some sqw files against which to compare the output of accumulate_sqw
            % ---------------------------------------------------------------------------
            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            
            [dummy,dummy,urange1456]=gen_sqw (this.spe_file([1,4,5,6]), '',sqw_file_1456, efix([1,4,5,6]), emode, alatt, angdeg, u, v,...
                psi([1,4,5,6]), omega([1,4,5,6]), dpsi([1,4,5,6]), gl([1,4,5,6]), gs([1,4,5,6]));
            
            
            % Now use accumulate sqw
            % ----------------------
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
            this=test_or_save_variables(this,w2_1456,'convert_old_classes');
            
        end
        function this=test_accumulate_sqw11456(this)
            %-------------------------------------------------------------
            [skip,cur_mex,pref,acsp,umc]=this.setup_mex_mode();
            if skip
                return
            end
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',cur_mex,'accum_in_separate_process',acsp,'use_mex_for_combine',umc));
            set(hor_config,'accum_in_separate_process',false,'use_mex_for_combine',false);
            %-------------------------------------------------------------
            
            
            % build test files if they have not been build
            this=build_test_files(this);
            sqw_file_accum=fullfile(tempdir,['test_sqw_acc_sqw11456',pref,'.sqw']);
            sqw_file_11456=fullfile(tempdir,['test_sqw_11456',pref,'.sqw']);                   % output sqw file
            
            
            if ~this.want_to_save_output
                cleanup_obj1=onCleanup(@()rm_files(this,sqw_file_11456,sqw_file_accum));
            end
            % ---------------------------------------
            % Test accumulate_sqw
            % ---------------------------------------
            
            % Create some sqw files against which to compare the output of accumulate_sqw
            % ---------------------------------------------------------------------------
            [dummy,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            
            
            [dummy,dummy,urange]=gen_sqw (this.spe_file([1,1,4,5,6]), '', sqw_file_11456, efix([1,3,4,5,6]), ...
                emode, alatt, angdeg, u, v, psi([1,3,4,5,6]), omega([1,3,4,5,6]), dpsi([1,3,4,5,6]), gl([1,3,4,5,6]), gs([1,3,4,5,6]), 'replicate');
            
            
            % Now use accumulate sqw
            % ----------------------
            this.proj.u=u;
            this.proj.v=v;
            
            % Repeat a file with 'replicate'
            spe_accum={this.spe_file{1},'',this.spe_file{1},this.spe_file{4},this.spe_file{5},this.spe_file{6}};
            accumulate_sqw (spe_accum, '', sqw_file_accum,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 'replicate');
            [ok,mess,w2_11456]=is_cut_equal(sqw_file_11456,sqw_file_accum,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same',mess]);
            % Test against saved or store to save later
            this=test_or_save_variables(this,w2_11456,'convert_old_classes');
            
            
            if this.want_to_save_output
                return;
            end
            
            % Accumulate nothing:
            spe_accum={this.spe_file{1},'',this.spe_file{1},this.spe_file{4},this.spe_file{5},this.spe_file{6}};
            accumulate_sqw (spe_accum, '', sqw_file_accum, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 'replicate');
            [ok,mess]=is_cut_equal(sqw_file_11456,sqw_file_accum,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same: ',mess]);
        end
        
        
    end
end
