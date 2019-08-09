classdef field_generic_class_hv3 < field_simple_class_hv3
    %  The class describes conversion of arbitrary Matlab variable and arrays
    %  used to read/write data in sqw format v3
    %
    %  The variable is serialized together with its length and class type
    %  so its format is fully self-consistent
    %
    %
    % $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
    %
    
    properties(Access=private)
    end
    
    properties(Dependent)
    end
    
    methods
        function obj=field_generic_class_hv3()
            % :
            %>>obj = field_simple_class_hv3()
            % or
            %>>obj = field_var_array(n_dimensions)
            % assumes
            %
        end
        %
        function bytes = bytes_from_field(obj,val)
            % convert variable length array into
            % invertible sequence of bytes
            type = class(val);
            
            if obj.sclass_map_.isKey(type)
                bytes = bytes_from_field@field_simple_class_hv3(obj,val);
                return;
            end
            %
            shape = size(val);
            head = obj.head_to_bytes(type,shape);
            bytes = convert_cell_struct_or_class_(obj,head,val);
        end
        %
        function sz = size_of_field(obj,val)
            % calculate length of the variable on hdd or in byte stream
            type = class(val);
            if obj.sclass_map_.isKey(type)
                sz = size_of_field@field_simple_class_hv3(obj,val);
                return;
            end
            shape = size(val);
            sz  = obj.head_size(type,shape);
            sz = size_of_cell_struct_or_class_(obj,sz,type,shape,val);
            
        end
        %
        function [var,sz] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the generic object
            if size(bytes,1) == 1
                bytes = bytes';
            end
            % get the information, describing common structure of the data,
            % i.e. class name, shape and size of the data
            [type,shape,sz] = obj.head_from_bytes(bytes,pos);
            if obj.sclass_map_.isKey(type)
                [var,sz] = field_from_bytes@field_simple_class_hv3(obj,bytes,pos);
                return;
            end
            pos = pos + sz;
            if strcmp(type,'cell')
                [var,sz] = restore_cellarray_(obj,bytes,pos,shape,sz);
                return;
            elseif strcmp(type,'function_handle')
                fhl = typecast(bytes(pos:pos+8-1),'double');
                f_name = char(bytes(pos+8:pos+8+fhl-1))';
                var = str2func(f_name);
                sz = sz+8+fhl;
                return;
            end
            % structure or custom class
            % get field names and array shape
            [names,sz,pos]=restore_fieldnames_(bytes,pos,sz);
            %
            if strcmp(type,'struct')
                [var,sz] = restore_structure_(obj,bytes,names,shape,pos,sz);
                return
            end
            % custom class name
            [var,sz] = restore_class_(obj,bytes,names,type,shape,pos,sz);
        end
        %
        function [sz,obj] = size_from_bytes(obj,bytes,pos)
            if size(bytes,1) == 1
                bytes = bytes';
            end
            
            [type,shape,sz] = obj.head_sz_from_bytes(bytes,pos);
            if obj.sclass_map_.isKey(type)
                [sz,obj] = size_from_bytes@field_simple_class_hv3(obj,bytes,pos);
                return
            end
            obj.precision_ = type;
            pos = pos + sz;
            
            if strcmp(type,'cell')
                sz = proces_cellarray_size_(obj,bytes,pos,shape,sz);
                obj.n_prec_ = sz;
                return
            elseif strcmp(type,'function_handle')
                fn_len=typecast(bytes(pos:pos+8-1),'double');
                sz = sz + 8 + fn_len;                
                return
            end
            % structure or custom class
            % get field names
            [sz,n_fields,pos] = size_fieldnames_(bytes,pos,sz);
            % treat class and structure the same way,i.e. analysing the
            % list of the public fields
            sz = size_structure_(obj,bytes,n_fields,shape,pos,sz);
            obj.n_prec_ = sz;            
            
        end
        %
        function  [sz,obj,err] = size_from_file(obj,fid,pos)
            %
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
            if obj.sclass_map_.isKey(type)
                elem_size = obj.sclass_map_(type);
                sz = sz + prod(shape)*elem_size;
                obj.precision_ = type;
                obj.n_prec_ = elem_size;
                return
            end
            obj.precision_ = type;
            pos = pos + sz;
            
            if strcmp(type,'cell')
                [sz,err] = cellarray_size_from_file_(obj,fid,pos,shape,sz);
                obj.n_prec_ = sz;
                return
            end
            % structure or custom class
            % get field names
            [sz,n_fields,pos,err] = size_fieldnames_from_file_(fid,pos,sz);
            if err; return; end;
                
            % treat class and structure the same way,i.e. analysing the
            % list of the public fields
            sz = size_structure_from_file_(obj,fid,n_fields,shape,pos,sz);
            obj.n_prec_ = sz;
        end
    end
    
end