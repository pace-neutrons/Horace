function obj = fun_append (obj_in, isfore, varargin)
% Append function handle(s) and parameter list(s)
%
%   >> obj = fun_append (obj_in, isfore, n)	% append n empty handles and parameter sets
%   >> obj = fun_append (obj_in, isfore, fun, pin, np)
%
% Input:
% ------
%   obj_in  Functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_,
%               background_is_local_, bfun_, bpin_, nbp_
%   isfore  True if foreground functions, false if background functions
%   n       Number of empty entries to append
%   fun     Function handles (row vector)
%   plist   Array of mfclass_plist objects (row vector)
%   np      Array of number of parameters (row vector)
%
% Output:
% -------
%   obj     Updated functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_,
%               background_is_local_, bfun_, bpin_, nbp_
%
%
% In principle this function can be replaced by a call to fun_insert, but
% the case of append is much faster if done by a simple function.
%
% NOTE: IT IS POSSIBLE TO MAKE THE STRUCTURE INCONSISTENT AS NO CHECK IS
%       PERFORMED THAT THE NUMBER OF FUNCTIONS IS CONSISTENT WITH THE
%       SCOPE (LOCAL OR GLOBAL) IN THE INPUT STRUCTURE


% Get arguments
if numel(varargin)==1
    n = varargin{1};
    fun = cell(1,n);
    pin = cell(1,n);
    np  = zeros(1,n);
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
    obj.fun_ = [obj.fun_, fun];
    obj.pin_ = [obj.pin_, pin];
    obj.np_  = [obj.np_, np];
else
    obj.bfun_ = [obj.bfun_, fun];
    obj.bpin_ = [obj.bpin_, pin];
    obj.nbp_  = [obj.nbp_, np];
end
