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

        sqw_cut = cut_data_from_file_paged(...
            obj.sqw_file, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);

        % sqw_cut = cut_sqw(...
        %     obj.sqw_file, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);

        ref_sqw = sqw('test_cut_ref_sqw.sqw');
        assertEqualToTol(sqw_cut, ref_sqw, 1e-5, 'ignore_str', true);
    end

    function test_taking_cut_from_a_larger_file(obj)
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

        tic;
        sqw_cut = cut_data_from_file_paged(...
            file_path, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);
        toc;

        % tic;
        % sqw_cut = cut_sqw(...
        %     file_path, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);
        % toc;

        ref_sqw = sqw('ref_large.sqw');
        assertEqualToTol(sqw_cut, ref_sqw, [0, 1e-4], 'ignore_str', true);
    end

    function test_you_can_take_a_cut_from_an_sqw_object(obj)
        sqw_obj = sqw(obj.sqw_file);

        proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

        u_axis_lims = [-0.1, 0.025, 0.1];
        v_axis_lims = [-0.1, 0.025, 0.1];
        w_axis_lims = [-0.1, 0.1];
        en_axis_lims = [105, 1, 114];

        sqw_cut = cut_data_from_file_paged(...
            sqw_obj, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);

        ref_sqw = sqw('test_cut_ref_sqw.sqw');
        assertEqualToTol(sqw_cut, ref_sqw, 1e-4, 'ignore_str', true);
    end

    function test_you_can_take_a_cut_from_an_sqw_file_to_another_sqw_file(~)
    end

    function test_you_can_take_a_cut_from_an_sqw_object_to_an_sqw_file(~)
    end

    function test_you_can_take_a_cut_from_a_dnd_object(~)
    end

    function test_you_can_take_a_cut_from_a_dnd_object_to_an_sqw_file(~)
    end

end

end