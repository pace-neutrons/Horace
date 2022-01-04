function [npix,s,e,pix] = bin_pixels_(obj,coord,mode,npix,s,e,...
    pix_cand,varargin)


[ndims,sz_proj] = obj.data_dims();
data_range = obj.get_binning_range();

r1 = data_range(1,:)';
r2 = data_range(2,:)';

ok = all(coord>=r1 & coord<=r2,1);
coord = coord(:,ok);
if isempty(coord)
    if mode>3
        pix = PixelData();
    else
        pix = [];
    end
    return;
end

% bin only points in dimensions, containing more then one bin
n_bins = sz_proj;
if ndims<2
    n_bins = n_bins(1);
end
if ndims == 0
    npix = npix + sum(ok);
else
    r1 = r1(obj.pax);
    r2 = r2(obj.pax);
    step = (r2-r1)./n_bins';
    coord   = coord(obj.pax,:);
    
    %
    bin_step = 1./step;
    indx = floor((coord-r1)'.*bin_step')+1;
    % Due to round-off errors and general binning procedure, the
    % leftmost points have index, exceeding (by 1) the box size.
    % We include points with these indexes in the leftmost cell.
    on_edge = indx>n_bins;
    if any(reshape(on_edge,numel(on_edge),1))
        % assign these points to the leftmost bins
        for i=1:ndims
            indx(on_edge(:,i),i) = n_bins(i);
        end
    end
    
    npix = accumarray(indx, ones(1,size(indx,1)), sz_proj);
end
if mode<3
    pix = [];
    return;
end
sig = pix_cand.signal;
var = pix_cand.variance;
if ndims == 0
    s = s + sum(sig(ok));
    e = e + sum(var(ok));
else
    s = s + accumarray(indx, sig(ok), sz_proj);
    e = e + accumarray(indx, var(ok), sz_proj);
end
if mode<4
    pix = [];
    return;
end
pix = pix_cand.get_pixels(ok);
clear ok;
if ndims > 1
    stride = cumprod(sz_proj);
    indx =indx*[1,stride(1:end-1)]';
end
if ndims > 0
    pix = sort_pix(pix,indx,npix,varargin{:});
end
