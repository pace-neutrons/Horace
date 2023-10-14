classdef pix_write_handle < handle
    %PIX_WRITE_HANDLE wraps different kinds of write access handles for
    % writing pixels, provides common interface for writing pixels.
    %
    % In addition, it closes accessor handle on class deleteon, and may
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
        % true, if file has extension tmp
        is_tmp_file
        %
        write_handle;
    end
    properties(Access=private)
        npix_written_ = 0;
        handle_is_class_ = false;
        write_handle_ = [];

        delete_target_file_ = true;
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

        function obj = save_data(obj,data,start_pos)
            if nargin <3
                start_pos = obj.npix_written_+1;
            end
            if obj.handle_is_class_
                obj.write_handle_.put_raw_pix(data,start_pos);
            else
                fwrite(obj.write_handle_, single(data), 'single');
            end
            obj.npix_written_ = obj.npix_written_ + size(data, 2);

        end
        function init_info = release_pixinit_info(obj,pix_obj)
            % Return information, necessary for initialize access to
            % written data using  PixelDataFileBacked
            num_pixels = double(obj.npix_written_);
            if obj.handle_is_class_
                init_info = obj.write_handle_;
                init_info = init_info.put_pix_metadata(obj,pix_obj);
                % Force pixel update. TODO: Is this necessary?
                init_info = init_info.put_num_pixels(num_pixels);
                % set eof_pos cache as closed faccessor does not have eof
                % position.
                eof_pos   = init_info.eof_pos;
                init_info.eof_pos = eof_pos;
            else
                offset   = 0;
                tail     = 0;
                init_info = memmapfile(obj.write_file_name, ...
                    'Format', PixelDataBase.get_memmap_format(num_pixels,tail), ...
                    'Repeat', 1, ...
                    'Writable', true, ...
                    'Offset', offset);
            end
            obj = obj.close_handles();
            % file is released for external access. Do not delete it on
            % deleteon of this class.
            obj.delete_target_file_ = false;
        end
        function delete(obj)
            obj = obj.close_handles();
            % in case of errors in operations, delete intermediate/incomplete
            % files on handle closure.
            if obj.delete_target_file_
                del_memmapfile_files(obj.write_file_name);
            end
        end
        %==================================================================
        function is = get.is_tmp_file(obj)
            [~,~,fe] = fileparts(obj.write_file_name);
            is = strncmp(fe,'.tmp',4);
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