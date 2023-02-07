classdef test_tobyfit_cuts < TestCaseWithSave
    % Test of basic fitting operations with Tobyfit
    
    properties
        fe_1
        fe_2
        fe_arr
        rb_arr
        mc_fe
        mc_rb
        nlist
        tolerance
        seed
        rng_state
    end
    
    methods
        function obj = test_tobyfit_cuts (name)
            % Initialise object properties and pre-load test cuts for faster tests
            
            % Note: in the (hopefully) extremely rare case of needing to
            % regenerate the data, use the static method generate_data (see
            % elsewhere in this class definition)
            data_file = 'test_tobyfit_cuts_data.mat';   % filename where cuts for tests are stored
            obj = obj@TestCaseWithSave(name);

            % Load sqw cuts
            load (data_file, 'fe_1', 'fe_2', 'fe_arr', 'rb_arr');
            
            % Add instrument and sample information to the cuts
            
            % For mysterious reasons lost in time, the two sets of tests merged
            % here had different sample geometry descriptions. Stick with
            %   IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02]);
            % rather than:
            %   IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.03,0.03,0.04]);
            % and use lattice parameters
            %   [2.8700 2.8700 2.8700]
            % rather than
            %   [2.8504 2.8504 2.8504]
            
            sample_fe = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02]);
            sample_fe.alatt = [2.8700 2.8700 2.8700];
            sample_fe.angdeg = [90 90 90];
            fe_1=set_sample_and_inst(fe_1,sample_fe,...
                @maps_instrument_obj_for_tests,'-efix',600,'S');
            fe_2=set_sample_and_inst(fe_2,sample_fe,...
                @maps_instrument_obj_for_tests,'-efix',600,'S');
            for i=1:numel(fe_arr)
                fe_arr(i)=set_sample_and_inst(fe_arr(i),sample_fe,...
                    @maps_instrument_obj_for_tests,'-efix',600,'S');
            end
            
            % Add sample and instrument information to the RbMnF3 cuts
            sample_rb=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
            sample_rb.alatt = [4.2240 4.2240 4.2240];
            sample_rb.angdeg = [90 90 90];
            for i=1:numel(rb_arr)
                rb_arr(i)=set_sample_and_inst(rb_arr(i),sample_rb,...
                    @maps_instrument_obj_for_tests,'-efix',300,'S');
            end
                
            % Initialise test object properties
            obj.fe_1 = fe_1;      % short const-E cut, 150-160 meV
            obj.fe_2 = fe_2;      % long const-E cut, 150-160 meV
            obj.fe_arr = fe_arr;  % three short const-E cuts, 140-160, 160-180, 180-200 meV
            obj.rb_arr = rb_arr;    % two const-Q cuts, 2-10 meV
            
            tol_sig = 0.25;        % tolerance as multiple of st. dev. of reference value
            tol_abs = 0;        % absolute tolerance
            tol_rel = 0;        % relative tolerance
            obj.tolerance = [tol_sig, tol_abs, tol_rel];
            obj.seed = 0;
            obj.mc_fe = 2;
            obj.mc_rb = 1;
            obj.nlist = 0;

            % Required final line (see testCaseWithSave documentation)
            obj.save();
        end

        function obj = setUp(obj)
            % Save current rng state and force random seed and method
            obj.rng_state = rng(obj.seed, 'twister');
            warning('off', 'HERBERT:mask_data_for_fit:bad_points')
        end
        
        function obj = tearDown(obj)
            % Undo rng state
            rng(obj.rng_state);
            warning('on', 'HERBERT:mask_data_for_fit:bad_points')
        end
                
        
        %% --------------------------------------------------------------------------------------
        % Fit single cut from Fe
        % --------------------------------------------------------------------------------------
        function obj = test_fit_fe_single_good_par(obj)
            % Single cut, starting parameters close to a good fit
            
            amp=50;  sj=40;   fwhh=50;   const=0.1;  grad=0;
            
            kk = tobyfit(obj.fe_1);
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd, [amp,sj,fwhh,const,grad], [1,1,0,1,0]);
            kk = kk.set_mc_points(obj.mc_fe);
            kk = kk.set_options('listing', obj.nlist);
            [~, fp] = kk.fit;
            
            assertTestWithSave(obj, fp, @is_same_fit, obj.tolerance)
            
        end
        
        function obj = test_fit_fe_single_bad_par(obj)
            % Single cut, starting parameters well away from a good fit
            
            amp=100;  sj=50;   fwhh=50;   const=0;  grad=0;
            
            kk = tobyfit(obj.fe_1);
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad],[1,1,0,1,0]);
            kk = kk.set_mc_points(obj.mc_fe);
            kk = kk.set_options('listing',obj.nlist);
            [~, fp] = kk.fit;
            
            assertTestWithSave(obj, fp, @is_same_fit, obj.tolerance)
            
        end
        
        function obj = test_fit_fe_single_fore_back_decoupled(obj)
            % Decouple foreground and background models - get same result, so good!
            amp=100;  sj=50;   fwhh=50;   const=0;  grad=0;
            
            kk = tobyfit(obj.fe_1);
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_free([1,1,0]);
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
            kk = kk.set_bfree([1,0]);
            kk = kk.set_mc_points(obj.mc_fe);
            kk = kk.set_options('listing',obj.nlist);
            [~, fp] = kk.fit;
            
            assertTestWithSave(obj, fp, @is_same_fit, obj.tolerance)
            
        end
        
        function obj = test_fit_fe_single_lin_bkgd_free(obj)
            % Allow linear background parameter to vary
            amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;
            
            kk = tobyfit(obj.fe_1);
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_free([1,1,0]);
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
            kk = kk.set_mc_points(obj.mc_fe);
            kk = kk.set_options('listing',obj.nlist);
            [~,fp]=kk.fit;
            
            assertTestWithSave(obj, fp, @is_same_fit, obj.tolerance)
            
        end
        
        %% --------------------------------------------------------------------------------------
        % Fit multiple datasets from Fe
        % ---------------------------------------------------------------------------------------
        
        function obj = test_fit_fe_multi_all_free(obj)
            % Global foreground; allow all parameters to vary
            amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;
            
            kk = tobyfit(obj.fe_arr);
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
            kk = kk.set_mc_points(obj.mc_fe);
            kk = kk.set_options('listing',obj.nlist);
            [~,fp] = kk.fit;
            
            assertTestWithSave(obj, fp, @is_same_fit, obj.tolerance)
            
        end
        
        function obj = test_fit_fe_multi_sj_and_gamma_global(obj)
            % Local foreground; constrain SJ and gamma as global but allow
            % amplitude and gamma to vary locally
            
            amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;
            
            kk = tobyfit(obj.fe_arr);
            kk = kk.set_local_foreground;
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_bind({2,[2,1]});
            kk = kk.set_bind({3,[3,1]});
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
            kk = kk.set_mc_points(obj.mc_fe);
            kk = kk.set_options('listing',obj.nlist);
            [~,fp] = kk.fit;
            
            assertTestWithSave(obj, fp, @is_same_fit, obj.tolerance)

        end
        
        function obj = test_fit_fe_multi_sj_global(obj)
            % Local foreground; constrain SJ as global but allow amplitude
            % and gamma to vary locally.
            % The intensity and lifetime are very highly correlated, so not
            % actually a discriminating test.
            
            amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;
            
            kk = tobyfit(obj.fe_arr);
            kk = kk.set_local_foreground;
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_bind({2,[2,1]});
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
            kk = kk.set_mc_points(obj.mc_fe);
            kk = kk.set_options('listing',obj.nlist);
            [~,fp] = kk.fit;
            
            assertTestWithSave(obj, fp, @is_same_fit, obj.tolerance)

        end
        
        %% --------------------------------------------------------------------------------------
        % Fit multiple datasets from RbMnF3
        % ---------------------------------------------------------------------------------------
        
        function obj = test_fit_rb_multi_sj_global(obj)
            % Local foreground; constrain SJ as global, fix gamma and gap,
            % but allow intensity to vary locally
            Seff = 6000; SJ = 8.8; gap = 0.01; gam=0.04;   const=0;  grad=0;
            
            kk = tobyfit(obj.rb_arr);
            kk = kk.set_local_foreground;
            kk = kk.set_fun(@testfunc_rbmnf3_sqw,[Seff, SJ, gap, gam],[1,1,0,0]);
            kk = kk.set_bind({2,[2,1]});
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad],[1,0]);
            kk = kk.set_mc_points(obj.mc_rb);
            kk = kk.set_options('listing',obj.nlist);
            [~,fp] = kk.fit;
            
            assertTestWithSave(obj, fp, @is_same_fit, obj.tolerance)
            
        end
        
        
        %% --------------------------------------------------------------------------------------
        % Fit multiple datasets from Fe and RbMnF3
        % ---------------------------------------------------------------------------------------

        function obj = test_fit_fe_rb_multi(obj)
            % This is a fit of Fe and Rb arrays of cuts that are independent,
            % but intermixed as a really testing exercise of multifit and
            % Tobyfit input parsing and functionality.
            
            % Fe: Local foreground; constrain SJ and gamma as global but allow
            % amplitude and gamma to vary locally
            %
            % RbMnF3: Local foreground; constrain SJ as global, fix gamma and gap,
            % but allow intensity to vary locally
            
            amp=100;  sj=40;   fwhh=50;
            Seff = 6000; SJ = 8.8; gap = 0.01; gam=0.04;
            const=0;  grad=0;
            
            datasets = [obj.fe_arr(1), obj.rb_arr(1), obj.rb_arr(2),...
                obj.fe_arr(2), obj.fe_arr(3), obj.rb_arr(3)];
            ind_fe = [1,4,5];
            ind_rb = [2,3,6];
            
            kk = tobyfit(datasets);
            kk = kk.set_local_foreground;
            
            kk = kk.set_fun(ind_fe,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_bind(ind_fe,{2,[2,1]});
            kk = kk.add_bind(ind_fe,{3,[3,1]});
            kk = kk.set_bfun(ind_fe,@testfunc_bkgd,[const,grad]);
            
            kk = kk.set_fun(ind_rb,@testfunc_rbmnf3_sqw,[Seff, SJ, gap, gam],[1,1,0,0]);
            kk = kk.add_bind(ind_rb,{2,[2,1],0.245});
            kk = kk.set_bfun(ind_rb,@testfunc_bkgd,[const,grad],[1,0]);
            
            kk = kk.set_mc_points(obj.mc_rb);
            kk = kk.set_options('listing',obj.nlist);
            [~, fp] = kk.fit();
            
            assertTestWithSave(obj, fp, @is_same_fit, obj.tolerance)
            
        end

      
    end

    %------------------------------------------------------------------
    methods (Static)
        function generate_data (datafile)
            % Generate data and save to file
            %
            % Use:
            %   >> test_tobyfit_cuts.generate_data ('my_output_file.mat')
            %
            % Input:
            % ------
            %   datafile    Name of file to which to save cuts for future use
            %               e.g. fullfile(tempdir,'test_tobyfit_cuts_data.mat')
            %               Normal practice is to write to tempdir to check contents
            %               before manually replacing the file in the repository.
            
            % sqw files from which to take cuts for setup
            % These are private to Toby's computer as of 22/1/2023
            % Long term solution needed for data source locations
            data_source_fe = 'T:\data\Fe\sqw_Toby\Fe_ei787.sqw';
            data_source_rb = 'T:\data\RbMnF3\sqw\rbmnf3_ref_newformat.sqw';
            
            % Cuts from iron
            % --------------
            proj_fe.u = [1,1,0];
            proj_fe.v = [-1,1,0];
            
            % Short cut along [1,1,0]
            fe_1=cut_sqw(data_source_fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[150,160]);
            
            % Long cut along [1,1,0]
            fe_2=cut_sqw(data_source_fe,proj_fe,[0.95,1.05],[-2,0.05,3],[-0.05,0.05],[150,160]);
            
            % Create cuts to simulate or fit simultaneously
            tmp_1=cut_sqw(data_source_fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[140,160]);
            tmp_2=cut_sqw(data_source_fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[160,180]);
            tmp_3=cut_sqw(data_source_fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[180,200]);
            
            fe_arr=[tmp_1,tmp_2,tmp_3];
            
            % Cuts from RbMnF3
            % ----------------
            proj_rb.u = [1,1,0];
            proj_rb.v = [0,0,1];
            tmp_1 = cut_sqw(data_source_rb,proj_rb,[0.45,0.55],[-0.05,0.05],[-0.05,0.05],[5,0,11]);
            tmp_2 = cut_sqw(data_source_rb,proj_rb,[0.45,0.55],[0.25,0.35],[-0.05,0.05],[2,0,10]);
            tmp_3 = cut_sqw(data_source_rb,proj_rb,[0.45,0.55],[0.15,0.25],[-0.05,0.05],[2,0,10]);
            
            rb_arr = [tmp_1;tmp_2;tmp_3];
            
            % Save data
            % ---------
            save(datafile,'fe_1','fe_2','fe_arr','rb_arr');
            disp(['Saved data for future use in ',datafile])
            
        end
    end

end
