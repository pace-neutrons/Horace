function [vals_av, vals_var, vals_devsqr] = average_bin_data_(w, vals)
% Given sqw_type object, average one or more arrays of npixtot values to give one value per bin.
% npixtot is the number of pixels in the sqw object.
%
%   >> [vals_av,vals_var,vals_devsqr]=average_bin_data_(w,vals)
%
% Input:
% ------
%   w       sqw object of sqw-type
%
%   vals   array, or cell array of arrays, each with npixtot elements, to be
%          averaged over the bins of w. That is, the first w.data.npix(1)
%          values are averaged to give one element, the next w.data.npix(2)
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

if stddev_request
    [vals_av, vals_var, vals_devsqr] = average_bin_data(w.data.npix, vals);
else
    [vals_av, vals_var] = average_bin_data(w.data.npix, vals);
end

end
