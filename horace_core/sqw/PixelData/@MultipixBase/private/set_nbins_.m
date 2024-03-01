function obj = set_nbins_(obj,val)
%SET_NBINS_ defines number of bins in each image to combine together
% val -- single positive value, describing number of bins in
%        the images to be combined. Single value as have to be same for all
%        images
if ~isnumeric(val) || val < 1
    error('HORACE:pix_combine_info:invalid_argument', ...
        'number of bins for pix_combine info should be positive number. It is: %s',...
        dis2str(val));
end
obj.nbins_ = val;
