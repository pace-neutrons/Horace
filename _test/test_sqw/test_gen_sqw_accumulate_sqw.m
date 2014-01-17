classdef test_gen_sqw_accumulate_sqw < TestCaseWithSave
    % Series of tests of gen_sqw and associated functions
    % Optionally writes results to output file
    %
    %   >>runtests test_gen_sqw_accumulate_sqw          % Compares with previously saved results in test_gen_sqw_accumulate_sqw_output.mat
    %                                           % in the same folder as this function
    %                                        % in the same folder as this function
    %   >>save(test_multifit_horace_1())    % Save to test_multifit_horace_1_output.mat
    %
    %   >>test_name(test_multifit_horace_1()) % run particular test from this
    
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
        sqw_file_14;
        sqw_file_123456;
        sqw_file_145623;
        sqw_file_1456;
        sqw_file_11456;
        sqw_file_15456;
        
    end
    
    methods
        function this=test_gen_sqw_accumulate_sqw (varargin)
            % Series of tests of gen_sqw and associated functions
            % Optionally writes results to output file
            %
            %   >> test_gen_sqw_accumulate_sqw          % Compares with previously saved results in test_gen_sqw_accumulate_sqw_output.mat
            %                                           % in the same folder as this function
            %   >> test_gen_sqw_accumulate_sqw ('save') % Save to test_multifit_horace_1_output.mat
            %
            % Reads previously created test data sets.
            
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this = this@TestCaseWithSave(name,fullfile(fileparts(mfilename('fullpath')),'test_gen_sqw_accumulate_sqw_output.mat'));
            
            
            this.comparison_par={ 'min_denominator', 0.01, 'ignore_str', 1};
            this.tol = 1.e-5;
            this.test_functions_path=fullfile(fileparts(which('horace_init.m')),'_test/common_functions');
            
            addpath(this.test_functions_path);
            
            
            % build test file names
            this.spe_file=cell(1,this.nfiles_max);
            for i=1:this.nfiles_max
                this.spe_file{i}=[tempdir,'gen_sqw_acc_sqw_spe_',num2str(i),'.spe'];
            end
            
            this.par_file=fullfile(this.results_path,'96dets.par');
            this.sqw_file_123456=fullfile(tempdir,'sqw_123456.sqw');                   % output sqw file
            this.sqw_file_145623=fullfile(tempdir,'sqw_145623.sqw');                   % output sqw file
            
            this.sqw_file_14=fullfile(tempdir,'sqw_14.sqw');                   % output sqw file
            this.sqw_file_11456=fullfile(tempdir,'sqw_11456.sqw');                   % output sqw file
            this.sqw_file_1456=fullfile(tempdir,'sqw_1456.sqw');                   % output sqw file
            this.sqw_file_15456=fullfile(tempdir,'sqw_15456.sqw');                   % output sqw file
            
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
        function [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this)
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
        end
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
            
            sample_1=sample_ref;
            sample_2=sample_ref;
            sample_2.temperature=350;
            
            
            %% =====================================================================================================================
            % Make spe files
            % =====================================================================================================================
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            for i=1:this.nfiles_max
                if ~exist(this.spe_file{i},'file')
                    simulate_spe_testfunc (en{i}, this.par_file,this.spe_file{i}, @sqw_sc_hfm_testfunc, this.pars, this.scale,...
                        efix(i), emode, alatt, angdeg, u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i));
                end
            end
            this=add_to_files_cleanList(this,this.spe_file{:});
            
        end
        function this=test_gen_sqw(this)
            
            % build test files if they have not been build
            this=build_test_files(this);
            % generate the names of the output sqw files
            sqw_file=cell(1,this.nfiles_max);
            for i=1:this.nfiles_max
                sqw_file{i}=fullfile(tempdir,['gen_sqw_acc_sqw_sqw_',num2str(i),'.sqw']);    % output sqw file
            end
            if ~this.want_to_save_output
                cleanup_obj=onCleanup(@()rm_files(this,this.sqw_file_123456,this.sqw_file_145623,sqw_file{:}));
            end
            %% ---------------------------------------
            % Test gen_sqw
            % ---------------------------------------
            
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            for i=1:this.nfiles_max
                gen_sqw (this.spe_file(i), this.par_file, sqw_file{i}, efix(i), emode, alatt, angdeg, u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i),[3,3,3,3]);
            end
            
            
            [dummy,grid,urange]=gen_sqw (this.spe_file, this.par_file, this.sqw_file_123456, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            
            
            [dummy,grid,urange]=gen_sqw (this.spe_file([1,4,5,6,2,3]), this.par_file, this.sqw_file_145623, efix([1,4,5,6,2,3]), emode, alatt, angdeg, u, v, psi([1,4,5,6,2,3]), omega([1,4,5,6,2,3]), dpsi([1,4,5,6,2,3]), gl([1,4,5,6,2,3]), gs([1,4,5,6,2,3]));
            
            
            % Make some cuts:
            % ---------------
            this.proj.u=[1,0,0.1]; this.proj.v=[0,0,1];
            
            % Check cuts from each sqw individually, and the single combined sqw file are the same
            [ok,mess,w1a,w1ref]=is_cut_equal(this.sqw_file_123456,sqw_file,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,['Combining cuts from each individual sqw file and the cut from the combined sqw file not the same ',mess]);
            % Test against saved or store to save later
            this=test_or_save_variables(this,w1ref,w1a);
            
            
            % Check cuts from gen_sqw output with spe files in a different order are the same
            [ok,mess,dummy_w1,w1b]=is_cut_equal(this.sqw_file_123456,this.sqw_file_145623,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,'Cuts from gen_sqw output with spe files in a different order are not the same');
            % Test against saved or store to save later
            this=test_or_save_variables(this,w1ref,w1b);
            
            
        end
        function this=test_wrong_params_gen_sqw(this)
            
            this=build_test_files(this);
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            try
                gen_sqw (this.spe_file([1,5,4,5,6]), this.par_file, this.sqw_file_15456, efix([1,5,4,5,6]), emode, alatt, angdeg, u, v, psi([1,5,4,5,6]), omega([1,5,4,5,6]), dpsi([1,5,4,5,6]), gl([1,5,4,5,6]), gs([1,5,4,5,6]), 'replicate');
                ok=false;
            catch
                ok=true;
            end
            assertTrue(ok,'Should have failed because of repeated spe file name and parameters');
        end
        function this=test_wrong_params_accum_sqw(this)
            
            this=build_test_files(this);
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            
            % Repeat a file
            spe_accum={this.spe_file{1},'',this.spe_file{5},this.spe_file{4},this.spe_file{5},this.spe_file{6}};
            try
                accumulate_sqw (spe_accum, this.par_file, sqw_file_accum,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
                ok=false;
            catch
                ok=true;
            end
            assertTrue(ok,'Should have failed because of repeated spe file name');
            
        end
        
        function this=test_accumulate_sqw(this)
            % build test files if they have not been build
            this=build_test_files(this);
            sqw_file_accum=fullfile(tempdir,'test_accumulate_sqw_sqw_accum.sqw');
            
            if ~this.want_to_save_output
                cleanup_obj=onCleanup(@()rm_files(this,this.sqw_file_14,this.sqw_file_1456,this.sqw_file_15456,this.sqw_file_11456,sqw_file_accum));
            end
            % ---------------------------------------
            % Test accumulate_sqw
            % ---------------------------------------
            
            % Create some sqw files against which to compare the output of accumulate_sqw
            % ---------------------------------------------------------------------------
            [~,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this);
            
            [~,~,urange14]=gen_sqw (this.spe_file([1,4]), this.par_file, this.sqw_file_14, efix([1,4]), emode, alatt, angdeg, u, v, psi([1,4]), omega([1,4]), dpsi([1,4]), gl([1,4]), gs([1,4]));
            
            [~,~,urange1456]=gen_sqw (this.spe_file([1,4,5,6]), this.par_file, this.sqw_file_1456, efix([1,4,5,6]), emode, alatt, angdeg, u, v,...
                psi([1,4,5,6]), omega([1,4,5,6]), dpsi([1,4,5,6]), gl([1,4,5,6]), gs([1,4,5,6]));
            
            
            [~,~,urange]=gen_sqw (this.spe_file([1,1,4,5,6]), this.par_file, this.sqw_file_11456, efix([1,3,4,5,6]), ...
                              emode, alatt, angdeg, u, v, psi([1,3,4,5,6]), omega([1,3,4,5,6]), dpsi([1,3,4,5,6]), gl([1,3,4,5,6]), gs([1,3,4,5,6]), 'replicate');
            
            
            % Now use accumulate sqw
            % ----------------------
            
            spe_accum={this.spe_file{1},'','',this.spe_file{4}};
            [~,~,acc_urange14]=accumulate_sqw (spe_accum, this.par_file, sqw_file_accum,efix(1:4), ...
                emode, alatt, angdeg, u, v, psi(1:4), omega(1:4), dpsi(1:4), gl(1:4), gs(1:4),'clean');
            
            assertElementsAlmostEqual(urange14,acc_urange14,'relative',1.e-2)
            [ok,mess,w2_14]=is_cut_equal(this.sqw_file_14,sqw_file_accum,this.proj,[-1.5,0.025,0],[-0.5,0.5],[-2.1,-1.9],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same',mess]);
            
            spe_accum={this.spe_file{1},'','',this.spe_file{4},this.spe_file{5},this.spe_file{6}};
            [~,~,acc_urange1456]=accumulate_sqw (spe_accum, this.par_file, sqw_file_accum,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            %assertEqual(urange1456,acc_urange1456)
            
            [ok,mess,w2_1456]=is_cut_equal(this.sqw_file_1456,sqw_file_accum,this.proj,[-1.5,0.025,0],[-0.5,0.5],[-2.1,-1.9],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same: ',mess])
            
            % Test against saved or store to save later
            this=test_or_save_variables(this,w2_14,w2_1456);
            
            
            % Repeat a file with 'replicate'
            spe_accum={this.spe_file{1},'',this.spe_file{1},this.spe_file{4},this.spe_file{5},this.spe_file{6}};
            accumulate_sqw (spe_accum, this.par_file, sqw_file_accum,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 'replicate');
            [ok,mess,w2_11456]=is_cut_equal(this.sqw_file_11456,sqw_file_accum,this.proj,[-1.5,0.025,0],[-0.5,0.5],[-2.1,-1.9],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same',mess]);
            % Test against saved or store to save later
            this=test_or_save_variables(this,w2_11456);
            
            
            % Accumulate nothing:
            
            spe_accum={this.spe_file{1},'',this.spe_file{1},this.spe_file{4},this.spe_file{5},this.spe_file{6}};
            accumulate_sqw (spe_accum, this.par_file, sqw_file_accum, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 'replicate');
            [ok,mess]=is_cut_equal(this.sqw_file_11456,sqw_file_accum,this.proj,[-1.5,0.025,0],[-0.5,0.5],[-2.1,-1.9],[-Inf,Inf]);
            assertTrue(ok,['Cuts from gen_sqw output and accumulate_sqw are not the same: ',mess]);
            
            
        end
    end
end
