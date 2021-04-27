function pix_out = get_pix_in_ranges(obj, abs_indices_starts, abs_indices_ends)
%%GET_PIX_IN_RANGES read pixels in the specified ranges
% Ranges are inclusive.
%
%   >> pix = get_pix_in_ranges([1, 12, 25], [6, 12, 27])
%
% Input:
% ------
% pix_starts  Absolute indices of the starts of pixel ranges [Nx1 or 1xN array].
% pix_ends    Absolute indices of the ends of pixel ranges [Nx1 or 1xN array].
%
% Output:
% -------
% pix_out     A PixelData object containing the pixels in the given ranges.
%
[ok, mess] = validate_ranges(abs_indices_starts, abs_indices_ends);
if ~ok
    error('HORACE:PixelData:invalid_argument', mess);
end

if obj.is_file_backed_()
    if any(obj.page_dirty_)
        % At least some pixels sit in temporary files
        abs_indices = get_values_in_ranges(abs_indices_starts, abs_indices_ends);
        pix_out = obj.get_pixels(abs_indices);
    else
        skip_arg_validation = true;  % no point validating inputs again in faccess
        pix_out = PixelData( ...
            obj.f_accessor_.get_pix_in_ranges( ...
                abs_indices_starts, abs_indices_ends, skip_arg_validation ...
            ) ...
        );
    end
else
    % All pixels in memory
    indices = get_values_in_ranges(abs_indices_starts, abs_indices_ends);
    pix_out = PixelData(obj.data(:, indices));
end

end  % function


% -----------------------------------------------------------------------------
function out = get_values_in_ranges(range_starts, range_ends)
    % Get an array containing the values between the given ranges
    % e.g.
    %   >> range_starts = [1, 15, 12]
    %   >> range_ends = [4, 17, 14]
    %   >> get_values_in_ranges(range_starts, range_ends)
    %       ans = [1, 2, 3, 4, 15, 16, 17, 12, 13, 14]

    % Ensure the vectors are 1xN so concatenation below works
    if length(range_starts) > 1 && size(range_starts, 1) ~= 1
        range_starts = range_starts(:).';
        range_ends = range_ends(:).';
    end

    % Find the indexes of the boundaries of each range
    range_boundary_idxs = cumsum([1; range_ends(:) - range_starts(:) + 1]);
    % Generate vector of ones with length equal to output vector length
    value_diffs = ones(range_boundary_idxs(end) - 1, 1);
    % Insert size of the difference between boundaries in each boundary index
    value_diffs(range_boundary_idxs(1:end - 1)) = [ ...
        range_starts(1), range_starts(2:end) - range_ends(1:end - 1) ...
    ];
    % Take the cumulative sum
    out = cumsum(value_diffs);
end
