classdef test_cut < TestCase

properties
    sqw_file = '../test_sym_op/test_cut_sqw_sym.sqw';
    sqw_4d;
end

methods

    function obj = test_cut(~)
        obj = obj@TestCase('test_cut');
        obj.sqw_4d = sqw(obj.sqw_file);
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
        en_axis_lims = [105.5, 1, 114.5];

        sqw_cut = cut_data_from_file_paged(...
            obj.sqw_file, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);

        ref_sqw = sqw('test_cut_ref_sqw.sqw');
        assertEqualToTol(sqw_cut, ref_sqw, 1e5, 'ignore_str', true);
    end

    % function test_you_can_take_a_cut_from_an_sqw_object(obj)
    %     sqw_obj = sqw(obj.sqw_file);

    %     proj = projaxes([1, -1 ,0], [1, 1, 0], 'uoffset', [1, 1, 0], 'type', 'paa');

    %     u_axis_lims = [-0.1, 0.025, 0.1];
    %     v_axis_lims = [-0.1, 0.025, 0.1];
    %     w_axis_lims = [-0.1, 0.1];
    %     en_axis_lims = [105, 1, 114];

    %     sqw_cut = cut_data_from_file_paged(...
    %         sqw_obj, proj, u_axis_lims, v_axis_lims, w_axis_lims, en_axis_lims);

    %     ref_sqw = sqw('test_cut_ref_sqw.sqw');
    %     assertEqualToTol(sqw_cut, ref_sqw, 1e5, 'ignore_str', true);
    % end

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