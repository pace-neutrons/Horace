function pix_out = get_pix_in_ranges(obj, abs_indices_starts, block_sizes,...
    recalculate_pix_range,keep_precision)
%%GET_PIX_IN_RANGES read pixels in the specified ranges
% Ranges are inclusive.
%
%   >> pix = get_pix_in_ranges([1, 12, 25], [6, 12, 27])
%
% Input:
% ------
% pix_starts  Absolute indices of the starts of pixel ranges [Nx1 or 1xN array].
% block_sizes The sizes of the blocks to read                [Nx1 or 1xN array].
% Optional
% recalculate_pix_range -- if true, recalulate q-dE range of obrained
%                          pixels. Default -- true
% keep_precision         --if true, load pixels in memory, as they are
%                          stored on hdd (single precision pixels). If
%                          false, convert pixels into double precision at
%                          load. Default false
%
% Output:
% -------
% pix_out     A PixelData object containing the pixels in the given ranges.
%

if ~exist('recalculate_pix_range','var')
    recalculate_pix_range = true;
end
if ~exist('keep_precision','var')
    keep_precision = false;
end

validate_ranges(abs_indices_starts, block_sizes);

if any(obj.page_dirty_)
    % At least some pixels sit in temporary files
    abs_indices = get_ind_from_ranges(abs_indices_starts, block_sizes);
    pix_out = obj.get_pixels(abs_indices);
    return
else
    skip_arg_validation = true;  % no point validating inputs again in faccess
    obj
    obj.f_accessor_
    raw_pix = obj.f_accessor_.get_pix_in_ranges( ...
        abs_indices_starts, block_sizes, skip_arg_validation,keep_precision);
end

if recalculate_pix_range
    pix_out = PixelDataBase.create(raw_pix);
else
    pix_out = PixelDataBase.create();
    set_data(pix_out,'all',raw_pix);
end


end  % function
% -----------------------------------------------------------------------------
