classdef test_struct_to_named_args_cell < TestCase

methods
    function obj = test_struct_to_named_args_cell(~)
        obj = obj@TestCase('test_struct_to_named_args_cell');
    end

    function test_converts_struct_fields_to_cell_array_of_args(~)
        s.category = 'tree';
        s.height = 37.4;
        s.name = 'birch';

        c = struct_to_named_args_cell(s);

        expected_c = {'category', 'tree', 'height', 37.4, 'name', 'birch'};
        assertEqual(c, expected_c);
    end

end

end
