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
    end
    properties(Access=private)
        chunk_size_   =  1024*32;   % decent io speed starts from 16*1024
        cache_nslots_   =  521 ; % in block sizes
        cache_size_     =  -1 ; % in bytes
        max_num_pixels_  = -1;
        num_pixels_      = 0;
        %
        pix_group_id_     = -1;
        file_space_id_    = -1;
        pix_data_id_      = -1;
        pix_dataset_      = -1;
        io_mem_space_     = -1;
        io_chunk_size_    = 0;
        
        %
        pix_range_ = [inf,-inf;inf,-inf;inf,-inf;inf,-inf];
        
        use_mex_to_read_ = false;
    end
    
    methods
        function obj = hdf_pix_group(fid,n_pixels,chunk_size)
            % Open existing or create new pixels group in existing hdf file.
            %
            % If the group does not exist, additional parameters describing
            % the pixel array size have to be specified. If it does exist,
            % all input parameters except fid will be ignored
            %Usage:
            % pix_wr = hdf_pixel_group(fid,n_pixels,[chunk_size]);
            %          creates pixel group to store specified number of
            %          pixels.
            % chunk_size -- if present, specifies the chunk size of the
            %               chunked hdf dataset to create. If not, default
            %               class value is used
            %          If the pixel dataset exists, and  its sizes are
            %          different from the values, provided with this
            %          command, the dataset will be recreated with new
            %          parameters. Old dataset contents will be destroyed.
            %
            % pix_wr = hdf_pixel_group(fid); open existing pixels group
            %                                for IO operations. Throws if
            %                                the group does not exist.
            %          a writing (if any) occurs into an existing group
            %          allowing to modify the contents of the pixel array.
            %
            if exist('n_pixels','var')|| exist('chunk_size','var')
                pix_size_defined = true;
            else
                pix_size_defined = false;
                n_pixels = [];
            end
            if exist('chunk_size','var')
                obj.chunk_size_ = chunk_size;
            else
                chunk_size = obj.chunk_size_;
            end
            
            group_name = 'pixels';
            
            obj.pix_data_id_ = H5T.copy('H5T_NATIVE_FLOAT');
            if H5L.exists(fid,group_name,'H5P_DEFAULT')
                open_existing_dataset_(obj,fid,pix_size_defined,n_pixels,chunk_size,group_name);
            else
                if nargin<1
                    error('HDF_PIX_GROUP:invalid_argument',...
                        'the pixels group does not exist but the size of the pixel dataset is not specified')
                end
                if ~pix_size_defined
                    error('HDF_PIX_GROUP:invalid_argument',...
                        'Attempting to create new pixels group but the pixel number is not defined');
                end
                create_pix_dataset_(obj,fid,group_name,n_pixels,chunk_size);
            end
            block_dims = [obj.chunk_size_,9];
            obj.io_mem_space_ = H5S.create_simple(2,block_dims,block_dims);
            obj.io_chunk_size_ = obj.chunk_size_;
            %H5P.close(dcpl_id);
            %H5P.close(pix_dapl_id );
            
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

