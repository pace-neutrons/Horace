classdef data_block < serializable
    %DATA_BLOCK describes the unit of binary data, which faccess_sqw_v4
    %operates with.
    %
    %Block contains information about the block size, its location in the
    %binary file and the ways of extracting these data from sqw/dnd object of
    %interest or placing this object there

    properties(Dependent)
        name;
        position;
        size;
    end
    properties(Access=protected)
        name_ ='';
        position_=0;
        size_ = 0;
    end
    %======================================================================
    methods
        function obj = put_block_data(obj,fid,sqw_obj)
            % extract sub-block information from sqw object and write this
            % information on HDD
            subobj = extract_proper_subobj(sqw_obj);
            bindata = subobj.serialize();
            obj.size_ = numel(bindata);
            obj = put_bindata_in_file(obj,fid,bindata);
        end
        function obj = put_bindata_in_file(obj,fid,bindata)
            % store array of bytes into selected and opened binary file
            % Inputs: 
            % fid      -- opened file handle
            % bindata  -- array of bytes to store on hdd
            obj = put_bindata_in_file_(obj,fid,bindata);
        end
    end
    %======================================================================
    % CONSTRUCTOR and PROPERTY ACCESSORS
    methods
        function obj = data_block(varargin)
            if nargin == 0
                return;
            end
            fldNames = obj.saveableFields();
            [obj,remains] = set_positional_and_key_val_arguments(obj,...
                fldNames,false,varargin{:});
            if ~isempty(remains)
                error('HORACE:data_block:invalid_argument', ...
                    'Unrecognized properties/values are provided to the block constructor %s',...
                    disp2str(remains));
            end
        end
        %
        function nm = get.name(obj)
            nm = obj.name_;
        end
        function obj = set.name(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HORACE:data_block:invalid_argument', ...
                    'Block name can be only string or character array. In fact its class is %s', ...
                    class(val));
            end
            obj.name_ = val;
        end
        %
        function pos = get.position(obj)
            pos = obj.position_;
        end
        function obj = set.position(obj,val)
            if ~(isscalar(val)&&isnumeric(val)&&val>=0)
                error('HORACE:data_block:invalid_argument', ...
                    'block position can be only non-negative number. It is %s',...
                    disp2str(val));
            end
            obj.position_ = val;
        end
        %
        function pos = get.size(obj)
            pos = obj.size_;
        end
        function obj = set.size(obj,val)
            if ~(isscalar(val)&&isnumeric(val)&&val>=0)
                error('HORACE:data_block:invalid_argument', ...
                    'block size can be only non-negative number. It is %s',...
                    disp2str(val));
            end
            obj.size_ = val;
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods
        function  ver  = classVersion(~)
            % serializable fields version
            ver = 1;
        end
        function flds = saveableFields(~)
            flds = {'name','position','size'};
        end
        %------------------------------------------------------------------
    end
end