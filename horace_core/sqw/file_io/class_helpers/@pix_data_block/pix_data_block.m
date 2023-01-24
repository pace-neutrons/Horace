classdef pix_data_block < data_block
    % PIX_DATA_BLOCK describes the binary data, corresponding to pixelData
    % arrays (extracted by  pix_data class v0) and used for storing/restoring
    % pixel information on HDD in a binary form if it is possible or ogranizing
    % file-based access to the data on HDD.
    %
    % The special form of data_block binary data format is caused by need
    % to access pix_data_block from third party (non-Matlab) applications
    % and the constrains of efficient binary access to this array for the
    % arrays which are impossible to load in memory
    %
    properties(Dependent)
        % properties defile the location of the appropriate arrays in
        % binary file. The positions are defined in bytes and counted from
        % the beginning of the file.
        num_pix_position;  % position of the uint64 variable describing the
        %               % number of pixels contributed into sqw file
        pix_position;   % position of the
        % The parameters, which define the size of the pixel data block
        npixels; % number of pixels, stored in the file
        n_rows;  % number of pixel data rows. Either default (9) or something set from
        %        % the subobject, used as input
        bytes_pp % bytes per point -- how much every pixel value occupies on hdd
    end
    properties(Access=protected)
        npixels_  = 0;
        n_rows_   = 9;
        bytes_pp_ = 4;
    end
    methods
        function obj = pix_data_block(varargin)
            %DND_DATA_BLOCK constructor
            obj = obj@data_block(varargin{:});
            obj.sqw_prop_name = 'pix';
            obj.level2_prop_name = 'data_wrap';
        end
        %
        function pos = get.num_pix_position(obj)
            pos = obj.position_+4;
        end
        %
        function np = get.npixels(obj)
            np = obj.npixels_;
        end
        function obj = set.npixels(obj,np)
            if ~(isscalar(np) && isnumeric(np) && np >= 0 )
                error('HORACE:pix_data_block:invalid_argument', ...
                    'Number of pixels shoud be single non-negative number. In fact it is: %s', ...
                    disp2str(np))
            end
            obj.npixels_ = np;
        end
        %
        function nr = get.n_rows(obj)
            nr  = obj.n_rows_;
        end
        function obj = set.n_rows(obj,nr)
            if ~(isscalar(nr) && isnumeric(nr) && nr > 1)
                error('HORACE:pix_data_block:invalid_argument', ...
                    'Number of pix rows should define the size of the single pixel, so it should be numeric and at bigger then 1. In fact it is: %s', ...
                    disp2str(nr))
            end
            obj.n_rows_ = nr;
        end
        %
        function bpp = get.bytes_pp(obj)
            bpp  = obj.bytes_pp_;
        end
        function obj = set.bytes_pp(obj,bpp)
            if ~(isscalar(bpp) && isnumeric(bpp) && bpp >= 4)
                error('HORACE:pix_data_block:invalid_argument', ...
                    'Number of pix rows should define the size of the single pixel, so it should be numeric and at bigger then 3. In fact it is: %s', ...
                    disp2str(bpp))
            end
            obj.bytes_pp_ = bpp;
        end
        %
        function pos = get.pix_position(obj)
            pos = obj.position_+12;
        end
        function obj = set.pix_position(obj,val)
            % set block position from known pix position
            if ~(isscalar(val) && isnumeric(val) && val>12)
                error('HORACE:pix_data_block:invalid_argument', ...
                    'pix position defines the location of pixel data block within a sqw file on hdd, so it should be positive number exceeding 12. In fact it is: %s', ...
                    disp2str(val))
            end
            obj.position_ = val - 12;
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
            obj.npixels = subobj.npix;
            obj.n_rows  = subobj.n_rows;
            if ~nocache
                obj.serialized_obj_cache_ = subobj;
            end
        end
    end
    methods(Access=protected)
        function size = get_size(obj)
            % Overloaded the Main part of data_block size getter

            % 4 bytes for n_rows (9), 8 bytes for npixels + (nrows*n_cols)*4
            % (4 - for single precision)
            size  = 4+8+obj.npixels*obj.n_rows*obj.bytes_pp;
        end
        function obj = set_size(obj,val)
            % Overloadable part of data_block size setter
            if ~(isscalar(val)&&isnumeric(val)&&val>=0)
                error('HORACE:data_block:invalid_argument', ...
                    'block size can be only non-negative number. It is: %s',...
                    disp2str(val));
            end
            all_pix_size = uint64(val - 12);
            pix_size = uint64(obj.n_rows*obj.bytes_pp);
            npix =  idivide(all_pix_size ,pix_size);
            err = rem(all_pix_size,pix_size);
            if err>eps("single")
                error('HORACE:data_block:invalid_argument', ...
                    'Provided size of pix_data block %d does not contans whole number of pixels (%d)', ...
                    val,npix)
            end
            obj.npixels_ = npix;
        end

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
            flds = {'position','npixels','n_rows','bytes_pp'};
        end
        %------------------------------------------------------------------
    end

end