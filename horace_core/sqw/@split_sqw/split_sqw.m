classdef split_sqw < sqw

    properties (Access=private)
        region = [];
        nWorkers = -1;
    end

    methods
        function obj = split_sqw(varargin)
            obj = obj@sqw();
        end

        function [s,var,mask_null] = sigvar_get (obj)
            s = obj.s;
            var = obj.e;
            mask_null = 0;
        end
    end

    methods(Static)
        function obj = distribute(varargin)
            ip = inputParser();
            addRequired(ip, 'sqw', @(x)(isa(x, 'sqw')))
            addParameter(ip, 'nWorkers', 1, @(x)(validateattributes(x, {'numeric'}, {'positive', 'integer', 'scalar'})));
            ip.parse(varargin{:})

            sqw = ip.Results.sqw;
            nWorkers = ip.Results.nWorkers;

            obj(1:nWorkers) = split_sqw();
            for i=1:nWorkers
                obj(i).main_header = sqw.main_header;
                obj(i).header = sqw.header;
                obj(i).detpar = sqw.detpar;
                obj(i).data = sqw.data;
            end
            nPer = floor(sqw.data.num_pixels / nWorkers);
            num_pixels = repmat(nPer, 1, nWorkers);
            for i=1:mod(sqw.data.npix, nWorkers)
                num_pixels(i) = num_pixels(i)+1;
            end

            points = [1, cumsum(num_pixels)];

            for i=1:nWorkers
                obj(i).data.pix = get_pix_in_ranges(sqw.data.pix, points(i), points(i+1));
            end
        end

    end

end