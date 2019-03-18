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
        % initialization to true if mex code is available and enabled.
        use_mex_to_read_ = [];
        % internal operation facilitating subsequent read of sequence of
        % N-pixels. If true, the previous read operation is completed and
        % the new operation starts from the beginning of the input info
        % array. If false, the internal cach information is used to
        % continue read operation from the place, the previous read
        % operation was finished
        read_op_completed_ = true;
        % placeholder for file_id, used in partial io, accessing pixel
        % group only.
        fid_ = [];
        % for hdf5 1.6, this is actual file id and fid above becomes the
        % accessor  to the root hdf group
        old_style_fid_ = [];
        % The handler for initialized mex reader.
        mex_read_handler_ = [];
        
        nxsqw_version_ = 0;
        
        matlab_read_info_cache_ = {};
    end
    
    methods
        function obj = hdf_pix_group(varargin)
            % Open existing or create new pixels group in existing hdf file.
            % Usage:
            %>>obj = hdf_pix_group(); -- create uninitialized version of the
            %                           class for further initialization
            %                           and operations
            %
            
            %>>obj = hdf_pixel_group(filename,['-use_mex_to_read'|'-use_matlab_to_read']);
            %          open existing pixels group for IO operations.
            %          Throws if the group does not exist.
            %          a writing (if any) occurs into the existing group
            %          allowing to modify the contents of the pixel array.
            %
            %>>obj = hdf_pixel_group(filename,n_pixels,[chunk_size],...
            %                       ['-use_mex_to_read'|'-use_matlab_to_read']);
            %          creates pixel group to store specified number of
            %          pixels.
            % If the group does not exist, additional parameters describing
            % the pixel array size have to be specified. If it does exist,
            % all input parameters except fid will be ignored
            %
            % Inputs:
            % filename -- nxnsqw file name containing sqw object information
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
            %,'-use_mex_to_read'|'-use_matlab_to_read' -- redefine the
            %          Horace configuration setting and force using mex code/matlab code
            %          to read pixels information. If absent,
            %          hor_config.use_mex option is used to establish
            %          operation mode.
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
            % write block of pixels into the selected position of
            % hdf5 pixels array.
            %
            % Inputs:
            % start_pos -- the location of the block of pixels within
            %              file-based pixel array. (Matlab/FORTRAN
            %              convention first pixel number is 1)
            write_pixels_matlab_(obj,start_pos,pixels)
        end
        %
        function [pixels,read_op_completed]= read_pixels(obj,blocks_pos,pix_block_size,buf_size,varargin)
            % read pixel information specified by pixels starting position
            % and the sizes of the pixels blocks
            %
            % Usage:
            %>>[pixels,reading_completed]= read_pixels(obj,blocks_pos,pix_block_size,buf_size,[reading_completed],["-use_mex|-use_matlab"])
            %
            %Inputs:
            % blocks_pos     -- array of pixel blocks positions to read
            % pix_block_size -- array of block sizes to read
            % buf_size       -- the max size of the buffer defining the number
            %                  of pixels to return from single read operation
            % read_op_completed -- if false, the read operation should be
            %                  continued from the place where the previous
            %                  read operation completed.
            %                  if absent or true, the read operation begins
            %                  from the start of blocks_pos and
            %                  pix_block_size arrays. (see output value)
            % -use_mex_to_read/-use_matlab_to_read -- can be present only if
            %                  all previous options are present. Implicitly
            %                  overrides operation mode (mex or Matlab),
            %                  selected during class construction.
            %
            %Outputs:
            %pixels     [9 x npix] array of pixels information
            %
            %read_op_completed     true if all pixels defined by blocks_pos
            %                      and pix_block_size arrays have been
            %                      returned. If false, the number of the
            %                      pixels defined by these array is larger
            %                      than the buffer size provided and the
            %                      following read operations, called with
            %                      read_continues true are necessary to
            %                      read all pixels.
            %
            %
            % WARNING! unexpected behavior. If the previous read operation
            % is not completed (more data specified in npix array than buffer provided)
            % and the next operation started with new
            % data, cache will be setup to the previous read operation and
            % the behavior is undefined. 
            %
            if ~exist('buf_size','var')
                buf_size = sum(pix_block_size); % read all
            end
            if nargin > 4
                read_op_completed = varargin{1};
                obj.read_op_completed_ = read_op_completed;
            else
                read_op_completed = obj.read_op_completed_;
            end
            if obj.use_mex_to_read
                read_op = double(read_op_completed); % some version of Matlab do not accept logical pointer as input!!!
                [pixels,read_op_completed,obj.mex_read_handler_] = hdf_mex_reader('read',obj.mex_read_handler_,...
                    blocks_pos,pix_block_size,buf_size,read_op);
                obj.read_op_completed_ = read_op_completed;
            else
                if read_op_completed % if previous reading was completed, new one begins from the start
                    [pixels,blocks_pos,pix_block_size] = read_pixels_matlab_(obj,blocks_pos,pix_block_size,buf_size);
                else
                    blocks_pos = obj.matlab_read_info_cache_{1};
                    pix_block_size = obj.matlab_read_info_cache_{2};
                    [pixels,blocks_pos,pix_block_size] = read_pixels_matlab_(obj,blocks_pos,pix_block_size,buf_size);
                end
                if isempty(blocks_pos)
                    read_op_completed = true;
                    obj.matlab_read_info_cache_ = {};
                else
                    read_op_completed = false;
                    obj.matlab_read_info_cache_ = {blocks_pos,pix_block_size};
                end
                obj.read_op_completed_ = read_op_completed;
            end
        end
        %
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
        function [npix_read,pos_in_first_block] = get_read_info(obj)
            % return the information about current state of pixels read operations
            %
            if obj.use_mex_to_read
                [npix_read,pos_in_first_block] = hdf_mex_reader('get_read_info',obj.mex_read_handler_);
            else
                error('HDF_PIX_GROUP:not_implemented','The operation is not yet implemented');
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
            set_use_mex_(obj,use);
        end
        
        %------------------------------------------------------------------
        function delete(obj)
            % close pixel related intormation
            delete_hdf_objects(obj);
        end
    end
end

