classdef field_img < field_const_array_dependent
    % describes format s,e and npix data fields
    
    properties
    end
    
    methods
        function obj=field_img(varargin)
            obj= obj@field_const_array_dependent('p_size',1,varargin{:});
        end
        function dim = process_host_value(obj)
            % get size of the array from axis field
            fmt = obj.host.(obj.host_struct_field_);
            dim= fmt.field_value;
            if isempty(dim)
                dim = [1,1];
            end
            
        end
        
        
        %
        function [val,sz] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the array
            dims = obj.process_host_value();
            nelem = prod(dims);
            sz = double(nelem*obj.elem_byte_size);
            if sz ==0
                val = [];
            else
                val = typecast(bytes(pos:pos+sz-1),obj.precision);
                if numel(dims)>1
                    val = reshape(val,dims(:)');
                end
            end
        end
        function [sz,obj] = size_from_bytes(obj,bytes,pos)
            %size_length = obj.n_dims*4;
            dim = obj.process_host_value();
            nelem = prod(dim);
            sz  = double(nelem*obj.elem_byte_size);
        end
        %
        function  [sz,obj,err] = size_from_file(obj,fid,pos)
            err = false;
            [sz,obj] = obj.size_from_bytes([],pos);
        end
        
        
        
    end
    
end

