function varargout = expand_args (varargin)
% Expand the number of input arguments to vectors
%
%   >> [B1,B2,B3...] = expand_args (A1,A2,A3...)
%
% Input:
% ------
%   A1,A2,...   Input arguments: scalar or array, where arrays must all
%               have the same number of elements.
%               The elements cannot be empty, except for the special case
%               of all input arguments being empty.
%
% Output:
% -------
%   B1,B2,...   Output arguments: expanded to have the same number of 
%               elements. If the array inputs all have the same size, then
%               scalars are expanded to that same size; if not, then
%               scalars are expanded to column vectors.


% If no input arguments, just finish
if nargin==0, return, end

% Get size and number of elements for each input argument
sz = cellfun(@size,varargin,'UniformOutput',false);
n = cellfun(@prod,sz);
nmax=max(n);
if ~all(n==1 | n==nmax)
    throwAsCaller(MException('expand_args:invalid_arguments',...
        'Arguments must all be scalar or non-empty arrays with the same number of elements'))
end

% Get number of output arguments
nout = min(nargout,numel(varargin));

% If all scalar or arrays with same number of elements, do nothing to input arguments
if all(n==1) || all(n==nmax)
    varargout = varargin(1:nout);
    return
end
  
% At least one scalar and one array; get size to which to scale scalars
szarr = sz(n==nmax);
sz0 = szarr{1};
for i=2:numel(szarr)
    if ~isequal(szarr{i},sz0)
        sz0 = [nmax,1];     % no common array size, so make expansion to a column
        break
    end
end

% Now fill output arguments, expanding where necessary
varargout = cell(1:nout);
for i=1:nout
    if isscalar(varargin{i})
        varargout{i} = repmat(varargin{i},sz0);
    else
        varargout{i} = varargin{i};
    end
end
