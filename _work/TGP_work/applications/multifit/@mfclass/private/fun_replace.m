function obj = fun_replace (obj_in, isfore, ind, varargin)
% Replace function(s) and parameter list(s)
%
%   >> obj = fun_replace (obj_in, isfore, 'all')
%   >> obj = fun_replace (obj_in, isfore, ind)
%   >> obj = fun_replace (obj_in, isfore, ind, fun, pin, np)
%
% Input:
% ------
%   obj_in  Functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_,
%               background_is_local_, bfun_, bpin_, nbp_
%   isfore  True if foreground functions, false if background functions
%   ind     Indicies of the functions to be replaced (row vector)
%           One index per functions, in the range
%               foreground functions:   1:(numel(obj.fun_)
%               background functions:   1:(numel(obj.bfun_)
%   fun     Function handles (row vector)
%   plist   Cell array with parameter lists (row vector)
%   np      Array of number of parameters (row vector)
%
% Output:
% -------
%   obj     Updated functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_,
%               background_is_local_, bfun_, bpin_, nbp_


% Get arguments
if nargin==3
    if isnumeric(ind)
        n = numel(ind);
    elseif ischar(ind) && strcmp(ind,'all')
        if isfore
            n = numel(obj_in.fun_);
        else
            n = numel(obj_in.bfun_);
        end
        ind = 1:n;
    else
        error('Contact developers')
    end
    fun = repmat({[]},1,n);
    pin = repmat({[]},1,n);
    np = zeros(1,n);
else
    n = numel(varargin{1});
    fun = varargin{1};
    pin = varargin{2};
    np = varargin{3};
end

% Fill output with default structure
obj = obj_in;
if n==0
    return
end

% Update properties
if isfore
    obj.fun_(ind) = fun;
    obj.pin_(ind) = pin;
    obj.np_(ind)  = np;
else
    obj.bfun_(ind) = fun;
    obj.bpin_(ind) = pin;
    obj.nbp_(ind)  = np;
end
