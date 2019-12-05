function [vals_av,vals_var,vals_devsqr]=average_bin_data(w,vals)
% Given sqw_type object, average one or more arrays of npixtot values to give one value per bin.
% npixtot is the number of pixels in the sqw object.
%
%   >> [vals_av,vals_var,vals_devsqr]=average_bin_data(w,vals)
%
% Input:
% ------
%   w       sqw object of sqw-type
%
%   vals    array, or cell array of arrays, each with npixtot elements, to be
%          averaged over the bins of w. That is, the first w.data.npix(1) values
%          are averaged to give one element, the next w.data.npix(2) averaged for
%          the second element etc.
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


% See also recompute_bin_data, which uses en essentially the same algorithm. Any changes
% to the one routine must be propagated to the other.

% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)

if nargout>=2
    var_request=true;
else
    var_request=false;
end

% Get the bin index for each pixel
nend=cumsum(w.data.npix(:));
nbeg=nend-w.data.npix(:)+1;
nbin=numel(w.data.npix);
npixtot=nend(end);
ind=zeros(npixtot,1);
for i=1:nbin
    ind(nbeg(i):nend(i))=i;
end

% Check size(s) of input array(s)
if iscell(vals)
    for i=1:numel(vals)
        if numel(vals{i})~=npixtot
            error('Check number of elements in input array(s)')
        end
    end
else
    if numel(vals)~=npixtot
        error('Check number of elements in input array')
    end
end

% Accumulate signal
nopix=(w.data.npix(:)==0);
if iscell(vals)
    vals_av=cell(size(vals));
    for i=1:numel(vals)
        vals_av{i}=accumarray(ind,vals{i}(:),[nbin,1])./w.data.npix(:);
        vals_av{i}=reshape(vals_av{i},size(w.data.npix));
        vals_av{i}(nopix)=0;
    end
    if var_request
        vals_var=cell(size(vals));
        vals_devsqr=cell(size(vals));
        for i=1:numel(vals)
            vals_devsqr{i}=(vals{i}(:)-replicate_array(vals_av{i},w.data.npix)).^2;    % square of deviations
            vals_var{i}=accumarray(ind,vals_devsqr{i},[nbin,1])./(w.data.npix(:).^2);
            vals_var{i}=reshape(vals_var{i},size(w.data.npix));
            vals_var{i}(nopix)=0;
        end
    end
else
    vals_av=accumarray(ind,vals(:),[nbin,1])./w.data.npix(:);
    vals_av=reshape(vals_av,size(w.data.npix));
    vals_av(nopix)=0;
    if var_request
        vals_devsqr=(vals(:)-replicate_array(vals_av)).^2;    % square of deviations
        vals_var=accumarray(ind,vals_devsqr,[nbin,1])./(w.data.npix(:).^2);
        vals_var=reshape(vals_var,size(w.data.npix));
        vals_var(nopix)=0;
    end
end

