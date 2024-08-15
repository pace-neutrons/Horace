function obj_out = product (objB, objA)
% Create the IX_map that gives the mapping of workspaces created by an second map
%
%   >> obj_out = product (objB, objA)
%
% Creates the map that is the result of applying the left-hand map, objB, to the
% right-hand map, objA, or equivalently it is the map produced by identifying
% the workspaces of objA as the spectra of objB, resulting in the output being
% the mapping of the spectra of objA to the workspaces of objB.
%
% THe mapping can be considered as a mathematical operation that produces
% workspaces as an operation to map spectra to those workspaces:
%           w = M s     (w == workspaces, M == mapping operation, s == spectra)
%
%   so that if:
%           w = objA s
%      and  w'= objB s'
%
%   then the chain of operations:
%       w'= objB objA s
%
%   is accomplished by the output of:
%       product(objB, objA)
%
%
% EXAMPLE
%  Suppose map1 consists of
%
% Input:
% ------
%   objB, objA      IX_map objects to be applied in series
%
% Output:
% -------
%   obj_out         Single IX_map object that is equivalent to the workspaces of
%                   objA being treated as the spectra of objB, resulting in the
%                   mapping of the spectra of objA to the workspaces of objB


% Check both input arguments are scalar IX_map arrays
% The first is an IX_map or this method would not have been called
if ~isa(objA,'IX_map') || ~isscalar(objA) || ~isscalar(objB)
    error ('HERBERT:IX_map:invalid_argument',...
        'Both input arguments to IX_map/product must have class ''IX_map''')
end

% Check that all spectra in objB appear as workspaces in objA
[ok, loc_in_objA_wkno] = ismember(objB.s, objA.wkno);
if ~all(ok)
    wkno_bad = objB.s(find(~ok,1));
    error ('HERBERT:IX_map:invalid_argument', ['The left-hand map refers to at ',...
        'least one workspace (%d)\nthat does not exist in the right-hand map'], wkno_bad)
end

% Get the number of spectra in each of the workspaces identified by ObjB.s
ns = objA.ns;
ns_objB_s = ns(loc_in_objA_wkno);  % number of spectra in each of the identitified workspaces

% Get the indices of the spectra in objA.s corresponding to these workspaces
nscum = cumsum(ns);
noffset = nscum(loc_in_objA_wkno) - ns_objB_s;
is = ( replicate_iarray(noffset, ns_objB_s) + sawtooth_iarray(ns_objB_s) )'; % make is a row
s_out = objA.s(is);

% Get the number of spectra in each of the workspaces for the output object
ns_out = sum_partial(ns_objB_s, objB.ns);

% Create output IX_map
obj_out = IX_map (s_out, 'wkno', objB.wkno, 'ns', ns_out);


%-------------------------------------------------------------------------------
function S = sum_partial (iarr, n)
% Output partial sums of an integer array
%
%   >> S = sum_partial (iarr, n)
%
% Input:
% ------
%   iarr    Array of integers
%   n       Array of number of elements, all(n>=0)
%
% Output:
% -------
%   S       Array of partial sums, where
%               S(1) = sum(iarr(1:n(1)))
%               S(2) = sum(iarr(n(1)+1:n(2)))
%                    :

iend = cumsum(n(:));
ibeg = iend - n(:) + 1;
M = cumsum(iarr(:));
ok = (n(:)>0);
S = zeros(numel(n),1);
% [Use trick with reshape to ensure third term is always a vector]
S(ok) = M(iend(ok)) - M(ibeg(ok)) + reshape(iarr(ibeg(ok)), [], 1);
S = reshape(S, size(n));
