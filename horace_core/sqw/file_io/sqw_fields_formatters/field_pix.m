classdef field_pix < field_var_array
    %  The class describes conversion applied to save/restore
    %  pixel data.
    %
    %  The length of the pixel data array is specified || identified from
    %  the class information, but pixel data themselves are written
    %  separately as plain array
    %
    %
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
            % calculate length of pixel field
            
            if isa(val, 'PixelDataBase')
                nel = val.num_pixels*val.DEFAULT_NUM_PIX_FIELDS;
            else
                nel = numel(val);
            end
            sz = 8+nel*obj.elem_byte_size;
        end
        
        %
        function [val,length] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the array
            npix  = typecast(bytes(pos:pos+8-1),'uint64');
            if obj.old_matlab_
                npix = double(npix);
            end
            numel = npix*PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
            length = numel*obj.elem_byte_size;
            start = 8;
            if numel ==0
                val = [];
            else
                val = typecast(bytes(pos+start:pos+start+length-1),obj.precision);
                val = reshape(val,[PixelDataBase.DEFAULT_NUM_PIX_FIELDS,npix]);
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
            do_fseek(fid,pos,'bof');
            [~,res] = ferror(fid);
            if res ~=0
                err = true;
                return;
            end
            nelem = fread(fid,1,'*uint64')*PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
            [~,res] = ferror(fid);
            if res ~=0
                err = true;
                return;
            end
            
            sz = double(nelem*obj.elem_byte_size +8 );
        end
        
    end
    
end


