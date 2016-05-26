function obj = fun_insert (obj_in, isfore, ind, varargin)
% Insert function handle(s) and parameter list(s)
%
%   >> obj = fun_insert (obj_in, isfore, ind)     % insert empty handles and parameter sets
%   >> obj = fun_insert (obj_in, isfore, ind, fun, pin, np)
%
% Input:
% ------
%   obj_in  Functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_,
%               background_is_local_, bfun_, bpin_, nbp_
%   isfore  True if foreground functions, false if background functions
%   ind     Indicies after which the functions are to be inserted (row vector)
%           One index per function, in the range
%               foreground functions:   0:(numel(obj.fun_)
%               background functions:   0:(numel(obj.bfun_)
%   fun     Function handles (row vector)
%   plist   Cell array with parameter lists (row vector)
%   np      Array of number of parameters (row vector)
%
% Output:
% -------
%   obj     Updated functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_,
%               background_is_local_, bfun_, bpin_, nbp_
%
% NOTE: IT IS POSSIBLE TO MAKE THE STRUCTURE INCONSISTENT AS NO CHECK IS
%       PERFORMED THAT THE NUMBER OF FUNCTIONS IS CONSISTENT WITH THE
%       SCOPE (LOCAL OR GLOBAL) IN THE INPUT STRUCTURE


% Get arguments
if nargin==3
    n = numel(ind);
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
    [obj.fun_, obj.pin_, obj.np_] = insert (obj.fun_, obj.pin_, obj.np_,...
        ind, fun, pin, np);
else
    [obj.bfun_, obj.bpin_, obj.nbp_] = insert (obj.bfun_, obj.bpin_, obj.nbp_,...
        ind, fun, pin, np);
end


%------------------------------------------------------------------------------
function [fun_out, pin_out, np_out] = insert (fun_, pin_, np_, ind, fun, pin, np)
% Insert elements into arrays
[~,ix] = sort([1:numel(np_), ind]);

fun_out = [fun_,fun];
pin_out = [pin_, pin];
np_out  = [np_, np];

fun_out = fun_out(ix);
pin_out = pin_out(ix);
np_out  = np_out(ix);
