classdef data_block < serializable
    %DATA_BLOCK describes the unit of binary data, part of sqw/dnd object
    % which faccess_sqw_v4 file format operates with.
    %
    % Block contains information about the block size, its location in the
    % binary file (stored in BAT) and the ways of extracting these data
    % from sqw/dnd object of interest or place this information into
    % sqw/dnd object
    %
    % The information, contained in particular data_block occupies
    % constant size within the block allocation table
    %
    % The blocks also knows how to retrieve its contents from
    % sqw object provied

    properties(Dependent)
        % unique name of the data_block, identifying this block in BAT.
        block_name;
        % the name of the property of sqw/dnd object the block operates
        % with. E.g.: sqw_obj.experiment_info (experiment_info)
        sqw_prop_name;
        % the name of the property of the part of sqw object obtained by
        % calling sqw_prop_name used to extract/set-up the part of the data
        % this data_block operates with. E.g.:
        % sqw_obj.experiment_info.instruments (instruments)
        level2_prop_name;
        % position of the binary block on hdd in C numeration (first byte is
        % in the position 0)
        position;
        % size (in bytes) of the serialized block would occupy on hdd
        size;
        % True if BAT operations should not move this block from its place
        % on HDD (normally used for PixelData(Filebacked), which are big and
        % should not be moved into new place if object is modified.
        locked
    end
    properties(Dependent,Hidden)
        % return class name -- property, used for serialization into BAT
        % structure. Hidden not to pollute main class interface
        serial_name;
        % the format used to serialize class into BAT record,
        bat_format;
        % size (in bytes) this BAT record would occupy on hdd
        bat_record_size;
        % return array of bytes, necessary to store and/or recover initialized
        % data block class from blockAllocationTable.
        bat_record;
        % true if block position was initialized, i.e. its file position
        % have been set and size is known
        allocated
    end
    properties(Access=protected)
        sqw_prop_name_ ='';
        level2_prop_name_ = '';
        position_=uint64(0);
        size_ = 0;
        % The cache containing serialized object after estimating its size
        serialized_obj_cache_ = [];
        %
        locked_ = false;
    end
    %======================================================================
    methods
        function [obj,sqw_obj_to_set] = get_sqw_block(obj,fid,sqw_obj_to_set)
            % Read sub-block binary information from sqw object on HDD and
            % set this sub-object to the proper field of the input sqw
            % object.
            bindata = obj.get_bindata_from_file(fid);
            try
                subobj = serializable.deserialize(bindata);
            catch ME
                if strcmp(ME.identifier,'HERBERT:serializable:invalid_argument')
                    subobj = deserialize(bindata);
                else
                    rethrow(ME);
                end
            end
            if ~exist('sqw_obj_to_set','var') || isempty(sqw_obj_to_set)
                sqw_obj_to_set = subobj;
            else
                sqw_obj_to_set = obj.set_subobj(sqw_obj_to_set,subobj);
            end
        end
        %
        function obj = put_sqw_block(obj,fid,sqw_obj,check_size)
            % extract sub-block information from sqw or dnd object and write
            % this information on HDD
            % Inputs:
            % obj     -- initialized instance of data_block
            % fid     -- handle for binary file opened for write access
            % Optional:
            % sqw_obj -- if present, the data to save should be taken from
            %            the object provided.
            % check_size
            %         -- if present and true, expect that the object size
            %            has been precalculated earlier and now we want to
            %            ectract binary data from the input object. Does
            %            check if the size of binary data in the object
            %            still equal to size precalculated earlier. Throws
            %            if this does not happen
            %
            if nargin<3
                sqw_obj = [];
            end
            if nargin<4
                check_size = false;
            else
                check_size = logical(check_size);
            end
            obj = put_sqw_block_(obj,fid,sqw_obj,check_size);
        end
        function obj = calc_obj_size(obj,sqw_obj,nocache,check_size)
            % calculate size of the serialized sqw/dnd sub-object and put
            % the serialized sub-object into data cache for subsequent put
            % operation(s)
            %
            % Inputs:
            % obj     -- instance of data block class
            % sqw_obj -- sqw/dnd object - source of data for this
            %            data_block
            % nocache  -- if present and true do not serialize subobject for
            %             evaluating its size and placing serialized array
            %             into cache but use serializable.serial_size
            %             method to find the object size.
            % check_size
            %          -- if present and true, assumes that the size and
            %             position of the object was identified before
            %             (e.g. using nocache option) and are all known.
            %             Сhecks serialized size of the object against the
            %             size of the array calculated while serializing
            %             to ensure that precaclulatrions were performed
            %             correctly.
            %
            if nargin < 3 % nocache input is missing
                nocache = false;
            else
                nocache = logical(nocache);
            end
            if nargin <4
                check_size  = false;
            else
                check_size = logical(check_size);
            end
            obj = calc_obj_size_(obj,sqw_obj,nocache,check_size);
        end
        %------------------------------------------------------------------
        function subobj = get_subobj(obj,sqw_dnd_obj)
            % Extract class-defined sub-object from sqw or dnd object for
            % further operations. (serialization and damping to hdd)
            %
            % Generic value extractor, valid for majority of the sqw object
            % sub-objects we may want to extract.
            % If input is not a SQWDnDBase object, it is expected that the
            % necessary sub-object is provided as input
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
    end
    %======================================================================
    methods(Access=protected)
        function size = get_size(obj)
            % Overloadable part of data_block size getter
            size  =   obj.size_;
        end
        function obj = set_size(obj,val)
            % Overloadable part of data_block size setter
            if ~(isscalar(val)&&isnumeric(val)&&val>=0)
                error('HORACE:data_block:invalid_argument', ...
                    'block size can be only non-negative number. It is %s',...
                    disp2str(val));
            end
            obj.size_ = uint64(val);
        end

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
            % Eroror: HORACE:data_block:io_error is thrown in case of problem with
            %         reading data files
            bindata = get_bindata_from_file_(obj,fid);
        end

    end
    %======================================================================
    % CONSTRUCTOR and PROPERTY ACCESSORS
    methods
        function obj = data_block(varargin)
            %DATA_BLOCK constructor to create data block re
            if nargin == 0
                return;
            end
            if nargin == 1 && isstruct(varargin{1})
                obj = serializable.from_struct(varargin{1});
            else
                fldNames = obj.saveableFields();
                [obj,remains] = set_positional_and_key_val_arguments(obj,...
                    fldNames,false,varargin{:});
                if ~isempty(remains)
                    error('HORACE:data_block:invalid_argument', ...
                        'Unrecognised properties/values are provided to the block constructor %s',...
                        disp2str(remains));
                end
            end
        end
        %
        function name = get.block_name(obj)
            name = sprintf('bl_%s_%s',obj.sqw_prop_name,obj.level2_prop_name);
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
            nm = obj.level2_prop_name_;
        end
        function obj = set.level2_prop_name(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HORACE:data_block:invalid_argument', ...
                    'Second property name can be only string or character array. In fact its class is %s', ...
                    class(val));
            end
            obj.level2_prop_name_ = val;
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
            obj.position_ = uint64(val);
        end
        %
        function size = get.size(obj)
            size = uint64(get_size(obj));
        end
        function obj = set.size(obj,val)
            obj = set_size(obj,val);
        end
        function is = get.allocated(obj)
            is = obj.position_ > 0 && obj.size > 0;
            % note call to public size to allow overloading
        end
        %
        function is = get.locked(obj)
            is = obj.locked_;
        end
        function obj = set.locked(obj,val)
            obj.locked_ = logical(val);
        end

    end
    methods(Access=protected)
        function move_to_position(obj,fid,pos)
            % move read or write point to the position, specified by class
            % properties.
            %
            % Inputs:
            % obj  -- initialized instance of data_block,
            %
            % Optional:
            % pos -- specify position to move as input argument
            %
            % Throw, HORACE:data_block:io_error if the movement have not succeeded.
            %
            if nargin<3
                pos = [];
            end
            move_to_position_(obj,fid,pos);
        end
        function check_write_error(obj,fid,add_info)
            % check if write operation have completed successfully.
            %
            % Throw HORACE:data_block:io_error if there were write errors.
            %
            % If add_info is not empty, it added to the error message and
            % used for clarification of the error location.
            if ~exist('add_info','var')
                add_info = '';
            end
            check_write_error_(obj,fid,add_info);
        end
        function check_read_error(obj,fid,add_info)
            % check if read operation have completed successfully.
            %
            % Throw HORACE:data_block:io_error if there were read errors.
            %
            % If add_info is not empty, it added to the error message and
            % used for clarification of the error location.
            if ~exist('add_info','var')
                add_info = '';
            end
            check_read_error_(obj,fid,add_info);
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACES
    % Two serializable interfaces are defined here. One for supporting Matlab
    % loadobj/saveobj operations and other -- for supporting serialization
    % the records, stored in the BlockAllocationTable.
    properties(Constant,Access=protected)
        % structure describes the format of the record conversion in BAT table
        % the name of format retrieves the property to store and the
        % type of value specifies what format use for serializing this
        % property.
        bat_record_format_ = struct('serial_name','', ...
            'sqw_prop_name','','level2_prop_name','',...
            'position',uint64(1),'size',uint64(1))
        serializer_ = sqw_serializer();
    end
    methods(Static)
        function [data_bl_obj,pos] =deserialize_bat_record(bindata,pos)
            % Recover data block class instance from BlockAllocationTable
            % record
            % Inputs:
            % bindata -- array of uint8 elements containing serialized
            %            information to recover
            % Optional:
            % pos     -- the position of data to recover in the input
            %            array. If missing, assumed that the data are
            %            located at the beginning of the array
            if ~exist('pos','var')
                pos = 1;
            end
            [targ_struc,pos] = data_block.serializer_.deserialize_bytes(...
                bindata,data_block.bat_record_format_,pos);
            data_bl_obj = feval(targ_struc.serial_name,targ_struc);
        end
    end

    methods
        %------------------------------------------------------------------
        % OLD SQW BINDATA SERIALIZE INTERFACE, used to store data in BAT table
        function name = get.serial_name(obj)
            name = class(obj);
        end
        function format = get.bat_format(~)
            format = data_block.bat_record_format_;
        end
        function batr_size = get.bat_record_size(obj)
            [~,pos] = data_block.serializer_.calculate_positions(obj.bat_format, ...
                obj);
            batr_size = pos-1;
        end
        function batr = get.bat_record(obj)
            batr = data_block.serializer_.serialize(obj,obj.bat_format());
        end
        %-----------------------------------------------------------------
        % Global Serialization interface
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