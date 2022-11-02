function [obj, merge_data] = distribute(dnd_in, varargin)
% Function to split an dnd object between multiple processes.
% Attempts to split objects equally with respect to number of pixels per process.
%
% [obj, merge_data] = split_sqw(sqw, 'nWorkers', 1, 'split_bins', true)
%
% Input
% ---------
%   sqw         DnD object to be split amongst processors
%
%   nWorkers    number of processes to divide final object between
%
%   split_bins  whether bins are allowed to be split (in the case of sqw objects)
%
% Output
% ---------
%
%   obj         split DnD object as list of DnD subobjects each holding a smaller section of the pixels [nWorkers 1]
%
%   merge_data  list of structs containing relevant data to the splitting [nWorkers 1]
%                  nelem      - Number of pixels in first/last bins for merging
%                  nomerge    - Whether bins are split and remerging is necessary
%                  range      - Range in bins from  original sqw/DnD object contained in subobject
%                  pix_range  - Range in pixels from original sqw/DnD object contained in subobject
%

    ip = inputParser();

    addOptional(ip, 'nWorkers', 1, @(x)(validateattributes(x, {'numeric'}, {'positive', 'integer', 'scalar'})));
    addOptional(ip, 'split_bins', true, @islognumscalar) % Ignored as dnd can't split bins
    ip.parse(varargin{:})

    nWorkers = ip.Results.nWorkers;
    split_bins = ip.Results.split_bins;

    merge_data = arrayfun(@(x) struct(), 1:nWorkers);

    N = numel(dnd_in.npix);
    nPer = floor(N / nWorkers);
    overflow = mod(N, nWorkers);
    num_pixels = repmat(nPer, 1, nWorkers);
    num_pixels(1:overflow) = num_pixels(1:overflow)+1;

    points = [0, cumsum(num_pixels)];

    obj = repmat(dnd_in,nworkers,1);
    for i=1:nWorkers
        obj(i).data.do_check_combo_arg = false;

        obj(i).s = dnd_in.s(points(i)+1:points(i+1));
        obj(i).e = dnd_in.e(points(i)+1:points(i+1));
        obj(i).npix = dnd_in.npix(points(i)+1:points(i+1));
        obj(i).axes = axes_block('nbins_all_dims', [numel(npix{i}), 1, 1, 1]);

        obj(i).data.do_check_combo_arg = true;
        obj(i).data.check_combo_arg();

        merge_data(i).nelem = sum(logical(obj(i).npix));
        merge_data(i).nomerge = true;
        merge_data(i).range = [points(i)+1, points(i+1)];
        if i > 1
            merge_data(i).pix_range = [merge_data(i-1).pix_range(2)+1, ...
                                       merge_data(i-1).pix_range(2)+1+obj(i).npix];
        else
            merge_data(i).pix_range = [1, obj(i).npix+1];
        end
    end

end
