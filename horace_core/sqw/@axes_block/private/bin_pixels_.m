function [npix,s,e,pix] = bin_pixels_(obj,coord,mode,varargin)


[accum_se,return_pixels,coord,s,e]=parse_inputs(obj,coord,mode,varargin{:});

[ndims,sz_proj] = obj.data_dims();
data_range = obj.get_binning_range();

r1 = data_range(1,:)';
r2 = data_range(2,:)';

ok = all(coord>=r1 & coord<=r2,1);
coord = coord(:,ok);
if isempty(coord)
    if return_pixels
        pix = PixelData();
    end
    return;
end

% bin only points in dimensions, containing more then one bin
r1 = r1(obj.pax);
r2 = r2(obj.pax);
step = (r2-r1)./sz_proj';
coord   = coord(obj.pax,:);

%
bin_step = 1./step;
indx = floor((coord-r1)'.*bin_step')+1;
% due to round-off errors and general binning procedure, the
% leftmost points have index, exceeding (by 1) the box size
on_edge = indx>sz_proj;
if any(reshape(on_edge,numel(on_edge),1))
    % assign these points to the leftmost bins
    for i=1:ndims
        indx(on_edge(:,i),i) = sz_proj(i);
    end
end
if numel(sz_proj)==1
    sz_proj = [sz_proj,1];
end
npix = accumarray(indx, ones(1,size(indx,1)), sz_proj);
if exist('signal','var')
    s = accumarray(indx, sig(ok), sz_proj);
    e = accumarray(indx, err(ok), sz_proj);
else
    s = [];
    e = [];
end
if exist('candidate_pix','var')
    pix = candidate_pix.get_pixels(ok);
    pix = sort_pix(pix,indx,npix,varargin{:});
else
    pix = [];
end
function [accum_se,return_pixels]=parse_inputs(narg,varargin)
if ~isnumeric(coord) || size(coord,1) ~= 4
    error('HORACE:axes_block:invalid_argument',...
        'Unknown input type %s or shape %s of the input coordinates',...
        class(coord),evalc('disp(size(coord))'));
end

    npix = zeros(sz_proj);
    if exist('signal','var')
        s =  zeros(sz_proj);
        e =  zeros(sz_proj);
    else
        s = [];
        e = [];
    end
    if exist('candidate_pix','var')
        pix = PixelData();
    else
        pix = [];
    end

