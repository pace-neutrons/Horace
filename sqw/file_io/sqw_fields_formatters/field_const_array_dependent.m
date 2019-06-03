classdef field_const_array_dependent < field_var_array
    %  The class describes conversion applied to save/restore
    %  an array, with size and dimensions, specified by other field of
    %  the structure, this field belongs to
    %
    %
    %  The length of the array is specified || identified from host
    %  structure, which provides array size and dimensions
    %
    %
    % $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
    %
    
    properties(Access=protected)
        host_struct_ = [];
        host_struct_field_;
    end
    
    properties(Dependent)
        host
    end
    
    methods
        function obj=field_const_array_dependent(varargin)
            obj = obj@field_var_array(varargin{2:end});
            obj.host_struct_field_ = varargin{1};
        end
        function obj = set.host(obj,struct)
            obj.host_struct_ = struct;
        end
        function host_str = get.host(obj)
            host_str = obj.host_struct_;
        end
        function val = process_host_value(obj)
            fmt = obj.host.(obj.host_struct_field_);
            val= fmt.field_value;
            
        end
        
        %
        function bytes = bytes_from_field(obj,val)
            % convert the  array into invertible sequence of bytes
            nel = numel(val);
            type = class(val);
            if ~strcmp(type,obj.precision)
                data = feval(obj.precision,val);
            else
                data = val;
            end
            bytes = typecast(reshape(data,1,nel),'uint8');
        end
        function sz = size_of_field(obj,val)
            % calculate length of the array in bytes
            nel = numel(val);
            sz = nel*obj.elem_byte_size;
        end
        
        %
        function [val,sz] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the array
            nelem = obj.process_host_value();
            sz = double(nelem*obj.elem_byte_size);
            if sz ==0
                val = [];
            else
                val = typecast(bytes(pos:pos+sz-1),obj.precision);
                if numel(sz)>1
                    val = reshape(val,sz(:)');
                else
                    val = val';
                end
            end
        end
        function [sz,obj] = size_from_bytes(obj,bytes,pos)
            %size_length = obj.n_dims*4;
            nelem = obj.process_host_value();
            sz  = double(nelem*obj.elem_byte_size);
        end
        %
        function  [sz,obj,err] = size_from_file(obj,fid,pos)
            err = false;
            [sz,obj] = obj.size_from_bytes([],pos);
        end
        
    end
    
end

