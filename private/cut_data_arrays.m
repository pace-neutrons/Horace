function [s_out, e_out] = cut_data_arrays (ndims, iax, ilo, ihi, s, e)
% Sum signal and error (i.e. variance) arrays along the specified
% dimension between (and including) the two indexes. The output arrays are
% reduced in dimension by unity.
%
% Syntax:
%   >> [s_out, e_out] = cut_data_arrays (iax, ilo, ihi, s, e)
%
% Input arrays must have 1,2,3 or 4 dimensions. Checks are rudimentary - it is assumed
% that ilo and ihi are valid for the given summation axis, for example.
%
% inputs:
% -------
%   iax:    Integration axis
%   ilo:    Integration lower limit
%   ihi:    Integration higher limit
%   s:      Signal data
%   e:      Error data
%
% This will integrate the signal data in one dimension accross the limits 
% to reduce the dimensionality. 

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% generate n, number of contributing detectors, and insure that NaNs in
% signal are taken care of.

n = ones(size(s));
nanindex = isnan(s);
s(nanindex) = 0;
e(nanindex) = 0;
n(nanindex) = 0;

if ndims==1
    if iax==1
        n = sum(n(ilo:ihi));
        s_out = sum(s(ilo:ihi));
        e_out = sum(e(ilo:ihi) );
    else
        error ('ERROR: Invalid axis option')
    end
elseif ndims==2
    if iax==1
        n = sum(n(ilo:ihi,:) ,1);
        s_out = sum(s(ilo:ihi,:) ,1);
        e_out = sum(e(ilo:ihi,:) ,1);

    elseif iax==2
        n = sum(n(:,ilo:ihi) ,2);
        s_out = sum(s(:,ilo:ihi) ,2);
        e_out = sum(e(:,ilo:ihi) ,2);
    else
        error ('ERROR: Invalid axis option')
    end
elseif ndims==3
    if iax==1
        n = sum(n(ilo:ihi,:,:) ,1);
        s_out = sum(s(ilo:ihi,:,:) ,1);
        e_out = sum(e(ilo:ihi,:,:) ,1);
    elseif iax==2
        n = sum(n(:,ilo:ihi,:) ,2);
        s_out = sum(s(:,ilo:ihi,:) ,2);
        e_out = sum(e(:,ilo:ihi,:) ,2);
    elseif iax==3
        n = sum(n(:,:,ilo:ihi) ,3);
        s_out = sum(s(:,:,ilo:ihi) ,3);
        e_out = sum(e(:,:,ilo:ihi) ,3);
    else
        error ('ERROR: Invalid axis option')
    end
elseif ndims==4
    if iax==1
        n = sum(n(ilo:ihi,:,:,:) ,1);
        s_out = sum(s(ilo:ihi,:,:,:) ,1);
        e_out = sum(e(ilo:ihi,:,:,:) ,1);
    elseif iax==2
        n = sum(n(:,ilo:ihi,:,:) ,2);
        s_out = sum(s(:,ilo:ihi,:,:) ,2);
        e_out = sum(e(:,ilo:ihi,:,:) ,2);
    elseif iax==3
        n = sum(n(:,:,ilo:ihi,:) ,3);
        s_out = sum(s(:,:,ilo:ihi,:) ,3);
        e_out = sum(e(:,:,ilo:ihi,:) ,3);
    elseif iax==4
        n = sum(n(:,:,:,ilo:ihi) ,4);
        s_out = sum(s(:,:,:,ilo:ihi) ,4);
        e_out = sum(e(:,:,:,ilo:ihi) ,4);
    else
        error ('ERROR: Invalid axis option')
    end

else
    error('ERROR: Number of dimensions of input arrays must be =< 4')
end

% normalise by number of contributing pixels
n(~n) = nan;
s_out = s_out./n;
e_out = e_out./(n.^2);
