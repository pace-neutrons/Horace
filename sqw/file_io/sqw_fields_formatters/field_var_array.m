classdef field_var_array < sqw_field_format_interface
    %  The class describes conversion applied to save/restore
    %  unknown length array of single or double precision values
    %  when the length of the array is stored in front of the data
    %  and restored during conversion
    %
    %
    % $Revision$ ($Date$)
    %
    
    properties(Access=private)
        n_dims_
        precision_ = 'single'
        n_prec_ = 4;
        %
    end
    
    properties(Dependent)
        n_dims
        precision
        elem_byte_size % size of the array element in bytes
    end
    
    methods
        function obj=field_var_array(varargin)
            % usage:
            %>>obj = field_var_array([n_dimensions,[presision]])
            % n_dimensions -- defines number of array dimensions
            % presision    -- the array's elements precision (single,
            %                 double, int etc)
            % or
            %>>obj = field_var_array(n_dimensions)
            % assumes
            if nargin==0
                obj.n_dims_ = 1;
            else
                if ~isnumeric(varargin{1})
                    error('FIELD_VAR_ARRAY:invalid_argument',...
                        'first argument of field_var_array has to contain number of array dimensions')
                end
                obj.n_dims_ = varargin{1};
            end
            if nargin > 1
                prec = varargin{2};
                is = sqw_field_format_interface.class_map_.isKey(prec);
                if is
                    obj.precision_ = prec;
                    obj.n_prec_ = sqw_field_format_interface.class_map_(prec);
                else
                    error('FIELD_VAR_ARRAY:invalid_argument',...
                        ['second input argument for field_var_array constructor',...
                        ' can only belong to basic types.\n Got: %s'],...
                        prec)
                end
            end
            %
        end
        function nd = get.n_dims(obj)
            nd = obj.n_dims_;
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
            if obj.n_dims_ == 1
                a_size = int32(nel);
            else
                a_size = int32(size(val));
            end
            type = class(val);
            if ~strcmp(type,obj.precision_)
                data = feval(obj.precision_,val);
            else
                data = val;
            end
            bytes = [typecast(a_size,'uint8'),...
                typecast(reshape(data,1,nel),'uint8')];
        end
        function sz = size_of_field(obj,val)
            % calculate length of string defined by format string
            % invertible sequence of bytes
            nel = numel(val);
            if obj.n_dims_ == 1
                a_size = nel;
            else
                a_size = size(val);
            end
            sz = numel(a_size)*4+nel*obj.n_prec_;
        end
        
        %
        function [val,length] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the array
            sz  = typecast(bytes(pos:pos+obj.n_dims*4-1),'int32');
            length = prod(double(sz))*obj.n_prec_;
            start = obj.n_dims*4;
            if length ==0
                val = [];
            else
                val = typecast(bytes(pos+start:pos+start+length-1),obj.precision_);
                if numel(sz)>1
                    val = reshape(val,sz(:)');
                else
                    val = val';
                end
            end
            length = length +start;
        end
        function [sz,obj] = size_from_bytes(obj,bytes,pos)
            size_length = obj.n_dims*4;
            dims = double(typecast(bytes(pos:pos+size_length-1),'uint32'));
            nelem = prod(dims);
            sz  = double(obj.n_dims*4+ nelem*obj.n_prec_);
        end
        %
        function  [sz,obj,err] = size_from_file(obj,fid,pos)
            err = false;
            size_length = obj.n_dims;
            
            fseek(fid,pos,'bof');
            [~,res] = ferror(fid);
            if res ~=0
                err = true;
                return;
            end
            
            dims = fread(fid,obj.n_dims,'uint32');
            [~,res] = ferror(fid);
            if res ~=0
                err = true;
                return;
            end
            
            nelem = prod(dims);
            sz = double(nelem*obj.n_prec_ +size_length*4);
        end
        
    end
    
end

