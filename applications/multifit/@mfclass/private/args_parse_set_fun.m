function [ok,mess,ifun,fun,present,pin,free,bind] = args_parse_set_fun (varargin)
% Parse the input arguments for set_fun and set_bfun
%
% Set all functions
%   >> [ok,mess,ifun,fun,present,pin,free,bind] = args_parse_set_fun (fun)
%   >> [ok,mess,ifun,fun,present,pin,free,bind] = args_parse_set_fun (fun, pin)
%   >> [ok,mess,ifun,fun,present,pin,free,bind] = args_parse_set_fun (fun, pin, free)
%   >> [ok,mess,ifun,fun,present,pin,free,bind] = args_parse_set_fun (fun, pin, free, bind)
%   >> [ok,mess,ifun,fun,present,pin,free,bind] = args_parse_set_fun...
%                                            (fun, pin, 'free', free, 'bind', bind)
%
% Set a particular function or set of functions
%   >> [ok,mess,ifun,fun,present,pin,free,bind] = args_parse_set_fun (ifun, fun, pin,...)
%
% This function doesn't check the validity of the input, it merely extracts
% the arguments from the format of the input arguments.
%
% Input:
% ------
%   <argument list as above>
%
% Output:
% -------
%   ok      All ok: =true; otherwise =false
%   mess    Error message if not ok; otherwise ''
%   ifun    Function index list. If not given then set to 'all'
%   fun     Argument to be parsed as a function handle array (must be present;
%           =[] on error)
%   present Structure with fields: pin, free, bind. Where true the corresponding
%           argument was given; otherwise false
%   pin     Argument to be parsed as a parameter list (=[] if not given or error)
%   free    Argument to be parsed as a fixed/free list (=[] if not given or error)
%   bind    Argument to be parsed as a bindings list (=[] if not given or error)


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


% Parse input
% ------------
keyval_def = struct('free',[],'bind',[]);
[par,keyval,opt,~,ok,mess]=parse_arguments(varargin,keyval_def);
if ~ok
    [ifun,fun,present,pin,free,bind] = error_return;
    return
end

npar = numel(par);
if npar==0
    ok=false; mess='Check the number and type of input arguments';
    [ifun,fun,present,pin,free,bind] = error_return;
    return
end


% Find position of fitting function(s) - must be first or second parameter
if npar==1
    % Argument must be function handles, as it is the only input parameter
    % However, it is possible that 'all' was given, which should result in
    % an error.
    if (isnumeric(par{1}) && ~isempty(par{1})) ||...
            (is_string(par{1}) && ~isempty(par{1}) && strncmpi('all',par{1},numel(par{1})))
        ind_func = NaN;
    else
        ind_func = 1;
    end
else
    % One of the first two arguments must be a valid function handle array
    % There is potential ambiguity depending on the type and number of
    % arguments (including keyword arguments). But don't be too clever:
    % we just assume that if the first parmaeter list is a non-empty
    % numeric (or the character string 'all') it is meant to be an index
    % vector, otherwise it is meant to be a valid function handle array.
    if (isnumeric(par{1}) && ~isempty(par{1})) ||...
            (is_string(par{1}) && ~isempty(par{1}) && strncmpi('all',par{1},numel(par{1})))
        ind_func = 2;
    else
        ind_func = 1;
    end
end

% Check that required parameters are present
if ind_func==1 && npar<=4
    ifun = 'all';
    fun = par{1};
elseif ind_func==2 && npar<=5
    ifun = par{1};
    fun = par{2};
else
    ok=false; mess='Check the number and type of input arguments';
    [ifun,fun,present,pin,free,bind] = error_return;
    return
end

% Get optional parameters
present = struct('pin',false,'free',false,'bind',false);

if npar>=1+ind_func
    pin = par{1+ind_func};
    present.pin = true;
else
    pin = [];
    present.pin = false;
end

if npar>=2+ind_func
    % free given as one of the leading arguments - so pin must have been present
    if ~opt.free
        free=par{2+ind_func};
        present.free = true;
    else
        ok=false; mess='Cannot give free parameter list(s) as both an optional parameter and keyword';
        [ifun,fun,present,pin,free,bind] = error_return;
        return
    end
else
    % if free was given as keyword a argument, check that pin was given
    if present.pin || ~opt.free
        free=keyval.free;
        present.free = opt.free;
    else
        ok=false; mess='Cannot give free parameter list(s) without given initial parameters';
        [ifun,fun,present,pin,free,bind] = error_return;
        return
    end
end

if npar>=3+ind_func
    % bind given as one of the leading arguments - so pin must have been present
    if ~opt.bind
        bind=par{3+ind_func};
        present.bind = true;
    else
        ok=false; mess='Cannot give parameter binding(s) as both an optional parameter and keyword';
        [ifun,fun,present,pin,free,bind] = error_return;
        return
    end
else
    % if bind was given as keyword a argument, check that pin was given
    if present.pin || ~opt.bind
        bind=keyval.bind;
        present.bind = opt.bind;
    else
        ok=false; mess='Cannot give parameter binding(s) without given initial parameters';
        [ifun,fun,present,pin,free,bind] = error_return;
        return
    end
end

%-----------------------------------------------------------------------------------
function [ifun,fun,present,pin,free,bind] = error_return
ifun=[]; fun=[]; pin=[]; free=[]; bind=[];
present = struct('pin',false,'free',false,'bind',false);
