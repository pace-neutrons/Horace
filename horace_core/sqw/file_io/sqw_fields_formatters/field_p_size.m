classdef field_p_size < field_const_array_dependent & iVirt_field
    %  The hepler  class to identify the dimensions of image arrays
    %
    %
    %
    % $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)
    %
    methods
        function obj=field_p_size(varargin)
            % constructor expects the name of the field, containing
            % the array-source of the data for this class
            obj = obj@field_const_array_dependent('npax');
            %
        end

        %
        function bytes = bytes_from_field(obj,struct)
            % convert variable into invertible sequence of bytes to store
            % on hdd
            bytes = [];
        end
        function sz = size_of_field(obj,struct)
            % calculate size of the field on HDD
             sz = 0;
        end

        %
        function [val,length] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the variable
            % and find its length
            n_cells = obj.process_host_value();
            length = 0;
            if n_cells  ==0
                val = [];
                return
            end
            val  = zeros(1,n_cells);
            sz = 4;
            for i=1:n_cells
                ndims = typecast(bytes(pos:pos+sz-1),'int32');
                size_i = double(ndims*obj.elem_byte_size);
                val(i) = double(ndims-1);
                pos = pos+sz+size_i;
            end
        end
        %
        function [sz,obj] = size_from_bytes(obj,bytes,pos)
            [obj.field_value,sz] = field_from_bytes(obj,bytes,pos);
        end
        %
        function  [length,obj,err] = size_from_file(obj,fid,pos)
            err = false;
            n_cells = obj.process_host_value();
            length = 0;
            if n_cells  ==0
                return
            end
            val  = zeros(1,n_cells);
            sz = 4;
            for i=1:n_cells

                try
                    do_fseek(fid,pos,'bof');
                catch
                    err = true;
                    return;
                end

                ndims = fread(fid,1,'int32');
                [~,res] = ferror(fid);
                if res ~=0
                    err = true;
                    return;
                end
                size_i = ndims*obj.elem_byte_size;
                val(i) = ndims-1;
                pos = pos+sz+size_i;
            end
            obj.field_value = val;
        end

    end

end
