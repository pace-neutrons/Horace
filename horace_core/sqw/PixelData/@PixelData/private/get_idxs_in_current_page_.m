function [idx_in_pg, global_idx] = get_idxs_in_current_page_(obj, abs_indices)
% Extract the indices from abs_indices that lie within the bounds of the
% currently cached page of data and the corresponding page indices.
%
% Indices that do not exist in the current page are ignored.
%
% Example:
% --------
% If the PixelData object has 10 pixels, has a page size of 4, is on page 2,
% and `abs_indices` = [5, 3, 8, 4], then this function will return
% `global_idx` = [5, 8] (since 5 and 8 are the global indices in this page) and
% `idx_in_pg` = [1, 4] (since these are the indices relative to the second
% page).
%
% Input:
% ------
% obj          This PixelData object.
% abs_indices  The absolute indices of the desired pixels.
%
% Output:
% -------
%  idx_in_page  The page indices corresponding to the given absolute indices
%               that exist within the current page.
%  global_idx   The absolute indices that exist within the current page. This
%               will be a subset of `abs_indices`.
%
pg_start_idx = (obj.page_number_ - 1)*obj.max_page_size_ + 1;
pg_end_idx = pg_start_idx + obj.max_page_size_ - 1;

global_idx = find((abs_indices >= pg_start_idx) & (abs_indices <= pg_end_idx));
idx_in_pg = abs_indices(global_idx) - (obj.page_number_ - 1)*obj.max_page_size_;
