function args_out=multifit_gateway_wrap_functions (args,pos,func,plist,bpos,bfunc,bplist,...
                                                    fwrap,fwrap_par,bfwrap,bfwrap_par)
% Wrap the functions for multifit with another function and arguments
%
%   >> args_out = multifit_gateway_wrap_functions (args,pos,func,plist,bpos,bfunc,bplist,...
%                                                 fwrap,fwrap_par,bfwrap,bfwrap_par)
%
% Takes the output from a call to multfit_gateway_parsefunc to check the input arguments
%   >> [ok,mess,pos,func,plist,pfree,pbind,bpos,bfunc,bplist,bpfree,bpbind,narg] =...
%                   multifit_gateway_parsefunc (win, arg1, arg2,...'parsefunc_')
%
% or, if x-y-e arguments are separately given
%   >> [ok,mess,pos,func,plist,pfree,pbind,bpos,bfunc,bplist,bpfree,bpbind,narg] =...
%                   multifit_gateway_parsefunc (x, y, e, arg1, arg2,...'parsefunc_')
%
% Input:
% ------
%   args        Cell array of input arguments as passed to the caller function
%              e.g.  function [wout,fitpar]=my_multifit(w,varargin)
%               then there would be a call
%                           :
%                    args_out=multifit_gateway_wrap_functions (varargin,...)
%                           :
%   pos         Position of foreground function handle(s) in input argument list
%   func        Cell array of foreground function handle(s)
%   plist       Cell array of foreground parameter lists, one per foreground function
%   bpos        Position of background function handle(s) in input argument list
%   bfunc       Cell array of background function handle(s)
%   bplist      Cell array of background parameter lists, one per background function
%   fwrap       Handle to wrapper function for foreground functions
%   fwrap_par   Cell array of parameters for foreground wrapper function
%               Can be omitted or set to an empty argument if none
%   bfwrap      Handle to wrapper function for background functions
%               Can be omitted if none
%   bfwrap_par  Cell array of parameters for background wrapper function
%
% Output:
% -------
%   args_out    Cell array of arguments to be passed to multifit_gateway_main.
%              Continuing the example lines above:
%                           :
%                    [ok,mess,wout,fitdata] = multifit_gateway_main (win, args_out{:});


% Create new foreground parameter list(s)
if ~exist('fwrap_par','var')||isempty(fwrap_par)
    fwrap_par={};
end
if numel(func)==1
    plist_new=[{func{1},plist{1}},fwrap_par];
else
    plist_new=cell(size(plist));
    for i=1:numel(func)
        plist_new{i}=[{func{i},plist{i}},fwrap_par];
    end
end

% Create new background parameter list(s)
if ~isempty(bpos)
    if ~exist('bfwrap_par','var')||isempty(bfwrap_par)
        bfwrap_par={};
    end
    if numel(bfunc)==1
        bplist_new=[{bfunc{1},bplist{1}},bfwrap_par];
    else
        bplist_new=cell(size(bplist));
        for i=1:numel(bfunc)
            bplist_new{i}=[{bfunc{i},bplist{i}},bfwrap_par];
        end
    end
end

% Create new argument list
args_out=args;
args_out{pos}=fwrap;
args_out{pos+1}=plist_new;
if ~isempty(bpos)
    args_out{bpos}=bfwrap;
    args_out{bpos+1}=bplist_new;
end
