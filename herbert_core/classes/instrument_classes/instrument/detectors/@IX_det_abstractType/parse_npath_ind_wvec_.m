function [sz, npath, ind, wvec] = parse_npath_ind_wvec_ (obj, npath_in, varargin)
% Check that the detector indices and wavevectors are consistently sized arrays
%
%   >> [sz, ind, wvec] = parse_npath_ind_wvec_ (obj, npath, wvec_in)
%
%   >> [sz, ind, wvec] = parse_npath_ind_wvec_ (obj, npath, ind_in, wvec_in)
%
%
% Input:
% ------
%   npath_in    Unit vectors along the neutron path in the detector coordinate
%               frame for each detector. Vector length 3 or an array size [3,n]
%               where n is the number of indices (see ind below). If a vector
%               then npath is expanded to [3,n] array
%
%   ind_in      Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet)
%
%   wvec_in     Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%               This serves only to determine the size of the output arrays
%               from calling functions in the case when ind is a scalar
%
% If both ind and wvec are arrays, then they must have the same number of elements
%
%
% Output:
% -------
%   sz          Size of output arrays - used to reshape output.
%               If one of ind or wvec is scalar, then it will
%              be the size of that array; if both are arrays, then
%              it will be the size of wvec
%
%   npath       Array size [3,n] where n = numel(ind)
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.


% Check ind and wvec
try
    [sz, ind, wvec] = parse_ind_wvec_ (obj, varargin{:});
catch ME
    ME.throwAsCaller
end

% Check the neutron path unit vectors
if numel(npath_in)==3
    npath = npath_in(:);
elseif numel(size(npath_in))==2 && size(npath_in,1)==3 && size(npath_in,2)==numel(ind)
    npath = npath_in;
else
    throwAsCaller(MException('parse_npath_ind_wvec_:invalid_arguments',...
        'Check the size and shape of ''npath'': must a vector length 3 or array size [3,n]'))
end

nlen = sqrt(sum(npath.^2,1));
if all(nlen>0)
    npath = npath./(repmat(nlen,3,1));
else
    throwAsCaller(MException('parse_npath_ind_wvec_:invalid_arguments',...
        'One or more neutron path direction vectors has zero length'))
end
