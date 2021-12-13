function [nbin,s,e,pix] = bin_pixels_(obj,pix_data,varargin)
if isa(pix_data,'PixelData')
    coord = pix_data.coordinates;
elseif isnumeric(pix_data)
    coord  = pix_data(1:4,:);
else
    error('HORACE:axes_block:invalid_argument',...
        'Unknown input type %s to bin data',...
        class(pix_data));
end

[~,size] = obj.data_dims();
data_range = obj.get_binning_range();
r0 = data_range(1,:)';
r1 = data_range(2,:)';
step = (r2-r1)./size;

ok = coord>=r0 & coord<=r1;
coord = coord(:,ok);

bin_step = cumprod(size);
bin_range =[1,bin_step(end-1)];
bin_step = bin_range./step;

indx = floor((coord-r0).*bin_step)+1;
