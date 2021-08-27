function [obj, merge_data] = split_sqw(varargin)
    ip = inputParser();

    addRequired(ip, 'sqw', @(x)(isa(x, 'SQWDnDBase')))
    addParameter(ip, 'nWorkers', 1, @(x)(validateattributes(x, {'numeric'}, {'positive', 'integer', 'scalar'})));
    ip.parse(varargin{:})

    sqw_in = ip.Results.sqw;
    nWorkers = ip.Results.nWorkers;

% $$$       debugging
% $$$             for nw=1:8
% $$$                 nPer = floor(sqw_in.data.num_pixels / nw);
% $$$                 num_pixels = repmat(nPer, 1, nw);
% $$$                 for i=1:mod(sqw_in.data.num_pixels, nw)
% $$$                     num_pixels(i) = num_pixels(i)+1;
% $$$                 end
% $$$                 split_npix(num_pixels, sqw_in.data.npix)
% $$$                 cellfun(@sum, split_npix(num_pixels, sqw_in.data.npix))
% $$$                 sum(cellfun(@sum, split_npix(num_pixels, sqw_in.data.npix)))
% $$$             end

    merge_data = arrayfun(@(x) struct(), 1:3);

    if isa(sqw_in, 'DnDBase') % DnD object
        N = numel(sqw_in.npix);
        nPer = floor(N / nWorkers);
        num_pixels = repmat(nPer, 1, nWorkers);
        for i=1:mod(N, nWorkers)
            num_pixels(i) = num_pixels(i)+1;
        end

        points = [0, cumsum(num_pixels)];

        for i=1:nWorkers
            obj(i) = sqw_in;
            obj(i).s = sqw_in.s(points(i)+1:points(i+1));
            obj(i).e = sqw_in.e(points(i)+1:points(i+1));
            obj(i).npix = sqw_in.npix(points(i)+1:points(i+1));
            merge_data(i).nelem = sum(logical(obj(i).npix));
            merge_data(i).nomerge = true;
        end
    elseif isa(sqw_in, 'sqw')

        nPer = floor(sqw_in.data.num_pixels / nWorkers);
        num_pixels = repmat(nPer, 1, nWorkers);
        for i=1:mod(sqw_in.data.num_pixels, nWorkers)
            num_pixels(i) = num_pixels(i)+1;
        end

        points = [0, cumsum(num_pixels)];
        [npix, nomerge] = split_npix(num_pixels, sqw_in.data.npix);

        for i=1:nWorkers
            obj(i) = sqw_in;
            obj(i).data.npix = npix{i};
            obj(i).data.pix = get_pix_in_ranges(sqw_in.data.pix, points(i)+1, points(i+1));
% $$$             obj(i) = recompute_bin_data(obj(i));
% $$$             obj(i).s = obj(i).data_.s;
% $$$             obj(i).e = obj(i).data_.e;
            merge_data(i).nomerge = nomerge(i);
            merge_data(i).nelem = sum(logical(obj(i).data.npix));

        end

    end
end

function [npix, nomerge] = split_npix(num_pixels, old_npix)
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
        nomerge = true;
        return
    end

    % Preallocate
    npix = cell(nWorkers, 1);
    prev_ind = 0;

    rem = cumpix(1);
    nomerge(nWorkers) = 0;

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
        nomerge(i+1) = rem == 0;

        % Skip split bin
        prev_ind = ind+1;
    end

    % Fill last worker
    if prev_ind > 0
        npix{nWorkers} = old_npix(prev_ind+1:end);
    end
    npix{nWorkers} = [rem; npix{nWorkers}];

end