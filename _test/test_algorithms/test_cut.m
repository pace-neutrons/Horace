classdef test_cut < TestCase
    % Testing cuts and comparing the results against the reference cuts.
    %
    % This is a non-standard test class, as it compares cut
    % against saved reference, but the reference is not saved as .mat file
    % as in normal TestCaseWithSave classes, but stored as binary sqw file.
    %
    % The interface made similar to TestCaseWithSave classes but is a bit simpler:
    % If the constructor is called with '-save' option, the reference cut
    % is generated afresh.
    % The tests are run and compared against reference cut regardless of
    % '-save' option provided as input to the constructor.
    % Reference cut is generated in the constructor if '-save' option is
    % provided
    properties
        FLOAT_TOL = 1e-5;

        sqw_file = '../test_sym_op/test_cut_sqw_sym.sqw';
        dnd_file = '../common_data/w1d_d1d.sqw';
        ref_cut_file = 'test_cut_ref_sqw.sqw'
        ref_params = { ...
            line_proj([1, -1 ,0], [1, 1, 0]/sqrt(2), 'offset', [1, 1, 0], 'type', 'paa'), ...
            [-0.1, 0.025, 0.1], ...
            [-0.1, 0.025, 0.1], ...
            [-0.1, 0.1], ...
            [105, 1, 114], ...
            };
        sqw_4d;
        working_dir;
        old_ws;
    end

    methods

        function obj = test_cut(varargin)
            save_reference = false;
            if nargin == 0
                name = 'test_cut';
            else
                if strcmpi(varargin{1},'-save')
                    save_reference = true;
                    name = 'test_cut';
                else
                    name = varargin{1};
                    if nargin>1 && strcmpi(varargin{2},'-save')
                        save_reference = true;
                    end
                end
            end
            obj = obj@TestCase(name);
            obj.sqw_4d = read_sqw(obj.sqw_file);
            obj.working_dir = tmp_dir();
            obj.old_ws = warning('off','HORACE:old_file_format');

            if save_reference
                fprintf('*** Rebuilding and overwriting reference cut file %s\n',...
                    obj.ref_cut_file);
                sqw_cut = cut(obj.sqw_file, obj.ref_params{:});
                save(sqw_cut,obj.ref_cut_file);
            end
        end

        function test_cut_sqw_file_single_chunk(obj)
            % Really large file V2 on disk to ensure that ranges are
            % calculated using filebased algorithm rather than all data
            % loaded in memory.
            %v2large_file= 'c:\Users\abuts\Documents\Data\Fe\Data\sqw\Fe_ei1371_base_a.sqw';
            %sqw_cut = cut(v2large_file, obj.ref_params{:});

            mem_chunk_size = 8000;
            cleanup_hor_config = set_temporary_config_options( ...
                hor_config, ...
                'mem_chunk_size', mem_chunk_size, ...
                'use_mex', true ...
                );

            sqw_cut = cut(obj.sqw_file, obj.ref_params{:});

            ref_sqw = read_sqw(obj.ref_cut_file);
            assertEqualToTol(sqw_cut, ref_sqw, obj.FLOAT_TOL, ...
                'ignore_str', true,'-ignore_date');
        end
        function test_cut_bin_given(obj)
            ref_sqw = read_sqw(obj.ref_cut_file);
            cut_sqw = cut(ref_sqw,0.025,3*0.025,2);

            assertEqualToTol(ref_sqw.data.img_range ,cut_sqw.data.img_range,obj.FLOAT_TOL);
            assertEqualToTol(ref_sqw.data.p{1} ,cut_sqw.data.p{1},obj.FLOAT_TOL);
        end


        function test_cut_default_ranges(obj)
            ref_sqw = read_sqw(obj.ref_cut_file);
            cut_sqw = cut(ref_sqw,[-0.05,0.05],[-0.05,0.05],[]);

            assertEqual(ref_sqw.data.p{3},cut_sqw.data.p{1});
        end


        function test_cut_sqw_object(obj)
            %sqw_obj = read_sqw(obj.sqw_file);
            sqw_obj = obj.sqw_4d; % it has already been read in constructor
            ref_par = obj.ref_params;
            sqw_cut = cut(sqw_obj,ref_par{:});

            % offset is currently expressed in hkl
            assertElementsAlmostEqual(sqw_cut.data.offset,obj.ref_params{1}.offset);

            ref_sqw = read_sqw(obj.ref_cut_file);

            assertEqualToTol(sqw_cut, ref_sqw, obj.FLOAT_TOL, ...
                'ignore_str', true,'-ignore_date');

        end

        function test_cut_sqw_object_mb_fb(obj)
            mem_chunk_size = 10000;
            cleanup_config_handle = set_temporary_config_options(hor_config, 'mem_chunk_size', mem_chunk_size);

            sqw_obj = obj.sqw_4d;
            ref_par = obj.ref_params;

            sqw_obj.pix = PixelDataFileBacked(sqw_obj.pix);
            sqw_cut_fb = cut(sqw_obj,ref_par{:});

            sqw_obj.pix = PixelDataMemory(sqw_obj.pix);
            sqw_cut_mb = cut(sqw_obj,ref_par{:});

            % Pix are in different order due to paged application in FileBacked
            % Can only compare binned data here
            assertEqualToTol(sqw_cut_mb.data, sqw_cut_fb.data, ...
                obj.FLOAT_TOL, 'ignore_str', true);

        end
        function test_cut_sqw_with_pix_in_memory_advanced_logging(obj)
            diary_file1 = fullfile(tmp_dir,'advanced_logging_pix_test_level0.txt');
            clFile1 = onCleanup(@()delete(diary_file1));
            diary_file2 = fullfile(tmp_dir,'advanced_logging_pix_test_level2.txt');
            clFile2 = onCleanup(@()delete(diary_file2));
            clConfig = set_temporary_config_options(hor_config,'log_level',0);
            diary(diary_file1);
            sqw_cut = cut(obj.sqw_4d, obj.ref_params{:});
            assertTrue(isfile(diary_file1));
            diary off;
            clConfig2 = set_temporary_config_options(hor_config,'log_level',2);
            diary(diary_file2);
            sqw_cut = cut(obj.sqw_4d, obj.ref_params{:});
            assertTrue(isfile(diary_file2));
            diary off;

            log_1 = fileread(diary_file1);
            log_2 = fileread(diary_file2);
            assertTrue(numel(log_2)> numel(log_1))
            assertFalse(contains(log_1,'Access speed'))
            assertTrue(contains(log_2,'Access speed'))
        end

        function test_cut_sqw_with_pix_advanced_logging(obj)
            diary_file1 = fullfile(tmp_dir,'advanced_logging_pix_test_level0.txt');
            clFile1 = onCleanup(@()delete(diary_file1));
            diary_file2 = fullfile(tmp_dir,'advanced_logging_pix_test_level2.txt');
            clFile2 = onCleanup(@()delete(diary_file2));
            clConfig = set_temporary_config_options(hor_config,'log_level',0);
            diary(diary_file1);
            sqw_cut = cut(obj.sqw_file, obj.ref_params{:});
            assertTrue(isfile(diary_file1));
            diary off;
            clConfig2 = set_temporary_config_options(hor_config,'log_level',2);
            diary(diary_file2);
            sqw_cut = cut(obj.sqw_file, obj.ref_params{:});
            assertTrue(isfile(diary_file2));
            diary off;

            log_1 = fileread(diary_file1);
            log_2 = fileread(diary_file2);
            assertTrue(numel(log_2)> numel(log_1))
            assertFalse(contains(log_1,'Read speed'))
            assertTrue(contains(log_2,'Read speed'))
        end

        function test_cut_sqw_nopix_advanced_logging(obj)
            diary_file1 = fullfile(tmp_dir,'advanced_logging_nopix_test_level0.txt');
            clFile1 = onCleanup(@()delete(diary_file1));
            diary_file2 = fullfile(tmp_dir,'advanced_logging_nopix_test_level2.txt');
            clFile2 = onCleanup(@()delete(diary_file2));
            clConfig1 = set_temporary_config_options(hor_config,'log_level',0);
            diary(diary_file1);
            sqw_cut = cut(obj.sqw_file, obj.ref_params{:}, '-nopix');
            assertTrue(isfile(diary_file1));
            diary off;
            clConfig2 = set_temporary_config_options(hor_config,'log_level',2);
            diary(diary_file2);
            sqw_cut = cut(obj.sqw_file, obj.ref_params{:}, '-nopix');
            assertTrue(isfile(diary_file2));
            diary off;

            log_1 = fileread(diary_file1);
            log_2 = fileread(diary_file2);
            assertTrue(numel(log_2)> numel(log_1))
            assertFalse(contains(log_1,'Read speed'))
            assertTrue(contains(log_2,'Read speed'))
            assertTrue(contains(log_2,'Resulting pix preparation:   0.0%'))
        end


        function test_cut_sqw_nopix(obj)
            sqw_cut = cut(obj.sqw_file, obj.ref_params{:}, '-nopix');

            ref_sqw = read_dnd(obj.ref_cut_file);
            assertEqualToTol(sqw_cut, ref_sqw, obj.FLOAT_TOL, 'ignore_str', true);
        end

        function test_cut_sqw_array(obj)
            sqw_obj1 = sqw(obj.sqw_file);
            sqw_obj2 = sqw(obj.sqw_file);

            out_sqw = cut([sqw_obj1, sqw_obj2], obj.ref_params{:});
            assertEqualToTol(out_sqw(1), out_sqw(2),'-ignore_date');
        end

        function test_cut_sqw_integrating_multi_axes(obj)
            proj = line_proj([1, -1 ,0], [1, 1, 0], 'offset', [1, 1, 0], 'type', 'paa');

            u_axis_lims = [-0.1, 0.025, 0.1];
            v_axis_lims = [-0.1, 0.1];
            w_axis_lims = [-0.1, 0.1];
            en_axis_lims = [105, 1, 114];

            dnd_cut = cut(...
                obj.sqw_file, proj, u_axis_lims, v_axis_lims, w_axis_lims, ...
                en_axis_lims, '-nopix' ...
                );

            assertEqual(numel(dnd_cut.pax), 2);
        end

        function test_cut_sqw_file_to_file(obj)
            mem_chunk_size = 500;
            clWarn = set_temporary_warning('off', ...
                'HOR_CONFIG:set_mem_chunk_size','HORACE:physical_memory_configured');

            cleanup_hor_config = set_temporary_config_options( ...
                hor_config, ...
                'mem_chunk_size', mem_chunk_size, ...
                'fb_scale_factor',3, ...
                'use_mex',false ...
                );

            outfile = fullfile(obj.working_dir, 'cut_sqw_file_to_file_out.sqw');
            cleanup = onCleanup(@()del_memmapfile_files(outfile));

            ret_sqw = cut(obj.sqw_file, obj.ref_params{:}, outfile);
            clear cleanup_hor_config;
            runid = unique(ret_sqw.pix.run_idx);
            assertEqual(runid,ret_sqw.experiment_info.expdata.get_run_ids());

            loaded_cut = read_sqw(outfile);

            assertEqualToTol(ret_sqw, loaded_cut, obj.FLOAT_TOL, 'ignore_str', true);
        end

        function test_cut_sqw_file_to_file_combined_mex(obj)
            [~, ~, can_combine_with_mex] = check_horace_mex();
            if ~can_combine_with_mex
                skipTest('Combinbing with mex is not available on this system')
            end

            mem_chunk_size = 500;
            clWarn = set_temporary_warning('off', ...
                'HOR_CONFIG:set_mem_chunk_size', ...
                'HORACE:physical_memory_configured', ...
                'HORACE:insufficient_physical_memory');

            cleanup_hor_config = set_temporary_config_options( ...
                hor_config, ...
                'mem_chunk_size', mem_chunk_size, ...
                'fb_scale_factor',3,...
                'use_mex', true ...
                );

            cleanup_hpc_config = set_temporary_config_options( ...
                hpc_config, ...
                'combine_sqw_using', 'mex' ...
                );

            ref_obj= copy(obj.sqw_4d); % it has been read in constructor

            ref_tfile = fullfile(obj.working_dir, 'mex_combine_source_from_file_to_file.sqw');
            rf_cleanup = onCleanup(@()del_memmapfile_files(ref_tfile ));
            save(ref_obj,ref_tfile);

            % test filebased cut
            outfile = fullfile(obj.working_dir, 'mex_combine_cut_from_file_to_file.sqw');
            clear_targ_file = onCleanup(@()del_memmapfile_files(outfile));
            cut(ref_tfile, obj.ref_params{:}, outfile);
            clear cleanup_hor_config;


            loaded_cut = read_sqw(outfile);

            % reference memory-based cut
            ref_par = obj.ref_params;
            ref_cut = cut(ref_obj,ref_par{:});

            assertEqualToTol(ref_cut, loaded_cut, obj.FLOAT_TOL, ...
                'ignore_str', true,'-ignore_date');
            % clear custom hpc_config first to avoid warnings
            clear cleanup_hpc_config;

        end


        function test_cut_sqw_file_to_sqw_file_combined_nomex(obj)
            mem_chunk_size = 500;
            clWarn = set_temporary_warning('off', ...
                'HOR_CONFIG:set_mem_chunk_size', ...
                'HORACE:physical_memory_configured', ...
                'HORACE:insufficient_physical_memory');

            cleanup_hor_config = set_temporary_config_options( ...
                hor_config, ...
                'mem_chunk_size', mem_chunk_size, ...
                'fb_scale_factor',3,...
                'use_mex', false ...
                );

            cleanup_hpc_config = set_temporary_config_options( ...
                hpc_config, ...
                'combine_sqw_using', 'matlab' ...
                );

            % test filebased cut
            outfile = fullfile(obj.working_dir, 'nomex_combine_cut_from_file_to_file.sqw');
            w3_t = cut(obj.sqw_file, obj.ref_params{:}, outfile);
            cleanup = onCleanup(@()del_memmapfile_files(outfile));

            loaded_cut = sqw(outfile);

            clear cleanup_hor_config;
            % reference memory-based cut
            sqw_obj = obj.sqw_4d; % it have just been read in constructor
            ref_par = obj.ref_params;
            ref_cut = cut(sqw_obj,ref_par{:});

            assertEqualToTol(ref_cut, loaded_cut, obj.FLOAT_TOL, 'ignore_str', true);
            % clear custom hpc_config first to avoid warnings
            clear cleanup_hpc_config;
        end

        function test_cut_sqw_object_to_file(obj)
            clWarn = set_temporary_warning('off', ...
                'HOR_CONFIG:set_mem_chunk_size','HORACE:physical_memory_configured');

            mem_chunk_size = 4000;
            cleanup_config = set_temporary_config_options( ...
                hor_config, ...
                'mem_chunk_size', mem_chunk_size, ...
                'fb_scale_factor',3 ...
                );
            ws = warning('off','HORACE:old_file_format');
            clWarn = onCleanup(@()warning(ws));

            sqw_obj = read_sqw(obj.sqw_file);

            outfile = fullfile(tmp_dir, 'test_cut_from_obj_to_file.sqw');

            cut(sqw_obj, obj.ref_params{:}, outfile);
            cleanup = onCleanup(@() clean_up_file(outfile));

            loaded_cut = read_sqw(outfile);
            ref_cut = read_sqw(obj.ref_cut_file);

            assertEqualToTol(loaded_cut, ref_cut, obj.FLOAT_TOL, ...
                'ignore_str', true,'-ignore_date');
            clear cleanup_config

        end

        function test_cut_dnd(obj)
            dnd_obj = read_dnd(obj.sqw_file);

            u_axis_lims = [-0.1, 0.024, 0.1];
            v_axis_lims = [-0.1, 0.024, 0.1];
            w_axis_lims = [-0.1, 0.1];
            en_axis_lims = [105, 1, 114];
            res = cut(dnd_obj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);
            assertTrue(isa(res, 'd3d'));

            % We expect 3 dimensions since we are integrating over w (u3), as
            % numel(w_axis_lims) = 2.
            % We expect 9 in the u dimension because the range defined in
            % u_axis_lims has 9 steps - you can justify this to yourself by
            % evaluating `numel(u_axis_lims(1):u_axis_lims(2):u_axis_lims(3))`.
            % For similar reasons, v and en have 9 and 10 dims respectively.
            expected_img_size = [11,11, 10];
            assertEqual(size(res.s), expected_img_size);
        end

        function test_multiple_cuts_integration_axis(obj)
            proj = line_proj([1, -1 ,0], [1, 1, 0], 'offset', [1, 1, 0], 'type', 'paa');

            u_axis_lims = [-0.1, 0.025, 0.1];
            v_axis_lims = [-0.1, 0.025, 0.1];
            w_axis_lims = [-0.1, 0.1];

            % Short-hand for defining multiple integration ranges (as opposed to a loop).
            en_axis_lims = [106, 4, 114, 4];
            % The indices are as follows:
            %   1 - first range center
            %   2 - distance between range centers
            %   3 - final range center
            %   4 - range width
            % Hence the above limits define three cuts, each cut integrating over a
            % different energy range. The first range being 104-108, the second
            % 108-112 and the third 112-116.

            sqw_obj = sqw(obj.sqw_file);
            res = cut(...
                sqw_obj, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims ...
                );

            expected_en_int_lims = {[104, 108], [108, 112], [112, 116]};

            assertTrue(isa(res, 'sqw'));
            assertEqual(size(res), [3, 1]);
            for i = 1:numel(res)
                assertEqual(size(res(i).data.s), [9, 9]);
                assertEqual(res(i).data.iint(3:4), expected_en_int_lims{i});
            end
        end

        function test_multiple_cuts_int_axis_nopix(obj)
            proj = line_proj([1, -1 ,0], [1, 1, 0], 'offset', [1, 1, 0], 'type', 'paa');

            u_axis_lims = [-0.1, 0.025, 0.1];
            v_axis_lims = [-0.1, 0.025, 0.1];
            w_axis_lims = [-0.1, 0.1];
            en_axis_lims = [106, 4, 114, 4];

            sqw_obj = sqw(obj.sqw_file);
            res = cut(...
                sqw_obj, proj, u_axis_lims, v_axis_lims, w_axis_lims, ...
                en_axis_lims, '-nopix' ...
                );

            expected_en_int_lims = {[104, 108], [108, 112], [112, 116]};

            assertTrue(isa(res, 'd2d'));
            assertEqual(size(res), [3, 1]);
            for i = 1:numel(res)
                assertEqual(size(res(i).s), [9, 9]);
                assertEqual(res(i).iint(3:4), expected_en_int_lims{i});
            end
            % First two cuts are in range of data, final cut is out of range so
            % should have no pixel contributions
            assertFalse(all(res(1).s(:) == 0));
            assertFalse(all(res(2).s(:) == 0));
            assertEqual(res(3).s, zeros(9, 9));
            assertEqual(res(3).e, zeros(9, 9));
        end

        function test_cut_fail_outfile_not_created(obj)
            % If the outfile cannot be created, we want to know before we carry out
            % the potentially expensive cut.
            % We check that the error  is raised early by checking the error's ID,
            % which is different if writing fails after the cut is complete.
            outfile = fullfile('P:', 'not', 'a_valid', 'path.sqw');

            f = @() cut(obj.sqw_file, obj.ref_params{:}, outfile);
            assertExceptionThrown(f, 'HORACE:cut:invalid_argument');
        end

        function test_cut_fail_multiple_files(obj)
            f = @() cut({obj.sqw_file, obj.sqw_file}, obj.ref_params{:});
            assertExceptionThrown(f, 'HORACE:cut:invalid_argument');
        end

        function test_out_of_memory_cut_tmp_files_mex(obj)
            [~, ~, can_combine_with_mex] = check_horace_mex();
            if ~can_combine_with_mex
                skipTest('Combinbing with mex is not available on this system')
            end

            mem_chunk_size = 500;  %
            clWarn = set_temporary_warning('off', ...
                'HOR_CONFIG:set_mem_chunk_size', ...
                'HORACE:physical_memory_configured', ...
                'HORACE:insufficient_physical_memory');
            cleanup_config = set_temporary_config_options( ...
                hor_config, ...
                'mem_chunk_size', mem_chunk_size, ...
                'fb_scale_factor', 3, ...
                'use_mex', true ...
                );
            cleanup_hpc_config = set_temporary_config_options( ...
                hpc_config, ...
                'combine_sqw_using', 'mex' ...
                );
            outfile = fullfile(tmp_dir, 'tmp_outfile.sqw');
            cleanup_tmp_file = onCleanup(@() clean_up_file(outfile));
            cut(obj.sqw_file, obj.ref_params{:}, outfile);

            clear cleanup_config;
            clear cleanup_hpc_config;
            ref_sqw = sqw(obj.ref_cut_file);
            output_sqw = sqw(outfile);

            assertEqualToTol(output_sqw, ref_sqw, obj.FLOAT_TOL, ...
                'ignore_str', true,'-ignore_date');
        end

        function test_out_of_memory_cut_tmp_files_no_mex(obj)
            num_pixels = 200118; % number of pixels in the test file.
            mem_chunk_size = floor(num_pixels/1.9/10);  % this gives two pages of pixels over obj.sqw_file
            outfile = fullfile(tmp_dir, 'tmp_outfile.sqw');
            cleanup_config_handle = set_temporary_config_options( ...
                hor_config, ...
                'mem_chunk_size', mem_chunk_size, ...
                'use_mex', false ...
                );
            % assure that we are realy doing filebacked cut
            assertTrue(PixelDataBase.do_filebacked(num_pixels));

            cut(obj.sqw_file, obj.ref_params{:}, outfile);
            cleanup_tmp_file = onCleanup(@() clean_up_file(outfile));

            ref_sqw = sqw(obj.ref_cut_file);
            output_sqw = sqw(outfile);

            contrubuted_keys = output_sqw.runid_map.keys;
            contrib_ind  = contrubuted_keys;
            real_contr_ind = unique(ref_sqw.pix.run_idx);
            assertTrue(all(ismember(contrib_ind,real_contr_ind)));

            contr_headers = output_sqw.experiment_info.get_subobj(contrib_ind);
            assertEqual(contr_headers,output_sqw.experiment_info);

            assertEqualToTol(output_sqw, ref_sqw, obj.FLOAT_TOL, ...
                'ignore_str', true,'-ignore_date', 'reorder', true);

        end

        function test_cut_fail_no_outfile_no_nargout(obj)
            f = @() cut(obj.sqw_file, obj.ref_params{:});
            assertExceptionThrown(f, 'HORACE:cut:invalid_argument');
        end

        function test_cut_nopix_to_file(obj)
            outfile = fullfile(tmp_dir, 'tmp_outfile.sqw');
            cleanup = onCleanup(@() clean_up_file(outfile));

            cut(obj.sqw_file, obj.ref_params{:}, outfile, '-nopix')

            assertTrue(logical(exist(outfile, 'file')));
            ldr = sqw_formats_factory.instance().get_loader(outfile);
            output_obj = ldr.get_dnd();
            ref_object = read_dnd(obj.ref_cut_file);

            assertEqualToTol(output_obj, ref_object, ...
                'ignore_str', true,'abstol',2.e-7);
        end
        %-------------------------------------------------------------------
        function test_cut_dnd_multiple_obj_same_type_cell(obj)
            indata = {dnd_multicut_tester(),dnd_multicut_tester()};
            cuts = cut_dnd(indata,'-cell', obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts',indata);
        end

        function test_cut_dnd_multiple_obj_array(obj)
            indata = {dnd_multicut_tester(),dnd_multicut_tester()};
            cuts = cut_dnd(indata, obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts(1),indata{1});
            assertEqual(cuts(2),indata{2});
        end

        function test_cut_dnd_multiple_obj(obj)
            indata = {dnd_multicut_tester(),dnd_multicut_tester()};
            [cut1,cut2] = cut_dnd(indata, obj.ref_params{:});
            assertEqual(cut1,indata{1});
            assertEqual(cut2,indata{2});
        end

        function test_cut_dnd_wrapper(obj)
            indata = dnd_multicut_tester();
            cut1 = cut_dnd(indata, obj.ref_params{:});
            assertEqual(cut1,indata);
        end

        %-------------------------------------------------------------------

        function test_cut_hor_multiple_obj_same_type_cell(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut_horace(indata,'-cell', obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts',indata);
        end

        function test_cut_hor_multiple_obj_array(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut_horace(indata, obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts(1),indata{1});
            assertEqual(cuts(2),indata{2});
        end

        function test_cut_hor_multiple_obj(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            [cut1,cut2] = cut_horace(indata, obj.ref_params{:});
            assertEqual(cut1,indata{1});
            assertEqual(cut2,indata{2});
        end

        function test_cut_hor_wrapper_dnd(obj)
            indata = dnd_multicut_tester();
            cut1 = cut_horace(indata, obj.ref_params{:});
            assertEqual(cut1,indata);
        end

        function test_cut_horace_wrapper_sqw(obj)
            indata = sqw_multicut_tester();
            cut1 = cut_horace(indata, obj.ref_params{:});
            assertEqual(cut1,indata);
        end

        %-------------------------------------------------------------------

        function test_cut_sqw_multiple_obj_same_type_cell(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut_sqw(indata,'-cell', obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts',indata);
        end

        function test_cut_sqw_multiple_obj_array(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut_sqw(indata, obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts(1),indata{1});
            assertEqual(cuts(2),indata{2});
        end

        function test_cut_sqw_multiple_obj(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            [cut1,cut2] = cut_sqw(indata, obj.ref_params{:});
            assertEqual(cut1,indata{1});
            assertEqual(cut2,indata{2});
        end

        function test_cut_sqw_wrapper(obj)
            indata = sqw_multicut_tester();
            cut1 = cut_sqw(indata, obj.ref_params{:});
            assertEqual(cut1,indata);
        end

        %-------------------------------------------------------------------

        function test_fake_cut_multiple_obj_same_type_cell(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut(indata,'-cell', obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts,indata');
        end

        function test_fake_cut_multiple_obj_array(obj)
            indata = {sqw_multicut_tester(),sqw_multicut_tester()};
            cuts = cut(indata, obj.ref_params{:});
            assertEqual(numel(cuts),2)
            assertEqual(cuts(1),indata{1});
            assertEqual(cuts(2),indata{2});
        end

        function test_fake_cut_multiple_obj_cell(obj)
            indata = {sqw_multicut_tester(),dnd_multicut_tester()};
            cuts = cut(indata, obj.ref_params{:});
            assertEqual(cuts{1},indata{1});
            assertEqual(cuts{2},indata{2});
        end

        function test_fake_cut_multiple_obj(obj)
            indata = {sqw_multicut_tester(),dnd_multicut_tester()};
            [cut1,cut2] = cut(indata, obj.ref_params{:});
            assertEqual(cut1,indata{1});
            assertEqual(cut2,indata{2});
        end

        %------------------------------------------------------------------

        function test_multicut_1(obj)
            % Test multicut capability for cuts that are adjacent
            % Note that the last cut has no pixels retained - a good test too!

            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            bin = [range(1)+step/2,step,range(2)-step/2];
            width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            args = {obj.ref_params{1}, bin, width, width};

            % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut(obj.sqw_4d, args{:}, [106,4,114,4], '-pix');
            w2 = repmat(sqw,[3,1]);

            for i=1:3
                tmp = cut(obj.sqw_4d, args{:}, 102+4*i+[-2,2], '-pix');
                w2(i) = tmp;
            end
            assertEqualToTol(w1, w2, obj.FLOAT_TOL,'ignore_str',1)

        end

        function test_multicut_2(obj)
            % Test multicut capability for cuts that are adjacent
            % Last couple of cuts have no pixels read or are even outside the range
            % of the input data

            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            bin = [range(1)+step/2,step,range(2)-step/2];
            width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            args = {obj.ref_params{1}, bin, width, width};

            % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut(obj.sqw_4d, args{:}, [110,2,118,2], '-pix');
            w2 = repmat(sqw,[5,1]);
            for i=1:5
                w2(i) = cut(obj.sqw_4d, args{:}, 108+2*i+[-1,1], '-pix');
            end
            assertEqualToTol(w1, w2, obj.FLOAT_TOL,'ignore_str',1)

        end

        function test_multicut_3(obj)
            % Test multicut capability for cuts that overlap adjacent cuts

            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            bin = [range(1)+step/2,step,range(2)-step/2];
            width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            args = {obj.ref_params{1}, bin, width, width};

            % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut(obj.sqw_4d, args{:}, [106,4,114,8], '-pix');
            w2 = repmat(sqw,[3,1]);
            for i=1:3
                w2(i) = cut(obj.sqw_4d, args{:}, 102+4*i+[-4,4], '-pix');
            end
            assertEqualToTol(w1, w2, obj.FLOAT_TOL,'ignore_str',1)

        end

        %------------------------------------------------------------------

        function test_cut_multiple_sqw_files(obj)
            mem_chunk_size = 8000;
            cleanup_config_handle = set_temporary_config_options( ...
                hor_config, ...
                'mem_chunk_size', mem_chunk_size ...
                );

            files = {obj.sqw_file,obj.sqw_file};
            [sqw_cut1,sqw_cut2] = cut(files, obj.ref_params{:});
            assertEqualToTol(sqw_cut1,sqw_cut2,'-ignore_date');
        end

        function test_cut_fail_dnd_sqw_file(obj)
            ex = assertExceptionThrown(@()cut_dnd(obj.sqw_file, obj.ref_params{:}), ...
                'HORACE:cut:invalid_argument');
        end

        function test_cut_fail_sqw_dnd_file(obj)
            ex = assertExceptionThrown(@()cut_sqw(obj.dnd_file, obj.ref_params{:}), ...
                'HORACE:cut:invalid_argument');
        end

        function test_cut_fail_no_output_no_file(obj)

            assertExceptionThrown(@()cut(obj.dnd_file,obj.ref_params{:}),...
                'HORACE:cut:invalid_argument');
        end

        function test_cut_2inputs_2files_as_cell(obj)
            files = {'file_name1.sqw','file_name2.sqw'};
            inputs = obj.ref_params;
            inputs{end+1} = files;
            [nin,nout,is_file,files,argi] = ...
                dnd_multicut_tester.cut_inputs_tester(2,0,inputs{:});
            assertEqual(nin,2)
            assertEqual(nout,0)
            assertTrue(is_file)
            assertEqual(numel(files),2)
            assertEqual(files{1},'file_name1.sqw')
            assertEqual(files{2},'file_name2.sqw')
            assertEqual(obj.ref_params,argi);
        end

        function test_cut_2inputs_2files_as_params(obj)
            inputs = [obj.ref_params(:);{'file_name1.sqw';'file_name2.sqw'}]';
            [nin,nout,is_file,files,argi] = ...
                dnd_multicut_tester.cut_inputs_tester(2,0,inputs{:});
            assertEqual(nin,2)
            assertEqual(nout,0)
            assertTrue(is_file)
            assertEqual(numel(files),2)
            assertEqual(files{1},'file_name1.sqw')
            assertEqual(files{2},'file_name2.sqw')
            assertEqual(obj.ref_params,argi);
        end

        function test_cut_2inputs_1file_expanded(obj)
            inputs = [obj.ref_params(:);'some_file_name.sqw']';
            [nin,nout,is_file,files,argi] = ...
                dnd_multicut_tester.cut_inputs_tester(2,0,inputs{:});
            assertEqual(nin,2)
            assertEqual(nout,0)
            assertTrue(is_file)
            assertEqual(numel(files),2)
            assertEqual(files{1},'some_file_name_cutN1.sqw')
            assertEqual(files{2},'some_file_name_cutN2.sqw')
            assertEqual(obj.ref_params,argi);
        end

        function test_cut_inputs_one_file_identified(obj)
            inputs = [obj.ref_params(:);'some_file_name.sqw']';
            [nin,nout,is_file,files,argi] = ...
                dnd_multicut_tester.cut_inputs_tester(1,0,inputs{:});
            assertEqual(nin,1)
            assertEqual(nout,0)
            assertTrue(is_file)
            assertEqual(files{1},'some_file_name.sqw')
            assertEqual(obj.ref_params,argi);
        end

        function test_too_many_inputs_ignored(obj)
            [nin,nout,is_file,files,params]= ...
                dnd_multicut_tester.cut_inputs_tester(4,3,obj.ref_params{:});
            assertEqual(nin,3)
            assertEqual(nout,3)
            assertFalse(is_file);
            assertTrue(isempty(files));
            assertEqual(obj.ref_params,params);
        end

        function test_cut_fail_not_enough_outs(obj)
            err = assertExceptionThrown(@()(dnd_multicut_tester.cut_inputs_tester(2,3,obj.ref_params{:})),...
                'HORACE:cut:invalid_argument');
            assertEqual(err.message,'Number of input cut sources (2) is smaller than the number of requested outputs (3)');
        end
        function test_cut_fail_not_enough_files(obj)
            inputs = [obj.ref_params(:);{'file_name1.sqw';'file_name2.sqw'}]';
            err = assertExceptionThrown(@()(dnd_multicut_tester.cut_inputs_tester(3,0,inputs{:})),...
                'HORACE:cut:invalid_argument');
            assertTrue(strncmp(err.message,'Multiple cuts',12));
        end
        function test_cut_fail_no_nargout_no_file(obj)
            assertExceptionThrown(@()(dnd_multicut_tester.cut_inputs_tester(1,0,obj.ref_params{:})),...
                'HORACE:cut:invalid_argument');
        end
    end
end
