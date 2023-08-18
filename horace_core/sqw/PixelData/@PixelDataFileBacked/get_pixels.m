function pix_out = get_pixels(obj, abs_pix_indices,varargin)
% Retrieve the pixels at the given indices in the full pixel block,
% return a new PixelData object.
%
%  >> pix_out = pix.get_pixels(15640:19244)  % retrieve pixels at indices 15640 to 19244
%
%  >> pix_out = pix.get_pixels([1, 0, 1])  % retrieve pixels at indices 1 and 3
%
% The function attempts to mimic the behaviour you would see when indexing into
% a Matlab array. The difference being the returned object is a PixelData
% object and not an array.
%
% This function may be useful if you want to extract data for a particular
% image bin.
%
% Input:
% ------
%   abs_pix_indices  A vector of positive integers or a vector of logical.
%                    The syntax for these indices attempts to replicate indexing
%                    into a regular Matlab array. You can use logical indices
%                    as well as normal indices, and you can index into the array
%                    "out-of-order". However, you cannot use `end`, but it is
%                    possible to achieve the same effect using the `num_pixels`
%                    property.
%  Optional:
%  '-ignore_range'  -- if provided, new pix_object will not contain correct
%                      pixel ranges
%  '-raw_data'      -- do not wrap the data into PixelData class and return
%                      array of pixel_data as they are.
%  '-keep_precision'-- keep the precision of output raw data as it is (not
%                      doubling it if possible)
%  '-align'         -- if provided and pixels are realigned, apply
%                      alignment transformation to pixels

% Output:
% -------
%   pix_out        Another PixelData object containing only the pixels
%                  specified in the abs_pix_indices argument.
%

[abs_pix_indices,ignore_range,raw_data,keep_precision] = ...
    obj.parse_get_pix_args(abs_pix_indices,varargin{:});

misaligned = obj.is_misaligned;
mmf = obj.f_accessor_;
% Return raw pixels
pix_data = mmf.Data.data(:,abs_pix_indices);
if align && misaligned
    pix_data(1:3,:) = obj.alignment_matr*pix_data(1:3,:);
end

if ~keep_precision
    pix_data = double(pix_data);
end
if raw_data
    pix_out = pix_data;
    return;
end
pix_out = PixelDataMemory();
if ~align && misaligned
    pix_out.alignment_matr  = obj.alignment_matr;
end
pix_out = pix_out.set_raw_data(pix_data);

if ~ignore_range
    pix_out.data_range_ = pix_out.pix_minmax_ranges(pix_out.data);
end
