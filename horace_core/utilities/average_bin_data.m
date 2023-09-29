function [vals_av, vals_var, vals_devsqr] = average_bin_data(npix, vals)
% Given sqw_type object, average one or more arrays of npixtot values to give one value per bin.
% npixtot is the number of pixels in the sqw object.
%
%   >> [vals_av,vals_var,vals_devsqr]=average_bin_data(w,vals)
%
% Input:
% ------
%   npix   npix array of bins to average data over
%
%   vals   array, or cell array of arrays, each with npixtot elements, to be
%          averaged over the bins of w. That is, the first npix(1)
%          values are averaged to give one element, the next npix(2)
%          averaged for the second element etc.
%
% Output:
% -------
%   val_av  array, or cell array of arrays, containing the averaged values.
%           - the size is equal to size(w.data.signal)
%           - if there were no pixels for a bin, the average is returned as 0.
%
%   val_var array, or cell array of arrays, containing the variance of the values.
%           - the size is equal to size(w.data.signal)
%           - if there were no pixels for a bin, the average is returned as 0.
%
%   val_devsqr  Square deviation for all of the values

stddev_request = nargout >= 2;

nbin    = numel(npix);
npixtot = sum(npix(:));
% Get the bin index for each pixel
ind = repelem(1:numel(npix), npix(:))';


% Check size(s) of input array(s)
if iscell(vals) && any(cellfun(@numel, vals) ~= npixtot)
    error('HORACE:average_bin_data:invalid_argument',...
        'Invalid number of elements in input array(s)')
elseif ~iscell(vals) && numel(vals)~=npixtot
    error('HORACE:average_bin_data:invalid_argument',...
        'Invalid number of elements in input array')
end

% Accumulate signal
nopix=(npix(:)==0);
if iscell(vals)
    vals_av=cell(size(vals));
    for i=1:numel(vals)
        vals_av{i}=accumarray(ind,vals{i}(:),[nbin,1])./npix(:);
        vals_av{i}=reshape(vals_av{i},size(npix));
        vals_av{i}(nopix)=0;
    end
    if stddev_request
        vals_var=cell(size(vals));
        vals_devsqr=cell(size(vals));
        for i=1:numel(vals)
            vals_devsqr{i}=(vals{i}(:)-replicate_array(vals_av{i},npix)).^2;    % square of deviations
            vals_var{i}=accumarray(ind,vals_devsqr{i},[nbin,1])./(npix(:).^2);
            vals_var{i}=reshape(vals_var{i},size(npix));
            vals_var{i}(nopix)=0;
        end
    end
else
    vals_av=accumarray(ind,vals(:),[nbin,1])./npix(:);
    vals_av=reshape(vals_av,size(npix));
    vals_av(nopix)=0;
    if stddev_request
        vals_devsqr=(vals(:)-replicate_array(vals_av,npix)).^2;    % square of deviations
        vals_var=accumarray(ind,vals_devsqr,[nbin,1])./(npix(:).^2);
        vals_var=reshape(vals_var,size(npix));
        vals_var(nopix)=0;
    end
end

end
