classdef sqw_field_format_interface
    % Interface to specific non-standard i/o conversions used in legacy sqw file format
    properties(Constant,Access=protected)
        base_classes_ = {'double','single','int8','uint8','int16','uint16',...
            'int32','uint32','int64','uint64'};
        class_sizes_ =  [8,4,1,1,2,2,4,4,8,8]; % in bytes
        class_map_ = containers.Map(sqw_field_format_interface.base_classes_,...
            sqw_field_format_interface.class_sizes_); % map to associate field types and field sizes
    end
    
    methods(Abstract)
        % convert sequence of bytes into the field value
        [val,size] = field_from_bytes(obj,bytes,pos)
        % identify size of the filed from sequence of bytes (should know
        % the location and the position of the size information in bytes array)
        [size,obj] = size_from_bytes(obj,bytes,pos)
        % identify size of the filed from open binary file (should know the
        % the location and the position of the size information in bytes array)
        [size,obj,err] = size_from_file(obj,fid,pos);
        % estimate size of data field using format structure and
        % structure's value
        size = size_of_field(obj,val);
        % convert field value into sequence of bytes in the form,
        % convertible back by other methods
        bytes = bytes_from_field(obj,val);
        
    end
    methods
        function [size,obj,err] = field_size(obj,input,pos)
            % retrieve field size defined either in bytes array or
            % within a binary file, defined by file handle
            if isa(input,'uint8') % bytes
                [size,obj] = obj.size_from_bytes(input,pos);
                err = false;
            else %file stream
                [size,obj,err] = obj.size_from_file(input,pos);
            end
        end
        %
    end
    
end

