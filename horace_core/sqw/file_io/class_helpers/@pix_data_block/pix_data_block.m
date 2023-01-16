classdef pix_data_block < data_block
    % PIX_DATA_BLOCK describes the binary data, corresponding to pixelData
    % arrays (extracted by  pix_data class v0) and used for storing/restoring
    % object on HDD in a binary form if it is possible or ogranizing
    % file-based access to the data on HDD.
    %
    % The special form of data_block binary data format is caused by need
    % to access pix_data_block from third party (non-Matlab) applications
    %
    properties(Dependent)
        % properties defile the location of the appropriate arrays in
        % binary file. The positions are defined in bytes and counted from
        % the beginning of the file.
        npix_position;  % position of the uint64 variable describing the 
        %               % number of pixels contributed into sqw file
        pix_position;   % position of the 
    end
    properties(Access=protected)
    end
    methods
        function obj = pix_data_block(varargin)
            %DND_DATA_BLOCK constructor
            obj = obj@data_block(varargin{:});
            obj.sqw_prop_name = 'pix';
            obj.level2_prop_name = 'data_wrap';
        end
        %
        function pos = get.npix_position(obj)
            pos = obj.position_+4;
        end
        function pos = get.pix_position(obj)
            pos = obj.position_+12;
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
        function obj =calc_obj_size(obj,sqw_obj,nocache)
            % Overloaded: -- calculate size of the serialized object and
            % put the serialized object into data cache for subsequent put
            % operation(s)
            if ~exist('nocache','var')
                nocache = false;
            end
            subobj = obj.get_subobj(sqw_obj);
            npix = subobj.npix;
            n_rows = subobj.n_rows;

            % 4 bytes for n_rows (9), 8 bytes for npixels + (nrows*n_cols)*4 
            % (4 - for single precision)
            obj.size_ = 4+8+npix*n_rows*4;
            if ~nocache
                obj.serialized_obj_cache_ = subobj;
            end
        end
    end
    methods(Access=protected)
        %-----------------------------------------------------------------
        function obj = put_bindata_in_file(obj,fid,obj_data)
            % Overloaded: -- store data contained in dnd_data_block class
            % into binary file
            % Inputs:
            % fid      -- opened file handle
            % obj_data -- full instance of dnd_data class
            %
            % Returns:
            % obj      -- unchanged
            % Error:  HORACE:data_block:io_error is thrown in case of
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
            % Error: HORACE:data_block:io_error is thrown in case of
            %         problem with reading data fields
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