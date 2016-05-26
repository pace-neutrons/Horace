function [ok,mess,ifun,fun,pin,pfree,pbind] = function_parse (varargin)
% Parse the input arguments for set_fun and set_bfun
%
%   >> [ok,mess,ifun,fun,pin,pfree,pbind] = function_parse (varargin)
%
% This function doesn't checkthe validity of the input, it merely extracts
% the arguments from the format of the input argumnents.
%
% Valid input to set_fun is as follows (same for set_bfun):
% Set all functions
%   >> obj = obj.set_fun (@fhandle, pin)
%   >> obj = obj.set_fun (@fhandle, pin, pfree)
%   >> obj = obj.set_fun (@fhandle, pin, pfree, pbind)
%   >> obj = obj.set_fun (@fhandle, pin, 'pfree', pfree, 'pbind', pbind)
%
% Set a particular function or set of functions
%   >> obj = obj.set_fun (ifun, @fhandle, pin,...)    % ifun can be scalar or row vector


% Parse input
% ------------
keyval_def = struct('pfree',[],'pbind',[]);
[par,keyval,present,~,ok,mess]=parse_arguments(varargin,keyval_def);
if ~ok
    ifun=[]; fun=[]; pin=[]; pfree=[]; pbind=[];
    return
end

npar = numel(par);
if npar==0
    ok=false; mess='Check the number and type of input arguments';
    ifun=[]; fun=[]; pin=[]; pfree=[]; pbind=[];
    return
end


% Find position of fitting function(s)
% Find the first occurence of a function handle or cell array of function handles
ind_func=[]; 
for i=1:2 
    [ok,mess,fun]=function_handles_valid(par{i}); 
    if ok, ind_func=i; break, end 
end 
if isempty(ind_func)
    ok=false; mess='Must provide handle(s) to fitting function(s) with a valid format';
    ifun=[]; fun=[]; pin=[]; pfree=[]; pbind=[];
    return
end 
 
% Check that required parameters are present
if ind_func==1 && npar>=2 && npar<=4
    ifun = [];      	% indicates default will have to be given
    pin = par{2};
elseif ind_func==2 && npar>=3 && npar<=5
    ifun = par{1};
    pin = par{3};
else
    ok=false; mess='Check the number and type of input arguments';
    ifun=[]; fun=[]; pin=[]; pfree=[]; pbind=[];
    return
end

% Get optional parameters
if npar>=2+ind_func
    if ~present.pfree
        pfree=par{2+ind_func};
    else
        ok=false; mess='Cannot give free parameter list(s) as both an optional parameter and keyword';
        ifun=[]; fun=[]; pin=[]; pfree=[]; pbind=[];
        return
    end
else
    pfree=keyval.pfree;
end
if npar>=3+ind_func
    if ~present.pbind
        pbind=par{3+ind_func};
    else
        ok=false; mess='Cannot give parameter binding(s) as both an optional parameter and keyword';
        ifun=[]; fun=[]; pin=[]; pfree=[]; pbind=[];
        return
    end
else
    pbind=keyval.pbind;
end
