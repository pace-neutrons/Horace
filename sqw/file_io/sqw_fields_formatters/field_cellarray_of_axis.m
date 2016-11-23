classdef field_cellarray_of_axis < field_const_array_dependent
    % transform cellarray of different size arrays
    
    
    properties
    end
    
    methods
        function obj=field_cellarray_of_axis(varargin)
            obj= obj@field_const_array_dependent(varargin{:});
        end
        function bytes = bytes_from_field(obj,val)
            % convert the cellarray of arrays into invertable sequence of bytes
            nel = numel(val);
            if nel ==0
                bytes = [];
                return
            end
            tBytes = cell(1,nel);
            for i=1:nel
                tBytes{i} = [typecast(int32(numel(val{i})),'uint8'),...
                    typecast(single(val{i}'),'uint8')];
            end
            bytes = [tBytes{:}];
            
        end
        function sz = size_of_field(obj,val)
            % calculate length of the array in bytes
            nel = numel(val);
            if nel ==0
                sz = 0;
                return
            end
            sz1 = cellfun(@(x)numel(x),val);
            sz = nel*4+sum(sz1)*obj.elem_byte_size;
        end
        
        %
        function [val,sz] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the array
            n_cells = obj.process_host_value();
            sz = 0;
            if n_cells  ==0
                val = {};
                return
            end
            val  = cell(1,n_cells);
            sz = 4;
            pos0 = pos;
            for i=1:n_cells
                size_i = typecast(bytes(pos:pos+sz-1),'int32')*obj.elem_byte_size;
                pos = pos+sz;
                val{i} = typecast(bytes(pos:pos+size_i-1),obj.precision);
                pos = pos+size_i;
            end
            sz = double(pos- pos0);
        end
        function [sz,obj] = size_from_bytes(obj,bytes,pos)
            %size_length = obj.n_dims*4;
            n_cells = obj.process_host_value();
            sz = 0;
            if n_cells  ==0
                return
            end
            sz = 4;
            pos0 = pos;
            for i=1:n_cells
                size_i = typecast(bytes(pos:pos+sz-1),'int32')*obj.elem_byte_size;
                pos = pos+sz+size_i;
            end
            sz = double(pos- pos0);
            
        end
        %
        function  [sz,obj,err] = size_from_file(obj,fid,pos)
            err = false;
            n_cells = obj.process_host_value();
            sz = 0;
            if n_cells  ==0
                return
            end
            sz = 4;
            pos0 = pos;
            %
            for i=1:n_cells
                fseek(fid,pos,'bof');
                [~,res] = ferror(fid);
                if res ~=0
                    err = true;
                    return;
                end
                
                size_i = fread(fid,1,'int32')*obj.elem_byte_size;
                [~,res] = ferror(fid);
                if res ~=0
                    err = true;
                    return;
                end
                
                pos = pos+sz+size_i;
            end
            sz = double(pos- pos0);
            
        end
        
        
    end
    
end

