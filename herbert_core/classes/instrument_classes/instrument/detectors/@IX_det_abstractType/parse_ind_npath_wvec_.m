function [sz, ind, npath, wvec] = parse_ind_npath_wvec_ (obj, varargin)
% Check that the detector indices and wavevectors are consistently sized arrays
%
%   >> [sz, ind, npath, wvec] = parse_ind_npath_wvec_ (obj, npath_in, wvec_in)
%
%   >> [sz, ind, npath, wvec] = parse_ind_npath_wvec_ (obj, ind_in, npath_in, wvec_in)
%
%
% Input:
% ------
%   ind_in      Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet) as a row vector.
%
%   npath_in    Unit vectors along the neutron path in the detector coordinate
%               frame for each detector. Vector length 3 or an array size [3,n]
%               where n is the number of indices (see ind below). If a vector
%               then npath is expanded to [3,n] array.
%
%   wvec_in     Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%               If both ind and wvec are arrays, then they must have the same
%               number of elements, but not necessarily the same shape.
%
%
% Output:
% -------
%   sz          Size of output arrays - used to reshape output.
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec.
%
%   npath       Array size [3,n] where n = numel(ind)
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.


% Check ind and wvec
narg = numel(varargin);
if narg==2
    [sz, ind, wvec] = parse_ind_wvec_ (obj, varargin{2});
    npath = varargin{1};
elseif narg==3
    [sz, ind, wvec] = parse_ind_wvec_ (obj, varargin{1}, varargin{3});
    npath = varargin{2};
else
    error ('parse_ind_npath_wvec_:invalid_arguments', ['Check the size and ',...
        'shape of ''npath'': must a vector length 3 or array size [3,n]'])
end

% Check the neutron path unit vectors
if numel(npath)==3
    npath = npath(:);   % make column vector
elseif ~numel(size(npath))==2 || ~size(npath,1)==3 || size(npath,2)~=numel(ind)
    error ('parse_ind_npath_wvec_:invalid_arguments', ['Check the size and ',...
        'shape of ''npath'': must a vector length 3 or array size [3,n]'])
end

nlen = sqrt(sum(npath.^2,1));
if all(nlen>0)
    npath = npath./(repmat(nlen,3,1));
else
    error ('parse_ind_npath_wvec_:invalid_arguments',...
        'One or more neutron path direction vectors has zero length')
end
