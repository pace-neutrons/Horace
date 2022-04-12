function pix = get_pix_in_ranges(obj, pix_starts, pix_bl_sizes, ...
    skip_validation,keep_precision)
%%GET_PIX_IN_RANGES read pixels in the specified ranges
%
% Read blocks of pixels, which start from pix_starts positions and occupy
% pix_bl_sizes sizes
%
% skip_validation -- if present and true,
%                    For performance reasons, there is no validation
%                    performed on input arguments, but the input arrays
%                    should have equal length and for all i we should have:
%
%   pix_bl_sizes(i) > 0
%   pix_starts(i + 1) > pix_starts(i)
%   pix_starts(i + 1) >= pix_starts(i)+pix_bl_sizes(i)+1 % not verified in
%                                                          any case but
%                                                          should be
%
%   >> pix = get_pix_in_ranges([1, 12, 25], [6, 1, 3])
%      pix =
%        [9x10] double array  % pixels 1-6,12,25-27
%
% Input:
% ------
% pix_starts       Indices of the starts of pixel ranges [Nx1 or 1xN array].
% pix_bl_sizes     The sizes of the blocks of pixels to read [Nx1 or 1xN array].
% skip_validation  Do not validate input array (optional, default = false) [bool]
%
% Output:
% -------
% pix              Raw pixel array [9xN double].
%
skip_validation = exist('skip_validation', 'var') && skip_validation;
if ~skip_validation
    [ok, mess] = validate_ranges(pix_starts, pix_bl_sizes);
    if ~ok
        error('HORACE:sqw_binfile_common:invalid_argument', mess);
    end
end
if ~exist('keep_precision','var')
    keep_precision = true;
end
if keep_precision
    format = '*float32';
else
    format = 'float32';
end

%NUM_BYTES_IN_FLOAT = 4;
%PIXEL_SIZE = NUM_BYTES_IN_FLOAT*PixelData.DEFAULT_NUM_PIX_FIELDS;  % bytes

% This decreases no. of calls needed to read data - big speed increase.
% Should be done elsewhere
%[pix_starts, pix_bl_sizes] = merge_adjacent_ranges(pix_starts, pix_bl_sizes);

% TODO: verify if there are any performance benifits from commented
% code or the currently enabled code. (see
% [#686](https://github.com/pace-neutrons/Horace/issues/686))

% Position file reader at start of first block of pixels to read
%first_seek_pos = obj.pix_pos_ + (pix_starts(1) - 1)*PIXEL_SIZE;
%do_fseek(obj.file_id_, first_seek_pos, 'bof');

% blocks = cell(1, numel(pix_starts));
% for i = 1:numel(pix_starts)
%     seek_pos = obj.pix_pos_ + (pix_starts(i) - 1)*PIXEL_SIZE;
%     do_fseek(obj.file_id_, seek_pos, 'bof');
%     num_pix_to_read = pix_ends(i) - pix_starts(i) + 1;
%
%     read_size = [PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix_to_read];
%     %blocks{i} = fread_catch(obj.file_id_, read_size, '*float32');
%     blocks{i} = fread(obj.file_id_,read_size, '*float32');
%
%     try
%         seek_size = (pix_starts(i + 1) - pix_ends(i) - 1)*PIXEL_SIZE;
%     catch ME
%         if strcmpi(ME.identifier, 'MATLAB:badsubscript')
%             % we've read in the final block, no more seeking to do
%             break
%         end
%     end
%     do_fseek(obj.file_id_, seek_size, 'cof');
%end
blocks = arrayfun(@(pix_start,bl_size)(read_block(obj, ...
    PixelData.DEFAULT_NUM_PIX_FIELDS,pix_start,bl_size,format)),...
    pix_starts,pix_bl_sizes,'UniformOutput',false);
pix = [blocks{:}];

end  % function

function block = read_block(obj,NUM_FIELS,pix_start,block_size,format)
seek_pos = obj.pix_pos_ + (pix_start - 1)*obj.pixel_size;
do_fseek(obj.file_id_, seek_pos, 'bof');
read_size = [NUM_FIELS,block_size];
block  = fread(obj.file_id_,read_size, format);
[f_message,n_err] = ferror(obj.file_id_);
if n_err ~=0
    error('HORACE:sqw_binfile_common:io_error',f_message)
end

end
% -----------------------------------------------------------------------------
function [starts, ends] = merge_adjacent_ranges(starts, ends)
%%MERGE_ADJACENT_RANGES merge ranges starting in 'starts' and ending in
% 'ends' that are adjacent
% e.g.
%    >> starts = [1, 10, 45, 79, 86]
%    >> ends   = [5, 44, 67, 85, 90]
%    >> merge_adjacent_ranges(starts, ends)
%       ans =
%         [1, 10, 79]
%         [5, 67, 90]

% Find indices where end of one range and start of next differ by one
offsets = starts(2:end) - ends(1:(end - 1));
idxs_to_del = find(offsets == 1);
% Delete the indices such that those ranges are merged
starts(idxs_to_del + 1) = [];
ends(idxs_to_del) = [];
end
