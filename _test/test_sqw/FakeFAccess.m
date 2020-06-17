classdef FakeFAccess < sqw_binfile_common
% A fake file access class that can return data as if from an sqw file

properties
    fake_data = [];
    closed = false;
end

methods

    function obj = FakeFAccess(data)
        obj.fake_data = data;
        obj.npixels_ = size(data, 2);
    end

    function data = get_pix(obj, varargin)
        if nargin > 2
            [pix_lo, pix_hi] = varargin{:};
        else
            pix_lo = 1;
            pix_hi = size(obj.fake_data, 2);
        end
        try
            data = obj.fake_data(:, pix_lo:pix_hi);
        catch ME
            switch ME.identifier
            case 'MATLAB:badsubscript'
                error('FAKEFACCESS:get_pix', 'End of fake file reached');
            otherwise
                rethrow(ME);
            end
        end
    end

    function new_obj = upgrade_file_format(obj)
        new_obj = [];
    end

    function obj = fclose(obj)
        obj.closed = true;
    end

    function obj = activate(obj)
        obj.closed = false;
    end

    function is = is_activated(obj)
        is = ~obj.closed;
    end

end

end
