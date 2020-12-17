function pix_out = get_pix_in_ranges(obj, abs_indices_starts, abs_indices_ends);
%%GET_PIX_IN_RANGES
%

if obj.is_file_backed_()
    if any(obj.page_dirty_)
        % At least some pixels sit in temporary files
        abs_indices = get_values_in_ranges(abs_indices_starts, abs_indices_ends);
        pix_out = obj.get_pixels(abs_indices);
    else
        pix_out = PixelData( ...
            obj.f_accessor_.get_pix_in_ranges( ...
                abs_indices_starts, abs_indices_ends) ...
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
    %   >> get_values_in_range(range_starts, range_ends)
    %       ans = [1, 2, 3, 4, 15, 16, 17, 12, 13, 14]

    % Find the indexes of the boundaries of each range
    range_bounds_idxs = cumsum([1; range_ends(:) - range_starts(:) + 1]);
    z = ones(range_bounds_idxs(end) - 1, 1);
    % Insert size of the difference between boundaries in each boundary index
    z(range_bounds_idxs(1:end - 1)) = [ ...
        range_starts(1), range_starts(2:end) - range_ends(1:end - 1) ...
    ];
    % Take a cumulative sum
    out = cumsum(z);
end
