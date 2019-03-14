classdef hdf_pix_group < handle
    % Helper class to control I/O operations over pixels stored in hdf sqw
    % file.
    %
    % $Revision$ ($Date$)
    %
    
    properties(Dependent)
        % the number of pixels allowed to be stored in the dataset
        max_num_pixels;
        % The size of the chunk providing access to
        % the pixel dataset
        chunk_size
        % the min/max values of the pixels data, stored in the dataset
        pix_range
        %
        %
        cache_nslots;
        cache_size; % in pixels
        % version of nxsqw dataset
        nxsqw_version;
        %
        use_mex_to_read;
    end
    properties(Access=private)
        chunk_size_   =  1024*32;   % decent io speed starts from 16*1024
        cache_nslots_   =  521 ; % in block sizes
        cache_size_     =  -1 ; % in bytes
        max_num_pixels_  = -1; % unlimited dataset allocated, though class
        %does not have methods to extend it. Equal to max allocated pixels
        %spece 
        num_pixels_      = 0; % unreliable number. 
        %
        % HDF5 pointers handles used in file access. 
        pix_group_id_     = -1;
        file_space_id_    = -1;
        pix_data_id_      = -1;
        pix_dataset_      = -1;
        io_mem_space_     = -1;
        io_chunk_size_    = 0;
        
        %
        pix_range_ = [inf,-inf;inf,-inf;inf,-inf;inf,-inf];
        
        % The full name of nxspe file, used for IO operations.
        filename_ = ''
        nexus_group_name_ = '';
        % if one should use mex code to read pixels. Assigned during
        % initialization to true if mex code is availible and enabled.
        use_mex_to_read_ = [];
        % placeholder for file_id, used in partial io, accessing pixel
        % group only.
        fid_ = [];
        % for hdf5 1.6, this is actual file id and fid above becomes the
        % accessor  to the root hdf group
        old_style_fid_ = [];
        % The handler for initialized mex reader.
        mex_read_handler_ = [];
        
        nxsqw_version_ = 0; 
    end
    
    methods
        function obj = hdf_pix_group(varargin)
            % Open existing or create new pixels group in existing hdf file.
            % Usage:
            %>>obj = hdf_pix_group(); -- create uninitialized version of the
            %                           class for further initialization
            %                           and operations
            %
            
            %>>obj = hdf_pixel_group(filename); open existing pixels group
            %                              for IO operations. Throws if
            %                              the group does not exist.
            %          a writing (if any) occurs into the existing group
            %          allowing to modify the contents of the pixel array.
            %
            %>>obj = hdf_pixel_group(filename,n_pixels,[chunk_size]);
            %          creates pixel group to store specified number of
            %          pixels.
            % If the group does not exist, additional parameters describing
            % the pixel array size have to be specified. If it does exist,
            % all input parameters except fid will be ignored
            %
            % Inputs:
            % filename -- nxnspe file name with nxsqw information
            %
            % n_pixels -- number of pixels to be stored in the pix dataset.
            %
            %
            % chunk_size -- if present, specifies the chunk size of the
            %               chunked hdf dataset to create. If not, default
            %               class value is used
            %          If the pixel dataset exists, and  its sizes are
            %          different from the values, provided with this
            %          command, the dataset will be recreated with new
            %          parameters. Old dataset contents will be destroyed.
            %
            %
            if nargin == 0
                return;
            end
            init_(obj,varargin{:});
        end
        %
        function init(obj,varargin)
            % initialize existing class with new settings.
            % if a pixel group was already assosiated with the class,
            % all initialization will be reset.
            
            % all other class parameters are equal to the one, specified in
            % the constructor.
            init_(obj,varargin{:});
        end
        %
        function write_pixels(obj,start_pos,pixels)
            % write block of pixels into the selected postion of
            % hdf5 pixels array.
            %
            % Inputs:
            % start_pos -- the location of the block of pixels within
            %              file-based pixel array. (Matlab/Fortran
            %              convension first pixel number is 1)
            write_pixels_matlab_(obj,start_pos,pixels)
        end
        %
        function [pixels,blocks_pos,pix_block_size]= read_pixels(obj,blocks_pos,pix_block_size)
            % read pixel information specified by pixels starting position
            % and the sizes of the pixels blocks
            %
            %Inputs:
            %blocks_pos     -- array of pixel blocks positions to read
            %pix_block_size -- array of block sizes to read
            %
            %Outputs:
            %pixels     [9 x npix] array of pixels information
            %blocks_pos            array of pixel blocks positions which
            %                      have not been read in current read
            %                      operation. Empty if all pixels defined
            %                      by the input arrays have been read.
            %pix_block_size        array of pixel block sizes, have not
            %                      been read by current read operation
            %
            % n_pix always > 0 and numel(start_pos)== numel(n_pix) (or n_pix == 1)
            % for algorithm to be correct
            [pixels,blocks_pos,pix_block_size] = read_pixels_matlab_(obj,blocks_pos,pix_block_size);
        end
        function is = is_initialized(obj)
            if isempty(obj.use_mex_to_read_)
                is = false;
            else
                if obj.use_mex_to_read_
                    is = isempty(obj.pix_dataset_);
                else
                    is = isempty(obj.mex_read_handler_);
                end
            end
        end
        
        %------------------------------------------------------------------
        function sz = get.chunk_size(obj)
            sz  = obj.chunk_size_;
        end
        function np = get.max_num_pixels(obj)
            np  = obj.max_num_pixels_;
        end
        function range = get.pix_range(obj)
            range  = obj.pix_range_;
        end
        function sz = get.cache_size(obj)
            sz = uint32(obj.cache_size_/(36));
        end
        function sz = get.cache_nslots(obj)
            sz = obj.cache_nslots_;
        end
        function ver= get.nxsqw_version(obj)
            ver = obj.nxsqw_version_;
        end
        function use = get.use_mex_to_read(obj)
            use = obj.use_mex_to_read_ ;
        end
        %
        function set.use_mex_to_read(obj,use)
            use = logical(use);
            if obj.use_mex_to_read && ~use
                obj.mex_read_handler_ = hdf_mex_reader('close',obj.mex_read_handler_);
                obj.use_mex_to_read = false;
                init_(obj.filename_,obj.max_num_pixels,obj.chunk_size,'-use_matlab_to_read');
            elseif ~obj.use_mex_code && use
                if isempty(obj.fid_)
                    error('HDF_PIX_GROUP:invalid_argument',...
                        'can not change to use mex code when hdf_pix_group is not controlling the file')
                end
                root_nx_path  = find_root_nexus_dir(obj.filename_,"NXSQW");
                groupname = [root_nx_path,'/pixels'];
                obj.mex_read_handler_ = hdf_mex_reader('init',obj.filename_,groupname);
                obj.use_mex_to_read_ = true;
            end
        end
        
        %------------------------------------------------------------------
        function delete(obj)
            % close pixel related intormation
            if obj.io_mem_space_ ~= -1
                H5S.close(obj.io_mem_space_);
            end
            if obj.pix_data_id_ ~= -1
                H5T.close(obj.pix_data_id_);
                obj.pix_data_id_ = -1;
            end
            close_pix_dataset_(obj);
            %
            if obj.pix_group_id_ ~= -1
                H5G.close(obj.pix_group_id_);
            end
            if obj.use_mex_to_read
                obj.mex_read_handler_ = hdf_mex_reader('close',obj.mex_read_handler_);
            end
            if isempty(obj.old_style_fid_)
                if ~isempty(obj.fid_)
                    H5F.close(obj.fid_)
                end
            else
                H5G.colse(obj.fid_);
                H5F.close(obj.old_style_fid_)
            end
            obj.use_mex_to_read_ = [];
            obj.pix_range_  = [inf,-inf;inf,-inf;inf,-inf;inf,-inf];
        end
    end
    methods(Access = private)
        %
        function mem_space_id = get_cached_mem_space_(obj,block_dims)
            % function extracts memory space object from a data buffer
            if obj.io_chunk_size_ ~= block_dims(1)
                H5S.set_extent_simple(obj.io_mem_space_,2,block_dims,block_dims);
                obj.io_chunk_size_ = block_dims(1);
            end
            mem_space_id = obj.io_mem_space_;
        end
        %
        %
    end
end

