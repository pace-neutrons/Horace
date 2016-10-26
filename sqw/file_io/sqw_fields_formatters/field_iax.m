classdef field_iax < field_const_array_dependent
    %Describes format of integration axis
    %
    
    properties
    end
    
    methods
        function obj=field_iax()
            obj= obj@field_const_array_dependent('npax',1,'int32');
        end
        
        function niax  = process_host_value(obj)
            % calculate number of integration axis from number of
            % projection axis
            fmt = obj.host.(obj.host_struct_field_);
            npax= fmt.field_value;
            niax  = 4-npax;
        end
        function [val,sz] = field_from_bytes(obj,bytes,pos)
            [val,sz] = field_from_bytes@field_const_array_dependent(obj,bytes,pos);
             val = double(val);
        end
        
        
    end
    
end

