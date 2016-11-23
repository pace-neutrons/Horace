classdef field_iint < field_const_array_dependent
    %UNTITLED10 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=field_iint()
            obj= obj@field_const_array_dependent('npax',2,'single');
        end
        
        function nelem  = process_host_value(obj)
            % calculate number of integration axis from number of
            % projection axis
            fmt = obj.host.(obj.host_struct_field_);
            npax= fmt.field_value;
            niax  = 4-npax;
            nelem = 2*niax;
        end
        function [val,sz] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the array
            nelem = obj.process_host_value();
            sz = double(nelem*obj.elem_byte_size);
            if sz ==0
                val = [];
            else
                val = typecast(bytes(pos:pos+sz-1),obj.precision);
                val = reshape(val,[2,nelem/2]);
            end
        end
        
        
    end
    
end

