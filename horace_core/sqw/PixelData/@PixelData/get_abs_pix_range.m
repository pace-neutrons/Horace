function pix_out = get_abs_pix_range(obj, pix_indices)
%% GET_ABS_PIX_RANGE get the given range of pixels by absolute index into the
% .sqw file backing the given PixelData object
%
% This function may be useful if you want to extract data for a particular
% image bin.
%
pix_indices = parse_args(pix_indices);

if obj.is_file_backed_()
    obj.move_to_first_page();

    pix_out = PixelData(numel(pix_indices));

    [pg_idxs, global_idxs] = get_idxs_in_current_pg(obj, pix_indices);
    pix_out.data(:, global_idxs) = obj.data(:, pg_idxs);
    while obj.has_more()
        obj.advance();
        [pg_idxs, global_idxs] = get_idxs_in_current_pg(obj, pix_indices);
        pix_out.data(:, global_idxs) = obj.data(:, pg_idxs);
    end
else
    pix_out = obj.data(:, pix_indices);
end

end  % function


% -----------------------------------------------------------------------------
function pix_indices = parse_args(varargin)
    parser = inputParser();
    parser.addRequired('pix_indices', @isvector);
    parser.parse(varargin{:});

    pix_indices = parser.Results.pix_indices;
end

function [idx_in_pg, global_idx] = get_idxs_in_current_pg(obj, abs_indices)
    % Extract the indices from abs_indices that lie within the bounds of the
    % currently cached page of data.
    % Get the corresponding absolute indices as well.
    %
    pg_start_idx = (obj.page_number_ - 1)*obj.max_page_size_ + 1;
    pg_end_idx = pg_start_idx + obj.max_page_size_ - 1;

    global_idx = find((abs_indices >= pg_start_idx) & (abs_indices <= pg_end_idx));
    idx_in_pg = abs_indices(global_idx) - (obj.page_number_ - 1)*obj.max_page_size_;
end
