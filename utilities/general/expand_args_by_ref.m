function varargout = expand_args_by_ref (Aref, varargin)
% Expand the number of input arguments to vectors
%
%   >> [B1,B2,B3...] = expand_args (Aref,A1,A2,A3...)
%
% Input:
% ------
%   Aref        Input argument giving reference size
%   A1,A2,...   Input arguments: scalar or array, where arrays must all
%               have the same number of elements as Aref.
%               The elements cannot be empty, except for the special case
%               of the reference object and all other input arguments being empty.
%
% Output:
% -------
%   B1,B2,...   Output arguments: expanded to have the same number of
%               elements. Scalars are expanded to the same shape as Aref,
%               and arrays are reshaped to the same size as Aref


% If no input arguments, just finish
if numel(varargin)==0, return, end

% Get size and number of elements for each input argument
sz = cellfun(@size,varargin,'UniformOutput',false);
n = cellfun(@prod,sz);

% Get number of output arguments
nout = min(nargout,numel(varargin));

nref=numel(Aref);
if nref==0
    % Empty reference object
    if all(n==0)
        varargout = varargin(1:nout);
    else
        throwAsCaller(MException('expand_args_by_ref:invalid_arguments',...
            'Arguments must all be empty if the reference object is empty'))
    end
elseif nref==1
    % Scalar reference object
    if all(n==1)
        varargout = varargin(1:nout);
    else
        throwAsCaller(MException('expand_args_by_ref:invalid_arguments',...
            'Arguments must all be scalar if the reference object is scalar'))
    end
else
    % Non-scalar reference object
    if all(n==1 | n==nref)
        % Now fill output arguments, expanding where necessary
        sz0 = size(Aref);
        varargout = cell(1:nout);
        for i=1:nout
            if isscalar(varargin{i})
                varargout{i} = repmat(varargin{i},sz0);
            elseif isequal(sz{i},sz0)
                varargout{i} = varargin{i};
            else
                varargout{i} = reshape(varargin{i},sz0);
            end
        end
    else
        throwAsCaller(MException('expand_args_by_ref:invalid_arguments',...
            'Arguments must all be scalar or non-empty arrays with the same number of elements as reference object'))
    end
end
