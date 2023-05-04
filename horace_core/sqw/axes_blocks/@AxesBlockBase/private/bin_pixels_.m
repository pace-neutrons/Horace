function [npix, s, e, pix_ok, unique_runid, pix_indx, selected] = bin_pixels_(obj,coord,nout,...
    npix,s,e,pix_cand,unique_runid,varargin)
% s,e,pix,unique_runid,pix_indx
% Sort pixels according to their coordinates in the axes grid and
% calculate pixels grid statistics.
%
%--------------------------------------------------------------------------
% Inputs:
%
% obj   -- the initialized AxesBlockBase object with the grid defined
% coord -- the 3D or 4D array of pixels coordinates transformed into
%          AxesBlockBase coordinate system
% num_outputs
%       -- the number of output parameters requested to process. Depending
%          on this number, additional parts of the algorithm will be
%          deployed.
% npix  -- the array of size of this grid, accumulating the information
%          about number of pixels contributing into each bin of the grid,
%          defined by this axes block.
% s    --  the array of size of the grid, defined by this
%          AxesBlockBase, containing the information about the accumulated
%          signal from all pixels, contributing to each grid cell.
% e    --  the array of size of the grid, defined by this
%          AxesBlockBase, containing the information about the error from all
%          pixels, contributing to each grid cell.
% npix, s, e arrays on input, contain the previous
%          state of the accumulator or 0, if this is the first call to
%          bin_pixels routine.
% pix_cand
%      -- if provided (not empty) contain PixelData information with
%         the pixels to bin. The signal and error, contributing into s and
%         e arrays are taken from this data. Some outputs may request sorting
%         pix_cand according to the grid.
% unique_runid
%      -- The unique indices, contributing into the cut. Empty on first
%         call.
% varargin may contain the following parameters:
% '-force_double'
%              -- if provided, the routine changes type of pixels
%                 it gets on input, into double. if not, output
%                 pixels will keep their initial type.
% '-return_selected'
%              -- sets pix_ok to return the indices of selected pixels
%                 for use with DnD cuts where fewer args are requested
%--------------------------------------------------------------------------
% Outputs:
% npix  -- the array of size of this grid, accumulating the information
%          about number of pixels contributing into each bin of the grid,
%          defined by this axes block.
% Optional:
% s,e  -- if num_outputs >=3, contains accumulated signal and errors from
%         the pixels, contributing into the grid. num_outputs >=3 requests
%         pix_cand parameter to be present and not empty.
% pix_ok
%      -- if num_outputs >=4, returns input pix_cand contributed to
%         the the cut and sorted by grid cell or left unsorted,
%         depending on requested pix_indx output.
%         IF '-return_selected' passed, contains indices of kept pixels
% unique_runid
%      -- if num_outputs >=5, array, containing the unique runids from the
%         pixels, contributed to the cut. If input unique_runid was not
%         empty, output unique_runid is combined with the input unique_runid
%         and contains no duplicates.
% pix_indx
%      -- in num_outputs ==6, contains indices of the grid cells,
%         containing the pixels from input pix_cand. If this parameter is
%         requested, the order of output pix corresponds to the order of
%         pixels in PixelData. if num_outputs<6, output pix are sorted by
%         npix bins.
%
% selected
%      -- in num_outputs == 7, contains indices of kept pixels

pix_ok = [];
pix_indx = [];
if nargin>8
    options = {'-force_double'};
    % keep unused argi parameter to tell parse_char_options to ignore
    % unknown options
    [ok,mess,force_double,argi]=parse_char_options(varargin,options);
    if ~ok
        error('HORACE:AxesBlockBase:invalid_argument',mess)
    end
else
    force_double = false;
end

bin_array_size  = obj.nbins_all_dims; % arrays of this size will be allocated too
ndims           = obj.dimensions;
data_range      = obj.img_range;
is_pix = isa(pix_cand,'PixelDataBase');

pax = obj.pax;
if size(coord,1) == 4
    r1 = data_range(1,:)';
    r2 = data_range(2,:)';
else % 3D array binning
    r1 = data_range(1,1:3)';
    r2 = data_range(2,1:3)';
    pax = pax(pax~=4);
    ndims = numel(pax);
end

% collapse first dimension, all along it should be ok for pixel be ok
if is_pix
    % Add filter for duplicated pix
    ok = all(coord>=r1 & coord<=r2,1) & pix_cand.detector_idx >= 0;
else
    ok = all(coord>=r1 & coord<=r2,1);
end

if ~any(ok)
    if nout>3 % no further calculations are necessary, so all
        % following outputs are processed.
        if iscell(pix_cand)
            pix_ok = zeros(size(s));
            selected = [];
        elseif return_selected
            pix_ok = [];
        else
            pix_ok = PixelDataBase.create();
            selected = [];
        end
        return;
    end
end

coord = coord(:,ok);

% bin only points in dimensions, containing more then one bin
n_bins  = bin_array_size(pax);

if ndims == 0
    npix = npix + sum(ok);
else
    r1 = r1(pax);
    r2 = r2(pax);
    step = (r2-r1)./n_bins';

    coord = coord(pax,:);

    bin_step = 1./step;
    pix_indx = floor((coord-r1)'.*bin_step')+1;
    % Due to round-off errors and general binning procedure, the
    % rightmost points have index, exceeding (by 1) the box size.
    % We include points with these indices in the rightmost cell.
    on_edge = pix_indx>n_bins;
    if any(on_edge(:))
        % assign these points to the leftmost bins
        for i=1:ndims
            pix_indx(on_edge(:,i),i) = n_bins(i);
        end
    end
    if numel(n_bins) == 1
        n_bins = [n_bins,1];
    end
    % mex code, if deployed below, needs pixels collected during this
    % particular accumulation.
    npix1 = accumarray(pix_indx, ones(1,size(pix_indx,1)), n_bins);
    npix = npix + npix1;
end

if nout<3
    return;
end

%--------------------------------------------------------------------------
% more then 1 output
% Calculating signal and error
%--------------------------------------------------------------------------

if is_pix
    ndata = 2;
else % cell with data array
    ndata = numel(pix_cand);
end

out = cell(1,ndata);
out{1} = s;
out{2} = e;

if is_pix
    bin_values = {pix_cand.signal;pix_cand.variance};
else % cellarray of arrays to accumulate
    bin_values = pix_cand;
    if ndata>=3 % Output changes type and meaning. Nasty.
        % Needs something better in a future
        pix_ok = zeros(size(s));
        out{3} = pix_ok;
    end
end

if ndims == 0
    for i=1:ndata
        out{i} = out{i}+sum(bin_values{i});
    end
else
    for i=1:ndata
        out{i} = out{i}+accumarray(pix_indx,bin_values{i}(ok),n_bins);
    end
end

s = out{1};
e = out{2};
if nout<4 || ~is_pix
    if ndata>=3
        pix_ok = out{3}; % redefine pix_ok to be npix accumulated
    end
    return;
end

if nout > 6
    selected = find(ok);
elseif return_selected
    pix_ok = find(ok);
    return
end

%--------------------------------------------------------------------------
% more than 4 outputs requested
% Get unsorted pixels, contributed to the bins
%--------------------------------------------------------------------------
% s,e,pix_ok,unique_runid,pix_indx
pix_ok = pix_cand.get_pixels(ok);
if nout<5
    return;
end

%--------------------------------------------------------------------------
% find unique indices,
% more then 5 outputs apparently requested to obtain sorted pixels
loc_unique = unique(pix_ok.run_idx);
unique_runid = unique([unique_runid,loc_unique]);
clear ok;

%-------------------------------------------------------------------------
% sort pixels according to bins
if ndims > 1 % convert to 1D indices
    stride = cumprod(n_bins);
    pix_indx =(pix_indx-1)*[1,stride(1:end-1)]'+1;
end
pix = pix_ok;

if ~isa(pix.data,'double') && force_double
    pix = PixelDataBase.create(double(pix.data));
end

if nout ~= 6 && ndims > 0
    pix = sort_pix(pix,pix_indx,npix1,varargin{:});
end

if nout == 6 && ndims == 0
    pix_indx = ones(pix.num_pixels,1);
end

pix_ok = pix;

end
