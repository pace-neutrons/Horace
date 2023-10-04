function pix_out = get_pixels(obj, varargin)
% Retrieve the raw pixels at the given indices in the full pixel block,
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
%   index_set       -- string, which define set of pixel elements to return.
%                      or cellarray of such strings. If present, do not
%                      return complete pixels but return subset of pixels
%                      values. Can be provided with keyword -raw_data only
%  '-ignore_range'  -- if provided, new pix_object will not contain correct
%                      pixel ranges
%  '-raw_data'      -- do not wrap the data into PixelData class
%
%  '-keep_precision'-- keep the precision of output raw data as it is (not
%                      doubling it if possible)
%  '-align'         -- if provided and pixels are realigned, apply
%                      alignment transformation to pixels

% Output:
% -------
%   pix_out        Another PixelData object containing only the pixels
%                  specified in the abs_pix_indices argument.
%
[pix_indices,col_pix_idx,ignore_range,raw_data,keep_precision,align] =...
    obj.parse_get_pix_args(true,varargin{:});

pix_data  = obj.get_raw_pix_data(pix_indices,col_pix_idx);

pix_out = obj.pack_get_pix_result(pix_data,ignore_range,raw_data,keep_precision,align);
