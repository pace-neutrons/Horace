function varargout = func_eval (this, varargin)
% Evaluate a method of an object for indexed occurences in an object lookup
%
%   >> [X1, X2,...] = func_eval (this, iarray, ind, funchandle, p1, p2,...)
%   >> [X1, X2,...] = func_eval (this, ind, funchandle, p1, p2,...)
%
% Very similar to arrayfun
%
% Input:
% ------
%   this        object_lookup object
%
%   iarray      Scalar index of the original object array from the
%              cell array of object arrays from which the sampling_table
%              was created.
%               If there was only one object array, then this is not
%              necessary (as it assumed iarray=1)
%
%   ind         Array containing the probability distribution function
%              indicies from which a random number is to be taken.
%              min(ind(:))>=1, max(ind(:))<=number of objects in the
%              object array selected by iarray
%
%   funchandle  Handle to function to be evaluated. The function
%              must have the form
%
%               [X1, X2, X3...] = my_function (self, p1, p2,...)
%
%              where X1, X2,... are the output arguments, which can be 
%              scalars or arrays of any objects that can be concantenated
%              and reshaped.
%
%   p1, p2,..   Any arguments to be passed to the function
%
%
% Output:
% -------
%   X1, X2,...  Output arguments. If the size of X1 for a single call to
%               funchandle is sz1, then the size of X1 is [sz1,size(ind)]
%               with singleton dimensions in the size squeezed away.


% Parse the input
narg = numel(varargin);
if narg>=2 && isa(varargin{2},'function_handle')
    if numel(this.indx_)==1
        iarray = 1;
        ind = varargin{1};
        funchandle = varargin{2};
        arg = varargin(3:end);
    else
        error('Must give index to the object array from which samples are to be drawn')
    end
elseif narg>=3 && isa(varargin{3},'function_handle')
    iarray = varargin{1};
    if ~isscalar(iarray)
        error('Index to original object array, ''iarray'', must be a scalar')
    end
    ind = varargin{2};
    funchandle = varargin{3};
    arg = varargin(4:end);
else
    error('Insufficient number of input arguments')
end


obj = this.object_array_;
indx = this.indx_{iarray}(ind);

% Find unique occurences of ind
% In principle, ind could be a large array (e.g. the 10^7 pixels in a large cut
% from Horace). We only want to evaluate the function for distinct objects in the
% lookup array, as the function could be expensive to evaluate.
N = max(indx);
ix = 1:N;
ind_present = logical(accumarray(indx(:),1,[N,1]));
indxu = ix(ind_present);

% Evaluate the function for the distinct instances
nout = nargout;
[Xtmp{1:nout}] = funchandle (obj(indxu(1)), arg{:});    % get outputs from first call
sz = cellfun(@size, Xtmp, 'UniformOutput', false);

if numel(indxu)>1
    % Fill cell arrays with output from unique objects
    X = cellfun (@(x)(NaN([prod(x),numel(indx)])), sz, 'UniformOutput', false);
    for i=1:numel(indxu)
        if i>1
            [Xtmp{1:nout}] = funchandle (obj(indxu(i)), arg{:});
        end
        for j=1:nout
            X{j}(:,i) = Xtmp{j}(:);
        end
    end
    
    % Expand acccording to the repetitions in indx
    ix = zeros(1,N);
    ix(indxu) = 1:numel(indxu);
    indu_expand = ix(indx);
    X = cellfun (@(x,y)(x(:,indu_expand)), X, 'UniformOutput', false);
    
    % Reshape output
    varargout = cellfun (@(x,y)(squeeze(reshape(x,[y,size(ind)]))), X, sz, 'UniformOutput', false);
    
else
    varargout = cellfun (@(x,y)(squeeze(repmat(x,[ones(size(y)),size(ind)]))), Xtmp, sz, 'UniformOutput', false);
end
