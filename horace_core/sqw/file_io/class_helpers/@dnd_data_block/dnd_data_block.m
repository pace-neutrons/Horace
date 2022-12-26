classdef dnd_data_block < data_block
    % DND_DATA_BLOCK describes the binary data, corresponding to DnD object
    % arrrays (extracted by  dnd_data class) and used for storing/restoring
    % DnD object on HDD in a binary form.
    %
    % The special form of data_block binary data format is caused by need
    % to access dnd_data_block from third party (non-Matlab) applications
    %
    properties(Dependent)
        % properties defile the location of the appropriate arrays in
        % binary file. The positions are defined in bytes and canuted from
        % the begining of the file.
        sig_position;   % signal array position
        err_position;   % error array position
        npix_position;  % npix array positio
    end
    properties(Access=protected)
        dimensions_=[]; % number dimensions, the dnd arrays have
        data_size_=0;   % the result of size operation applied to a dnd
        %               % array
    end
    methods
        function obj = dnd_data_block(varargin)
            %DND_DATA_BLOCK constructor
            obj = obj@data_block(varargin{:});
            obj.sqw_prop_name = 'data';
            obj.level2_prop_name = 'nd_data';
        end
        %
        function pos = get.sig_position(obj)
            pos = obj.position_+4+obj.dimensions_*4;
        end
        function pos = get.err_position(obj)
            pos = obj.sig_position+8*prod(obj.data_size_);
        end
        function pos = get.npix_position(obj)
            pos = obj.sig_position+2*8*prod(obj.data_size_);
        end
        %
        function [obj,sqw_obj_to_set] = get_sqw_block(obj,fid,sqw_obj_to_set)
            % Read sub-block binary information from sqw object on HDD and
            % set this subobject to the proper field of the input sqw
            % object.
            subobj = obj.get_bindata_from_file(fid);
            if ~exist('sqw_obj_to_set','var') || isempty(sqw_obj_to_set)
                sqw_obj_to_set = subobj;
            else
                sqw_obj_to_set = obj.set_subobj(sqw_obj_to_set,subobj);
            end
        end
        function obj =calc_obj_size(obj,sqw_obj,varargin)
            % Overloaded: -- caclculate size of the serialized object and
            % put the serialized object into data cache for subsequent put
            % operation(s)
            subobj = obj.get_subobj(sqw_obj);
            obj.dimensions_ = subobj.dimensions();
            obj.data_size_  = subobj.data_size();

            % num_dim,+ size(arrays)*4+3 data arrays 2-single precision,
            % 4--uint64 each of prop(subobj.data_size) elements
            obj.size_ = 4+obj.dimensions_*4+(3*8)*prod(obj.data_size_);
            obj.serialized_obj_cache_ = subobj;
        end
    end
    methods(Access=protected)
        %-----------------------------------------------------------------
        function obj = put_bindata_in_file(obj,fid,obj_data)
            % Overloaded: -- store data containing in dnd_data_block class
            % into binary file
            % Inputs:
            % fid      -- opened file handle
            % obj_data -- full instance of dnd_data class
            %
            % Returns:
            % obj      -- unchanged
            % Eroror: HORACE:data_block:io_error is thrhown in case of
            %         problem with writing data fields
            obj = put_bindata_in_file_(obj,fid,obj_data);
        end
        function dnd_data_obj = get_bindata_from_file(obj,fid)
            % read information about dnd_data_block from opened binary file
            % and recover the instance of dnd_data_block class
            %
            % Inputs:
            % fid      -- opened file handle
            %
            % Returns:
            % dnd_data_obj
            %          -- instance of dnd_data read from file.
            %
            % Eroror: HORACE:data_block:io_error is thrhown in case of
            %         problem with redading data fields
            dnd_data_obj = get_bindata_from_file_(obj,fid);
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
            flds = {'position','size'};
        end
        %------------------------------------------------------------------
    end

end