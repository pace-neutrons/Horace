classdef test_tobyfit_resfun < TestCaseWithSave

    properties
        fac

        ilist

        rng_state
        seed

        res_w2a
        res_wce
        res_w2b
    end

    methods
        function this = test_tobyfit_resfun(name)

            output_file = 'test_tobyfit_resfun.mat';   % filename where saved results are written
            datafile = 'test_tobyfit_resfun_data.mat';
            this = this@TestCaseWithSave(name, output_file);


            % Determine whether or not to save output
            regen_data = false;
            this.save_output = true;

            if regen_data
                data_source = 'T:\data\RbMnF3\sqw\rbmnf3_ref_newformat.sqw'; % sqw file from which to take cuts for setup
                this.gen_data(data_source, datafile);
                return
            end

            % Original data structure
            %{
            orig_datafile = 'test_tobyfit_resfun_1_data.mat');      % filename where saved results are written
            load(orig_datafile.res, 'w2a','wce','w2b');
            %}

            load(datafile,'w2a','wce','w2b')

            ssi = @(x, samp, e) set_sample_and_inst(x,samp,@maps_instrument_obj_for_tests,'-efix',e,'S');

            this.tol = [0.25,1.0,0.1]; % sig, abs, rel
            this.seed = 0;
            this.ilist = 0;

            sample_rb=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
            sample_rb.alatt = [4.2240 4.2240 4.2240];
            sample_rb.angdeg = [90 90 90];


            % Rubidium tests (Resfun)
            this.res_w2a=ssi(w2a,sample_rb,300);
            this.res_wce=ssi(wce,sample_rb,300);
            this.res_w2b=ssi(w2b,sample_rb,300);

            this.fac=[0.25,1,0.1];    % used by comparison function

            if this.save_output
                this.save();
            end
        end


        function this = gen_data(this, data_source, datafile)
            % Generate data and save to outputs


            % Cuts from RbMnF3
            % ----------------

            % q-e plot along [0,0,1]
            w2a = cut_sqw(data_source,proj_rb,[0.45,0.55],[-0.5,0.01,1.5],[-0.05,0.05],[-2,0,12],'-pix');
            % q-q plot
            wce = cut_sqw(data_source,proj_rb,[0,0.01,1],[0,0.01,1],[-0.05,0.05],[5.8,6.2],'-pix');
            % q-e plot along [1,1,0]
            w2b = cut_sqw(data_source,proj_rb,[0,0.01,1],[0.45,0.55],[-0.05,0.05],[-2,0,12],'-pix');


            % Now save to file for future use
            datafile_full = fullfile(tmp_dir,datafile);
            load(datafile,'w2a','wce','w2b');
            % Not including unfinished mosaic tests


            % Original data structure
            %{
            datafile_full = fullfile(tmp_dir,datafile.res);
            save(datafile_full,'w2a','wce','w2b');
            %}
        end

        function this = setUp(this)
            % Force random seed
            this.rng_state = rng(this.seed, 'twister');
            warning('off', 'HERBERT:mask_data_for_fit:bad_points')
        end

        function this = tearDown(this)
            % Undo rand seeding
            rng(this.rng_state);
            warning('on', 'HERBERT:mask_data_for_fit:bad_points')
        end


        %% --------------------------------------------------------------------------------------
        % Test resfun
        % ---------------------------------------------------------------------------------------

        function this = test_resfun_standalone_1(this)
            inst = maps_instrument_obj_for_tests(90,250,'s');
            samp = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);

            det.x2=6;
            det.phi=30;
            det.azim=0;
            det.width=0.0254;
            det.height=0.0367;

            ww1=resolution_plot([12.5,13.5],inst,samp,det,100,1,[3,4,5],[90,90,90],[1,1,0],[0,0,1],24,0,1,2,3);
            assertEqualToTolWithSave(this, ww1,[1e-8,1e-8])

        end

        function this = test_resfun_standalone_2(this)
            inst = maps_instrument_obj_for_tests(90,250,'s');
            samp = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);

            det.x2=6;
            det.phi=30;
            det.azim=0;
            det.width=0.0254;
            det.height=0.0367;

            iax = [1,4];
            ww2=resolution_plot([-0.5,0.5],inst,samp,det,100,1,[3,4,5],[90,90,90],[1,1,0],[0,0,1],24,0,1,2,3, iax);
            assertEqualToTolWithSave(this, ww2,[1e-8,1e-8])

        end

        function this = test_resfun_standalone_3(this)
            inst = maps_instrument_obj_for_tests(90,250,'s');
            samp = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);

            det.x2=6;
            det.phi=30;
            det.azim=0;
            det.width=0.0254;
            det.height=0.0367;

            iax = [1,4];
            ww3=resolution_plot([39.5,40.5],inst,samp,det,100,1,[3,4,5],[90,90,90],[1,1,0],[0,0,1],24,0,1,2,3, iax);
            assertEqualToTolWithSave(this, ww3,[1e-8,1e-8])

        end

        %% --------------------------------------------------------------------------------------
        % Plot resolution functions on a plot of an sqw object
        % ---------------------------------------------------------------------------------------

        function this = test_resfun_sqw_1(this)
            % q-e plot along [0,0,1]
            cov1 = resolution_plot (this.res_w2a, [0.3,6; 0.7,6], 'noplot');
            assertEqualToTolWithSave(this, cov1,[1e-8,1e-8])
        end

        function this = test_resfun_sqw_2(this)
            % q-q plot
            cov2 = resolution_plot (this.res_wce, [0.5,0.3; 0.5,0.7], 'noplot');
            assertEqualToTolWithSave(this, cov2,[1e-8,1e-8])
        end

        function this = test_resfun_sqw_3(this)
            % q-q plot
            cov3 = resolution_plot (this.res_wce, [0.64,0.5; 0.36,0.5], 'noplot');
            assertEqualToTolWithSave(this, cov3,[1e-8,1e-8])
        end

        function this = test_resfun_sqw_4(this)
            % q-e plot along [1,1,0]
            cov4 = resolution_plot (this.res_w2b, [0.36,6; 0.64,6], 'noplot');
            assertEqualToTolWithSave(this, cov4,[1e-8,1e-8])
        end

    end
end
