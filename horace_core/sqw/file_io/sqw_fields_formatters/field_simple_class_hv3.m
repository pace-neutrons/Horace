classdef field_simple_class_hv3 < sqw_field_format_interface
    %  The class describes conversion to basic Matlab variables and arrays
    %  used in sqw format v3
    %
    %  The variable is serialized together with its length and class type
    %  so its format is fully self-consistent
    %
    %
    % $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
    %
    
    properties(Access=protected)
        precision_ = ''
        n_prec_ = [];
        % map of simple classes, which have standard conversion
        sclass_map_;
    end
    
    properties(Dependent)
        precision
        elem_byte_size % size of the array element in bytes
    end
    methods(Static)
        function bytes = head_to_bytes(type,shape)
            % method converts a class head into
            ctype = numel(type);
            bytes = [typecast(ctype,'uint8'),...
                uint8(type),typecast(numel(shape),'uint8'),...
                typecast(shape,'uint8')];
        end
        function sz = head_size(type,shape)
            ltype = numel(type);
            sz = 8+ltype+8+numel(shape)*8;
        end
        function [type,shape,sz] = head_from_bytes(bytes,pos)
            type_size = typecast(bytes(pos:pos+8-1),'double');
            sz = 8;
            type = char(bytes(pos+sz:pos+sz+type_size-1))';
            sz = sz + type_size;
            shape_size = typecast(bytes(pos+sz:pos+sz+8-1),'double');
            sz = sz + 8;
            shape = typecast(bytes(pos+sz:pos+sz+shape_size*8-1),'double');
            sz = sz + shape_size*8;
        end
        function [type,shape,sz] = head_sz_from_bytes(bytes,pos)
            class_size = typecast(bytes(pos:pos+8-1),'double');
            type = char(bytes(pos+8:pos+class_size+8-1))';
            sz = class_size+8;
            pos = pos+sz;
            shape_size = typecast(bytes(pos:pos + 8-1),'double');
            pos  = pos + 8;
            shape  = typecast(bytes(pos:pos+shape_size*8-1),'double');
            sz = sz+8+shape_size*8;
        end
        function [type,shape,sz] = head_sz_from_file(fid,pos)
            % class header sizes in bytes are:
            % 8 -- class descriptor size
            % class_descr -- the type descriptor (e.g. word 'double' or 'struct')
            % 8 -- size of the shape array
            % (shape array elements) x 8
            % elements of the array itself
            fseek(fid,pos,'bof');
            [mess,res] = ferror(fid);
            if res ~=0; error('FIELD_SIMPLE_CLASS:io_error',...
                    'Error moving to start of a class header %s',mess); end
            
            class_size = fread(fid,1,'float64');
            [mess,res] = ferror(fid);
            if res ~=0; error('FIELD_SIMPLE_CLASS:io_error',...
                    'Error reading the size of a class name: %s',mess); end
            %
            type = fread(fid,[1,class_size],'*char');
            [mess,res] = ferror(fid);
            if res ~=0; error('FIELD_SIMPLE_CLASS:io_error',...
                    'Error reading the class name: %s',mess); end
            
            sz = class_size+8;
            %
            shape_size = fread(fid,1,'float64');
            [mess,res] = ferror(fid);
            if res ~=0; error('FIELD_SIMPLE_CLASS:io_error',...
                    'Error reading the size of a shape array %s',mess); end
            sz = sz+8+shape_size*8;
            shape = fread(fid,[1,shape_size],'float64');
            [mess,res] = ferror(fid);
            if res ~=0; error('FIELD_SIMPLE_CLASS:io_error',...
                    'Error reading the class shape array %s',mess); end
        end
        
    end
    
    methods
        function obj=field_simple_class_hv3()
            % constructor
            %>>obj = field_simple_class_hv3()
            obj.sclass_map_ = sqw_field_format_interface.class_map_;
            obj.sclass_map_('logical') = 1;
            obj.sclass_map_('char') = 1;
        end
        function pr = get.precision(obj)
            pr = obj.precision_;
        end
        function nb = get.elem_byte_size(obj)
            nb = obj.n_prec_;
        end
        %
        function bytes = bytes_from_field(obj,val)
            % convert variable length array into
            % invertible sequence of bytes
            nel = numel(val);
            type = class(val);
            shape = size(val);
            if isa(val,'logical') ||isa(val,'char')
                bytes = [obj.head_to_bytes(type,shape),...
                    uint8(reshape(val,1,nel))];
            else
                bytes = [obj.head_to_bytes(type,shape),...
                    typecast(reshape(val,1,nel),'uint8')];
            end
        end
        function sz = size_of_field(obj,val)
            % calculate length of the variable on hdd or in byte stream
            type = class(val);
            if ~obj.sclass_map_.isKey(type)
                error('FIELD_SIMPLE_CLASS_HV3:invalid_argument',...
                    'size_of_field: Class %s can not be converted as simple class',...
                    type);
            end
            nel = numel(val);
            shape = size(val);
            bl_size = obj.sclass_map_(type);
            sz = field_simple_class_hv3.head_size(type,shape)+nel*bl_size;
        end
        
        %
        function [val,length] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the array
            [type,shape,sz] = obj.head_from_bytes(bytes,pos);
            if ~obj.sclass_map_.isKey(type)
                error('FIELD_SIMPLE_CLASS_HV3:invalid_argument',...
                    'field_from_bytes: Class %s can not be converted as simple class',...
                    type);
            end
            
            cl_size = obj.sclass_map_(type);
            nel = prod(shape);
            if strcmp(type,'logical')
                val = logical(bytes(pos+sz:pos+sz+nel-1));
            elseif strcmp(type,'char')
                val = char(bytes(pos+sz:pos+sz+nel-1));                
            else
                val  = typecast(bytes(pos+sz:pos+sz+nel*cl_size-1),type);
            end
            val = reshape(val,shape');
            length = sz+nel*cl_size;
        end
        %
        function [sz,obj] = size_from_bytes(obj,bytes,pos)
            [type,shape,sz] = obj.head_sz_from_bytes(bytes,pos);
            
            if ~obj.sclass_map_.isKey(type)
                error('FIELD_SIMPLE_CLASS_HV3:invalid_argument',...
                    'size_from_bytes: Class %s can not be converted as simple class',...
                    type);
            end
            elem_size = obj.sclass_map_(type);
            sz = sz + prod(shape)*elem_size;
            obj.precision_ = type;
            obj.n_prec_ = elem_size;
        end
        %
        function  [sz,obj,err] = size_from_file(obj,fid,pos)
            % Caclculate size of a simple class field reading it from file
            err = false;
            try
                [type,shape,sz] = obj.head_sz_from_file(fid,pos);
            catch ME
                if strcmp(ME.identifier, 'FIELD_SIMPLE_CLASS:io_error')
                    err = true;
                    return
                else
                    rethrow(ME);
                end
            end
            
            if ~obj.sclass_map_.isKey(type)
                error('FIELD_SIMPLE_CLASS_HV3:invalid_argument',...
                    'size_from_file: Class %s can not be converted as simple class',...
                    type);
            end
            elem_size = obj.sclass_map_(type);
            sz = sz + prod(shape)*elem_size;
            obj.precision_ = type;
            obj.n_prec_ = elem_size;
        end
        
    end
    
end

