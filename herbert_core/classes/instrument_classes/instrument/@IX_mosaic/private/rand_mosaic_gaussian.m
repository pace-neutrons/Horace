function X = rand_mosaic_gaussian (sz, eta)
% Return random rotation vectors for a Gaussian mosaic spread
%
%   >> V = rand_mosaic_gaussian (object, sz, eta)
%
% Input:
% ------
%   object  IX_mosaic object
%   sz      Size of array of random points. A three vector will be returned
%           for each point
%   eta     Mosaic spread
%           - scalar     FWHH (degrees) 
%           - vector     FWHH (degrees) about each of three orthonormal axes
%           - 3x3 matrix FWHH-squared matrix (degrees) in orthonormal frame
%                        i.e. covariance matrix scaled to give FWHH rather 
%                        then standard deviations
%
% Output:
% -------
%   X       Vector of random rotations with size [3,sz]. If sz has a leading
%           singleton e.g. sz=[1,1000], then that singleton will be absorbed
%           e.g sz = [1,1000]   size(V) = [3,1000]
%               sz = [5,1000]   size(V) = [3,5,1000]
%               sz = [1,1,10]   size(V) = [3,1,10]


[ok,mess,~,eta_diag,V] = check_mosaic_matrix(eta);
if ~ok, error(mess), end

if isscalar(sz)
    sz = [sz,sz];
end

fwhh_to_sig = sqrt(log(256));
if numel(eta)==1
    X = (eta/fwhh_to_sig)*randn(3,prod(sz));
elseif numel(eta)==3
    X = repmat((eta(:)/fwhh_to_sig),1,prod(sz)).*randn(3,prod(sz));
elseif numel(eta)==9
    rotvec = repmat((eta_diag(:)/fwhh_to_sig),1,prod(sz)).*randn(3,prod(sz));
    X = V * rotvec;
end

if sz(1)==1
    sz_out = [3,sz(2:end)];
else
    sz_out = [3,sz];
end
X = reshape (X,sz_out);
