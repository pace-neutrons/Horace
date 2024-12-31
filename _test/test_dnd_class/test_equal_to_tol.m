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

            obj.dnd_2d = read_horace(obj.test_dnd_file_path);
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
            assertTrue( ...
                strcmp(mess, ...
                'Objects have different types. "input_1" has class: "d2d" and "input_2" class: "sqw"'));
        end

        function test_different_d2d_objects_are_not_equal(obj)
            %class_fields = properties(obj.dnd_2d);
            class_prop=dnd_object_sample_properties([10,2]);
            class_fields = class_prop.keys;
            class_prop('dax') = [2,1];
            %
            for idx = 1:numel(class_fields)
                dnd_copy = obj.dnd_2d;


                field_name = class_fields{idx};
                old_val = dnd_copy.(field_name);
                try
                    dnd_copy.(field_name) = class_prop(field_name);
                catch ME
                    if strcmp(ME.identifier,'HORACE:DnDBase:invalid_argument')
                        continue;
                    end
                end

                [ok, mess] = equal_to_tol(obj.dnd_2d, dnd_copy);
                assertFalse(ok, ['Expected ', field_name, ...
                    ' to be not equal. Difference: ', mess]);
                dnd_copy.(field_name) = old_val;
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
