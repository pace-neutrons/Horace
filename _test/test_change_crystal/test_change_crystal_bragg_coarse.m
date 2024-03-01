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
        alatt=[5, 5, 5];
        par_file
        angdeg=[90, 90, 90];
        u=[1, 0, 0];
        v=[0, 1, 0];
        psi=0:2:10;
        omega=0;
        dpsi=2;
        gl=3;
        gs=-3;

        hpc_restore;
    end

    methods
        function obj = test_change_crystal_bragg_coarse(varargin)
            test_ref_data= fullfile(fileparts(mfilename('fullpath')), 'test_change_crystal_coarse.mat');
            if nargin == 0
                argi = {'test_change_crystal_bragg_coarse', test_ref_data};
            else
                argi = {varargin{1}, test_ref_data};

            end
            obj= obj@TestCaseWithSave(argi{:});

            obj.hpc_restore = set_temporary_config_options(hpc_config, ...
                'build_sqw_in_parallel', false, ...
                'combine_sqw_using', 'mex_code' ...
                );

            % -----------------------------------------------------------------------------
            % Add common functions folder to path, and get location of common data
            pths = horace_paths;
            common_data_dir = pths.test_common;

            % -----------------------------------------------------------------------------
            % generate shifted sqw file
            obj.par_file = fullfile(common_data_dir, 'map_4to1_dec09.par');
            % Parameters for generation of reference sqw file
            obj.dir_out = tmp_dir;

            sim_sqw_file = fullfile(obj.dir_out, 'test_change_crystal_coarse_sim.sqw'); % output file for simulation in reference lattice
            obj = obj.build_misaligned_source_file(sim_sqw_file);

        end
        function test_change_crystal_family_invalid_throw_in_memory(obj)
            sqw_sample = read_sqw(obj.misaligned_sqw_file);
            dnd_sample = sqw_sample.data;

            corrections = crystal_alignment_info([5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], [-0.0530 0.0519 0.0345]);

            assertExceptionThrown(@()change_crystal_dnd({sqw_sample,dnd_sample},corrections), ...
                'HORACE:change_crystal:invalid_argument');

            assertExceptionThrown(@()change_crystal_sqw({sqw_sample,dnd_sample},corrections), ...
                'HORACE:change_crystal:invalid_argument');

            al_obj = change_crystal({sqw_sample,dnd_sample},corrections);

            assertEqualToTol(al_obj{1}.data,al_obj{2})
        end

        function test_change_crystal_family_invalid_throw(obj)
            targ_file = fullfile(tmp_dir,'aligned_copy.sqw');
            clOb = onCleanup(@()delete(targ_file));

            copyfile(obj.misaligned_sqw_file, targ_file, 'f');
            corrections = crystal_alignment_info([5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], [-0.0530 0.0519 0.0345]);

            assertExceptionThrown(@()change_crystal_dnd(targ_file,corrections), ...
                'HORACE:change_crystal:invalid_argument');

            dnd_obj = read_dnd(targ_file);

            dnd_obj1 = change_crystal(dnd_obj,corrections);
            dnd_obj2 = change_crystal_dnd(dnd_obj,corrections);
            assertEqual(dnd_obj1,dnd_obj2)

            save(dnd_obj,targ_file);
            assertExceptionThrown(@()change_crystal_sqw(targ_file,corrections), ...
                'HORACE:change_crystal:invalid_argument');
        end


        function test_u_alignment_tf_way(obj)
            % Fit Bragg peak positions
            % ------------------------
            proj.u=obj.u;
            proj.v=obj.v;

            % theoretical bragg points positions
            bragg_pos=[...
                0, -1, 0; ...
                1,  2, 0; ...
                0, -1, 1];

            % the Bragg points positions found by fitting measured Bragg
            % peaks shape to Gaussian and identifying the Gaussian centrepoints
            % See test_u_alignment_tf_way for the procedure of obtaining
            % them. The operation is:
            %[rlu_real, width, wcut, wpeak]=bragg_positions(obj.misaligned_sqw_file, ...
            %    bp, 1.5, 0.02, 0.4, 1.5, 0.02, 0.4, 2, 'gauss');
            rlu_real = [...
                0.0372, -0.9999, 0.0521;...
                0.9200,  2.0328, -0.1568;...
                0.1047, -0.9425, 1.0459];

            half_len=0.5;
            half_thick=0.25;
            bin_width=0.025;

            %[rlu0, width, wcut, wpeak]=bragg_positions(read_sqw(sim_sqw_file), proj, rlu, half_len, half_thick, bin_width);
            %bragg_positions_view(wcut, wpeak)

            % Get correction matrix from the 3 peak positions:
            % ------------------------------------------------
            alignment_info = refine_crystal(rlu_real, ...
                obj.alatt, obj.angdeg, bragg_pos, ...
                'fix_angdeg', 'fix_alatt_ratio');
            %'fix_lattice');

            % Apply to a copy of the sqw object to see that the alignment is now OK
            % ---------------------------------------------------------------------
            tmp_file_1 = TmpFileHandler('test_change_crystal_coarse_sima_corr.sqw',true);
            sim_sqw_file_corr = tmp_file_1.file_name;

            copyfile(obj.misaligned_sqw_file, sim_sqw_file_corr, 'f')

            change_crystal_sqw(sim_sqw_file_corr, alignment_info);
            rlu0_corr=get_bragg_positions(read_sqw(sim_sqw_file_corr), proj, ...
                bragg_pos, half_len, half_thick, bin_width);

            % problem in
            assertElementsAlmostEqual(bragg_pos, rlu0_corr, 'absolute', half_thick);

            [alatt_c, angdeg_c, dpsi_deg, gl_deg, gs_deg] = ...
                crystal_pars_correct(obj.u, obj.v, obj.alatt, obj.angdeg, ...
                0, 0, 0, 0, alignment_info);

            assertElementsAlmostEqual(alatt_c, obj.alatt, 'absolute', 0.01)
            assertElementsAlmostEqual(angdeg_c, obj.angdeg, 'absolute', 0.01)

            realigned_sqw_file = tmp_file_1.file_name;

            % Generate re-aligned crystal
            gen_sqw (obj.nxs_file, '', realigned_sqw_file, ...
                obj.efix, obj.emode, alatt_c, obj.angdeg, ...
                obj.u, obj.v, obj.psi, 0, dpsi_deg, gl_deg, gs_deg);

            rlu1_corr=get_bragg_positions(read_sqw(realigned_sqw_file), ...
                proj, bragg_pos, half_len, half_thick, bin_width);
            assertElementsAlmostEqual(bragg_pos, rlu1_corr, 'absolute', half_thick);
            assertElementsAlmostEqual(rlu0_corr, rlu1_corr, 'absolute', 0.01);
        end

        function test_finalize_alignment_on_file_same(obj)
            % testing the possibility to align the crystal using
            % finalize_alignment routine on file
            clConf = set_temporary_config_options(hor_config, ...
                'mem_chunk_size', 100000, 'fb_scale_factor', 4);


            tmp_file_1 = TmpFileHandler(obj.misaligned_sqw_file);
            tf_ref_corr = tmp_file_1.file_name;

            tf_ref_al = fullfile(tmp_dir,'test_finalize_alignment_on_file_same.sqw');
            clOb  = onCleanup(@()del_memmapfile_files(tf_ref_al ));


            copyfile(obj.misaligned_sqw_file, tf_ref_corr, 'f');

            corrections = crystal_alignment_info(...
                [5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], ...
                [-0.0530 0.0519 0.0345]);

            % apply new crystal alignment
            change_crystal(tf_ref_corr, corrections);
            copyfile(tf_ref_corr, tf_ref_al, 'f');

            [wout_aligned, corr_rev] = finalize_alignment(tf_ref_al);
            assertEqual(wout_aligned.full_filename,tf_ref_al);

            % ensure we indeed do filebacked algorithm
            assertTrue(wout_aligned.is_filebacked);
            assertFalse(wout_aligned.is_tmp_obj);

            corr_rev.rotvec = -corr_rev.rotvec;
            assertEqualToTol(corrections, corr_rev, 'tol', 1.e-9)

            % test cut ranges:
            cr=[-0.3,-2.0,-0.5,-0.5;...
                +3.5,+4.2,+1.0,+0.5];

            proj = line_proj;
            cut_range = {[cr(1, 1), 0.08, cr(2, 1)], ...
                [cr(1, 2), 0.08, cr(2, 2)], ...
                cr(:, 3)', cr(:, 4)'};

            % test the cut from crystal with alignment and cut with aligned
            % crystal, alignment applied are the same
            cut_cor= cut(tf_ref_corr, proj, cut_range{:});
            assertTrue(cut_cor.is_tmp_obj)
            cut_al = cut(tf_ref_al, proj, cut_range{:});
            assertTrue(cut_al.is_tmp_obj)

            assertEqualToTol(cut_cor, cut_al, 4*eps('single'), 'ignore_str', true);
        end

        function test_finalize_alignment_on_file_keep(obj)
            % testing the possibility to align the crystal using
            % finalize_alignment routine on file
            clConf = set_temporary_config_options(hor_config, ...
                'mem_chunk_size', 100000, 'fb_scale_factor', 4);

            tmp_file_1 = TmpFileHandler(obj.misaligned_sqw_file);
            tf_ref_corr = tmp_file_1.file_name;

            copyfile(obj.misaligned_sqw_file, tf_ref_corr, 'f');


            corrections = crystal_alignment_info(...
                [5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], ...
                [-0.0530 0.0519 0.0345]);

            % apply new crystal alignment
            change_crystal(tf_ref_corr, corrections);
            [wout_aligned, corr_rev] = finalize_alignment(tf_ref_corr, '-keep');
            assertFalse(strcmp(wout_aligned.full_filename,tf_ref_corr));

            % ensure we do filebacked algorithm
            assertTrue(wout_aligned.pix.is_filebacked);

            corr_rev.rotvec = -corr_rev.rotvec;
            assertEqualToTol(corrections, corr_rev, 'tol', 1.e-9)

            % test cut ranges:
            cr=[-0.3, -2.0, -0.5, -0.5;...
                +3.5, +4.2, +1.0, +0.5];

            proj = line_proj;
            cut_range = {...
                [cr(1, 1), 0.08, cr(2, 1)], ...
                [cr(1, 2), 0.08, cr(2, 2)], ...
                cr(:, 3)', cr(:, 4)'};

            cut_cor= cut_sqw(tf_ref_corr, proj, cut_range{:});
            cut_al = cut_sqw(wout_aligned, proj, cut_range{:});
            assertEqualToTol(cut_cor, cut_al, 4*eps('single'), 'ignore_str', true);
        end

        function test_upgrade_legacy_alignment_on_file(obj)
            % testing the possibility to realign the crystal, aligned by
            % legacy algorithm when object stored in sqw file.
            tmp_file_1 = TmpFileHandler(obj.misaligned_sqw_file);
            tf_legacy_al = tmp_file_1.file_name;
            tmp_file_2 = TmpFileHandler(obj.misaligned_sqw_file);
            tf_ref_al = tmp_file_2.file_name;

            copyfile(obj.misaligned_sqw_file, tf_legacy_al, 'f');
            copyfile(obj.misaligned_sqw_file, tf_ref_al, 'f');

            corrections = crystal_alignment_info(...
                [5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], ...
                [-0.0530 0.0519 0.0345]);

            % apply new crystal alignment
            change_crystal(tf_ref_al, corrections);

            % get the crystal aligned according to legacy algorithm.
            corrections.legacy_mode = true;
            change_crystal (tf_legacy_al, corrections);

            upgrade_legacy_alignment(tf_legacy_al, ...
                obj.alatt, obj.angdeg);

            test_obj = read_sqw(tf_legacy_al);
            ref_obj  = read_sqw(tf_ref_al);

            assertEqualToTol(test_obj, ref_obj, 'tol', 1.e-9, 'ignore_str', true)
        end
        function test_pageOp_moves_from_tmp_misaligned_to_tmp_other_obj(obj)
            % Prepare test data
            test_file = build_tmp_file_name(obj.misaligned_sqw_file);
            copyfile(obj.misaligned_sqw_file, test_file, 'f');
            corrections = crystal_alignment_info([5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], [-0.0530 0.0519 0.0345]);

            test_fb = sqw(test_file,'file_backed',true);
            test_fb = test_fb.set_as_tmp_obj();
            assertTrue(test_fb.is_tmp_obj)

            test_fb = change_crystal(test_fb, corrections);

            % test alignment into the same file
            [test_fb_al, corr_rev_fb] = test_fb.finalize_alignment();

            assertTrue(isa(corr_rev_fb,'crystal_alignment_info'))

            % old file was deleted
            assertTrue(is_file(test_file));
            assertTrue(test_fb_al.is_tmp_obj);
            assertTrue(strcmp(test_fb.full_filename,test_file));
            assertFalse(strcmp(test_fb_al.full_filename,test_file));

            clear test_fb;
            % old file deleted.
            assertFalse(is_file(test_file));
            obj_file = test_fb_al.full_filename;
            assertTrue(is_file(obj_file));

            % new file deleted too.
            clear test_fb_al;
            assertFalse(is_file(test_file));
        end

        function test_pageOp_moves_from_tmp_misaligned_to_tmp_same_obj(obj)
            % Prepare test data
            test_file = build_tmp_file_name(obj.misaligned_sqw_file);
            copyfile(obj.misaligned_sqw_file, test_file, 'f');
            corrections = crystal_alignment_info([5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], [-0.0530 0.0519 0.0345]);

            test_fb = sqw(test_file,'file_backed',true);
            test_fb = test_fb.set_as_tmp_obj();
            assertTrue(test_fb.is_tmp_obj)

            test_fb = change_crystal(test_fb, corrections);

            % test alignment into the same file
            [test_fb, corr_rev_fb] = test_fb.finalize_alignment();

            assertTrue(isa(corr_rev_fb,'crystal_alignment_info'))

            % old file was deleted
            assertFalse(is_file(test_file));
            assertTrue(test_fb.is_tmp_obj);
            assertFalse(strcmp(test_fb.full_filename,test_file));

            clear test_fb;
            % new file deleted too.
            assertFalse(is_file(test_file));
        end


        function test_finalize_alignment_moves_from_tmp_misaligned_file(obj)
            targ_file = fullfile(tmp_dir,'aligned_copy.sqw');
            clOb = onCleanup(@()delete(targ_file));

            test_file = build_tmp_file_name(obj.misaligned_sqw_file);

            copyfile(obj.misaligned_sqw_file, test_file, 'f');
            corrections = crystal_alignment_info([5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], [-0.0530 0.0519 0.0345]);

            test_fb = sqw(test_file,'file_backed',true);
            test_fb = test_fb.set_as_tmp_obj();
            assertTrue(test_fb.is_tmp_obj)

            test_fb = change_crystal(test_fb, corrections);

            [test_fb_al, corr_rev_fb] = test_fb.finalize_alignment(targ_file);

            assertTrue(isa(corr_rev_fb,'crystal_alignment_info'))
            assertFalse(test_fb_al.pix.is_misaligned);

            assertTrue(is_file(targ_file));
            assertTrue(test_fb.is_tmp_obj);
            assertEqual(test_fb_al.full_filename,targ_file);
            assertFalse(test_fb_al.is_tmp_obj);
            clear test_fb;
            assertFalse(is_file(test_file));
        end


        function test_finalize_alignment_moves_tmp_aligned_file(obj)
            targ_file = fullfile(tmp_dir,'nonaligned_copy.sqw');
            clOb = onCleanup(@()delete(targ_file));

            tmp_file = build_tmp_file_name(obj.misaligned_sqw_file);

            copyfile(obj.misaligned_sqw_file, tmp_file, 'f');

            test_fb = sqw(tmp_file, 'file_backed', true);
            test_fb = test_fb.set_as_tmp_obj();
            assertTrue(test_fb.is_tmp_obj)

            [test_fb_al, corr_rev_fb] = test_fb.finalize_alignment(targ_file);

            assertTrue(isempty(corr_rev_fb));
            assertTrue(is_file(targ_file));
            assertTrue(test_fb.is_tmp_obj);
            assertEqual(test_fb_al.full_filename,targ_file);
            assertFalse(test_fb_al.is_tmp_obj);
            clear test_fb;
            assertFalse(is_file(tmp_file));
        end

        function test_finalize_alignment_copies_non_aligned_file(obj)
            targ_file = fullfile(tmp_dir,'nonaligned_copy.sqw');
            clOb = onCleanup(@()delete(targ_file));

            test_fb = sqw(obj.misaligned_sqw_file, 'file_backed', true);

            [test_fb_al, corr_rev_fb] = test_fb.finalize_alignment(targ_file);

            assertTrue(isempty(corr_rev_fb));
            assertTrue(is_file(targ_file));
            assertEqual(test_fb_al.full_filename,targ_file);
            assertFalse(test_fb_al.is_tmp_obj);
        end

        function test_finalize_alignment_mem_fb(obj)
            tmp_file_1 = TmpFileHandler(obj.misaligned_sqw_file);
            tf_ref_al = tmp_file_1.file_name;

            copyfile(obj.misaligned_sqw_file, tf_ref_al, 'f');

            test_fb = sqw(tf_ref_al, 'file_backed', true);
            test_mb = test_fb;
            test_mb.pix = PixelDataMemory(test_mb.pix);

            proj = test_mb.data.proj;

            corrections = crystal_alignment_info([5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], [-0.0530 0.0519 0.0345]);
            proj.alatt  = corrections.alatt;
            proj.angdeg = corrections.angdeg;
            test_mb = change_crystal(test_mb, corrections);
            test_fb = change_crystal(test_fb, corrections);

            assertEqualToTol(test_mb, test_fb, 'tol', 1.e-6, 'ignore_str', true);

            [test_mb, corr_rev_mb] = finalize_alignment(test_mb);
            [test_fb, corr_rev_fb] = finalize_alignment(test_fb);

            assertEqualToTol(corr_rev_mb, corr_rev_fb, 'tol', 1.e-6);
            assertEqualToTol(test_mb, test_fb, 'tol', 1.e-6, 'ignore_str', true);

        end

        function test_finalize_alignment_in_mem(obj)
            % testing the possibility to align the crystal using
            % finalize_alignment routine in memory
            test_obj = read_sqw(obj.misaligned_sqw_file);
            proj = test_obj.data.proj;

            corrections = crystal_alignment_info(...
                [5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], ...
                [-0.0530 0.0519 0.0345]);

            proj.alatt = corrections.alatt;
            proj.angdeg = corrections.angdeg;

            wout_corrected = change_crystal(test_obj, corrections);
            [wout_aligned, corr_rev] = finalize_alignment(wout_corrected);

            corr_rev.rotvec = -corr_rev.rotvec;
            assertEqualToTol(corrections, corr_rev, 'tol', 1.e-9)

            % test cut ranges:
            cr = [-0.3,-2.0,-0.5,-0.5;...
                +3.5,+4.2,+1.0,+0.5];

            cut_range = {[cr(1, 1), 0.05, cr(2, 1)], ...
                [cr(1, 2), 0.05, cr(2, 2)], ...
                cr(:, 3)', cr(:, 4)'};

            cut_cor = cut(wout_corrected, proj, cut_range{:});
            cut_al = cut(wout_aligned, proj, cut_range{:});
            assertEqualToTol(cut_cor, cut_al, 'tol', 1.e-9);
        end

        function test_upgrade_legacy_alignment(obj)
            % testing the possibility to realign the crystal, aligned by
            % legacy algorithm.
            test_obj = read_sqw(obj.misaligned_sqw_file);
            alatt0   = test_obj.data.alatt;
            angdeg0  = test_obj.data.angdeg;
            corrections = crystal_alignment_info(...
                [5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], ...
                [-0.0530 0.0519 0.0345]);
            proj = test_obj.data.proj;
            proj = proj.set_ub_inv_compat(inv(proj.bmatrix));

            wout_legacy = test_obj;
            wout_legacy.data.proj = proj;
            % get the crystal aligned according to legacy algorithm.
            wout_legacy = change_crystal (wout_legacy, corrections);

            [obj_realigned, deal_info] = upgrade_legacy_alignment(wout_legacy, ...
                alatt0, angdeg0);

            wout_modern = change_crystal (test_obj, corrections);

            assertEqualToTol(deal_info.rotvec, -corrections.rotvec, 'tol', 1.e-9)
            assertEqual(wout_modern, obj_realigned);
        end

        function test_remove_legacy_keep_lattice_change_fails(obj)
            % testing the possibility to dealign the crystal, aligned by
            % legacy algorithm if original lattice is unknown
            test_obj = read_sqw(obj.misaligned_sqw_file);

            corrections = crystal_alignment_info(...
                [5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], ...
                [-0.0530 0.0519 0.0345]);
            proj = test_obj.data.proj;
            proj = proj.set_ub_inv_compat(inv(proj.bmatrix));

            wout_legacy  = test_obj;
            wout_legacy.data.proj = proj;
            % get the crystal aligned according to legacy algorithm.
            wout_legacy = change_crystal (wout_legacy, corrections);

            [obj_recovered, deal_info] = remove_legacy_alignment(wout_legacy);

            lat_corrections = crystal_alignment_info(...
                [5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], ...
                [0 0 0]);
            wout_lat = change_crystal (test_obj, lat_corrections);

            assertElementsAlmostEqual(deal_info.rotvec, -corrections.rotvec);
            % change legacy without lattice does not properly recover
            % alignment
            obj_recovered.experiment_info = wout_lat.experiment_info;
            obj_recovered.data.proj = wout_lat.data.proj;
            assertEqual(wout_lat, obj_recovered);
        end

        function test_remove_legacy_alignment(obj)
            % testing the possibility to dealign the crystal, aligned by
            % legacy algorithm.
            test_obj = read_sqw(obj.misaligned_sqw_file);
            alatt0 = test_obj.data.alatt;
            angdeg0 = test_obj.data.angdeg;
            corrections = crystal_alignment_info(...
                [5.0191 4.9903 5.0121], ...
                [90.1793 90.9652 89.9250], ...
                [-0.0530 0.0519 0.0345]);
            proj = test_obj.data.proj;
            proj = proj.set_ub_inv_compat(inv(proj.bmatrix));

            wout_legacy  = test_obj;
            wout_legacy.data.proj = proj;
            % get the crystal aligned according to legacy algorithm.
            wout_legacy = change_crystal (wout_legacy, corrections);

            [obj_recovered, deal_info] = remove_legacy_alignment(wout_legacy, ...
                alatt0, angdeg0);

            assertElementsAlmostEqual(deal_info.rotvec, -corrections.rotvec);
            assertEqual(test_obj, obj_recovered);
        end

        function test_legacy_vs_pix_alignment(obj)
            % theoretical Bragg points positions
            bragg_pos=[...
                0, -1, 0; ...
                1, 2, 0; ...
                0, -1, 1];

            fit_obj = read_sqw(obj.misaligned_sqw_file);
            % the Bragg points positions found by fitting measured Bragg
            % peaks shape to Gaussian and identifying the Gaussian centerpoints
            % See test_u_alignment_tf_way for the procedure of obtaining
            % them
            rlu_real = [...
                0.0372, -0.9999, 0.0521;...
                0.9200, 2.0328, -0.1568;...
                0.1047, -0.9425, 1.0459];


            % Get correction matrix from the 3 peak positions:
            % ------------------------------------------------
            corr = refine_crystal(rlu_real, ...
                obj.alatt, obj.angdeg, bragg_pos);

            proj = fit_obj.data.proj;
            proj = proj.set_ub_inv_compat(inv(proj.bmatrix));
            wout_legacy = fit_obj;
            wout_legacy.data.proj = proj;
            wout_legacy = change_crystal (wout_legacy, corr);

            wout_align = change_crystal (fit_obj, corr);

            pix_sample  = PixelDataMemory(eye(9));
            pix_aligned = pix_sample;
            pix_aligned.alignment_matr = wout_align.pix.alignment_matr;

            pix_leg = wout_legacy.data.proj.transform_pix_to_img(pix_sample);
            pix_al  = wout_align.data.proj.transform_pix_to_img(pix_aligned);
            assertElementsAlmostEqual(pix_al, pix_leg);

            proj_leg = wout_legacy.data.proj;

            % This is not correct and should not. One projection contains
            % alignment matrix attached to B-matrix and another one does not
            % (alignment is on pixels only)
            %mix_cut_range = wout_legacy.targ_range(proj_al);
            %assertElementsAlmostEqual(mix_cut_range, al_cut_range);

            % test cut ranges:
            cr = [-0.3, -2, -1.8, -0.5;3.5, 4.2, 2, 0.5];

            cut_old1d  = cut(wout_legacy, proj_leg, [cr(1, 1), 0.05, cr(2, 1)], cr(:, 2)', cr(:, 3)', cr(:, 4)');
            cut_new1d  = cut(wout_align, proj_leg, [cr(1, 1), 0.05, cr(2, 1)], cr(:, 2)', cr(:, 3)', cr(:, 4)');

            assertEqual(cut_old1d.experiment_info.n_runs, ...
                cut_new1d.experiment_info.n_runs)
            % old alignment changes the direction of cu, cv components and
            % new one does not so they can not be compared directly.
            cut_old1d.experiment_info = cut_new1d.experiment_info;
            % images look the same but pixels remain misaligned in old cut
            % and aligned afer new cut so you can not do direct comparison
            assertEqualToTol(cut_old1d.data, cut_new1d.data);

            ranges = {[cr(1, 1), 0.05, cr(2, 1)], [cr(1, 2), 0.1, cr(2, 2)], [cr(1, 3), 0.1, cr(2, 3)], [cr(1, 4), 0.1, cr(2, 4)]};
            cut_old = cut(wout_legacy, proj_leg, ranges{:});
            cut_new = cut(wout_align, proj_leg, ranges{:});

            assertEqual(cut_old.experiment_info.n_runs, ...
                cut_new.experiment_info.n_runs)
            % old alignment changes the direction of cu, cv components and
            % new one does not so they can not be compared directly. Yet!
            cut_old.experiment_info = cut_new.experiment_info;
            assertEqualToTol(cut_old.data, cut_new.data);

        end

        function test_bragg_pos(obj)
            bragg_pos= [...
                0, -1, 0; ...
                1, 2, 0; ...
                0, -1, 1];

            radial_cut_length = 1.5;
            radial_bin_width  = 0.02;
            radial_thickness  = 0.4;
            trans_cut_length = 1.5;
            trans_bin_width  = 0.02;
            trans_thickness  = 2;

            [rlu_real, width, wcut, wpeak]=bragg_positions(obj.misaligned_sqw_file, ...
                bragg_pos, radial_cut_length, radial_bin_width, radial_thickness, ...
                trans_cut_length, trans_bin_width, trans_thickness, 'gauss');

            rlu_sample = ...
                [0.04   -0.9999    0.05;...
                0.90     2.       -0.16;...
                0.10    -0.95       1.0];
            assertElementsAlmostEqual(rlu_real, rlu_sample, 'absolute', 1.e-1);
            width_sample = ...
                [0.1    0.1    0.1;...
                0.18    0.13   0.1;...
                0.1     0.07   0.1];
            assertElementsAlmostEqual(width, width_sample, 'absolute', 1.e-1);
            % contains path, so need no-string comparison
            assertEqualToTolWithSave(obj, wcut, 1.e-6, 'ignore_str', true);
            assertEqualToTolWithSave(obj, wpeak, 1.e-6, 'ignore_str', true);
        end

        function delete(obj)
            clob = set_temporary_warning('off', 'MATLAB:DELETE:Permission');
            delete(obj.misaligned_sqw_file);
            % Delete temporary nxs files
            for i=1:numel(obj.nxs_file)
                try
                    delete(obj.nxs_file{i})
                catch
                end
            end
        end
    end

    methods(Access=private)

        function  obj=build_misaligned_source_file(obj, sim_sqw_file)
            % generate sqw file misaligned according to wrong gl, gs, dpsi.
            %
            obj.misaligned_sqw_file = sim_sqw_file;

            clob = set_temporary_config_options(hpc_config, ...
                'combine_sqw_using', 'matlab', ...
                'build_sqw_in_parallel', false ...
                );

            obj.nxs_file =cell(size(obj.psi));
            nxs_file_exist = true;
            for i=1:numel(obj.psi)
                obj.nxs_file{i} = fullfile(obj.dir_out, ['dummy_test_change_crystal_coarse_', num2str(i), '.nxspe']);

                if ~is_file(obj.nxs_file{i})
                    nxs_file_exist = false;
                end
            end

            if is_file(sim_sqw_file) && is_file(obj.nxs_file{1}) && is_file(obj.nxs_file{end})
                return;
            end

            qfwhh=0.1;                % Spread of Bragg peaks
            efwhh=1;                  % Energy width of Bragg peaks
            rotvec=[0, 0, 0]*(pi/180);  % orientation of the true lattice w.r.t reference lattice

            if ~nxs_file_exist

                % Create sqw file for refinement testing
                % --------------------------------------
                pix_range = calc_sqw_pix_range (obj.efix, obj.emode, ...
                    obj.en(1), obj.en(end), obj.par_file, obj.alatt, obj.angdeg, ...
                    obj.u, obj.v, obj.psi, obj.omega, obj.dpsi, obj.gl, obj.gs);

                for i=1:numel(obj.psi)
                    sqw_obj = dummy_sqw (obj.en, obj.par_file, '', obj.efix, ...
                        obj.emode, obj.alatt, obj.angdeg, ...
                        obj.u, obj.v, obj.psi(i), obj.omega, ...
                        obj.dpsi, obj.gl, obj.gs, [1, 1, 1, 1], pix_range);
                    % Simulate cross-section on every the sqw file: place blobs at Bragg positions of the true lattice
                    sqw_obj=sqw_eval(sqw_obj{1}, @make_bragg_blobs, ...
                        {[1, qfwhh, efwhh], [obj.alatt, obj.angdeg], ...
                        [obj.alatt, obj.angdeg], rotvec});
                    % mainly to propagate errors as sqw_eval nullified errors?
                    npix = sqw_obj.pix.num_pixels;
                    sqw_obj.pix.variance = ones(1, npix);
                    sqw_obj=recompute_bin_data(sqw_obj);
                    % convert to nxspe (instrument view)
                    rdo = rundatah(sqw_obj);
                    rdo.saveNXSPE(obj.nxs_file{i});
                end
            end

            % Generate misaligned sqw file, with gl gs dpsi =0
            if ~is_file(sim_sqw_file)
                gen_sqw (obj.nxs_file, '', sim_sqw_file, ...
                    obj.efix, obj.emode, obj.alatt, obj.angdeg, ...
                    obj.u, obj.v, obj.psi, 0, 0, 0, 0);
            end
        end
    end
end
