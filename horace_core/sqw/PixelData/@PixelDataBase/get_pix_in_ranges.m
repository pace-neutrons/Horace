function pix_out = get_pix_in_ranges(obj, abs_indices_starts, block_sizes,...
    recalculate_pix_range,keep_precision)
%%GET_PIX_IN_RANGES read pixels in the specified ranges
% Ranges are inclusive.
%
%  E.g. for 3 sets of pixels (1-6, 12, 25-27)
%
%   >> pix = get_pix_in_ranges([1, 12, 25], [6, 12, 27])
%
% Input:
% ------
% pix_starts  Absolute indices of the starts of pixel ranges [Nx1 or 1xN array].
% block_sizes The sizes of the blocks to read                [Nx1 or 1xN array].
% Optional
% recalculate_pix_range -- if true, recalculate q-dE range of obtained
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

% All pixels in memory
indices = get_ind_from_ranges(abs_indices_starts, block_sizes);

if keep_precision
    raw_pix = obj.get_pixels(indices,'-keep','-raw');
else
    raw_pix = obj.get_pixels(indices,'-raw');
end

if recalculate_pix_range
    pix_out = PixelDataBase.create(raw_pix);
else
    pix_out = PixelDataBase.create();
    pix_out = pix_out.set_raw_data(raw_pix);
end
if obj.is_misaligned
    pix_out.alignment_matr_ = obj.alignment_matr;
    pix_out.is_misaligned_ = true;
end
