classdef data_block < serializable
    %DATA_BLOCK describes the unit of binary data, part of sqw/dnd object
    % which faccess_sqw_v4 file format operates with.
    %
    % Block contains information about the block size, its location in the
    % binary file and the ways of extracting these data from sqw/dnd object
    % of interest or place this information into sqw/dnd object

    properties(Dependent)
        sqw_prop_name;
        level2_prop_name;
        % position of the binary block on hdd in C numeration (first byte is
        % in the position 0)
        position;
        % size (in bytes) of the block would occupy on hdd
        size;
    end
    properties(Access=protected)
        sqw_prop_name_ ='';
        second_prop_name_ = '';
        position_=0;
        size_ = 0;
        % The cache containing serialized object after estimating its size
        serialized_obj_cache_ = [];
    end
    %======================================================================
    methods
        function [obj,sqw_obj_to_set] = get_data_block(obj,fid,sqw_obj_to_set)
            % Read sub-block binary information from sqw object on HDD and
            % set this subobject to the proper field of the input sqw
            % object.
            bindata = obj.get_bindata_from_file(fid);
            subobj = serializable.deserialize(bindata);
            sqw_obj_to_set = obj.set_subobj(sqw_obj_to_set,subobj);
        end
        %
        function obj = put_data_block(obj,fid,sqw_obj)
            % extract sub-block information from sqw object and write this
            % information on HDD
            if exist('sqw_obj','var')
                obj = obj.cache_and_calc_obj_size(sqw_obj);
            else
                if isempty(obj.serialized_obj_cache_)
                    error('HORACE:data_block:runtime_error',...
                        ['put_data_block is called sqw object argument, ', ...
                        'but the size of the object has not been set ', ...
                        'and object cache is empty']);
                end
            end
            bindata = obj.serialized_obj_cache_;
            obj = obj.put_bindata_in_file(fid,bindata);
            if nargout>0
                obj.serialized_obj_cache_ = [];
            end
        end
        function obj = cache_and_calc_obj_size(obj,sqw_obj)
            % caclculate size of the serialized object and put the
            % serialized object into data cache for subsequent put
            % operation(s)
            subobj = obj.get_subobj(sqw_obj);
            bindata = subobj.serialize();
            obj.size_ = numel(bindata);
            obj.serialized_obj_cache_ = bindata;
        end
        %
        %==================================================================
        %    end % --- Should it be protected?
        %    methods(Access=protected)
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
            %
            % Sets the value of the property, defined by class,
            % to the appropriate place of the input sqw object.
            % Inputs:
            % sqw_dnd_obj -- input sqw or dnd object to set property value
            %                on
            sqw_dnd_obj = set_subobj_(obj,sqw_dnd_obj,part_to_set);
        end
        %------------------------------------------------------------------
        function obj = put_bindata_in_file(obj,fid,bindata)
            % store array of bytes into selected and opened binary file
            % Inputs:
            % fid      -- opened file handle
            % bindata  -- array of bytes to store on hdd
            %
            % Returns:
            % obj      -- unchanged
            obj = put_bindata_in_file_(obj,fid,bindata);
        end
        function bindata = get_bindata_from_file(obj,fid)
            % read array of bytes from opened binary file
            %
            % Inputs:
            % fid      -- opened file handle
            %
            % Returns:
            % bindata  -- unit8 array of the data read from file.
            %
            % Eroror: HORACE:data_block:io_error is thrhown in case of problem with
            %         redading data files
            bindata = get_bindata_from_file_(obj,fid);
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
        function nm = get.sqw_prop_name(obj)
            nm = obj.sqw_prop_name_;
        end
        function obj = set.sqw_prop_name(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HORACE:data_block:invalid_argument', ...
                    'Primary property name can be only string or character array. In fact its class is %s', ...
                    class(val));
            end
            obj.sqw_prop_name_ = val;
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
    methods(Access=protected)
        function move_to_position(obj,fid,pos)
            % move write point to the position, specified by class
            % properties.
            %
            % Inputs:
            % obj  -- initialized instance of data_block,
            %
            % Optional:
            % pos -- specify potition to move as input argument
            %
            % Throw, HORACE:data_block:io_error if the movement have not sucseeded.
            %
            if nargin<3
                pos = [];
            end
            move_to_position_(obj,fid,pos);
        end
        function check_write_error(obj,fid,add_info)
            % check if write operation have completed sucsesfully.
            %
            % Throw HORACE:data_block:io_error if there were write errors.
            %
            % If add_info is not empty, it added to the error message and
            % used for clarification of the error location.
            if ~exist('add_info','var')
                add_info = '';
            end
            check_io_error_(obj,fid,'writing',add_info);
        end
        function check_read_error(obj,fid,add_info)
            % check if read operation have completed sucsesfully.
            %
            % Throw HORACE:data_block:io_error if there were read errors.
            %
            % If add_info is not empty, it added to the error message and
            % used for clarification of the error location.
            if ~exist('add_info','var')
                add_info = '';
            end
            check_io_error_(obj,fid,'reading',add_info);
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
            flds = {'sqw_prop_name','level2_prop_name','position','size'};
        end
        %------------------------------------------------------------------
    end
end