classdef hlp_serial_types

    properties(Constant)
        % Names to numbers
        lookup = containers.Map({'logical', 'char', 'string', 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64', 'complex_double', 'complex_single', 'complex_int8', 'complex_uint8', 'complex_int16', 'complex_uint16', 'complex_int32', 'complex_uint32', 'complex_int64', 'complex_uint64', 'cell', 'struct', 'function_handle', 'value_object', 'handle_object_ref', 'enum', 'sparse_logical', 'sparse_double', 'sparse_complex_double'}, 1:32);

        % Details associated with type
        type_details = struct('name',...
                              {'logical', 'char', 'string', 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64', 'complex_double', 'complex_single', 'complex_int8', 'complex_uint8', 'complex_int16', 'complex_uint16', 'complex_int32', 'complex_uint32', 'complex_int64', 'complex_uint64', 'cell', 'struct', 'function_handle', 'value_object', 'handle_object_ref', 'enum', 'sparse_logical', 'sparse_double', 'sparse_complex_double'},...
                              'size',...
                              {1, 1, 2, 8, 4, 1, 1, 2, 2, 4, 4, 8, 8, 16, 8, 2, 2, 4, 4, 8, 8, 16, 16, 0, 0, 0, 0, 0, 0, 1, 8, 16},...
                              'tag',...
                              {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31});

    end

    methods(Static)
        function details = get_details(type)
            details = hlp_serial_types.type_details(hlp_serial_types.lookup(type));
        end

        function size = get_size(type)
            size = hlp_serial_types.type_details(hlp_serial_types.lookup(type)).size;
        end

        function cont = contains(type)
            cont = isKey(hlp_serial_types.lookup, type);
        end
    end

end