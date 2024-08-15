classdef pix_write_handle < handle
    %PIX_WRITE_HANDLE wraps different kinds of write access handles for
    % writing pixels and provides common interface for writing pixels.
    %
    % as pixels are closely related to image, the class also contains
    % methods to update image or part of the image, which was modified while
    % modifying pixels.
    %
    % In addition, it closes accessor handle on class deletion, and may
    % delete target file if the class goes out of scope due to errors.
    %
    properties
        % the name of the file, the handle works with and writes pixels to.
        write_file_name
        % auxiliary property, with keeps information about intentions
        % of PageOp. It is here to simplify PageOp interface.
        move_to_original
    end
    properties(Dependent)
        % number of pixels written using this write handle
        npix_written;
        % true, if file has extension tmp or has been set to be
        % true or false explicitly. tmp files deleted when the object
        % holding these files goes out of scope
        is_tmp_file
        %
        write_handle;
    end
    properties(Dependent,Hidden)
        % initial position (in bytes)from the beginning of file,
        % where target pixels are written.
        % Used by external mex code which writes pixels.
        pixout_start
    end
    properties(Access=private)
        npix_written_ = 0;
        handle_is_class_ = false;
        write_handle_ = [];

        % initial shift of components of image (s,e,npix) from their
        % physical position on file expressed in number of bins (image
        % pixels) used by save_img_chunk if run in a cycle without providing
        % the position where to write modified image chunk
        img_start_post_ = 0

        delete_target_file_ = true;

        is_tmp_file_ = [];
    end

    methods
        function obj = pix_write_handle(targ_obj)
            if nargin == 0
                targ_obj = 'in_mem';
            end
            if isa(targ_obj,'horace_binfile_interface')
                obj.write_handle_     = targ_obj;
                obj.handle_is_class_  = true;
                obj.write_file_name   = targ_obj.full_filename;
                return;
            elseif istext(targ_obj)
                targ_file = targ_obj;
            else
                error('HORACE:PixelData:invalid_argument', ...
                    ['pix_write_handle accepts a class, which can read/write pixel data or\n' ...
                    ' the name of the file, containing these data. Provided class %s'], ...
                    class(targ_obj))
            end
            obj.write_file_name   = targ_file;
            obj.write_handle_     = sqw_fopen(obj.write_file_name, 'wb+');
            obj.handle_is_class_  = false;
            obj.move_to_original =  false;

            obj.npix_written_ = 0;
        end
        function save_img_chunk(obj,img_struc,start_pos)
            % store part of image changed due to modifications in pixels
            % within specified location in the image already stored on disk.
            %
            % Inputs:
            % obj   -- instance of pix_write_handle initialized using
            %          faccessor class
            % img_struc
            %       -- the structure containing 3 fields of modified image
            %          (s,e, npix) to write
            % start_pos
            %       -- the position within existing image where to start
            %          writing the image chunk. If absent, uses internal
            %          value of the position, which is 0 initially, but
            %          modified by number of written bins each time the
            %          method get called.
            %
            if ~obj.handle_is_class_
                error('HORACE:pix_write_handle:not_implemented', ...
                    ['writing image using direct IO operations is not yet implemented.' ...
                    ' Use faccess_*** classes to modify image'])
            end
            if nargin < 3
                start_pos = obj.img_start_post_;
            end

            obj.write_handle_.put_senpix_block(img_struc,start_pos);
            obj.img_start_post_ = start_pos + numel(img_struc.npix);
        end

        function save_data(obj,data,start_pos)
            % write block of pixels at the specified location within the
            % binary sqw file.
            % Inputs:
            % Inputs:
            % obj   -- instance of pix_write_handle initialized using
            %          faccessor class or Matlab fopen operation
            % data  -- chunk of pixel data -- PixelDataBase.

            if nargin <3
                start_pos = obj.npix_written_+1;
            end
            if obj.handle_is_class_
                obj.write_handle_ = obj.write_handle_.put_raw_pix(data,start_pos);
            else
                fwrite(obj.write_handle_, single(data), 'single');
            end
            obj.npix_written_ = obj.npix_written_ + size(data, 2);
        end
        function pix_meta = finish_pix_dump(obj,pix_obj,store_metadata)
            % finalize multipage pix.write operation writing information
            % about number of pixels written using pix_write_handle at the
            % beginning of pixel data block stored in sqw file.
            %
            % if store_metadata true (or missing) also write pixel metadata
            % block
            % Inputs:
            % obj   -- initialized instance of pix_write_handle used to
            %          write pixels and containing number of pixels written
            %          during all these write operations.
            % pix_obj
            %       -- PixelDataFilebacked object used as source of
            %          metadata to store in sqw file. not used if
            %          store_metadata is false;
            % store_metadata
            %       -- if true, pixel metadata are stored in sqw file
            %          together with pixel_data. If missing -- assumed
            %          true.
            % Returns:
            % pix_meta
            %       -- modified by written pixel information pix_metadata
            %          class
            % Result:
            % finalized pix.data block in sqw file.
            % if store_metadata is true
            % also pix.metadata stored in file so correctly formed
            % PixelData block stored within sqw file.
            %
            if nargin<3
                store_metadata = true;
            end
            if obj.handle_is_class_
                num_pixels = obj.npix_written;
                wh = obj.write_handle_;
                % Force pixel update. This is necessary -- modifies
                % and writes pix_data_block information independently on
                % pix_metadata and modifies npix in wh too. If number of
                % pixels has changed (e.g. masking) this will reduce the
                % recorded in bat size of the file, so that following write
                % block operations may reuse the released space.
                wh = wh.put_num_pixels(num_pixels);
                %
                pix_meta = pix_obj.metadata;
                pix_meta.full_filename = wh.full_filename;
                pix_meta.npix = num_pixels;
                if store_metadata
                    obj.write_handle_ = wh.put_new_blocks_values(pix_meta, ...
                        'update','bl_pix_metadata');
                else
                    obj.write_handle_ = wh;
                end
            else
                pix_meta = [];
            end
        end
        %
        function init_info = release_pixinit_info(obj,keep_opened)
            % Return information, necessary for initialize access to
            % written data using  PixelDataFileBacked
            if nargin < 2
                keep_opened = false;
            end
            if obj.handle_is_class_
                init_info = obj.write_handle_;
                % set eof_pos cache as closed faccessor does not have eof
                % position.
                eof_pos   = init_info.eof_position;
                init_info.eof_position = eof_pos;
            else
                num_pixels = double(obj.npix_written_);
                offset   = 0;
                tail     = 0;
                init_info = memmapfile(obj.write_file_name, ...
                    'Format', PixelDataBase.get_memmap_format(num_pixels,tail), ...
                    'Repeat', 1, ...
                    'Writable', true, ...
                    'Offset', offset);
            end
            if ~keep_opened
                obj = obj.close_handles();
            end
            % file is released for external access. Do not delete it on
            % deleteon of this class.
            obj.delete_target_file_ = false;

        end
        %
        function delete(obj)
            obj = obj.close_handles();
            % in case of errors in operations, delete intermediate/incomplete
            % files on handle closure.
            if obj.delete_target_file_
                del_memmapfile_files(obj.write_file_name);
            end
        end
        %==================================================================
        function pixout = get.pixout_start(obj)
            if ~obj.handle_is_class_
                error('HORACE:pix_write_handle:runtime_error', ...
                    'Attempt to get pix position from incompartible binary file')
            end
            pixout = obj.write_handle_.pix_position;
        end
        function is = get.is_tmp_file(obj)
            if isempty(obj.is_tmp_file_)
                [~,~,fe] = fileparts(obj.write_file_name);
                is = strncmp(fe,'.tmp',4);
            else
                is = obj.is_tmp_file_;
            end
        end
        function set.is_tmp_file(obj,val)
            obj.is_tmp_file_ = logical(val);
        end
        function np = get.npix_written(obj)
            np = obj.npix_written_;
        end
        function set.npix_written(obj,val)
            % should be used only when pixels are written externaly by
            % mex-routine
            obj.npix_written_ = double(val);
        end
    end
    methods(Access=private)
        function obj = close_handles(obj)
            % close access to the target file
            % i.e. close file or call delete on data writer.
            if isempty(obj.write_handle_)
                return;
            end
            if obj.handle_is_class_
                obj.write_handle_.delete();
            else
                fclose(obj.write_handle_);
            end
            obj.write_handle_ = [];
        end
    end
end