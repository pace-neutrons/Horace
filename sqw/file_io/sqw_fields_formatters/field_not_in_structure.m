classdef field_not_in_structure < iVirt_field
    %  The class describes conversion applied to save/restore
    %  field, which defines some array length and is not stored together
    %  with the array
    %
    % Up to now only uint32 length fields are used by Horace
    %
    %
    % $Revision: 1148 $ ($Date: 2016-01-12 17:06:27 +0000 (Tue, 12 Jan 2016) $)
    %
    
    properties(Access=protected)
        precision_ = 'uint32'
        root_field_name_ =''
        n_prec_ = 4;
    end
    
    properties(Dependent)
        precision
        % the value determined from host field and used by host field
        % to recover itself
    end
    
    methods
        function obj=field_not_in_structure(varargin)
            % constructor expects the name of the field, referring to
            % the array-source of the data for this class
            if nargin ~= 1
                error('FIELD_NOT_IN_STRUCTURE:invalid_argument',...
                    [' field_not_in_structure has to be initialized with '...
                    'the name of the field this class gets its value from']);
            end
            obj.root_field_name_ = varargin{1};
            
            %
        end
        function pr = get.precision(obj)
            pr = obj.precision_;
        end
        %
        
        function bytes = bytes_from_field(obj,strct)
            % convert variable into invertible sequence of bytes
            val = strct.(obj.root_field_name_);
            data = uint32(numel(val));
            bytes = typecast(data,'uint8');
        end
        function sz = size_of_field(obj,struct)
            % calculate length of string defined by format string
            % invertible sequence of bytes
            %val = struct.(obj.root_field_name_);
            %sz = obj.n_prec_*ndims(val);
            sz = obj.n_prec_;
        end
        
        %
        function [val,length] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the variable
            length = obj.n_prec_;
            val = typecast(bytes(pos:pos+length-1),obj.precision);
        end
        %
        function [sz,obj] = size_from_bytes(obj,bytes,pos)
            sz = obj.n_prec_;
            obj.field_value = double(typecast(bytes(pos:pos+sz-1),obj.precision));
        end
        %
        function  [sz,obj,err] = size_from_file(obj,fid,pos)
            err = false;
            sz = obj.n_prec_;
            fseek(fid,pos,'bof');
            [~,res] = ferror(fid);
            if res ~=0
                err = true;
                return;
            end
            obj.field_value = fread(fid,sz/obj.n_prec_,obj.precision);
            [~,res] = ferror(fid);
            if res ~=0
                err = true;
                return;
            end
        end
        
    end
    
end

