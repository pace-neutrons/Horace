function [npix,s,e] = init_accumulators_(obj,n_accum,force_3D)
% Initialize binning accumulators, used during bin_pixels
% process.
%
% Inputs:
% obj     -- initialized instance of AxesBlockBase class
% n_accum -- number of accumulator arrays to initialize.
%            may be 1 or 3 (2 transformed to 3)
% force_3D-- if true, return only 3-dimensional 
%            accumulator arrays ignoring last (energy transfer) dimension.
%
% Returns:   Depending on n_accum, 1 or 3 empty arrays
%            if n_accum == 1, two other arrays are empty
% npix    -- empty npix array, used to accumulate pixels present
%            in a bin (size of obj.dims_as_ssize)
% s       -- empty signal array used to accumulate pixels signal
%            in a bin (size of obj.dims_as_ssize)
% e       -- empty error array used to accumulate pixels variance
%            in a bin (size of obj.dims_as_ssize)
%

if force_3D
    sz = obj.nbins_all_dims(1:3);
else
    sz = obj.dims_as_ssize();
end
npix = zeros(sz);
if force_3D
    npix = squeeze(npix);
end
if n_accum == 1
    s = []; e=[];
else
    s = zeros(sz);
    e = zeros(sz);
    if force_3D
        s= squeeze(s);
        e= squeeze(e);
    end
end
end