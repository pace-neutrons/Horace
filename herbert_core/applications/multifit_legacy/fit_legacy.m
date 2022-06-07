function [wout,fitdata,ok,mess] = fit_legacy(varargin)
%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit_gateway_main')),'_docify');
%   first_line = {'% Fits a function to a dataset, with an optional background function.'}
%   main = true;
%   method = false;
%   synonymous = false;
%
%   multifit=false;
%   func_prefix='fit_legacy';
%   func_suffix='';
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit')
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
%   <#file:> fullfile('<multifit_doc>','doc_fit_examples_1d.m')
% <#doc_end:>
%-------------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% Note:
% - In the following it is necessary to call multifit, not multifit_gateway, as the overloaded version of multifit
%  corresponding to an object may be needed (see e.g. IX_dataset_1d, which wraps the user function with a call to func_eval)
% - It is necessary to ensure that any overloaded version of multifit has the full return arguments
%  [wout,fitdata,ok,mess]


if numel(varargin)>1
    for i=1:numel(varargin)
        if isa(varargin{i},'function_handle')
            if i==4
                % x-y-e data is the only possibility; checking internal to multifit will test this
                [wout,fitdata,ok,mess]=multifit(varargin{:});
                if ~ok && nargout<3, error(mess), end

            elseif i==2
                % array or cellarray of datasets (structures or object)
                if iscell(varargin{1})
                    % If cellarray, the elements of the cell array must all be scalar structures or all objects of the same type
                    for id=1:numel(varargin{1})
                        if id==1
                            struct_data=isstruct(varargin{1}{id});
                            obj_data=isobject(varargin{1}{id});
                            if ~((struct_data||obj_data) && numel(varargin{1}{id})==1)
                                wout=[]; fitdata=[]; ok=false; mess='Check form of data to be fitted';
                                if nargout<3, error(mess), else return, end
                            end
                        else
                            if ~(isstruct(varargin{1}{id})==struct_data && isobject(varargin{1}{id})==obj_data && numel(varargin{1}{id})==1)
                                wout=[]; fitdata=[]; ok=false; mess='Check form of data to be fitted';
                                if nargout<3, error(mess), else return, end
                            end
                        end
                    end
                    % Now do fitting, handling simpler case of one dataset only separately
                    if numel(varargin{1})==1
                        [wout,fitdata,ok,mess]=multifit(varargin{1},varargin{2:end});
                        if ~ok && nargout<3, error(mess), end
                    else
                        wout=cell(size(varargin{1}));
                        fitdata=repmat(struct,size(wout));  % array of empty structures
                        ok=false(size(wout));
                        mess=cell(size(varargin{1}));
                        ok_fit_performed=false;
                        for id=1:numel(varargin{1})
                            [wout{id},fitdata_tmp,ok(id),mess{id}]=multifit(varargin{1}{id},varargin{2:end});
                            if ok(id)
                                if ~ok_fit_performed
                                    ok_fit_performed=true;
                                    fitdata=expand_as_empty_structure(fitdata_tmp,size(varargin{1}),id);
                                else
                                    fitdata(id)=fitdata_tmp;
                                end
                            else
                                disp(['ERROR (dataset ',num2str(id),'): ',mess{id}])
                            end
                        end
                    end
                elseif isstruct(varargin{1}) || isobject(varargin{1})
                    % Now do fitting, handling simpler case of one dataset only separately
                    if numel(varargin{1})==1
                        [wout,fitdata,ok,mess]=multifit(varargin{1},varargin{2:end});
                        if ~ok && nargout<3, error(mess), end
                    else
                        wout=varargin{1};
                        fitdata=repmat(struct,size(wout));  % array of empty structures
                        ok=false(size(wout));
                        mess=cell(size(varargin{1}));
                        ok_fit_performed=false;
                        for id=1:numel(varargin{1})
                            [wout_tmp,fitdata_tmp,ok(id),mess{id}]=multifit(varargin{1}(id),varargin{2:end});
                            if ok(id)
                                wout(id)=wout_tmp;
                                if ~ok_fit_performed
                                    ok_fit_performed=true;
                                    fitdata=expand_as_empty_structure(fitdata_tmp,size(varargin{1}),id);
                                else
                                    fitdata(id)=fitdata_tmp;
                                end
                            else
                                if nargout<3, error([mess{id}, ' (dataset ',num2str(id),')']), end
                                disp(['ERROR (dataset ',num2str(id),'): ',mess{id}])
                            end
                        end
                    end
                else
                    wout=[]; fitdata=[]; ok=false; mess='Check form of data to be fitted';
                    if nargout<3, error(mess), end
                end
            else
                wout=[]; fitdata=[]; ok=false; mess='Check input arguments - unexpected fit function location in argument list';
                if nargout<3, error(mess), end
            end
            return
        end
    end
    wout=[]; fitdata=[]; ok=false; mess='Check input arguments - no fit function found';
    if nargout<3, error(mess), end
else
    wout=[]; fitdata=[]; ok=false; mess='Check number of input arguments';
    if nargout<3, error(mess), end
end

%----------------------------------------------------------------------------------------------------------------------
function sout=expand_as_empty_structure(sin,sz,id)
% Expand a scalar structure as an empty structure, except retaining element id as the input
if isstruct(sin) && isscalar(sin)
    nams=fieldnames(sin);
    args=[nams';repmat({[]},1,numel(nams))];
    sout=repmat(struct(args{:}),sz);
    sout(id)=sin;
else
    error('Input not a scalar structure')
end

