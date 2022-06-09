function [wout, fitdata, ok, mess] = multifit_legacy(win, varargin)
%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit_gateway_main')),'_docify');
%   first_line = {'% Simultaneously fits a function to an array of IX_dataset_2d objects, with',...
%                 '% optional background functions.'}
%   main = false;
%   method = true;
%   synonymous = false;
%
%   multifit=true;
%   func_prefix='multifit_legacy';
%   func_suffix='';
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit')
%   obj_name = 'IX_dataset_2d'
%
%   doc_forefunc = fullfile(multifit_doc,'doc_func_simple_2d.m')
%   doc_backfunc = fullfile(multifit_doc,'doc_func_simple_2d.m')
%
%   custom_keywords = false;
%
% <#doc_beg:> multifit_legacy
%   <#file:> fullfile('<multifit_doc>','doc_multifit_short.m')
%
%
%   <#file:> fullfile('<multifit_doc>','doc_multifit_long.m')
%
%
%   <#file:> fullfile('<multifit_doc>','doc_multifit_examples_2d.m')
% <#doc_end:>
%-------------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% *** This function is identical for IX_dataset_1d, _2d, _3d, ...
% *** The help has specific references to the class name


% Parse the input arguments
[ok,mess,pos,func,plist,pfree,pbind,bpos,bfunc,bplist,bpfree,bpbind,narg] = ...
    multifit_gateway_parsefunc (win, varargin{:});
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

% Perform the fit
[ok,mess,wout,fitdata] = multifit_gateway_main (win, args{:});
if ~ok && nargout<3
    error(mess)
end

