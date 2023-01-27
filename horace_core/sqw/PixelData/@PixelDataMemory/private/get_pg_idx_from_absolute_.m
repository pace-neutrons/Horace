function [page_idx, global_idx] = get_pg_idx_from_absolute_(obj, abs_indices, ~)
% Provided for compatibility, since PixelDataMemory only has one page.
%
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
% page_number  Provided for interface compatibility, ignored since only one page.
%
% Output:
% -------
%  page_idx    The page indices corresponding to the given absolute indices
%              that exist within the given page.
%  global_idx  The absolute indices that exist within the given page. This
%              will be a subset of `abs_indices`.
%

page_idx = 1; % Only one page for MemoryBacked objects
global_idx = abs_indices(abs_indices < obj.page_size);

end
