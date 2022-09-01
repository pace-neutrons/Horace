classdef test_tobyfit_let < TestCaseWithSave

    properties
        nb_1
        nb_2
        nb_arr
        nb_qe
        v_data

        sample
        instru

        rf_efix
        chop_efix

        rng_state

        cont_tol
        ilist

        seed
    end

    methods
        function obj = test_tobyfit_let(name)

            output_file = 'test_tobyfit_let.mat';   % filename where saved results are written

            datafile = 'test_tobyfit_let_data.mat';

% $$$             datafile = 'test_tobyfit_let_1_data.mat';
% $$$             datafile2 = 'test_tobyfit_let_2_data.mat';
% $$$             datafile3='test_tobyfit_let_resfun_1_data.mat';

            obj = obj@TestCaseWithSave(name, output_file);

            % Determine whether or not to save output
            regen_data = false;
            obj.save_output = true;

            if regen_data
                obj.gen_data(data_source, datafile);
                return
            end

% $$$             load(datafile, 'w1a', 'w1b');
% $$$             load(datafile2, 'w1');
% $$$             load(datafile3, 'w_nb_qe');
% $$$
% $$$             nb_1 = w1a;
% $$$             nb_2 = w1b;
% $$$             v_data = w1;
% $$$             nb_qe = w_nb_qe;
            load(datafile, 'nb_1', 'nb_2', 'v_data', 'nb_qe')

            % test_tobyfit_let_1

            obj.rf_efix = 8.04;
            obj.instru = let_instrument_obj_for_tests(obj.rf_efix, 280, 140, 20, 2, 2);
            obj.sample = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.012,0.012,0.04]);
            obj.sample.alatt = [3.3000 3.3000 3.3000];
            obj.sample.angdeg = [90 90 90];

            obj.nb_1 = set_instrument(nb_1, obj.instru);
            obj.nb_1 = set_sample(obj.nb_1, obj.sample);

            obj.nb_2 = set_instrument(nb_2, obj.instru);
            obj.nb_2 = set_sample(obj.nb_2, obj.sample);

            obj.nb_arr = [obj.nb_1,obj.nb_2];

            obj.rng_state = rng();
            obj.tol = [0.5,0,0.02,0.02];  % sig, abs, rel
            obj.ilist = 0;

            % Test Tobyfit Resfun
            obj.nb_qe = sqw(nb_qe);
            obj.nb_qe=set_sample(obj.nb_qe,obj.sample);
            obj.nb_qe=set_instrument(obj.nb_qe,obj.instru);
            % test_tobyfit_let_2

            obj.chop_efix=8;
            obj.cont_tol = [0, 0.03];
            instru = let_instrument_obj_for_tests(obj.chop_efix, 280, 140, 20, 2, 2);
            sample = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            sample.alatt = [5 5 5];
            sample.angdeg = [90 90 90];

            obj.v_data = set_instrument(v_data, instru);
            obj.v_data = set_sample(obj.v_data, sample);

            % Simulate with vanadium lineshape
            obj.v_data = sqw_eval(obj.v_data,@van_sqw,[10,0,0.05]);   % 50 ueV fwhh; peak_cwhh gives 54
            obj.v_data = noisify(obj.v_data,1);     % add error bars

            instru_mod = let_instrument_obj_for_tests(obj.chop_efix, 280, 140, 20, 2, 2);
            instru_mod.shaping_chopper.frequency=171;
            wtmp=set_instrument(obj.v_data, instru_mod);

            % wq2 = cut_sqw(sqw_file_full, proj, 0.025, 0.025, [-0.2,0.2], [-3,6]);
            % wq1 = cut_sqw(sqw_file_full, proj, [-0.2,0.2], [-0.3,0.02,0.3], [-0.2,0.2], [-3,6]);

            % instru = let_instrument (obj.rf_efix, 280, 140, 20, 2, 2);
            % sample = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            % wq1 = set_instrument (wq1, instru);
            % wq1 = set_sample (wq1, sample);

            % % Test the cross-section model
            % fwhh = 0.25;
            % wq2_nores=sqw_eval(wq2,@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});
            % wq1_nores=sqw_eval(wq1,@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});

            if obj.save_output
                obj.save();
            end

        end

        function obj = gen_data(obj, data_source, datafile)
        % Generate data and save to outputs

        % Create sqw file for refinement testing
        % ---------------------------------------
        % Full output file names

            efix=8;
            emode=1;
            en0=-3:0.02:7;
            %en=-2:0.02:2;
            par_file=fullfile(pwd,'LET_one2one_153.par');

            % Parameters for reference lattice (i.e. what we think we have)
            alatt=[5,5,5];
            angdeg=[90,90,90];
            u=[1,1,0];
            v=[0,0,1];
            psi0=180;
            %psi=180:1:270;
            omega=0; dpsi=0; gl=0; gs=0;

            sqw_file_full = fullfile(tmp_dir,sqw_file);

            % Create sqw file for single spe file
            fake_sqw(en0, par_file, sqw_file_full, efix, emode, alatt, angdeg, u, v, psi0, omega, dpsi, gl, gs);

            % Create cut
            proj = projaxes([1,1,0],[0,0,1]);
            w1 = cut_sqw(sqw_file_full, proj, [-0.5,0], [0.5,1], [-0.2,0.2], [-3.01,0.02,7.01]);

            % Save cut for future use
            datafile_full = fullfile(tmp_dir,datafile);
            save(datafile_full,'w1');
            disp(['Saved data for future use in',datafile_full])
        end

        function obj = setUp(obj)
            warning('off', 'HERBERT:mask_data_for_fit:bad_points')
        end

        function obj = tearDown(obj)
        % Undo rand seeding
            rng(obj.rng_state);
            warning('on', 'HERBERT:mask_data_for_fit:bad_points')
        end

        function equalToSig(obj, fp1)
            % Tol as sig, abs, rel
            if obj.save_output
                assertEqualToTolWithSave(obj, fp1);
                return
            end

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

        %----------------------
        % Tests
        %----------------------

        function obj = test_nb_two_datasets(obj)
        % Fit multiple datasets for Nb

            rng(0, 'twister');

            % Local foreground; constrain gamma as global but allow amplitude to vary locally
            amp=6000;    fwhh=0.2;

            kk = tobyfit(obj.nb_arr);
            kk = kk.set_local_foreground();
            kk = kk.set_fun(@testfunc_nb_sqw,[amp,fwhh]);
            kk = kk.set_bind({2,[2,1]});
            kk = kk.set_bfun(@testfunc_bkgd,[0,0]);
            kk = kk.set_mc_points(2);
            kk = kk.set_options('listing',obj.ilist);

            [wfit,fitpar] = kk.fit();

            obj.equalToSig(wfit);
        end

        % -----------------------------------
        % Test the mod/shape chop pulse width
        % -----------------------------------

        function obj = test_chop_pulse_width_1(obj)
            % To access the distribution of sampling times from the joint moderator/chopper 1
            % deviate, need to use the debugger and inside the function tobyfit_DGdisk_resconv
            % pause and use the saver script to save y(1,1,:)

            % mod FWHH=99.37us, shape_chop FWHH=66.48us
            % Will have pulse determined by moderator

            rng(503057, 'twister');

            instru_mod = let_instrument_obj_for_tests(obj.chop_efix, 280, 140, 20, 2, 2);
            instru_mod.shaping_chopper.frequency=171;
            wtmp=set_instrument(obj.v_data, instru_mod);

            whist = get_tshape_histogram(wtmp);
            [~,~,fwhh] = peak_cwhh(whist);

            assertEqualToTolWithSave(obj, whist, obj.cont_tol);
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        function obj = test_chop_pulse_width_2(obj)
            % mod FWHH=99.37us, shape_chop FWHH=66.09us
            % Will have pulse determined by shaping chopper
            instru_shape = let_instrument_obj_for_tests(obj.chop_efix, 280, 140, 20, 2, 2);
            instru_shape.shaping_chopper.frequency=172;
            wtmp=set_instrument(obj.v_data, instru_shape);

            whist = get_tshape_histogram(wtmp);
            [~,~,fwhh] = peak_cwhh(whist);

            assertEqualToTolWithSave(obj, whist, obj.cont_tol);
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end


        function obj = test_chop_pulse_width_3(obj)
            % mod FWHH=99.37us, shape_chop FWHH=11368us
            instru_shape = let_instrument_obj_for_tests(obj.chop_efix, 280, 140, 20, 2, 2);
            instru_shape.shaping_chopper.frequency=1;
            wtmp=set_instrument(obj.v_data, instru_shape);

            whist = get_tshape_histogram(wtmp);
            [~,~,fwhh] = peak_cwhh(whist);

            assertEqualToTolWithSave(obj, whist, obj.cont_tol);
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        function obj = test_chop_pulse_width_4(obj)
            % mod FWHH=99.37us, shape_chop FWHH=11368us

            instru_shape_only = let_instrument_obj_for_tests(obj.chop_efix, 280, 140, 20, 2, 2);
            instru_shape_only.moderator.pp(1)=10000;
            instru_shape_only.shaping_chopper.frequency=171;
            wtmp=set_instrument(obj.v_data, instru_shape_only);


            whist = get_tshape_histogram(wtmp);
            [~,~,fwhh] = peak_cwhh(whist);

            assertEqualToTolWithSave(obj, whist, obj.cont_tol);
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        % -----------------------------------
        % All contributions
        % -----------------------------------

        function obj = test_contributions_all(obj)
            % All contributions: fwhh = 204 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);

            kk=kk.set_mc_contributions('all');
            wsim = kk.simulate();
            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        % ------------------------------
        % Individual contributions
        % ------------------------------

        function obj = test_contributions_none(obj)
        % No contributions: fwhh = 54 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('none');
            wsim = kk.simulate();

            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        function obj = test_contributions_mod_shape(obj)
        % Moderator & shape chopper only: fwhh = 123 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('none');
            kk = kk.set_mc_contributions('moderator','shape_chopper');
            wsim = kk.simulate();

            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        function obj = test_contributions_mono(obj)
        % Mono chopper only: fwhh = 169 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('none');
            kk = kk.set_mc_contributions('mono_chopper');
            wsim = kk.simulate();

            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        function obj = test_contributions_mod_choppers(obj)
        % Moderator & both chopper only: fwhh = 192 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('none');
            kk = kk.set_mc_contributions('moderator','shape_chopper','mono_chopper');
            wsim = kk.simulate();

            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        function obj = test_contributions_divergence(obj)
        % Divergence only: fwhh = 54 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('none');
            kk = kk.set_mc_contributions('horiz','vert');
            wsim = kk.simulate();

            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        function obj = test_contributions_sample(obj)
        % Sample only: fwhh = 77 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('none');
            kk = kk.set_mc_contributions('sample');
            wsim = kk.simulate();

            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        function obj = test_contributions_det_depth(obj)
        % Detector depth only: fwhh = 67 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('none');
            kk = kk.set_mc_contributions('detector_depth');
            wsim = kk.simulate();

            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        function obj = test_contributions_det_area(obj)
        % Detector area only: fwhh = 54 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('none');
            kk = kk.set_mc_contributions('detector_area');
            wsim = kk.simulate();

            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end


        function obj = test_contributions_energy_bin(obj)
        % Energy bins only: fwhh = 56 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('none');
            kk = kk.set_mc_contributions('energy_bin');
            wsim = kk.simulate();

            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        % -------------------------------------------------------------
        % Determine effect of dual moderator pulse and shaping chopper:
        % -------------------------------------------------------------

        function obj = test_contributions_no_shape(obj)
        % No shaping chopper: fwhh = 209 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('noshape');
            wsim = kk.simulate();

            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end


        function obj = test_contributions_no_mod_pulse(obj)
        % No shaping chopper: fwhh = 209 ueV
            kk = tobyfit(obj.v_data);
            kk = kk.set_fun(@van_sqw,[10,0,0.05]);
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('nomod');
            wsim = kk.simulate();

            [~,~,fwhh,~,~,~,~] = peak_cwhh(IX_dataset_1d(wsim));
            assertEqualToTolWithSave(obj, fwhh, obj.cont_tol);
        end

        % ---------------------------
        % Test the q-resolution width
        % ---------------------------

        function obj = test_resolution_horiz_1(obj)
        % Now test resolution
            skipTest('Not implemented')
            fwhh = 0.02;
            wnores = sqw_eval(wq1,@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});

            kk = tobyfit(wq1);
            kk = kk.set_fun(@sheet_sqw,{[1,fwhh],[5,5,5,90,90,90],[0,0,1]});
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('horiz');      % horizontal divergence only
            wsim = kk.simulate;
        end

        function obj = test_resolution_horiz_2(obj)
        % FWHH in Q
            skipTest('Not implemented')
            fwhh = 0.01;
            wq1_nores=sqw_eval(wq1,@rod_sqw,{[1,fwhh],[5,5,5,90,90,90]});

            % Now with resolution
            kk = tobyfit(wq1);
            kk = kk.set_fun(@rod_sqw,{[1,fwhh],[5,5,5,90,90,90]});
            kk = kk.set_mc_points(10);
            kk = kk.set_mc_contributions('horiz');      % horizontal divergence only
            wsim = kk.simulate();
        end

        function obj = test_resolution_disk_horiz(obj)
            skipTest('Not implemented')
            kkt = tobyfit (wq1,'disk_test');
            kkt = kkt.set_fun(@rod_sqw,{[1,fwhh],[5,5,5,90,90,90]});
            kkt = kkt.set_mc_points(10);
            kkt = kkt.set_mc_contributions('horiz');    % horizontal divergence only
            wsim_test = kkt.simulate();
        end

        % -------------------
        % Standalone plots
        % -------------------

        function obj = test_resfun_1(obj)

            det.x2=3.5;
            det.phi=60;
            det.azim=0;
            det.width=0.025;
            det.height=0.04;

            emode = 1;
            alatt = [3.3,3.3,3.3];
            angdeg = [90,90,90];
            u = [1,1,0];
            v = [0,0,1];
            ww=resolution_plot([2-0.01,2+0.01],obj.instru,obj.sample,det,obj.rf_efix,emode,alatt,angdeg,u,v,0,0,0,0,0);
            assertEqualToTolWithSave(obj, ww, [1e-8,1e-8]);

        end

        function obj = test_resfun_2(obj)
            det.x2=3.5;
            det.phi=60;
            det.azim=0;
            det.width=0.025;
            det.height=0.04;

            emode = 1;
            alatt = [3.3,3.3,3.3];
            angdeg = [90,90,90];
            u = [1,1,0];
            v = [0,0,1];
            iax = [1,4];
            ww=resolution_plot([2-0.01,2+0.01],obj.instru,obj.sample,det,obj.rf_efix,emode,alatt,angdeg,u,v,0,0,0,0,0,iax);
            assertEqualToTolWithSave(obj, ww, [1e-8,1e-8]);
        end

        function obj = test_resfun_3(obj)
            ww = resolution_plot (obj.nb_qe, [0.05,1.20; 0.15,2.80], 'noplot');
            assertEqualToTolWithSave(obj, ww, [1e-8,1e-8]);
        end

    end

end


function [whist, wsim] = get_tshape_histogram (wtmp)
% Get a histogram of the distribution of t_shape

debugtools('on')

kk = tobyfit (wtmp);
kk = kk.set_fun(@van_sqw,[10,0,0.05]);
kk = kk.set_mc_points(1);
wsim = kk.simulate();

tmp = load(fullfile(tmp_dir,'histogram.mat'));
whist = tmp.w;

debugtools('off')

end
