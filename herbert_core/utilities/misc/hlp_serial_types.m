classdef hlp_serial_types
    
    properties(Constant)
        % Names to numbers
        types = {'logical', 'char', 'string', 'double',...
            'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32',...
            'int64', 'uint64', 'complex_double', 'complex_single', 'complex_int8',...
            'complex_uint8', 'complex_int16', 'complex_uint16', 'complex_int32',...
            'complex_uint32', 'complex_int64', 'complex_uint64', 'cell', 'struct',...
            'function_handle', 'value_object', 'handle_object_ref', 'enum',...
            'sparse_logical', 'sparse_double', 'sparse_complex_double',...
            'serializable'}
        
        lookup = containers.Map(hlp_serial_types.types,1:33);
        
        % Details associated with type
        type_details = struct('name',...
            hlp_serial_types.types,...
            'size',... % Sizes of respective data types
            {1, 1, 2, 8,...          %      'logical', 'char', 'string', 'double',...
            4, 1, 1, 2, 2, 4, 4,...  %      'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32',...
            8, 8, 16, 8, 2, ...      %      'int64', 'uint64', 'complex_double', 'complex_single', 'complex_int8',...
            2, 4, 4, 8,...           %      'complex_uint8', 'complex_int16', 'complex_uint16', 'complex_int32',... 
            8, 16, 16, 0, 0, ...     %      'complex_uint32', 'complex_int64', 'complex_uint64', 'cell', 'struct',...
            0, 0, 0, 0, ...          %      'function_handle', 'value_object', 'handle_object_ref', 'enum',...
            1, 8, 16,...             %      'sparse_logical', 'sparse_double', 'sparse_complex_double'
            0},...                   %      'serializable' -- object serializes itself
            'tag',... % Lookup tags for type of serialised data
            cellfun(@uint8, num2cell(0:32), 'UniformOutput', false));
        
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
        
        function objID_struc = type_mapping(v)
            type = class(v);
            if isa(v,'serializable')
                objID_struc = hlp_serial_types.get_details('serializable');
                return
            end
            
            if isnumeric(v) && ~isreal(v)
                type = ['complex_' type];
            end
            if issparse(v)
                type = ['sparse_' type];
            end
            
            if isKey(hlp_serial_types.lookup, type)
                objID_struc = hlp_serial_types.get_details(type);
            elseif ishandle(v)
                objID_struc = hlp_serial_types.get_details('handle_object');
            else
                objID_struc = hlp_serial_types.get_details('value_object');
            end
            
        end
    end
    
end