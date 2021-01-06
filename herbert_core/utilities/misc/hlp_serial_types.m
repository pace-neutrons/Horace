classdef hlp_serial_types

    properties(Constant)
        % Names to numbers
        lookup = containers.Map({'logical', 'char', 'string', 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64', 'complex_double', 'complex_single', 'complex_int8', 'complex_uint8', 'complex_int16', 'complex_uint16', 'complex_int32', 'complex_uint32', 'complex_int64', 'complex_uint64', 'cell', 'struct', 'function_handle', 'value_object', 'handle_object_ref', 'enum', 'sparse_logical', 'sparse_double', 'sparse_complex_double'}, 1:32);

        % Details associated with type
        type_details = struct('name',...
                              {'logical', 'char', 'string', 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64', 'complex_double', 'complex_single', 'complex_int8', 'complex_uint8', 'complex_int16', 'complex_uint16', 'complex_int32', 'complex_uint32', 'complex_int64', 'complex_uint64', 'cell', 'struct', 'function_handle', 'value_object', 'handle_object_ref', 'enum', 'sparse_logical', 'sparse_double', 'sparse_complex_double'},...
                              'size',... % Sizes of respective data types
                              {1, 1, 2, 8, 4, 1, 1, 2, 2, 4, 4, 8, 8, 16, 8, 2, 2, 4, 4, 8, 8, 16, 16, 0, 0, 0, 0, 0, 0, 1, 8, 16},...
                              'tag',... % Lookup tags for type of serialised data
                              cellfun(@uint8, num2cell(0:31), 'UniformOutput', false));

        tag_size = 1;  % Size of standard tag (uint8) in bytes
        ndims_size = 1;% Size of standard num dimensions (uint8) in bytes
        dim_size = 4;  % Size of standard dimension (uint32) in bytes
        dims_tag = uint8([32 64 96 128 160 192 224]); % Dims tags to set number of dimensions
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

        function obj = type_mapping(v)
            type = class(v);

            if isnumeric(v) && ~isreal(v)
                type = ['complex_' type];
            end
            if issparse(v)
                type = ['sparse_' type];
            end

            if isKey(hlp_serial_types.lookup, type)
                obj = hlp_serial_types.get_details(type);
            elseif ishandle(v)
                obj = hlp_serial_types.get_details('handle_object');
            else
                obj = hlp_serial_types.get_details('value_object');
            end

        end
    end

end