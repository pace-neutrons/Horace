function [wout, fitdata, ok, mess] = fit_legacy(win, varargin)
%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit_gateway_main')),'_docify');
%   first_line = {'% Fits a function to an IX_dataset_3d object, with an optional background function.'}
%   main = false;
%   method = true;
%   synonymous = false;
%
%   multifit=false;
%   func_prefix='fit_legacy';
%   func_suffix='';
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit')
%   obj_name = 'IX_dataset_3d'
%
%   doc_forefunc = fullfile(multifit_doc,'doc_func_simple_3d.m')
%   doc_backfunc = fullfile(multifit_doc,'doc_func_simple_3d.m')
%
%   custom_keywords = false;
%
% <#doc_beg:> multifit_legacy
%   <#file:> fullfile('<multifit_doc>','doc_fit_short.m')
%
%
%   <#file:> fullfile('<multifit_doc>','doc_fit_long.m')
%
%
% EXAMPLES:
% =========
%
% The examples for IX_dataset_1d and IX_dataset_2d objects illustrate the use
% of fit, although the dimensionality of the examples is different.
% Type  >> help IX_dataset_1d/fit  or  >> help IX_dataset_2d/fit
% and look at the examples.
% <#doc_end:>
%-------------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% *** This function is identical for IX_dataset_1d, _2d, _3d, ...
% *** The help has specific references to the class name


% Note: we could rely on the generic fit function in Herbert, but this would
% re-check the parsing for every element of the array of objects to be fitted.
% Furthermore, we cannot customise the help documentation.


% Catch case of a single dataset input
% ------------------------------------
if numel(win)==1
    [wout,fitdata,ok,mess]=multifit(win,varargin{:});
    if ~ok && nargout<3, error(mess), end
    return
end

% Case of more than one dataset input
% -----------------------------------
% Parse the input arguments, and repackage for fit func
[ok,mess,pos,func,plist,pfree,pbind,bpos,bfunc,bplist,bpfree,bpbind,narg] = ...
    multifit_gateway_parsefunc (win(1), varargin{:});
if ~ok
    wout=[]; fitdata=[];
    if nargout<3, error(mess), else return, end
end
ndata=1;     % There is just one argument before the varargin
pos=pos-ndata;
bpos=bpos-ndata;

% Wrap the foreground and background functions
args=multifit_gateway_wrap_functions (varargin,pos,func,plist,bpos,bfunc,bplist,...
                                                    @func_eval,{},@func_eval,{});

% Evaluate function for each element of the array of objects
wout=win;
fitdata=repmat(struct,size(wout));  % array of empty structures
ok=false(size(wout));
mess=cell(size(wout));

ok_fit_performed=false;
for i = 1:numel(win)    % use numel so no assumptions made about shape of input array
    [ok(i),mess{i},wout_tmp,fitdata_tmp] = multifit_gateway_main (win(i), args{:});
    if ok(i)
        wout(i)=wout_tmp;
        if ~ok_fit_performed
            ok_fit_performed=true;
            fitdata=expand_as_empty_structure(fitdata_tmp,size(wout),i);
        else
            fitdata(i)=fitdata_tmp;
        end
    else
        if nargout<3, error([mess{i}, ' (dataset ',num2str(i),')']), end
        disp(['ERROR (dataset ',num2str(i),'): ',mess{i}])
    end
end

