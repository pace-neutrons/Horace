function [obj, merge_data] = distribute(sqw_in, varargin)
% Function to split (for parallel distribution) an sqw/dnd object between multiple processes.
% Attempts to split objects as close as possible to equal with respect to number of pixels per process.
%
% [obj, merge_data] = distribute(sqw_in, 'nWorkers', 1, 'split_bins', true)
%
% Input
% ---------
%   sqw_in      sqw/DnD object to be split amongst processors
%
%   nWorkers    number of processes to divide final object between
%
%   split_bins  whether bins are allowed to be split (in the case of sqw objects)
%
% Output
% ---------
%
%   obj         resulting split sqw object as list of SQW subobjects each
%               holding a smaller section of the pixels
%
%   merge_data  vector of structs  [nWorkers x 1] containing data relevant to the
%               re-merging of a split object
%                  nelem      - Number of pixels in first/last bins for merging
%                  nomerge    - Whether bins are split and remerging is necessary
%                  range      - Range in bins from  original sqw/DnD object contained in subobject
%                  pix_range  - Range in pixels from original sqw/DnD object contained in subobject
%

    ip = inputParser();

    addOptional(ip, 'nWorkers', 1, @(x)(validateattributes(x, {'numeric'}, {'positive', 'integer', 'scalar'})));
    addOptional(ip, 'split_bins', true, @islognumscalar)
    ip.parse(varargin{:})

    nWorkers = ip.Results.nWorkers;
    split_bins = ip.Results.split_bins;

    merge_data = arrayfun(@(x) struct('nelem', [], 'nomerge', true, 'pix_range', [-inf, -inf]), 1:nWorkers);

    nPer = floor(sqw_in.npixels / nWorkers);
    overflow = mod(sqw_in.npixels, nWorkers);
    num_pixels = repmat(nPer, 1, nWorkers);
    num_pixels(1:overflow) = num_pixels(1:overflow)+1;

    points = [0, cumsum(num_pixels)];

    if split_bins

        [npix, merge_data] = split_npix(num_pixels, sqw_in.data.npix, merge_data);
    else
        prev = 0;
        npix = cell(nWorkers, 1);

        loc = cumsum(sqw_in.data.npix(:));
        for i=1:nWorkers
            curr = find(loc > points(i+1), 1);

            if loc(curr - 1) == points(i+1)  % Falls on bin boundary
                curr = curr - 1;
            elseif isempty(curr)             % Falls after end of array
                curr = numel(loc);
            end

            npix{i} = sqw_in.data.npix(prev+1:curr);
            merge_data(i).range = [prev+1, curr];
            num_pixels(i) = sum(sqw_in.data.npix(prev+1:curr));
            points(i+1) = points(i)+num_pixels(i);
            prev = curr;
        end
    end

    obj = repmat(copy(sqw_in),nWorkers,1);
    tmp_pix = sqw_in.pix.distribute(points(1:end-1), num_pixels);
    for i=1:nWorkers
        obj(i).pix = tmp_pix{i};
        obj(i).data = d1d(axes_block('img_range', obj(i).pix.pix_range, ...
                                     'nbins_all_dims', [numel(npix{i}),1,1,1]), ...
                          sqw_in.data.proj);
        obj(i).data.do_check_combo_arg = false;
        obj(i).data.npix = npix{i};
        [obj(i).data.s, obj(i).data.e] = obj(i).pix.compute_bin_data(obj(i).data.npix);
        obj(i).data.do_check_combo_arg = true;
        obj(i).data.check_combo_arg();
        merge_data(i).nelem = [obj(i).data.npix(1), ...
                               obj(i).data.npix(end)]; % Pixels at split end-bins to recombine
        merge_data(i).pix_range = [points(i)+1, points(i)+num_pixels(i)];
    end
end

function [npix, merge_data] = split_npix(num_pixels, old_npix, merge_data)
% Splits npix between workers for accumulations, determining the split
% points with respect to bins.
%
% num_pixels -- is a list containing the number of pixels to go to each worker
% old_npix   -- incoming pixel-per-bin count
%
% Overlaps first and last elements even if aligned with bins for ease of reduction.

% Force column vector
    old_npix = old_npix(:);

    cumpix = cumsum(old_npix(:));
    cum_npix = cumsum(num_pixels);

    nWorkers = numel(num_pixels);

    if nWorkers == 1
        npix = {old_npix};
        merge_data.nomerge = true;
        merge_data.range = [1, numel(old_npix)];
        return
    end

    % Preallocate
    npix = cell(nWorkers, 1);
    prev_ind = 0;

    rem = cumpix(1);
    for i = 1:nWorkers
        merge_data(i).nomerge = false;
    end

    for i=1:nWorkers-1
        % Catch all-in-one
        if rem > num_pixels(i)
            rem = rem - num_pixels(i);
            npix{i} = [num_pixels(i), 0];
            if i > 1
                npix{i} = [0, npix{i}];
            end
            continue;
        end

        % Find last *full* bin
        ind = find(cumpix - cum_npix(i) >= 0, 1)-1;

        diff = cum_npix(i) - cumpix(ind);

        npix{i} = old_npix(prev_ind+1:ind);
        npix{i} = [npix{i}; diff];


        % Skip 0th element
        if i > 1
            npix{i} = [rem; npix{i}];
        end


        % Remainder from bin
        rem = old_npix(ind+1) - diff;

        % Have to be careful to not merge if whole bin
        merge_data(i+1).nomerge = rem == 0;
        merge_data(i).range = [prev_ind+1, ind];

        % Skip split bin
        prev_ind = ind+1;
    end

    % Fill last worker
    if prev_ind > 0
        npix{nWorkers} = old_npix(prev_ind+1:end);
        merge_data(nWorkers).range = [prev_ind+1, numel(old_npix)];
    end
    npix{nWorkers} = [rem; npix{nWorkers}];

end
