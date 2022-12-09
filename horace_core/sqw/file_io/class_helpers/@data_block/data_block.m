classdef data_block < serializable
    %DATA_BLOCK describes the unit of binary data, part of sqw/dnd object
    % which faccess_sqw_v4 file format operates with.
    %
    % Block contains information about the block size, its location in the
    % binary file and the ways of extracting these data from sqw/dnd object
    % of interest or place this information into sqw/dnd object

    properties(Dependent)
        base_prop_name;
        level2_prop_name;
       % position of the binary block on hdd in C numeration (first byte is
       % in the position 0)
        position; 
        % size (in bytes) of the block would occupy on hdd
        size;
    end
    properties(Access=protected)
        base_prop_name_ ='';
        second_prop_name_ = '';
        position_=0;
        size_ = 0;
    end
    %======================================================================
    methods
        function obj = put_block_data(obj,fid,sqw_obj)
            % extract sub-block information from sqw object and write this
            % information on HDD
            subobj = obj.get_subobj(sqw_obj);
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
        %
        function subobj = get_subobj(obj,sqw_dnd_obj)
            % Extract class-defined sub-object from sqw or dnd object for
            % further operations. (serialization and damping to hdd)
            %
            % Generic value extractor, valid for majority of the sqw object
            % sub-objects we may want to extract. A specific subobject
            % should overload this function
            subobj = get_subobj_(obj,sqw_dnd_obj);
        end
        function sqw_dnd_obj = set_subobj(obj,sqw_dnd_obj,part_to_set)
            % Set up class-defined sub-object at proper place of input
            % sqw_dnd_object. The operation is opposite to get_subobj and
            % used during recovery of the stored sqw object from binary file. 
            sqw_dnd_obj = set_subobj_(obj,sqw_dnd_obj,part_to_set);
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
        function nm = get.base_prop_name(obj)
            nm = obj.base_prop_name_;
        end
        function obj = set.base_prop_name(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HORACE:data_block:invalid_argument', ...
                    'Primary property name can be only string or character array. In fact its class is %s', ...
                    class(val));
            end
            obj.base_prop_name_ = val;
        end
        %
        function nm = get.level2_prop_name(obj)
            nm = obj.second_prop_name_;
        end
        function obj = set.level2_prop_name(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HORACE:data_block:invalid_argument', ...
                    'Second property name can be only string or character array. In fact its class is %s', ...
                    class(val));
            end
            obj.second_prop_name_ = val;
        end        
        %------------------------------------------------------------------
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
            flds = {'base_prop_name','level2_prop_name','position','size'};
        end
        %------------------------------------------------------------------
    end
end