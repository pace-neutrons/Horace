classdef test_cut < TestCase

properties
    old_warn_state;

    sqw_file = '../test_sym_op/test_cut_sqw_sym.sqw';
    sqw_4d;
end

methods

    function obj = test_cut(~)
        obj = obj@TestCase('test_cut');
        obj.sqw_4d = sqw(obj.sqw_file);

        obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');
    end

    function delete(obj)
        warning(obj.old_warn_state);
    end

    function test_you_can_take_a_cut_from_an_sqw_file(obj)
        conf = hor_config();
        old_conf = conf.get_data_to_store();
        conf.pixel_page_size = 5e5;
        cleanup = onCleanup(@() set(hor_config, old_conf));

        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

        u_axis_lims = [-0.1, 0.025, 0.1];
        v_axis_lims = [-0.1, 0.025, 0.1];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [105, 1, 114];

        sqw_cut = cut(...
            obj.sqw_file, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);

        ref_sqw = sqw('test_cut_ref_sqw.sqw');
        assertEqualToTol(sqw_cut, ref_sqw, 1e-5, 'ignore_str', true);
    end

    function test_taking_cut_from_a_larger_file(~)
        conf = hor_config();
        old_conf = conf.get_data_to_store();
        conf.pixel_page_size = 128e6;
        cleanup = onCleanup(@() set(hor_config, old_conf));
        file_path = ['C:\Users\ejo73213\PACE\tutorial\Horace_for_Tessella\' ...
                     'data_sqw\iron_data.sqw'];

        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [0, 0, 0, 0], 'type', 'rrr');

        u_axis_lims = [-3, 0.05, 3];
        v_axis_lims = [-3, 0.05, 3];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [0, 4, 360];

        sqw_cut = cut(...
            file_path, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);

        % ref_sqw = sqw('C:\Users\ejo73213\PACE\Horace\hscratch\ref_large_cut_matlab.sqw');
        ref_sqw = sqw('C:\Users\ejo73213\PACE\Horace\hscratch\ref_large_cut_mex.sqw');
        assertEqualToTol(sqw_cut, ref_sqw, [0, 1e-4], 'ignore_str', true);
    end

    function test_you_can_take_a_cut_from_an_sqw_object(obj)
        sqw_obj = sqw(obj.sqw_file);

        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

        u_axis_lims = [-0.1, 0.025, 0.1];
        v_axis_lims = [-0.1, 0.025, 0.1];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [105, 1, 114];

        sqw_cut = cut(sqw_obj, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);

        ref_sqw = sqw('test_cut_ref_sqw.sqw');
        assertEqualToTol(sqw_cut, ref_sqw, 1e-4, 'ignore_str', true);
    end

    function test_you_can_take_a_cut_from_a_larger_sqw_object(~)
        conf = hor_config();
        old_conf = conf.get_data_to_store();
        conf.pixel_page_size = 256e6;
        cleanup = onCleanup(@() set(hor_config, old_conf));
        file_path = ['C:\Users\ejo73213\PACE\tutorial\Horace_for_Tessella\' ...
                     'data_sqw\iron_data.sqw'];

        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [0, 0, 0, 0], 'type', 'rrr');

        u_axis_lims = [-3, 0.05, 3];
        v_axis_lims = [-3, 0.05, 3];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [0, 4, 360];

        sqw_obj = sqw(file_path);

        sqw_cut = cut(...
            sqw_obj, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);

        ref_sqw = sqw('C:\Users\ejo73213\PACE\Horace\hscratch\ref_large_cut_mex.sqw');
        assertEqualToTol(sqw_cut, ref_sqw, [0, 1e-4], 'ignore_str', true);
    end

    function test_you_can_take_a_cut_with_nopix_argument(obj)
        conf = hor_config();
        old_conf = conf.get_data_to_store();
        conf.pixel_page_size = 5e5;
        cleanup = onCleanup(@() set(hor_config, old_conf));

        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

        u_axis_lims = [-0.1, 0.025, 0.1];
        v_axis_lims = [-0.1, 0.025, 0.1];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [105, 1, 114];

        sqw_cut = cut(...
            obj.sqw_file, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims, ...
            '-nopix' ...
        );

        ref_sqw = d3d('test_cut_ref_sqw.sqw');
        assertEqualToTol(sqw_cut, ref_sqw, 1e-5, 'ignore_str', true);
    end

    function test_SQW_error_raised_taking_cut_of_array_of_sqw(obj)
        sqw_obj1 = sqw(obj.sqw_file);
        sqw_obj2 = sqw(obj.sqw_file);

        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

        u_axis_lims = [-0.1, 0.025, 0.1];
        v_axis_lims = [-0.1, 0.025, 0.1];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [105, 1, 114];

        f = @() cut([sqw_obj1, sqw_obj2], proj, u_axis_lims, v_axis_lims, ...
                    w_axis_lims, en_axis_lims);
        assertExceptionThrown(f, 'SQW:cut');
    end

    function test_you_can_take_a_cut_integrating_over_more_than_1_axis(obj)
        conf = hor_config();
        old_conf = conf.get_data_to_store();
        conf.pixel_page_size = 5e5;
        cleanup = onCleanup(@() set(hor_config, old_conf));

        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

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

    function test_you_can_take_a_cut_from_an_sqw_file_to_another_sqw_file(obj)
        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');
        u_axis_lims = [-0.1, 0.2, 0.1];
        v_axis_lims = [-0.1, 0.1];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [106, 4, 114];

        outfile = fullfile(tmp_dir, 'tmp_outfile.sqw');

        ret_sqw = cut(...
            obj.sqw_file, proj, u_axis_lims, v_axis_lims, w_axis_lims, ...
            en_axis_lims, outfile ...
        );
        % Write a cleanup_tmp_file function in _test/common that checks the file exists first
        % also check that the file is not open elsewhere and close it.
        % Pretty sure I wrote this function somewhere already
        cleanup = onCleanup(@() delete(outfile));

        loaded_cut = sqw(outfile);

        assertEqualToTol(ret_sqw, loaded_cut, 1e-5, 'ignore_str', true);

        % clear to ensure PixelData objects are not holding on to the temp file
        clear loaded_cut ret_sqw
    end

    function test_you_can_take_a_cut_from_an_sqw_object_to_an_sqw_file(obj)
        sqw_obj = sqw(obj.sqw_file);

        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

        u_axis_lims = [-0.1, 0.025, 0.1];
        v_axis_lims = [-0.1, 0.025, 0.1];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [105, 1, 114];

        outfile = fullfile(tmp_dir, 'tmp_outfile.sqw');

        cut(sqw_obj, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims, ...
            outfile);
        cleanup = onCleanup(@() delete(outfile));

        loaded_sqw = sqw(outfile);
        ref_sqw = sqw('test_cut_ref_sqw.sqw');
        assertEqualToTol(loaded_sqw, ref_sqw, 1e-4, 'ignore_str', true);
    end

    function test_you_can_take_a_cut_from_a_dnd_object(obj)
        dnd_obj = d4d(obj.sqw_file);

        u_axis_lims = [-0.1, 0.024, 0.1];
        v_axis_lims = [-0.1, 0.024, 0.1];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [105, 1, 114];

        res = cut(dnd_obj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);
        assertTrue(isa(res, 'd3d'));
        assertEqual(size(res.s), [9, 9, 10]);
    end

    function test_you_can_take_multiple_cuts_on_proj_axes(obj)
        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

        u_axis_lims = [-0.1, 0.025, 0.1];
        v_axis_lims = [-0.1, 0.025, 0.1];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [106, 4, 114, 4];

        sqw_obj = sqw(obj.sqw_file);
        res = cut(...
            sqw_obj, proj, u_axis_lims, v_axis_lims, w_axis_lims, ...
            en_axis_lims ...
        );

        assertTrue(isa(res, 'sqw'));
        assertEqual(size(res), [3, 1]);
        for i = 1:numel(res)
            assertEqual(size(res(i).data.s), [9, 9]);
        end
    end

    function test_you_can_take_multiple_cuts_on_proj_axes_with_nopix(obj)
        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

        u_axis_lims = [-0.1, 0.025, 0.1];
        v_axis_lims = [-0.1, 0.025, 0.1];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [106, 4, 114, 4];

        sqw_obj = sqw(obj.sqw_file);
        res = cut(...
            sqw_obj, proj, u_axis_lims, v_axis_lims, w_axis_lims, ...
            en_axis_lims, '-nopix' ...
        );

        assertTrue(isa(res, 'd2d'));
        assertEqual(size(res), [3, 1]);
        for i = 1:numel(res)
            assertEqual(size(res(i).s), [9, 9]);
        end
        % First two cuts are in range of data, final cut is out of range so
        % should have no pixel contributions
        assertFalse(all(res(1).s(:) == 0));
        assertFalse(all(res(2).s(:) == 0));
        assertEqual(res(3).s, zeros(9, 9));
        assertEqual(res(3).e, zeros(9, 9));
    end

    function test_cut_errors_early_if_outfile_cannot_be_created(obj)
        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

        u_axis_lims = [-0.1, 0.025, 0.1];
        v_axis_lims = [-0.1, 0.025, 0.1];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [106, 4, 114, 4];

        outfile = fullfile('P:', 'not', 'a_valid', 'path.sqw');

        f = @() cut( ...
            obj.sqw_file, proj, u_axis_lims, v_axis_lims, w_axis_lims, ...
            en_axis_lims, outfile ...
        );
        assertExceptionThrown(f, 'CUT_SQW:runtime_error');
    end

end

end
