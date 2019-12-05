classdef field_pix < field_var_array
    %  The class describes conversion applied to save/restore
    %  unknown length array of single or double precision values
    %
    %  The length of the array is specified || identified during conversion
    %
    %
    % $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
    %
    
    properties(Access=private)
    end
    
    properties(Dependent)
    end
    properties(Constant,Access=private)
        old_matlab_ = verLessThan('matlab','7.12');
    end
    
    methods
        function obj=field_pix()
            % usage:
            %>>obj = field_pix()
            %
            obj = obj@field_var_array();
        end
        %
        function bytes = bytes_from_field(obj,val)
            % convert variable length array into
            % invertible sequence of bytes
            sz = size(val);
            nel = prod(sz);
            num_pix = uint64(sz(2));
            type = class(val);
            if ~strcmp(type,obj.precision)
                data = feval(obj.precision,val);
            else
                data = val;
            end
            bytes = [typecast(num_pix,'uint8'),...
                typecast(reshape(data,1,nel),'uint8')];
        end
        function sz = size_of_field(obj,val)
            % calculate length of string defined by format string
            % invertible sequence of bytes
            nel = numel(val);
            sz = 8+nel*obj.elem_byte_size;
        end
        
        %
        function [val,length] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the array
            npix  = typecast(bytes(pos:pos+8-1),'uint64');
            if obj.old_matlab_
                npix = double(npix);
            end
            numel = npix*9;
            length = numel*obj.elem_byte_size;
            start = 8;
            if numel ==0
                val = [];
            else
                val = typecast(bytes(pos+start:pos+start+length-1),obj.precision);
                val = reshape(val,[9,npix]);
            end
            length = double(length +start);
        end
        function [sz,obj] = size_from_bytes(obj,bytes,pos)
            numel  = typecast(bytes(pos:pos+8-1),'uint64')*9;
            sz  = double(8+ numel*obj.elem_byte_size);
        end
        %
        function  [sz,obj,err] = size_from_file(obj,fid,pos)
            err = false;
            fseek(fid,pos,'bof');
            [~,res] = ferror(fid);
            if res ~=0
                err = true;
                return;
            end            
            nelem = fread(fid,1,'*uint64')*9;
            [~,res] = ferror(fid);
            if res ~=0
                err = true;
                return;
            end            
            
            sz = double(nelem*obj.elem_byte_size +8 );
        end
        
    end
    
end


