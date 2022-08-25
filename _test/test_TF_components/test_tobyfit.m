classdef test_tobyfit < TestCaseWithSave

    properties
        fac

        ilist

        rng_state
        seed

        fe_1
        fe_2
        fe_3
        fe_4
        fe_arr
        fe_arr2
        rb_1
        rb_arr
        w1inc
    end

    methods
        function obj = test_tobyfit(name)

            output_file = 'test_tobyfit.mat';   % filename where saved results are written
            datafile = struct('fe', 'test_tobyfit_fe_data.mat', ...
                'rb', 'test_tobyfit_rb_data.mat');
            obj = obj@TestCaseWithSave(name, output_file);


            % Determine whether or not to save output
            regen_data = false;
            obj.save_output = false;

            if regen_data
                data_source = struct('fe', 'D:\data\Fe\sqw_Toby\Fe_ei787.sqw', ...  % sqw file from which to take cuts for setup
                    'rb', 'T:\data\RbMnF3\sqw\rbmnf3_ref_newformat.sqw', ...
                    'mod', 'E:\data\aaa_Horace\rbmnf3_backup_v1.sqw');  % sqw file from which to take cuts for setup
                obj.gen_data(data_source, datafile);
                return
            end

            % Original data structure
            %{
            orig_datafile = struct('one', 'test_tobyfit_1_data.mat', ...   % filename where saved results are written
                                   'two', 'test_tobyfit_2_data.mat', ...     % filename where saved data are written
                                   'mod', 'test_tobyfit_refine_moderator_1_data.mat', ...   % filename where saved results are written
                                   'res', 'test_tobyfit_resfun_1_data.mat');      % filename where saved results are written
            % Mosaic tests not finished
            % orig_datafile.mos = 'test_tobyfit_mosaic_data.mat'

            load(orig_datafile.one, 'w110a','w110b','w110arr');
            load(orig_datafile.two, 'fe_1','fe_2','fe_arr','rb_1','rb_arr');
            load(orig_datafile.mod, 'w1inc');
            load(orig_datafile.res, 'w2a','wce','w2b');
            % load('w110arr_as_separate_objects.mat');
            % load('ferbarr_as_separate_objects.mat');
            %}

            load(datafile.fe,'fe_1','fe_2','fe_arr')
            load(datafile.rb,'rb_1','rb_arr','w1inc') %,'w2a','wce','w2b')

            obj.tol = [0.25,1.0,0.1]; % sig, abs, rel
            obj.seed = 0;
            obj.ilist = 0;

            obj.fe_arr = fe_arr;
            obj.fe_arr2 = fe_arr;
            obj.rb_arr = rb_arr;

            ssi = @(x, samp, e) set_sample_and_inst(x,samp,@maps_instrument_obj_for_tests,'-efix',e,'S');

            % Tobyfit tests
            % Add instrument and sample information to cuts
            sample_fe=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02]);
            sample_fe.alatt = [2.8700 2.8700 2.8700];
            sample_fe.angdeg = [90 90 90];

            obj.fe_1=ssi(fe_1,sample_fe,600);
            obj.fe_2=ssi(fe_2,sample_fe,600);
            obj.fe_arr = arrayfun(@(x) ssi(x, sample_fe, 600), fe_arr);


            sample_fe2=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.03,0.03,0.04]);
            sample_fe2.alatt = [2.8504 2.8504 2.8504];
            sample_fe2.angdeg = [90 90 90];

            obj.fe_3=ssi(fe_1,sample_fe2,600);
            obj.fe_4=ssi(fe_2,sample_fe2,600);
            obj.fe_arr2 = arrayfun(@(x) ssi(x, sample_fe2, 600), fe_arr);

            % Mosaic tests - not finished
            %{
              sample_fe_mos=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02],[6,0,4]);
              obj.w2_200 =ssi(w2_200, sample_fe_mos,600);
              obj.w2_020 =ssi(w2_020, sample_fe_mos,600);
              obj.w2_1m10=ssi(w2_1m10,sample_fe_mos,600);
            %}

            % Moderator tests
            sample_rb=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
            sample_rb.alatt = [4.2240 4.2240 4.2240];
            sample_rb.angdeg = [90 90 90];

            obj.w1inc=ssi(w1inc,sample_rb,300);

            % Rubidium tests (Tobyfit 2)

            obj.rb_1=ssi(rb_1,sample_rb,300);
            obj.rb_arr = arrayfun(@(x) ssi(x, sample_rb, 300), rb_arr);

            obj.fac=[0.25,1,0.1];    % used by comparison function

            if obj.save_output
                obj.save();
            end

        end

        function obj = gen_data(obj, data_source, datafile)
            % Generate data and save to outputs

            % Cuts from iron
            % --------------
            % Short cut along [1,1,0]
            proj_fe = projaxes([1,1,0],[-1,1,0]);

            % Short cut along [1,1,0]
            fe_1=cut_sqw(data_source.fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[150,160]);
            w110a = fe_1;

            % Long cut along [1,1,0]
            fe_2=cut_sqw(data_source.fe,proj_fe,[0.95,1.05],[-2,0.05,3],[-0.05,0.05],[150,160]);
            w110b = fe_2;

            % Create cuts to simulate or fit simultaneously
            tmp_1=cut_sqw(data_source.fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[140,160]);
            tmp_2=cut_sqw(data_source.fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[160,180]);
            tmp_3=cut_sqw(data_source.fe,proj_fe,[0.95,1.05],[-0.6,0.05,0.6],[-0.05,0.05],[180,200]);

            fe_arr=[tmp_1,tmp_2,tmp_3];
            w110arr = fe_arr;

            % Mosaic cuts
            %{
              proj_100 = projaxes([1,0,0],[0,1,0]);
              w2_200=cut_sqw(data_source.mos,proj_100,[1.95,2.05],[-0.3,0.02,0.3],[-0.3,0.02,0.3],[-10,10]);

              proj_010 = projaxes([0,1,0],[-1,0,0]);
              w2_020=cut_sqw(data_source.mos,proj_010,[1.95,2.05],[-0.3,0.02,0.3],[-0.3,0.02,0.3],[-10,10]);

              proj_1m10 = projaxes([1,-1,0],[1,1,0]);
              w2_1m10=cut_sqw(data_source.mos,proj_1m10,[0.965,1.035],[-0.2,0.015,0.2],[-0.3,0.02,0.3],[-10,10]);
            %}


            % Cuts from RbMnF3
            % ----------------

            proj_rb = projaxes([1,1,0],[0,0,1]);
            rb_1 = cut_sqw(data_source.rb,proj_rb,[0.45,0.55],[-0.05,0.05],[-0.05,0.05],[5,0,11]);

            tmp_1 = cut_sqw(data_source.rb,proj_rb,[0.45,0.55],[0.25,0.35],[-0.05,0.05],[2,0,10]);
            tmp_2 = cut_sqw(data_source.rb,proj_rb,[0.45,0.55],[0.15,0.25],[-0.05,0.05],[2,0,10]);

            rb_arr = [tmp_1;tmp_2];


            % Cuts for moderator
            % ------------------

            proj_mod=projaxes([1,1,0],[0,0,1]);
            w1inc=cut_sqw(data_source.mod,proj_mod,[0.3,0.5],[0,0.2],[-0.1,0.1],[-3,0.1,3]);


            % Now save to file for future use
            datafile_full = fullfile(tmp_dir,datafile.fe);
            save(datafile.fe,'fe_1','fe_2','fe_arr');
            datafile_full = fullfile(tmp_dir,datafile.rb);
            save(datafile.rb,'rb_1','rb_arr','w1inc')
            % Not including unfinished mosaic tests


            % Original data structure
            %{
            datafile_full = fullfile(tmp_dir,datafile.one);
            save(datafile_full,'w110a','w110b','w110arr');

            datafile_full = fullfile(tmp_dir,datafile.two);
            save(datafile_full,'fe_1','fe_2','fe_arr','rb_1','rb_arr');


            datafile_full = fullfile(tmp_dir,datafile.mos);
            save(datafile_full,'w2_200','w2_020','w2_1m10');


            datafile_full = fullfile(tmp_dir,datafile.mod);
            save(datafile_full,'w1inc');
            %}
        end

        function obj = setUp(obj)
            % Force random seed
            obj.rng_state = rng(obj.seed, 'twister');
            warning('off', 'HERBERT:mask_data_for_fit:bad_points')
        end

        function obj = tearDown(obj)
            % Undo rand seeding
            rng(obj.rng_state);
            warning('on', 'HERBERT:mask_data_for_fit:bad_points')
        end

        function equalToSig(obj, fp1)
            % Tol as sig, abs, rel
            tol = obj.tol;
            var_name = inputname(2);
            fp2 = obj.getReferenceData(var_name);

            sig1 = get_sig(fp1);
            sig2 = get_sig(fp2);

            tol_from_err = abs(tol(1)) * sqrt(sig1.^2 + sig2.^2);
            tol = {max(tol_from_err, tol(2)), tol(3)};
            message = '';

            for i=1:numel(fp1.p)
                try
                    assertEqualToTol(fp1.p(i), fp2.p(i), [tol{1}(i), tol{2}])
                catch ME
                    switch ME.identifier
                        case 'assertEqualToTol:tolExceeded'
                            message = [message, newline(), '(', num2str(i), ') ', ME.message];
                        otherwise
                            rethrow(ME)
                    end
                end
            end

            if ~isempty(message)
                error('assertEqualToTol:tolExceeded', message)
            end

        end


        %% --------------------------------------------------------------------------------------
        % fit single cuts
        % --------------------------------------------------------------------------------------


        function obj = test_fit_fe_single_good_par(obj)
            % An example of having starting parameters close to a good fit

            amp=50;  sj=40;   fwhh=50;   const=0.1;  grad=0;

            kk = tobyfit(obj.fe_1);
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad],[1,0,0,1,0]);
            kk = kk.set_mc_points(10);
            kk = kk.set_options('listing',obj.ilist);
            [~,fp110a1]=kk.fit;

            if ~obj.save_output
                obj.equalToSig(fp110a1);
            else
                assertEqualToTolWithSave(obj, fp110a1);
            end
        end

        function obj = test_fit_fe_single_bad_par(obj)
            % From a poor starting position

            amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

            kk = tobyfit(obj.fe_1);
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm_bkgd,[amp,sj,fwhh,const,grad],[1,0,0,1,0]);
            kk = kk.set_mc_points(10);
            kk = kk.set_options('listing',obj.ilist);
            [~,fp110a2]=kk.fit;

            if ~obj.save_output
                obj.equalToSig(fp110a2);
            else
                assertEqualToTolWithSave(obj, fp110a2);
            end
        end

        function obj = test_fit_fe_single_decouple(obj)
            % Decouple foreground and background - get same result, so good!
            amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

            kk = tobyfit(obj.fe_1);
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_free([1,0,0]);
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
            kk = kk.set_bfree([1,0]);
            kk = kk.set_mc_points(10);
            kk = kk.set_options('listing',obj.ilist);
            [~,fp110a3]=kk.fit;

            if ~obj.save_output
                obj.equalToSig(fp110a3);
            else
                assertEqualToTolWithSave(obj, fp110a3);
            end

        end

        function obj = test_fit_fe_single_all_free(obj)
            % Allow all parameters to vary
            amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

            kk = tobyfit(obj.fe_1);
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
            kk = kk.set_mc_points(10);
            kk = kk.set_options('listing',obj.ilist);
            [~,fp110a4]=kk.fit;

            if ~obj.save_output
                obj.equalToSig(fp110a4);
            else
                assertEqualToTolWithSave(obj, fp110a4);
            end
        end

        %% --------------------------------------------------------------------------------------
        % Fit multiple datasets
        % ---------------------------------------------------------------------------------------

        function obj = test_fit_fe_multi_all_free(obj)
            % Global foreground; allow all parameters to vary
            amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

            kk = tobyfit(obj.fe_arr);
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
            kk = kk.set_mc_points(10);
            kk = kk.set_options('listing',obj.ilist);
            [~,fp110arr1]=kk.fit;

            if ~obj.save_output
                obj.equalToSig(fp110arr1);
            else
                assertEqualToTolWithSave(obj, fp110arr1);
            end

        end

        function obj = test_fit_fe_multi_sj_global(obj)
            % Local foreground; constrain SJ as global but allow amplitude and gamma to vary locally

            amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

            kk = tobyfit(obj.fe_arr);
            kk = kk.set_local_foreground;
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_bind({2,[2,1]});
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
            kk = kk.set_mc_points(10);
            kk = kk.set_options('listing',obj.ilist);
            [~,fp110arr2]=kk.fit;

            if ~obj.save_output
                obj.equalToSig(fp110arr2);
            else
                assertEqualToTolWithSave(obj, fp110arr2);
            end
        end

        function obj = test_fit_fe_multi_multi_sj_global(obj)
            % Local foreground; constrain SJ as global but allow amplitude and gamma to vary locally
            amp=100;  sj=40;   fwhh=50;   const=0;  grad=0;

            fe = [obj.fe_3, obj.fe_4, obj.fe_arr2];
            kk = tobyfit(fe);
            kk = kk.set_local_foreground;
            kk = kk.set_fun(@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_bind({2,[2,1]});
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad]);
            kk = kk.set_mc_points(10);
            kk = kk.set_options('listing',obj.ilist);
            [~,par_fe_tf_1]=kk.fit;

            if ~obj.save_output
                obj.equalToSig(par_fe_tf_1);
            else
                assertEqualToTolWithSave(obj, par_fe_tf_1);
            end

        end

        function obj = test_fit_rb_multi_multi_sj_global(obj)
            % Local foreground; constrain SJ as global but allow amplitude and gamma to vary locally
            Seff = 6000; SJ = 8.8; gap = 0.01; gam=0.04;   const=0;  grad=0;

            rb = [obj.rb_1;obj.rb_arr];
            kk = tobyfit(rb);
            kk = kk.set_local_foreground;
            kk = kk.set_fun(@testfunc_rbmnf3_sqw,[Seff, SJ, gap, gam],[1,1,0,0]);
            kk = kk.set_bind({2,[2,1]});
            kk = kk.set_bfun(@testfunc_bkgd,[const,grad],[1,0]);
            kk = kk.set_mc_points(10);
            kk = kk.set_options('listing',obj.ilist);
            [~,par_rb_tf_1]=kk.fit;

            if ~obj.save_output
                obj.equalToSig(par_rb_tf_1);
            else
                assertEqualToTolWithSave(obj, par_rb_tf_1);
            end

        end

        function obj = test_fit_fe_rb_multi(obj)
            % Same fit as above, except constrain the ratio of the exchange constants to enforce
            % a coupling
            amp=100;  sj=40;   fwhh=50;
            Seff = 6000; SJ = 8.8; gap = 0.01; gam=0.04;
            const=0;  grad=0;

            ferb = [obj.fe_3,obj.fe_4,obj.rb_1]; %,obj.fe_arr2,obj.rb_arr'];
            kk = tobyfit(ferb);
            fe_datasets = [1,2]; %,4,5,6];
            rb_datasets = [3]; %,7,8];
            kk = kk.set_local_foreground;
            kk = kk.set_fun(fe_datasets,@testfunc_sqw_bcc_hfm,[amp,sj,fwhh]);
            kk = kk.set_bind(fe_datasets,{2,[2,1]});
            kk = kk.set_bfun(fe_datasets,@testfunc_bkgd,[const,grad]);
            kk = kk.set_fun(rb_datasets,@testfunc_rbmnf3_sqw,[Seff, SJ, gap, gam],[1,1,0,0]);
            kk = kk.add_bind(rb_datasets,{2,[2,1],0.245});
            kk = kk.set_bfun(rb_datasets,@testfunc_bkgd,[const,grad],[1,0]);
            kk = kk.set_mc_points(10);
            kk = kk.set_options('listing',obj.ilist);
            [~,par_ferb_tf_1]=kk.fit();


            if ~obj.save_output
                obj.equalToSig(par_ferb_tf_1);
            else
                assertEqualToTolWithSave(obj, par_ferb_tf_1);
            end

        end

        %% --------------------------------------------------------------------------------------
        % Test moderator effects
        % ---------------------------------------------------------------------------------------

        function obj = test_moderator(obj)

            amp=100;  en0=0;   fwhh=0.25;

            % Get moderator pulse name and parameters
            [pulse_model,ppmod]=get_mod_pulse(obj.w1inc);
            mc=2;

            % Set moderator tau-f to something else to actually test fitting
            ppmod=0.65*ppmod;
            obj.w1inc = set_mod_pulse(obj.w1inc,pulse_model,ppmod);

            kk = tobyfit (obj.w1inc);
            kk = kk.set_refine_moderator (pulse_model,ppmod,[1,0,0]);
            kk = kk.set_mc_points (mc);
            kk = kk.set_fun (@testfunc_sqw_van, [amp,en0,fwhh], [1,1,0]);

            % Fit
            kk = kk.set_options('listing',obj.ilist);
            [~,pfit] = kk.fit();

            if ~obj.save_output
                obj.equalToSig(pfit);
            else
                assertEqualToTolWithSave(obj, pfit);
            end

        end

        %% --------------------------------------------------------------------------------------
        % Test resfun
        % ---------------------------------------------------------------------------------------

        function obj = test_resfun_standalone_1(obj)
            inst = maps_instrument_obj_for_tests(90,250,'s');
            samp = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);

            det.x2=6;
            det.phi=30;
            det.azim=0;
            det.width=0.0254;
            det.height=0.0367;

            ww1=resolution_plot([12.5,13.5],inst,samp,det,100,1,[3,4,5],[90,90,90],[1,1,0],[0,0,1],24,0,1,2,3);
            assertEqualToTolWithSave(obj, ww1,[1e-8,1e-8])

        end

        function obj = test_resfun_standalone_2(obj)
            inst = maps_instrument_obj_for_tests(90,250,'s');
            samp = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);

            det.x2=6;
            det.phi=30;
            det.azim=0;
            det.width=0.0254;
            det.height=0.0367;

            iax = [1,4];
            ww2=resolution_plot([-0.5,0.5],inst,samp,det,100,1,[3,4,5],[90,90,90],[1,1,0],[0,0,1],24,0,1,2,3, iax);
            assertEqualToTolWithSave(obj, ww2,[1e-8,1e-8])

        end

        function obj = test_resfun_standalone_3(obj)
            inst = maps_instrument_obj_for_tests(90,250,'s');
            samp = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);

            det.x2=6;
            det.phi=30;
            det.azim=0;
            det.width=0.0254;
            det.height=0.0367;

            iax = [1,4];
            ww3=resolution_plot([39.5,40.5],inst,samp,det,100,1,[3,4,5],[90,90,90],[1,1,0],[0,0,1],24,0,1,2,3, iax);
            assertEqualToTolWithSave(obj, ww3,[1e-8,1e-8])

        end

    end
end



function p=make_vec(pin)
if ~isempty(pin)
    if iscell(pin)
        p=cell2mat(pin);
    else
        p=pin;
    end
else
    p=[];
end
end

function sig = get_sig(fp)
if isfield(fp,'sig')
    sig=fp.sig;
else
    sig=[];
end

if isfield(fp,'bsig')
    bsig=fp.bsig;
else
    bsig=[];
end
sig = [make_vec(sig), make_vec(bsig)];
end
