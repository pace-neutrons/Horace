function obj = set_wrapped_functions_ (obj, varargin)
% Wrap the foreground and background functions to nest one deeper
%
% Initialise defaults:
%       >> obj = set_wrapped_functions_ (obj)
%       >> obj = set_wrapped_functions_ (obj, 'fore')
%       >> obj = set_wrapped_functions_ (obj, 'back')
%
% Set:
%       >> obj = set_wrapped_functions_ (obj, fun_wrap, p_wrap, 'fore')
%       >> obj = set_wrapped_functions_ (obj, fun_wrap, p_wrap, 'back')
%       >> obj = set_wrapped_functions_ (obj, fun_wrap, p_wrap, bfun_wrap, bp_wrap)
%
% Should be defined as a protected method so can ionly be used within
% class or child methods


fun_def = [];
p_def   = {};

narg = numel(varargin);
if narg==0
    obj.fun_wrap_  = fun_def;
    obj.p_wrap_    = p_def;
    obj.bfun_wrap_ = fun_def;
    obj.bp_wrap_   = p_def;
    
elseif narg==1 && ischar(varargin{1})
    if strncmpi(varargin{1},'foreground')
        obj.fun_wrap_  = fun_def;
        obj.p_wrap_    = p_def;
    elseif strncmpi(varargin{1},'background')
        obj.bfun_wrap_ = fun_def;
        obj.bp_wrap_   = p_def;
    else
        error('Unrecognised option (must be ''fore'' or ''back'')')
    end
    
elseif narg==3 && ischar(varargin{3})
    if strncmpi(varargin{1},'foreground')
        [ok, mess, fun, p] = check_args (varargin{1}, varargin{2}, fun_def, p_def);
        if ok
            obj.fun_wrap_  = fun;
            obj.p_wrap_    = p;
        else
            error(['Foreground wrapper: ',mess])
        end
    elseif strncmpi(varargin{1},'background')
        [ok, mess, fun, p] = check_args (varargin{1}, varargin{2}, fun_def, p_def);
        if ok
            obj.bfun_wrap_  = fun;
            obj.bp_wrap_    = p;
        else
            error(['background wrapper: ',mess])
        end
    else
        error('Unrecognised option (must be ''fore'' or ''back'')')
    end
    
elseif narg==4
    [ok, mess, fun, p] = check_args (varargin{1}, varargin{2}, fun_def, p_def);
    if ok
        obj.fun_wrap_  = fun;
        obj.p_wrap_    = p;
    else
        error(['Foreground wrapper: ',mess])
    end
    [ok, mess, fun, p] = check_args (varargin{3}, varargin{4}, fun_def, p_def);
    if ok
        obj.bfun_wrap_  = fun;
        obj.bp_wrap_    = p;
    else
        error(['background wrapper: ',mess])
    end
    
else
    error('Check number of arguments')
end


%--------------------------------------------------------------------------------------------------
function [ok, mess, fun, p] = check_args (fun_wrap, p_wrap, fun_def, p_def)
% Check that functions and parameters have been set properly

fun = fun_def;
p = p_def;

ok = false;
if ~isempty(fun_wrap)
    if isa(fun_wrap,'function_handle')
        if iscell(p_wrap) && (isempty(p_wrap) || (numel(size(p_wrap))==2 && size(p_wrap,1)==1))
            p = p_wrap;
        else
            mess = 'Wrapping parameters must be row cell array';
            return
        end
        fun = fun_wrap;
    else
        mess = 'Wrapper function must be a function handle';
        return
    end
else
    if ~isempty(p_wrap)
        mess = 'The wrapper parameter list must be empty if no wrapper function is given';
        return
    end
end

ok = true;
mess = '';
