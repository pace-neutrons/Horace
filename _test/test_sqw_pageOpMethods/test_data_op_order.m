classdef test_data_op_order < TestCase

    methods
        function obj = test_data_op_order(name)
            if nargin == 0
                name = 'test_data_op_order';
            end
            obj = obj@TestCase(name);
        end

        function test_data_num_order(~)
            obj1 = IX_dataset_1d();
            obj2 = 4;
            [is,do_page_op,page_op_order]=data_op_interface.is_superior(obj1,obj2);
            assertFalse(is);
            assertFalse(do_page_op);            
            assertEqual(page_op_order,0)

        end

    end
end
