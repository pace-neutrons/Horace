function [ok,mess,parsing,output] = multifit_main(varargin) 
%-------------------------------------------------------------------------- 
% Some stuff that should not survive
%-------------------------------------------------------------------------- 




 
% <#doc_def:> 
%   first_line = {'% Simultaneously fits a function to several datasets, with optional',... 
%                 '% background functions.'} 
%   main = true; 
%   method = false; 
%   synonymous = false; 
% 
%   multifit=true; 
%   func_prefix='multifit'; 
%   func_suffix=''; 
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit') 
% 
%   custom_keywords = false; 
% 
% <#doc_beg:> 
%-------------------------------------------------------------------------- 
% The documentation for multifit is reproduced below, but this gateway 
% function differs as follows: 
% 
% - The output arguments are different, although the input arguments are 
%   the same; 
% - There are additional keyword arguments which, although visible from the 
%   public multifits, are not advertised because they are meant only for 
%   developers. 
% 
% In full: 
% 
%   >> [ok,mess,parsing,output] = multifit_main(x,y,e,...) 
%   >> [ok,mess,parsing,output] = multifit_main(w,...) 
% 
% 
% Input: 
% ====== 
% Input arguments are exactly the same as for the public multifit 
% application. 
% 
% 
% Optional keywords: 
% ------------------ 
% Keywords that are logical flags are indicated by * 
% 
% * 'parsefunc_'  If present, parse the fit functions, parameter values 
%                 fixed/free and binding, but do not actually fit. This has 
%                 a use, for example, when repackaging the input for a 
%                 custom call to multifit. 
%                 Default: true 
% 
%   'init_func'   Function handle: if not empty then apply a pre-processing 
%                function to the data before least squares fitting. 
%                 The purpose of this function is to allow pre-computation 
%                of quantities that speed up the evaluation of the fitting 
%                function. It must have the form: 
% 
%                   [ok,mess,c1,c2,...] = my_init_func(w)   % create c1,c2,... 
%                   [ok,mess,c1,c2,...] = my_init_func()    % recover stored 
%                                                           % c1,c2,... 
% 
%                where 
%                   w       Cell array, where each element is either 
%                           - an x-y-e triple with w(i).x a cell array of 
%                             arrays, one for each x-coordinate 
%                           - a scalar object 
% 
%                   ok      True if the pre-processed output c1, c2... was 
%                          computed correctly; false otherwise 
% 
%                   mess    Error message if ok==false; empty string 
%                          otherwise 
% 
%                   c1,c2,..Output e.g. lookup tables that can be 
%                          pre-computed from the data w 
% 
% 
% Output: 
% ======= 
%   ok      True: A fit coould be performed. This includes the cases of 
%             both convergence and failure to converge 
%           False: Fundamental problem with the input arguments e.g. 
%             the number of free parameters equals or exceeds the number 
%             of data points 
% 
%   mess    Error message if ok==false; Empty string if ok==true. 
% 
%   parsing True if just checking parsing i.e. the keyword 'parsefunc_' was 
%           set to true; false if fitting or evaluating 
% 
%   output  Cell array of output; one of the two instances below if ok; 
%           empty cell array (1x0) if not ok. 
% 
% 
%  If 'parsefunc_' is false: 
%  ------------------------- 
% Contains two elements giving results of a fit or simulation: 
%	output = {wout, fitdata} 
% 
% See the corresponding output arguments in the multifit documentation below 
% for the form of wout and fitdata 
% 
% 
%  If 'parsefunc_' is true: 
%  ------------------------ 
% Contains details of parsing of input data and functions: 
%   output = {pos, func, plist, pfree, pbind,... 
%                       bpos, bfunc, bplist, bpfree, bpbind, narg}; 
% where: 
% 
%   ok          True if all ok, false if there is a syntax problem. 
%   mess        Character string containing error message if ~ok; '' if ok 
%   pos         Position of foreground function handle argument in input 
%              argument list 
%   func        Cell array of function handle(s) to foreground function(s) 
%   plist       Cell array of parameter lists, one per foreground function 
%   pfree       Cell array of logical row vectors, one per foreground function, 
%              describing which parameters are free or not 
%   pbind       Structure defining the foreground function binding, each field 
%              a cell array with the same size as the corresponding functions 
%              array: 
%           ipbound     Cell array of column vectors of indicies of bound 
%                      parameters, one vector per function 
%           ipboundto   Cell array of column vectors of the parameters to 
%                      which those parameters are bound, one vector per 
%                      function 
%           ifuncboundto  Cell array of column vectors of single indicies 
%                      of the functions corresponding to the free parameters, 
%                      one vector per function. The index is ifuncfree(i)<0 
%                      for foreground functions, and >0 for background functions. 
%           pratio      Cell array of column vectors of the ratios 
%                      (bound_parameter/free_parameter),if the ratio was 
%                      explicitly given. Will contain NaN if not (the ratio 
%                      will be determined from the initial parameter values). 
%                      One vector per function. 
%   bpos        Position of background function handle argument in input 
%              argument list 
%   bfunc       Cell array of function handle(s) to background function(s) 
%   bplist      Cell array of parameter lists, one per background function 
%   bpfree      Cell array of logical row vectors, one per background function, 
%              describing which parameters are free or not 
%   bpbind      Structure defining the background function binding, with the 
%              same format as the foreground binding structure above. 
%   narg        Total number of arguments excluding keyword-value options 
% 
%-------------------------------------------------------------------------- 
% 
%   <#file:> meta_docs:::doc_multifit_short.m 
% 
% 
%   <#file:> meta_docs:::doc_multifit_long.m 
% 
% 
%   <#file:> meta_docs:::doc_multifit_examples_1d.m 
% <#doc_end:> 
 
 
% Original author: T.G.Perring 
% 
 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Clean up any persistent or global storage in case multifit was left in a strange state due to error or cntl-c 
% ---------------------------------------------------------------------------------------------------------------- 
multifit_cleanup    % initialise multifit 
if matlab_version_num>=7.06     % R2008a or more recent: robust cleanup even if cntl-c 
    cleanupObj=onCleanup(@multifit_cleanup); 
end 
 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Parse arguments and keywords 
% ---------------------------------------------------------------------------------------------------------------- 
% Set defaults: 
arglist = struct('fitcontrolparameters',[0.0001 30 0.0001],'list',0,... 
                 'keep',[],'remove',[],'mask',[],'selected',0,... 
                 'evaluate',0,'foreground',0,'background',0,'chisqr',0,... 
                 'local_foreground',0,'global_foreground',1,'local_background',1,'global_background',0,... 
                 'init_func',[],'parsefunc_',0); 
flags = {'selected','evaluate','foreground','background','chisqr',... 
         'local_foreground','global_foreground','local_background','global_background',... 
         'parsefunc_'}; 
 
% Parse parameters: 
[args,options,present] = parse_arguments(varargin,arglist,flags); 
 
% Determine if just parsing the function handles and parameters 
if options.parsefunc_ 
    parsing=true; 
    nop=11; 
else 
    parsing=false; 
    nop=2; 
end 
 
% Check there are some input arguments 
if numel(args)<3    % must have at least w, func, pin 
    [ok,mess,output]=multifit_error(nop,'Check number of input arguments'); return; 
end 
 
% Check if local or global foreground function 
% (If only one if present, over-ride default) 
if present.local_foreground && ~present.global_foreground 
    local_foreground=options.local_foreground; 
elseif ~present.local_foreground && present.global_foreground 
    local_foreground=~options.global_foreground; 
else 
    if options.local_foreground~=options.global_foreground 
        local_foreground=options.local_foreground; 
    else 
        [ok,mess,output]=multifit_error(nop,'Inconsistent options for global and local foreground options'); return; 
    end 
end 
 
% Check if local or global background function 
% (If only one if present, over-ride default) 
if present.local_background && ~present.global_background 
    local_background=options.local_background; 
elseif ~present.local_background && present.global_background 
    local_background=~options.global_background; 
else 
    if options.local_background~=options.global_background 
        local_background=options.local_background; 
    else 
        [ok,mess,output]=multifit_error(nop,'Inconsistent options for global and local foreground options'); return; 
    end 
end 
 
% Check options for 'evaluate' 
fitting=~options.evaluate; 
if ~fitting 
    eval_chisqr=options.chisqr; 
    % Allow one of 'foreground' or 'background' (or their complements) but not both 
    % e.g. 'noforeground' is the same as 'background' 
    eval_foreground=true; 
    eval_background=true; 
    if present.foreground && ~present.background 
        if options.foreground 
            eval_background=false; 
        else 
            eval_foreground=false; 
        end 
    elseif ~present.foreground && present.background 
        if options.background 
            eval_foreground=false; 
        else 
            eval_background=false; 
        end 
    elseif present.foreground && present.background 
        [ok,mess,output]=multifit_error(nop,'Cannot have both ''foreground'' and ''background'' keywords present'); return 
    end 
else 
    if present.chisqr, [ok,mess,output]=multifit_error(nop,'The option ''chisqr'' is only valid with ''evaluate'' keyword present'); return; end 
    if present.foreground, [ok,mess,output]=multifit_error(nop,'The option ''foreground'' is only valid with ''evaluate'' keyword present'); return; end 
    if present.background, [ok,mess,output]=multifit_error(nop,'The option ''background'' is only valid with ''evaluate'' keyword present'); return; end 
    eval_chisqr=false; 
    eval_foreground=true; 
    eval_background=true; 
end 
 
% Check preprocessor option is a function handle, if present 
if ~isempty(options.init_func) 
    if isa(options.init_func,'function_handle') 
        init_func=options.init_func; 
    else 
        [ok,mess,output]=multifit_error(nop,'The option ''init_func'' must be a function handle'); return 
    end 
else 
    init_func=[]; 
end 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Find position of foreground fitting function(s) 
% ---------------------------------------------------------------------------------------------------------------- 
% The first occurence of a function handle or cell array of function handles will be the foreground function(s) 
iarg_fore_func=[]; 
for i=1:numel(args) 
    [ok,mess,func]=function_handles_valid(args{i}); 
    if ok 
        iarg_fore_func=i; 
        break 
    end 
end 
if isempty(iarg_fore_func) 
    [ok,mess,output]=multifit_error(nop,'Must provide handle(s) to foreground fitting function(s) with valid format'); return; 
end 
 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Check nature and validity of data type(s) to be fitted 
% ---------------------------------------------------------------------------------------------------------------- 
[ok,mess,w,single_data_arg,cell_data,xye,xye_xarray] = repackage_input_datasets(args{1:iarg_fore_func-1}); 
if ~ok 
    [ok,mess,output]=multifit_error(nop,mess); return; 
end 
 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Check number of foreground and background fitting functions 
% ---------------------------------------------------------------------------------------------------------------- 
% Foreground function: 
[ok,mess,func]=function_handles_parse(func,size(w),local_foreground); 
if ~ok 
    [ok,mess,output]=multifit_error(nop,['Foreground function: ',mess]); return; 
end 
 
% The next occurence of a function handle or cell array of function handles will be background function(s), if any 
iarg_bkd_func=[]; 
for i=iarg_fore_func+1:numel(args) 
    [ok,mess,bkdfunc]=function_handles_valid(args{i}); 
    if ok   % if not OK, then assume that no background functions are given 
        iarg_bkd_func=i; 
        break 
    end 
end 
if isempty(iarg_bkd_func) 
    bkd=false; 
    if local_background 
        bkdfunc=cell(1); 
    else 
        bkdfunc=cell(size(w)); 
    end 
else 
    bkd=true; 
    [ok,mess,bkdfunc]=function_handles_parse(bkdfunc,size(w),local_background); 
    if ~ok 
        [ok,mess,output]=multifit_error(nop,['Background function: ',mess]); return; 
    end 
end 
 
% Check there is a foreground or a background function for every dataset 
% (If global function, then there will already be a function handle, so the only case to consider is 
% local foreground and local background) 
if local_foreground && local_background 
    for i=1:numel(func) 
        if isempty(func{i}) && isempty(bkdfunc{i}) 
            [ok,mess,output]=multifit_error(nop,'A fit function must be defined for each data set'); return; 
        end 
    end 
end 
 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Check function arguments 
% ---------------------------------------------------------------------------------------------------------------- 
 
% Get number of foreground and background arguments 
if ~bkd 
    nfore_args=numel(args)-iarg_fore_func; 
    nbkd_args=0; 
else 
    nfore_args=iarg_bkd_func-1-iarg_fore_func; 
    nbkd_args=numel(args)-iarg_bkd_func; 
end 
 
 
% Check that foreground fitting function parameter list has the correct form: 
if nfore_args>=1 
    [ok,mess,np,pin]=plist_parse(args{iarg_fore_func+1},func); 
    if ~ok; [ok,mess,output]=multifit_error(nop,['Foreground fitting function(s): ',mess]); return; end 
else 
    [ok,mess,output]=multifit_error(nop,'Must give foreground function(s) parameters'); return; 
end 
 
% Check background pin have correct form: 
if bkd 
    if nbkd_args>=1 
        [ok,mess,nbp,bpin]=plist_parse(args{iarg_bkd_func+1},bkdfunc); 
        if ~ok; [ok,mess,output]=multifit_error(nop,['Background fitting function(s): ',mess]); return; end 
    else 
        [ok,mess,output]=multifit_error(nop,'Must give background function(s) parameters'); return; 
    end 
else 
    nbp=zeros(size(w)); 
    bpin=cell(size(w)); 
end 
 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Check optional arguments that control which parameters are free, which are bound 
% ---------------------------------------------------------------------------------------------------------------- 
 
% Check foreground function(s) 
isforeground=true; 
ilo=iarg_fore_func+2;   % The first argument was pin, so skip over that 
ihi=iarg_fore_func+nfore_args; 
[ok,mess,pfree,pbind]=function_optional_args_parse(isforeground,np,nbp,args{ilo:ihi}); 
if ~ok 
    [ok,mess,output]=multifit_error(nop,mess); return; 
end 
 
% Check background function(s) 
isforeground=false; 
if bkd 
    ilo=iarg_bkd_func+2;   % The first argument was bpin, so skip over that 
    ihi=iarg_bkd_func+nbkd_args; 
    [ok,mess,bpfree,bpbind]=function_optional_args_parse(isforeground,np,nbp,args{ilo:ihi}); 
    if ~ok 
        [ok,mess,output]=multifit_error(nop,mess); return; 
    end 
else 
    [ok,mess,bpfree,bpbind]=function_optional_args_parse(isforeground,np,nbp);  % OK output guaranteed 
end 
 
% ======================================================================== 
% Return if just checking the parsing of the functions and their arguments 
% ------------------------------------------------------------------------ 
if options.parsefunc_ 
    ok=true; 
    mess=''; 
    output={iarg_fore_func, func, pin, pfree, pbind, iarg_bkd_func, bkdfunc, bpin, bpfree, bpbind, numel(args)}; 
    return 
end 
% ======================================================================== 
 
% Check consistency between the free parameters and all the bindings 
% (Do this now to isolate syntax problems before potentially expensive calculation of mask arrays. 
% Will have to repeat this check after masking because if some data sets are entirely masked then 
% some or all free parameters will no longer affect chi-square.) 
[ok,mess,pf]=ptrans_initialise(pin,pfree,pbind,bpin,bpfree,bpbind); 
 
if ~ok || (fitting && isempty(pf)) % inconsistency, or the intention is to fit but there are no free parameters 
    [ok,mess,output]=multifit_error(nop,mess); return; 
end 
 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Check masking values: 
% ---------------------------------------------------------------------------------------------------------------- 
% If masking options are a cell array, then must be either scalar (in which case they apply to all input datasets) or have 
% shape equal to the input data array. Otherwise, will appy to all datasets 
 
if ~isempty(options.keep) 
    xkeep=options.keep; 
    if ~iscell(xkeep), xkeep={xkeep}; end  % make a single cell 
    if ~(isscalar(xkeep) || isequal(size(w),size(xkeep))) 
        mess='''keep'' option must provide a single entity defining keep ranges, or a cell array of entities with same size as data source'; 
        [ok,mess,output]=multifit_error(nop,mess); return; 
    end 
    if isscalar(xkeep), xkeep=repmat(xkeep,size(w)); end 
else 
    xkeep=cell(size(w));     % empty cell array of correct size, for later convenience 
end 
 
 
if ~isempty(options.remove) 
    xremove=options.remove; 
    if ~iscell(xremove), xremove={xremove}; end  % make a single cell, for later convenience 
    if ~(isscalar(xremove) || isequal(size(w),size(xremove))) 
        mess='''remove'' option must provide a single entity defining remove ranges, or a cell array of entities with same size as data source'; 
        [ok,mess,output]=multifit_error(nop,mess); return; 
    end 
    if isscalar(xremove), xremove=repmat(xremove,size(w)); end 
else 
    xremove=cell(size(w));   % empty cell array of correct size, for later convenience 
end 
 
 
if ~isempty(options.mask) 
    msk=options.mask; 
    if ~iscell(msk), msk={msk}; end  % make a single cell, for later convenience 
    if ~(isscalar(msk) || isequal(size(w),size(msk))) 
        mess='''mask'' option must provide a single mask, or a cell array of masks with same size as data source'; 
        [ok,mess,output]=multifit_error(nop,mess); return; 
    end 
    if isscalar(msk), msk=repmat(msk,size(w)); end 
else 
    msk=cell(size(w));     % empty cell array of correct size, for later convenience 
end 
 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Get initial data points - mask out all the points not needed for the fit 
% ---------------------------------------------------------------------------------------------------------------- 
% Accumulate the mask array for later use. 
% Needs a method sigvar_get that also returns the mask file of points that can be ignored 
 
wmask=w;  % hold the input data - the memory penalty is only the cost of a bunch of pointers 
nodata=true(size(w)); 
for i=1:numel(w) 
    if numel(w)==1, data_id='Dataset:'; else data_id=['Dataset ',arraystr(size(w),i),':']; end 
    if xye(i)    % xye triple 
        [msk{i},ok,mess]=mask_points_xye(w{i}.x,xkeep{i},xremove{i},msk{i}); 
        if ok && ~isempty(mess) && options.list~=0 
            display_mess(data_id,mess)  % display warning messages 
        elseif ~ok 
            [ok,mess,output]=multifit_error(nop,[data_id,mess]); return; 
        end 
        [msk{i},ok,mess]=mask_for_fit_xye(w{i}.x,w{i}.y,w{i}.e,msk{i}); % accumulate bad points (y=NaN, zero error bars etc.) to the mask array 
        if ok && ~isempty(mess) && options.list~=0 
            display_mess(data_id,mess)  % display warning messages 
        elseif ~ok 
            [ok,mess,output]=multifit_error(nop,[data_id,mess]); return; 
        end 
        for idim=1:numel(w{i}.x) 
            wmask{i}.x{idim}=w{i}.x{idim}(msk{i}); 
        end 
        wmask{i}.y=w{i}.y(msk{i}); 
        wmask{i}.e=w{i}.e(msk{i}); 
        if any(msk{i}(:)), nodata(i)=false; end 
 
    else % a different data object 
        if ismethod(w{i},'mask_points') 
            [msk{i},ok,mess]=mask_points(w{i},'keep',xkeep{i},'remove',xremove{i},'mask',msk{i}); 
        else 
            [msk{i},ok,mess]=mask_points_xye(sigvar_getx(w{i}),xkeep{i},xremove{i},msk{i}); 
        end 
        if ok && ~isempty(mess) && options.list~=0 
            display_mess(data_id,mess)  % display warning messages 
        elseif ~ok 
            [ok,mess,output]=multifit_error(nop,[data_id,mess]); return; 
        end   % display warning messages 
        [ytmp,vtmp,msk_null]=sigvar_get(w{i}); 
        [msk{i},ok,mess]=mask_for_fit_xye({},ytmp,vtmp,(msk{i}&msk_null)); % accumulate bad points (y=NaN, zero error bars etc.) to the mask array 
        if ok && ~isempty(mess) && options.list~=0 
            display_mess(data_id,mess)  % display warning messages 
        elseif ~ok 
            [ok,mess,output]=multifit_error(nop,[data_id,mess]); return; 
        end   % display warning messages 
        wmask{i}=mask(w{i},msk{i}); % 24 Jan 2009: don't think we'll need to keep msk{i}, but do so for moment, for sake of symmetry 
        if any(msk{i}(:)), nodata(i)=false; end 
 
    end 
end 
 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Fix unbound free parameters that cannot have any effect on chi-squared because all data has been masked for that element of w 
% ---------------------------------------------------------------------------------------------------------------- 
[ok,mess,pf,p_info]=ptrans_initialise(pin,pfree,pbind,bpin,bpfree,bpbind,nodata); 
 
if ~ok  % inconsistency 
    [ok,mess,output]=multifit_error(nop,mess); return; 
else    % consistent, but may be no free parameters 
    if fitting 
        if ~isempty(pf) 
            if ~isempty(mess)     % still one or more free parameters, but print message if there is one 
                disp(' ') 
                disp('********************************************************************************') 
                disp(['WARNING: ',mess]) 
                disp('********************************************************************************') 
                disp(' ') 
            end 
        else                % no free parameters, so return with error 
            [ok,mess,output]=multifit_error(nop,mess); return; 
        end 
    else                    % the intention is to evaluate the function, but print the warning if there is one 
        if ~isempty(mess) 
            disp(['WARNING: ',mess]) 
        end 
    end 
end 
 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Perform the fit, evaluation or chisqr calculation (or any combination, as requested) 
% ---------------------------------------------------------------------------------------------------------------- 
 
% Perform fit, if requested 
if fitting || eval_chisqr 
    if ~isempty(init_func) 
        [ok,mess]=init_func(wmask); 
        if ~ok, [ok,mess,output]=multifit_error(nop,['Preprocessor function: ',mess]); return, end 
    end 
    [p_best,sig,cor,chisqr_red,converged,ok,mess]=multifit_lsqr(wmask,xye,func,bkdfunc,pin,bpin,pf,p_info,options.list,options.fitcontrolparameters,fitting); 
    if ~ok, [ok,mess,output]=multifit_error(nop,mess); return, end 
else 
    p_best=pf;              % Need to have the size of number of free parameters to be useable with p_info 
    sig=zeros(1,numel(pf)); % Likewise 
    cor=zeros(numel(pf));   % Set to zero, as no fitting done 
    chisqr_red=0;           % If do not want to use multifit_lsqr because of unwanted checks and overheads 
    converged=false;        % didn't fit, so set to false 
end 
 
% Evaluate the functions at the fitted parameter values / input parameter requests with ratios properly resolved) 
% On the face of it, it should not be necessary to re-evaluate the function, as this will have been done in multifit_lsqr. 
% However, there are two reasons why we perform an independent final function evaluation: 
% (1) We may want to evaluate the output object for the whole function, not just the fitted points. 
% (2) The evaluation of the function inside multifit_lsqr retains only the calculated values at the data points 
%     used in the evaluation of chi-squared; the evaluation of the output object(s) may require other fields to be 
%     evaluated. For example, when fitting Horace sqw objects, the signal for each of the individual pixels needs to 
%     be recomputed. 
% If the calculated objects were retained after each iteration, rather than just the values at the data points, then 
% it would be possible to use the stored values to avoid this final recalculation for the case of 
% options.selected==true. We could also avoid the second evaluation in the case of eval_chisqr==true. 
 
if options.selected 
    if ~isempty(init_func) 
        [ok,mess]=init_func(wmask); 
        if ~ok, [ok,mess,output]=multifit_error(nop,['Preprocessor function: ',mess]); return, end 
    end 
    wout=multifit_func_eval(wmask,xye,func,bkdfunc,pin,bpin,p_best,p_info,eval_foreground,eval_background); 
    for i=1:numel(wout) % must expand the calculated values into the unmasked x-y-e triple - may be neater way to do this 
        if xye(i) 
            wout{i}.x=w{i}.x; 
            ytmp=wout{i}.y; etmp=wout{i}.e; 
            wout{i}.y=NaN(size(w{i}.y)); wout{i}.y(msk{i})=ytmp; 
            wout{i}.e=zeros(size(w{i}.e)); wout{i}.e(msk{i})=etmp; 
        end 
    end 
else 
    if ~isempty(init_func) 
        [ok,mess]=init_func(w); 
        if ~ok, [ok,mess,output]=multifit_error(nop,['Preprocessor function: ',mess]); return, end 
    end 
    wout=multifit_func_eval(w,xye,func,bkdfunc,pin,bpin,p_best,p_info,eval_foreground,eval_background); 
end 
 
 
% ---------------------------------------------------------------------------------------------------------------- 
% Fill ouput parameters 
% ---------------------------------------------------------------------------------------------------------------- 
% Turn output data into form of input data 
wout = repackage_output_datasets(wout, single_data_arg, cell_data, xye, xye_xarray); 
 
% Fit parameters: 
fitdata = repackage_output_parameters (p_best, sig, cor, chisqr_red, converged, p_info, bkd); 
 
% Pack the output 
ok=true; 
mess=''; 
output={wout,fitdata}; 
 
% Cleanup multifit status 
if matlab_version_num<7.06     % prior to R2008a: does not automatically call cleanup (see start of this function) 
    multifit_cleanup 
end 
 
%================================================================================================================= 
function multifit_cleanup 
% Cleanup multfit 
multifit_store_state 
multifit_lsqr_func_eval 
