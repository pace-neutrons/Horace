classdef FakeFAccess < sqw_binfile_common
% A fake file access class that can return data as if from an sqw file

properties
    fake_data = [];
    closed = false;
end

methods

    function obj = FakeFAccess(data)
        obj.fake_data = single(data);
        obj.npixels_ = size(data, 2);
    end
    %
    function data = get_pix(obj, varargin)
        if nargin > 2
            [pix_lo, pix_hi] = varargin{:};
        else
            pix_lo = 1;
            pix_hi = size(obj.fake_data, 2);
        end
        try
            data = double(obj.fake_data(:, pix_lo:pix_hi));
        catch ME
            switch ME.identifier
            case 'MATLAB:badsubscript'
                error('FAKEFACCESS:get_pix', 'End of fake file reached');
            otherwise
                rethrow(ME);
            end
        end
    end
    %
    function data = get_pix_at_indices(obj, indices)
        try
            data = double(obj.fake_data(:, indices));
        catch ME
            switch ME.identifier
            case 'MATLAB:badsubscript'
                error('FAKEFACCESS:get_pix', 'Pixel indices out of bounds');
            otherwise
                rethrow(ME);
            end
        end
    end
    %
    function pix_range = get_pix_range(obj)
        pix_range = double([min(obj.fake_data(1:4,:),[],2),max(obj.fake_data(1:4,:),[],2)]');
    end
    %
    function new_obj = upgrade_file_format(~)
        new_obj = [];
    end
    %
    function obj = fclose(obj)
        obj.closed = true;
    end
    %
    function obj = activate(obj)
        obj.closed = false;
    end
    %
    function is = is_activated(obj, read_or_write)
        is = ~obj.closed;
    end
    %
    function obj = set_npixels(obj, npix)
        obj.npixels_ = npix;
    end
    %
    function obj = set_filepath(obj, file_path)
        [obj.filepath_, file_name, ext] = fileparts(file_path);
        obj.filename_ = [file_name, ext];
    end
end
end
