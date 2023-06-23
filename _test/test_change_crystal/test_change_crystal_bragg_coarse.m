classdef test_change_crystal_bragg_coarse < TestCaseWithSave
    % Test crystal refinement functions change_crytstal and refine_crystal
    %
    %
    properties
        %
        dir_out
        misaligned_sqw_file
        nxs_file;
        %
        %
        % Data for creation of test sqw file
        % ----------------------------------
        efix = 45;
        emode = 1;
        en=-0.75:0.5:0.75;
        alatt=[5,5,5];
        par_file
        angdeg=[90,90,90];
        u=[1,0,0];
        v=[0,1,0];
        psi=0:2:10;
        omega=0; dpsi=2; gl=3; gs=-3;

        hpc_restore;
    end
    properties(Access=private)
        clob % cleanup object
    end
    methods
        function obj = test_change_crystal_bragg_coarse(varargin)
            test_ref_data= fullfile(fileparts(mfilename('fullpath')),'test_change_crystal_coarse.mat');
            if nargin == 0
                argi = {'test_change_crystal_bragg_coarse',test_ref_data};
            else
                argi = {varargin{1},test_ref_data};

            end
            obj= obj@TestCaseWithSave(argi{:});
            %
            hpc = hpc_config;
            obj.hpc_restore = hpc.get_data_to_store;
            hpc.saveable = false;

            % -----------------------------------------------------------------------------
            % Add common functions folder to path, and get location of common data
            pths = horace_paths;
            common_data_dir = pths.test_common;
            % -----------------------------------------------------------------------------
            % generate shifted sqw file
            obj.par_file=fullfile(common_data_dir,'map_4to1_dec09.par');
            % Parameters for generation of reference sqw file
            obj.dir_out=tmp_dir;

            sim_sqw_file=fullfile(obj.dir_out,'test_change_crystal_coarse_sim.sqw'); % output file for simulation in reference lattice
            obj=obj.build_misaligned_source_file(sim_sqw_file);
            %
            obj.save();
        end
        function setUp(~)
            hpc = hpc_config;
            hpc.saveable = false;
            hpc.build_sqw_in_parallel=0;
            hpc.combine_sqw_using = 'mex_code';
        end
        %
        function test_u_alighnment_tf_way(obj)
            % Fit Bragg peak positions
            % ------------------------
            proj.u=obj.u;
            proj.v=obj.v;

            % theoretical bragg points positions
            bragg_pos=[...
                0, -1,  0; ...
                1,  2,  0; ...
                0, -1,  1];

            % the Bragg points positions found by fitting measured Bragg
            % peaks shape to Gaussian and identifying the Gaussian centerpoints
            % See test_u_alighnment_tf_way for the procedure of obtaining
            % them. The operation is:
            %[rlu_real,width,wcut,wpeak]=bragg_positions(obj.misaligned_sqw_file,...
            %    bp, 1.5, 0.02, 0.4, 1.5, 0.02, 0.4, 2, 'gauss');
            rlu_real = [...
                0.0372,-0.9999, 0.0521;...
                0.9200, 2.0328,-0.1568;...
                0.1047,-0.9425, 1.0459];


            half_len=0.5; half_thick=0.25; bin_width=0.025;

            %[rlu0,width,wcut,wpeak]=bragg_positions(read_sqw(sim_sqw_file), proj, rlu, half_len, half_thick, bin_width);
            %bragg_positions_view(wcut,wpeak)


            % Get correction matrix from the 3 peak positions:
            % ------------------------------------------------
            alignment_info = refine_crystal(rlu_real,...
                obj.alatt, obj.angdeg, bragg_pos,...
                'fix_angdeg','fix_alatt_ratio');
            %'fix_lattice');



            % Apply to a copy of the sqw object to see that the alignment is now OK
            % ---------------------------------------------------------------------
            sim_sqw_file_corr=fullfile(obj.dir_out,'test_change_crystal_coarse_sima_corr.sqw'); % output file for correction
            copyfile(obj.misaligned_sqw_file,sim_sqw_file_corr)
            cleanup_obj=onCleanup(@()delete(sim_sqw_file_corr));

            change_crystal_sqw(sim_sqw_file_corr,alignment_info)
            rlu0_corr=get_bragg_positions(read_sqw(sim_sqw_file_corr), proj,...
                bragg_pos, half_len, half_thick, bin_width);

            % problem in
            assertElementsAlmostEqual(bragg_pos,rlu0_corr,'absolute',half_thick);
            %
            [alatt_c, angdeg_c, dpsi_deg, gl_deg, gs_deg] = ...
                crystal_pars_correct (obj.u, obj.v, obj.alatt, obj.angdeg, ...
                0, 0, 0, 0, alignment_info);
            %
            %
            assertElementsAlmostEqual(alatt_c,obj.alatt,'absolute',0.01)
            assertElementsAlmostEqual(angdeg_c,obj.angdeg,'absolute',0.01)
            %
            realigned_sqw_file=fullfile(obj.dir_out,'test_change_crystal_coarse_sima_realigned.sqw'); % output file for correction
            cleanup_obj1=onCleanup(@()delete(realigned_sqw_file));

            % Generate re-aligned crystal
            gen_sqw (obj.nxs_file, '', realigned_sqw_file, ...
                obj.efix, obj.emode, alatt_c, obj.angdeg,...
                obj.u, obj.v, obj.psi, 0, dpsi_deg, gl_deg, gs_deg);

            rlu1_corr=get_bragg_positions(read_sqw(realigned_sqw_file), ...
                proj, bragg_pos, half_len, half_thick, bin_width);
            assertElementsAlmostEqual(bragg_pos,rlu1_corr,'absolute',half_thick);
            assertElementsAlmostEqual(rlu0_corr,rlu1_corr,'absolute',0.01);
        end
        function test_legacy_vs_pix_alignment(obj)
            % theoretical Bragg points positions
            bragg_pos=[...
                0, -1,  0; ...
                1,  2,  0; ...
                0, -1,  1];

            fit_obj = read_sqw(obj.misaligned_sqw_file);
            % the Bragg points positions found by fitting measured Bragg
            % peaks shape to Gaussian and identifying the Gaussian centerpoints
            % See test_u_alighnment_tf_way for the procedure of obtaining
            % them
            rlu_real = [...
                0.0372,-0.9999, 0.0521;...
                0.9200, 2.0328,-0.1568;...
                0.1047,-0.9425, 1.0459];


            % Get correction matrix from the 3 peak positions:
            % ------------------------------------------------
            corr = refine_crystal(rlu_real,...
                obj.alatt, obj.angdeg, bragg_pos);

            proj = fit_obj.data.proj;
            proj = proj.set_ub_inv_compat(inv(proj.bmatrix));
            wout_legacy = fit_obj;
            wout_legacy.data.proj = proj;
            wout_legacy = change_crystal (wout_legacy,corr);

            wout_align = change_crystal (fit_obj,corr);

            pix_sample  = PixelDataMemory(eye(9));
            pix_aligned = pix_sample;
            pix_aligned.alignment_matr = wout_align.pix.alignment_matr;

            pix_leg = wout_legacy.data.proj.transform_pix_to_img(pix_sample);
            pix_al  = wout_align.data.proj.transform_pix_to_img(pix_aligned);
            assertElementsAlmostEqual(pix_al,pix_leg);

            proj_leg = wout_legacy.data.proj;
            leg_cut_range = wout_legacy.targ_range(proj_leg);

            proj_al = wout_align.data.proj;
            al_cut_range = wout_align.targ_range(proj_al);
            assertElementsAlmostEqual(leg_cut_range,al_cut_range);

            % This is not correct and should not. One projection contains
            % alignment matrix attached to B-matrix and another one does not
            % (alignment is on pixels only)
            %mix_cut_range = wout_legacy.targ_range(proj_al);
            %assertElementsAlmostEqual(mix_cut_range,al_cut_range);

            % test cut ranges:
            cr = [-0.3,-2,-1.8,-0.5;3.5,4.2,2,0.5];

            cut_old1d = cut(wout_legacy,proj_leg,[cr(1,1),0.05,cr(2,1)],cr(:,2)',cr(:,3)',cr(:,4)');
            cut_new1d  = cut(wout_align,proj_leg,[cr(1,1),0.05,cr(2,1)],cr(:,2)',cr(:,3)',cr(:,4)');

            assertEqual(cut_old1d.experiment_info.n_runs, ...
                cut_new1d.experiment_info.n_runs)
            % old alignment changes the direction of cu,cv components and
            % new one does not so they can not be compared directly.
            cut_old1d.experiment_info = cut_new1d.experiment_info;

            assertEqualToTol(cut_old1d,cut_new1d);

            ranges = {[cr(1,1),0.05,cr(2,1)],[cr(1,2),0.1,cr(2,2)],[cr(1,3),0.1,cr(2,3)],[cr(1,4),0.1,cr(2,4)]};
            cut_old = cut(wout_legacy,proj_leg,ranges{:});
            cut_new = cut(wout_align,proj_leg,ranges{:});

            assertEqual(cut_old.experiment_info.n_runs, ...
                cut_new.experiment_info.n_runs)
            % old alignment changes the direction of cu,cv components and
            % new one does not so they can not be compared directly. Yet!
            cut_old.experiment_info = cut_new.experiment_info;
            assertEqualToTol(cut_old,cut_new);

        end
        %
        function test_bragg_pos(obj)
            bragg_pos= [...
                0, -1,  0; ...
                1,  2,  0; ...
                0, -1,  1];

            radial_cut_length = 1.5;
            radial_bin_width  = 0.02;
            radial_thickness  = 0.4;
            trans_cut_length = 1.5;
            trans_bin_width  = 0.02;
            trans_thickness  = 2;

            [rlu_real,width,wcut,wpeak]=bragg_positions(obj.misaligned_sqw_file,...
                bragg_pos,radial_cut_length,radial_bin_width, radial_thickness,...
                trans_cut_length,trans_bin_width ,trans_thickness, 'gauss');

            rlu_sample = ...
                [0.04   -0.9999    0.05;...
                0.90     2.       -0.16;...
                0.10    -0.95       1.0];
            assertElementsAlmostEqual(rlu_real,rlu_sample,'absolute',1.e-1);
            width_sample = ...
                [0.1    0.1    0.1;...
                0.18    0.13   0.1;...
                0.1     0.07   0.1];
            assertElementsAlmostEqual(width,width_sample,'absolute',1.e-1);
            % contains path, so need no-string comparison
            assertEqualToTolWithSave(obj,wcut,4.e-12,'ignore_str',true);
            assertEqualToTolWithSave(obj,wpeak,4.e-12,'ignore_str',true);
        end
        %------------------------------------------------------------------
        function delete(obj)
            %
            hpc = hpc_config;
            set(hpc,obj.hpc_restore);
            hpc.saveable = true;

            ws = warning('off','MATLAB:DELETE:Permission');

            delete(obj.misaligned_sqw_file);

            % Delete temporary nxs files
            for i=1:numel(obj.nxs_file)
                try
                    delete(obj.nxs_file{i})
                catch
                end
            end
            warning(ws);
        end

    end
    methods(Access=private)
        %
        function  obj=build_misaligned_source_file(obj,sim_sqw_file)
            % generate sqw file misaligned according to wrong gl, gs,dpsi.
            %

            obj.misaligned_sqw_file = sim_sqw_file;

            hpc = hpc_config;
            hpc_ds = hpc.get_data_to_store;
            clob2 = onCleanup(@()set(hpc_config,hpc_ds));
            hpc.combine_sqw_using = 'matlab';
            hpc.build_sqw_in_parallel = 0;

            obj.nxs_file =cell(size(obj.psi));
            nxs_file_exist = true;
            for i=1:numel(obj.psi)
                obj.nxs_file{i}=fullfile(obj.dir_out,['dummy_test_change_crystal_coarse_',num2str(i),'.nxspe']);
                if ~(exist(obj.nxs_file{i},'file')==2)
                    nxs_file_exist = false;
                end
            end

            if is_file(sim_sqw_file) && is_file(obj.nxs_file{1}) && is_file(obj.nxs_file{end})
                return;
            end

            qfwhh=0.1;                % Spread of Bragg peaks
            efwhh=1;                  % Energy width of Bragg peaks
            rotvec=[0,0,0]*(pi/180);  % orientation of the true lattice w.r.t reference lattice


            if ~nxs_file_exist

                % Create sqw file for refinement testing
                % --------------------------------------
                pix_range = calc_sqw_pix_range (obj.efix, obj.emode,...
                    obj.en(1), obj.en(end), obj.par_file, obj.alatt, obj.angdeg,...
                    obj.u, obj.v, obj.psi, obj.omega, obj.dpsi, obj.gl, obj.gs);

                for i=1:numel(obj.psi)
                    sqw_obj = dummy_sqw (obj.en, obj.par_file, '', obj.efix,...
                        obj.emode, obj.alatt, obj.angdeg,...
                        obj.u, obj.v, obj.psi(i), obj.omega, ...
                        obj.dpsi, obj.gl, obj.gs, [1,1,1,1], pix_range);
                    % Simulate cross-section on every the sqw file: place blobs at Bragg positions of the true lattice
                    sqw_obj=sqw_eval(sqw_obj{1},@make_bragg_blobs,...
                        {[1,qfwhh,efwhh],[obj.alatt,obj.angdeg],...
                        [obj.alatt,obj.angdeg],rotvec});
                    % mainly to propagate errors as sqw_eval nullified errors?
                    npix = sqw_obj.pix.num_pixels;
                    sqw_obj.pix.variance = ones(1,npix);
                    sqw_obj=recompute_bin_data(sqw_obj);
                    % convert to nxspe (instrument view)
                    rdo = rundatah(sqw_obj);
                    rdo.saveNXSPE(obj.nxs_file{i});
                end
            end

            % Generate misaligned sqw file, with gl gs dpsi =0
            if ~(exist(sim_sqw_file,'file')==2)
                gen_sqw (obj.nxs_file, '', sim_sqw_file, ...
                    obj.efix, obj.emode, obj.alatt, obj.angdeg,...
                    obj.u, obj.v, obj.psi, 0, 0, 0, 0);
            end

        end
    end
end
