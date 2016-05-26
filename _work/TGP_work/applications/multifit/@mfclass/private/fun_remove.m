function obj = fun_remove (obj_in, isfore, ind)
% Remove function handle(s) and parameter list(s)
%
%   >> obj = fun_remove (obj_in, isfore, ind)
%
% Input:
% ------
%   obj_in  Functions structure: fields are
%               foreground_is_local_, fun_, pin_, np_,
%               background_is_local_, bfun_, bpin_, nbp_
%   isfore  True if foreground functions, false if background functions
%   ind     Indicies of the functions to be removed (row vector)
%           One index per functions, in the range
%               foreground functions:   1:(numel(obj.fun_)
%               background functions:   1:(numel(obj.bfun_)
%           If empty, then nothing is done
%           For all functions of the type set by isfore, , set ind to 'all'
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


% Fill output with default structure
obj = obj_in;
if numel(ind)==0
    return
end

% Update properties
if ischar(ind) && strcmp(ind,'all')
    if isfore
        nfun = numel(obj.fun_);
        obj.fun_ = cell(1,nfun);
        obj.pin_ = cell(1,nfun);
        obj.np_  = zeros(1,nfun);
    else
        nfun = numel(obj.bfun_);
        obj.bfun_ = cell(1,nfun);
        obj.bpin_ = cell(1,nfun);
        obj.nbp_  = zeros(1,nfun);
    end
else
    if isfore
        ok=true(1,numel(obj.fun_));
        ok(ind)=false;
        obj.fun_ = obj.fun_(ok);
        obj.pin_ = obj.pin_(ok);
        obj.np_  = obj.np_(ok);
    else
        ok=true(1,numel(obj.bfun_));
        ok(ind)=false;
        obj.bfun_ = obj.bfun_(ok);
        obj.bpin_ = obj.bpin_(ok);
        obj.nbp_  = obj.nbp_(ok);
    end
end
