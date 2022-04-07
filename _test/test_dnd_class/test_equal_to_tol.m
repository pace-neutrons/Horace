classdef test_equal_to_tol < TestCase

properties
    old_config;
    old_warn_state;

    ALL_IN_MEM_PG_SIZE = 1e12;

    test_dnd_file_path = '../common_data/dnd_2d.sqw';
    test_sqw_file_path = '../common_data/sqw_2d_1.sqw';

    dnd_2d;
end

methods

    function obj = test_equal_to_tol(~)
        obj = obj@TestCase('test_equal_to_tol');

        hc = hor_config();
        obj.old_config = hc.get_data_to_store();

        hc.log_level = 0;  % hide the (quite verbose) equal_to_tol output

        obj.dnd_2d = d2d(obj.test_dnd_file_path);
    end

    function delete(obj)
        set(hor_config, obj.old_config);
    end

    function test_the_same_d2d_objects_are_equal(obj)
        dnd_copy = obj.dnd_2d;
        assertEqualToTol(obj.dnd_2d, dnd_copy);
    end

    function test_d2d_and_sqw_objects_are_not_equal(obj)
        sqw_2d = sqw(obj.test_sqw_file_path);
        [ok, mess] = equal_to_tol(obj.dnd_2d, sqw_2d);
        assertFalse(ok);
        assertEqual(mess, 'Objects being compared are not both sqw-type or both dnd-type');
    end

    function test_different_d2d_objects_are_not_equal(obj)
        class_fields = properties(obj.dnd_2d);
        for idx = 1:numel(class_fields)
            dnd_copy = obj.dnd_2d;
            field_name = class_fields{idx};
            if isstruct(dnd_copy.(field_name))
                dnd_copy.(field_name).test_field = 'test_value';
            elseif isstring(dnd_copy.(field_name))
                dnd_copy.(field_name) = 'test_value';
            else
                dnd_copy.(field_name) = [];
            end

            [ok, mess] = equal_to_tol(obj.dnd_2d, dnd_copy);
            assertFalse(ok, ['Expected ', field_name, ' to be not equal']);
        end
    end

    function test_equal_to_tol_can_be_called_with_negative_tol_for_rel_tol(obj)
        dnd_copy = copy(obj.dnd_2d);
        rel_tol = 1e-5;
        assertTrue(equal_to_tol(dnd_copy, obj.dnd_2d, -rel_tol));

        % find first non-zero signal value
        sig_idx = find(dnd_copy.s > 0, 1);

        % increase the difference in the value by 1% more than rel_tol
        value_diff = 1.01*rel_tol*obj.dnd_2d.s(sig_idx);
        dnd_copy.s(sig_idx) = obj.dnd_2d.s(sig_idx) + value_diff;

        assertFalse(equal_to_tol(dnd_copy, obj.dnd_2d, -rel_tol));

        % check increasing the rel_tol by 1% returns true
        assertTrue(equal_to_tol(dnd_copy, obj.dnd_2d, -rel_tol*1.01))

        % check absolute tolerance still true
        assertTrue(equal_to_tol(dnd_copy, obj.dnd_2d, value_diff + 1e-8));
    end

end

end
