classdef PixelIO

properties (Constant, Access=private)
    DIRTY_PIX_DIR_NAME_ = 'sqw_pix%05d';
end

properties (Access=private)
    dirty_pix_dir_ = '';
    pix_id_ = -1;
end

methods

    function obj = PixelIO(pix_id)
        % Construct a PixelIO object
        %
        % Input
        % -----
        % pix_id   The ID of the PixelData instance this object is linked to.
        %          This allows this sets the tmp directory name.
        obj.pix_id_ = pix_id;
        dirty_pix_dir_name = sprintf(obj.DIRTY_PIX_DIR_NAME_, obj.pix_id_);
        obj.dirty_pix_dir_ = fullfile(tempdir(), dirty_pix_dir_name);
    end

    function raw_pix = load_dirty_page(obj, page_number)
        % Load a page of data from a tmp file
        %
        % Input
        % -----
        % page_number   The number of the page to read data from
        %
        tmp_file_path = obj.generate_dirty_pix_file_path_(page_number);
        [file_id, err_msg] = fopen(tmp_file_path, 'rb');
        if file_id < 0
            error('PIXELDATA:load_dirty_page_', ...
                  'Could not open ''%s'' for reading:\n%s', tmp_file_path, ...
                  err_msg);
        end
        try
            raw_pix = fread(file_id, 'float32');
        catch ME
            fclose(file_id);
            rethrow(ME);
        end
        fclose(file_id);
    end

    function obj = write_dirty_pix(obj, page_number, pix_data)
        % Write the current page's pixels to a tmp file
        %
        % Inputs
        % ------
        % page_number   The number of the page being written, this set the tmp file name
        % pix_data      The raw data to write
        %
        tmp_file_path = obj.generate_dirty_pix_file_path_(page_number);
        if ~exist(obj.dirty_pix_dir_, 'dir')
            mkdir(obj.dirty_pix_dir_);
        end

        file_id = fopen(tmp_file_path, 'wb');
        if file_id < 0
            error('PIXELDATA:write_dirty_pix_', ...
                  'Could not open file ''%s'' for writing.\n', tmp_file_path);
        end

        try
            obj.write_pix_to_tmp_file_(file_id, pix_data);
        catch ME
            fclose(file_id);
            rethrow(ME);
        end
        fclose(file_id);
    end

    function delete_tmp_files(obj)
        % Delete the directory containing files holding dirty pixels
        if exist(obj.dirty_pix_dir_, 'dir')
            rmdir(obj.dirty_pix_dir_, 's');
        end
    end

end

methods (Access=private)

    function obj = write_pix_to_tmp_file_(obj, file_id, pix_data)
        % Write the pixels in the current page to the file corresponding to the
        % given file ID.
        % TODO: improve this by not writing all data at once
        try
            fwrite(file_id, pix_data, 'float32');
        catch ME
            switch ME.identifier
            case 'MATLAB:badfid_mx'
                error('PIXELDATA:write_pix_to_tmp_file_', ...
                  'Could not write to file with ID ''%d'':\n The file is not open', ...
                  file_id);
            otherwise
                tmp_file_path = fopen(file_id);
                error('PIXELDATA:write_pix_to_tmp_file_', ...
                      'Could not write to file ''%s'':\n%s', ...
                      tmp_file_path, ferror(file_id));
            end
        end
    end

    function tmp_file_path = generate_dirty_pix_file_path_(obj, page_number)
        % Generate the file path to the tmp directory for this object instance
        tmp_file_path = fullfile(obj.dirty_pix_dir_, ...
                                 sprintf('%09d.tmp', page_number));
    end

end

end
