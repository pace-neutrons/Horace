function [npix_chunks, idxs] = split_npix(obj, npix, npix_cum_sum)
%SPLIT_NPIX Split npix array into chunks such that each chunk contains a page
% worth of pixels.
%
% This is particularly useful when looping over pixel pages and an array
% defining the binning of each page is required.
%
% Input:
% ------
% npix    The npix array that defines the binning of all the pixels in obj.
%
% Output:
% -------
% npix_chunks   Cell array of double arrays. Each array sums to obj.page_size,
%               and defines the binning for each page of pixels in obj.
%               Not that obj.page_size for the final page of pixels can be less
%               than for every other page.
% idxs          Cell array of length 2 double arrays. Each array is the start
%               and end index of each npix chunk into the original npix array.
%
npix_cum_sum = cumsum(npix(:));
num_pix = npix_cum_sum(end);

num_pages = ceil(obj.num_pixels/obj.base_page_size);
pg_size = obj.base_page_size;
npix_chunks = cell(1, num_pages);
idxs = cell(1, num_pages);
end_idx = 1;
allocated = 0;
for i = 1:num_pages
    pg_size = min(pg_size, num_pix - allocated);

    % Find the index of the first bin to allocate pixels to.
    % We subtract allocated pixels from the cumulative sum later, so the first
    % bin to allocate pixels to will be the first bin with cumulative sum > 0
    start_idx = (end_idx - 1) + find(npix_cum_sum(end_idx:end) > 0, 1);
    % Get number of pixels to allocate to bin n, that weren't allocated on
    % the last iteration
    leftover_begin = npix_cum_sum(start_idx);

    % Subtract allocated pixels from the npix cumulative sum
    npix_cum_sum = npix_cum_sum - pg_size;
    % Find the index of the last bin to allocate pixels to
    end_idx = (start_idx - 1) + find(npix_cum_sum(start_idx:end) > 0, 1);
    if isempty(end_idx)
        % No end index found, must be at the end of the npix array
        end_idx = numel(npix);
    end

    if start_idx == end_idx
        % All pixels in page
        if ~exist('leftover_end', 'var')
            leftover_end = 0;
        end
        npix_chunks{i} = min(pg_size, npix(start_idx) - leftover_end);
    else
        % get the number of pixels in the page to allocate to each bin
        % leftover_begin = number of pixels remaining from last iteration
        npix_chunk = [leftover_begin, ...
                      reshape(npix(start_idx + 1:end_idx - 1), 1, []), ...
                      0];
        % get the number of pixels left in the page to allocate
        leftover_end = pg_size - sum(npix_chunk);
        npix_chunk(end) = leftover_end;
        npix_chunks{i} = npix_chunk;
    end
    idxs{i} = [start_idx, end_idx];
    allocated = allocated + sum(npix_chunks{i});
end
