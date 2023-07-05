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
%   abs_pix_indices  A vector of positive integers or a vector of logicals.
%                    The syntax for these indices attempts to replicate indexing
%                    into a regular Matlab array. You can use logical indices
%                    as well as normal indices, and you can index into the array
%                    "out-of-order". However, you cannot use `end`, but it is
%                    possible to achieve the same effect using the `num_pixels`
%                    property.
%  Optional:
%  '-ignore_range'  -- if provided, new pix_object will not contain correct
%                      pixel ranges
%  '-raw_data'      -- do not wrap the data into PixelData class
%
%  '-keep_precision'-- keep the precision of output raw data as it is (not
%                      doubling it if possible)

% Output:
% -------
%   pix_out        Another PixelData object containing only the pixels
%                  specified in the abs_pix_indices argument.
%
[abs_pix_indices,ignore_range,raw_data,keep_precision] =...
    obj.parse_get_pix_args(abs_pix_indices,varargin{:});


pix_out = obj.data(:, abs_pix_indices);

if ~keep_precision
    pix_out = double(pix_out);
end

if raw_data
    return;
end
if ignore_range
    pix_out = PixelDataMemory();
    pix_out = pix_out.set_raw_data(pix_out);

else
    pix_out = PixelDataMemory(pix_out);
end
