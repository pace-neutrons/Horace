classdef FakeFAccess < sqw_binfile_common
% A fake file access class that can return data as if from an sqw file

properties
    fake_data = [];
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
        data = obj.fake_data(:, pix_lo:pix_hi);
    end

    function new_obj = upgrade_file_format(obj)
        new_obj = [];
    end

end

end
