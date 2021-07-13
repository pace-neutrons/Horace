classdef split_sqw < sqw

    properties (Access=private)
        region = [];
        nWorkers = -1;
        s;
        e;
        npix;
        num_pixels;
    end

    methods
        function obj = split_sqw(varargin)
            obj = obj@sqw();
        end

        function [s,var,mask_null] = sigvar_get (obj)
            s = obj.s;
            var = obj.e;
            mask_null = logical(obj.data_.npix);
        end
    end

    methods(Static)
        function obj = distribute(varargin)
            ip = inputParser();


            addRequired(ip, 'sqw', @(x)(isa(x, 'SQWDnDBase')))
            addParameter(ip, 'nWorkers', 1, @(x)(validateattributes(x, {'numeric'}, {'positive', 'integer', 'scalar'})));
            ip.parse(varargin{:})

            sqw = ip.Results.sqw;
            nWorkers = ip.Results.nWorkers;
            obj(1:nWorkers) = split_sqw();

            if isa(sqw, 'DnDBase') % DnD object
                N = numel(sqw.npix);
                nPer = floor(N / nWorkers);
                num_pixels = repmat(nPer, 1, nWorkers);
                for i=1:mod(N, nWorkers)
                    num_pixels(i) = num_pixels(i)+1;
                end

                points = [0, cumsum(num_pixels)];
                for i=1:nWorkers
                    obj(i) = sqw;
                    obj(i).s = sqw.s(points(i)+1:points(i+1));
                    obj(i).e = sqw.e(points(i)+1:points(i+1));
                    obj(i).npix = sqw.npix(points(i)+1:points(i+1));
                    obj(i).num_pixels = num_pixels(i);
                end

            elseif isa(sqw, 'sqw')

                for i=1:nWorkers
                    obj(i).main_header = sqw.main_header;
                    obj(i).header = sqw.header;
                    obj(i).detpar = sqw.detpar;
                    obj(i).data = sqw.data;
                end
                nPer = floor(sqw.data.num_pixels / nWorkers);
                num_pixels = repmat(nPer, 1, nWorkers);
                for i=1:mod(sqw.data.num_pixels, nWorkers)
                    num_pixels(i) = num_pixels(i)+1;
                end

                points = [0, cumsum(num_pixels)];
                npix = split_npix(num_pixels, sqw.data.npix);

                for i=1:nWorkers
                    obj(i).data.pix = get_pix_in_ranges(sqw.data.pix, points(i)+1, points(i+1));
                    obj(i).data.npix = npix{i};
                    obj(i).s = obj(i).data_.s;
                    obj(i).e = obj(i).data_.e;
                end
            end
        end

    end

end

function npix = split_npix(num_pixels, old_npix)
% Splits npix between workers for accumulations, determining the split
% points with respect to bins.
%
% Overlaps first and last elements even if aligned with bins for ease of reduction.


    cumpix = cumsum(old_npix(:));
    cum_npix = cumsum(num_pixels);

    nWorkers = numel(num_pixels);

    % Preallocate
    npix = cell(nWorkers, 1);
    prev_ind = 0;

    rem = 0;

    for i=1:nWorkers-1
        % Find last *full* bin
        ind = find(cumpix - rem - cum_npix(i) > 0, 1)-1;

        diff = cum_npix(i) - cumpix(ind);

        npix{i} = old_npix(prev_ind+1:ind);
        npix{i} = [npix{i}, diff];

        % Skip 0th element
        if i > 1
            npix{i} = [rem, npix{i}];
        end

        % Remainder from bin
        rem = old_npix(ind+1) - diff;
        % Skip split bin
        prev_ind = ind+1;
    end

    % Fill last worker
    npix{nWorkers} = old_npix(prev_ind+1:end);
    npix{nWorkers} = [rem, npix{nWorkers}];

end