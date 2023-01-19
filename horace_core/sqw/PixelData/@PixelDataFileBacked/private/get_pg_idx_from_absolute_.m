function [page_idx, global_idx] = get_pg_idx_from_absolute_(obj, abs_indices, page_number)
% Extract the indices from abs_indices that lie within the bounds of the
% given page and the corresponding page indices.
%
% Indices that do not exist in the given page are ignored.
%
% Example:
% --------
% If the PixelData object has 10 pixels, has a page size of 4, page_number is
% 2, and `abs_indices` = [5, 3, 8, 4], then this function will return
% `global_idx` = [5, 8] (since 5 and 8 are the global indices in this page) and
% `idx_in_pg` = [1, 4] (since these are the global indices relative to the #
% second page).
%
% Input:
% ------
% obj          This PixelData object.
% abs_indices  The absolute indices of the desired pixels.
% page_number  The page number to get the indices relative to.
%
% Output:
% -------
%  page_idx    The page indices corresponding to the given absolute indices
%              that exist within the given page.
%  global_idx  The absolute indices that exist within the given page. This
%              will be a subset of `abs_indices`.
%

[pg_start_idx, pg_end_idx] = obj.get_page_idx_(page_number);
abs_idx_in_page = (abs_indices >= pg_start_idx) & (abs_indices <= pg_end_idx);
page_idx = abs_indices(abs_idx_in_page) - (page_number - 1)*obj.base_page_size;

if nargout == 2
    global_idx = find(abs_idx_in_page);
end

end
