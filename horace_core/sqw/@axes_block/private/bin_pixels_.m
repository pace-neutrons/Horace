function [npix,s,e,pix,unique_runid,pix_indx] = bin_pixels_(obj,coord,num_outputs,...
    npix,s,e,pix_cand,unique_runid,varargin)
% Sort pixels according to their coordinates in the axes grid and
% calculate pixels grid statistics.
%
%--------------------------------------------------------------------------
% Inputs:
%
% obj   -- the initialized axes_block object with the grid defined
% coord -- the 3D or 4D array of pixels coordinates transformed into
%          axes_block coordinate system
% num_outputs
%       -- the number of output parameters requested to process. Depending
%          on this number, additional parts of the algorithm will be
%          deployed.
% npix  -- the array of size of this grid, accumulating the information
%          about number of pixels contributing into each bin of the grid,
%          defined by this axes block.
% s    --  the array of size of the grid, defined by this
%          axes_block, containing the information about the accumulated
%          signal from all pixels, contributing to each grid cell.
% e    --  the array of size of the grid, defined by this
%          axes_block, containing the information about the error from all
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
%      -- The unuqueue indexes, contributing into the cut. Empty on first
%         call.
% Varargin may contain the following parameters:
% '-force_double'
%              -- if provided, the routine changes type of pixels
%                 it gets on input, into double. if not, output
%                 pixels will keep their initial type.
%--------------------------------------------------------------------------
% Outputs:
% npix  -- the array of size of this grid, accumulating the information
%          about number of pixels contributing into each bin of the grid,
%          defined by this axes block.
% Optional:
% s,e  -- if num_outputs >=3, contains accumulated signal and errors from
%         the pixels, contributing into the grid. num_outputs >=3 requests
%         pix_cand parameter to be present and not empty.
% pix  -- if num_outputs >=4, returns input pix_cand contributed to 
%         the the cut and sorted by grid cell or left unsorted, 
%         depending on requested pix_indx output.
% unique_runid
%      -- if num_outputs >=5, array, containing the unique runids from the
%         pixels, contributed to the cut. If input unique_runid was not
%         empty, output unique_runid is combined with input unique_runid
%         and contains no duplicates.
% pix_indx
%      -- in num_outputs ==6, contains indexes of the grid cells,
%         containing the pixels from input pix_cand. If this parameter is
%         requested, the order of output pix corresponds to the order of
%         pixels in PixelData. if num_outputs<6, output pix are sorted by
%         npix bins.


pix = [];
pix_indx = [];
if nargin>8
    options = {'-force_double'};
    % keep unused argi parameter to tell parce_char_options to ignore
    % unknown options
    [ok,mess,force_double,argi]=parse_char_options(varargin,options);
    if ~ok
        error('HORACE:axes_block:invalid_argument',mess)
    end
else
    force_double =false;
end

bin_array_size  = obj.nbins_all_dims; % arrays of this size will be allocated too
ndims           = obj.dimensions;
data_range      = obj.img_range;

pax = obj.pax;
if size(coord,1) ==4
    r1 = data_range(1,:)';
    r2 = data_range(2,:)';
else % 3D array binning
    r1 = data_range(1,1:3)';
    r2 = data_range(2,1:3)';
    pax = pax(pax~=4);
    if isempty(pax)
        ndims  = 0;
    end
end

ok = all(coord>=r1 & coord<=r2,1); % collapse first dimension, all along it should be ok for pixel be ok
coord = coord(:,ok);
if isempty(coord)
    if num_outputs>3 % no further calculations are necessary, so all 
        % following outputs are processed.
        pix = PixelData();
        return;
    end
end
% bin only points in dimensions, containing more then one bin
n_bins  = bin_array_size(pax);

if ndims == 0
    npix = npix + sum(ok);
else
    r1 = r1(pax);
    r2 = r2(pax);
    step = (r2-r1)./n_bins';

    coord   = coord(pax,:);

    %
    bin_step = 1./step;
    pix_indx = floor((coord-r1)'.*bin_step')+1;
    % Due to round-off errors and general binning procedure, the
    % rightmost points have index, exceeding (by 1) the box size.
    % We include points with these indexes in the rightmost cell.
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
    % particular accomulation.
    npix1 = accumarray(pix_indx, ones(1,size(pix_indx,1)), n_bins);
    npix = npix + npix1;
end
if num_outputs<3
    return;
end
%--------------------------------------------------------------------------
% moree then 1 output
% Calclulating signal and error
%--------------------------------------------------------------------------
sig = pix_cand.signal;
var = pix_cand.variance;
if ndims == 0
    s = s + sum(sig(ok));
    e = e + sum(var(ok));
else
    s = s + accumarray(pix_indx, sig(ok), n_bins);
    e = e + accumarray(pix_indx, var(ok), n_bins);
end
if num_outputs<4
    return;
end
%--------------------------------------------------------------------------
% more than 4 outputs
% Get unsorted pixels, contributed to the bins
%--------------------------------------------------------------------------
pix          = pix_cand.get_pixels(ok);
if num_outputs<5
    return;
end
%--------------------------------------------------------------------------
% find unique indexes,
% more then 5 outputs apparently requested to obtain sorted pixels
loc_unique = unique(pix.run_idx);
unique_runid = unique([unique_runid,loc_unique]);
clear ok;
%-------------------------------------------------------------------------
% sort pixels according to bins
if ndims > 1 % convert to 1D indexes
    stride = cumprod(n_bins);
    pix_indx =(pix_indx-1)*[1,stride(1:end-1)]'+1;
end

if ndims > 0
    if num_outputs ==6
        if ~isa(pix.data,'double') && force_double % TODO: this should be moved to get_pixels
            pix = PixelData(double(pix.data));     % when PixelData is separated into file accessor and memory accessor
        end
    else % sort will make pix double if requested  TODO: this should be moved to get_pixels
        pix = sort_pix(pix,pix_indx,npix1,varargin{:}); % when PixelData is separated into file accessor and memory accessor
    end
elseif ndims == 0
    if ~isa(pix.data,'double') && force_double % TODO: this should be moved to get_pixels
        pix = PixelData(double(pix.data));     % when PixelData is separated into file accessor and memory accessor
    end
    if num_outputs == 6
        pix_indx = ones(pix.num_pixels,1);
    end
end