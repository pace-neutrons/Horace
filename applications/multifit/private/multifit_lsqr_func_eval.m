function [ycalc,varcalc]=multifit_lsqr_func_eval(w,xye,func,bkdfunc,plist,bplist,pf,p_info,store_vals,listing)
% Calculate the intensities and variances for the data in multifit.
%
%   >> [ycalc,varcalc]=multifit_lsqr_func_eval(w,xye,func,bkdfunc,plist,bplist,pf,p_info,store_vals)
%
%   >> multifit_lsqr_func_eval     % cleanup stored arguments
%
% Input:
% ------
%   w           Cell array where each element w(i) is either
%                 - an x-y-e triple with w(i).x a cell array of arrays, one
%                  for each x-coordinate,
%                 - a scalar object
%
%   xye         Logical array, size(w): indicating which data are x-y-e triples (true),
%              or objects (false)
%
%   func        Handles to foreground functions:
%                 - a single function handle
%                 - cell array of function handles
%               Some, but not all, elements of the cell array can be empty.
%              Empty elements are interpreted as not having a function to
%              evaluate for the corresponding data set.
%
%   bkdfunc     Handles to background functions; same format as func, above
%
%   plist       Cell array of valid parameter lists, one list per foreground function.
%   
%   bkdlist     Cell array of valid parameter lists, one list per background function.
%
%   pf          Free parameter initial values
%
%   p_info      Structure with information needed to transform from pf to the
%              parameter values needed for function evaluation
%
%   store_vals  Logical scalar: =true if calculated signal and variance on
%              on calculation (could be useful in Monte Carlo function evaluation)
%              are to be stored; =false otherwise
%
%   listing     Control diagnostic output to the screen if >2 then list which
%              datasets were computed for the foreground and background functions
%
% Output:
% -------
%   ycalc       Calculated signal on those data points to be retianed in fitting
%   varcalc     Estimated cariance on the calculated values
%
%
% NOTES:
%  - The calculated intensities can be stored to minimise expensive calculation
%   of functions.
%  - If xye data, it is assumed that only those points which are being fitted have
%   been passed to this function. If data objects, then it is required that masked
%   points can be implicitly indicated in the object, so that the required method
%   sigvar_get for the object returns a mask array.

persistent store_filled pstore bpstore fcalc_store fvar_store bcalc_store bvar_store


% Cleanup and return if requested
if nargin==0
    store_filled=[];
    pstore=[]; bpstore=[];
    fcalc_store=[]; fvar_store=[]; bcalc_store=[]; bvar_store=[];
    return
end

% Initialise store if required
if store_vals && isempty(store_filled)
    store_filled=false;
    pstore=cell(size(plist)); bpstore=cell(size(bplist)); 
    fcalc_store=cell(size(w)); fvar_store=cell(size(w)); bcalc_store=cell(size(w)); bvar_store=cell(size(w));
end

% Status
isfitting=true;

% Get latest numerical parameters
[p,bp]=ptrans_par(pf,p_info);
fcalc=cell(size(w)); fvar=cell(size(w)); bcalc=cell(size(w)); bvar=cell(size(w));

% Get foreground function calculated values for non-empty functions, and store if required
fcalculated=false(numel(func),1);
if numel(func)==1
    if ~isempty(func{1})
        if ~isempty(store_filled) && store_filled && all(p{1}==pstore{1})
            for iw=1:numel(w)
                fcalc{iw}=fcalc_store{iw};
                fvar{iw}=fvar_store{iw};
            end
        else
            pars=parameter_set(plist{1},p{1});
            if ~iscell(pars), pars={pars}; end  % make a cell for convenience
            for iw=1:numel(w)
                multifit_store_state (isfitting,iw,true,store_vals)
                if xye(iw)
                    fcalc{iw}=func{1}(w{iw}.x{:},pars{:});
                    fvar{iw}=zeros(size(fcalc{iw}));
                else
                    wcalc=func{1}(w{iw},pars{:});
                    [fcalc{iw},fvar{iw},msk]=sigvar_get(wcalc);
                    fcalc{iw}=fcalc{iw}(msk);         % remove the points that we are told to ignore
                    fvar{iw}=fvar{iw}(msk);
                end
                fcalc{iw}=fcalc{iw}(:); % make column vector
                fvar{iw}=fvar{iw}(:);
                if store_vals
                    fcalc_store{iw}=fcalc{iw};
                    fvar_store{iw}=fvar{iw};
                end
                fcalculated(iw)=true;
            end
        end
    end
else
    for iw=1:numel(w)
        if ~isempty(func{iw})
            if ~isempty(store_filled) && store_filled && all(p{iw}==pstore{iw})
                fcalc{iw}=fcalc_store{iw};
                fvar{iw}=fvar_store{iw};
            else
                multifit_store_state (isfitting,iw,true,store_vals)
                pars=parameter_set(plist{iw},p{iw});
                if ~iscell(pars), pars={pars}; end  % make a cell for convenience
                if xye(iw)
                    fcalc{iw}=func{iw}(w{iw}.x{:},pars{:});
                    fvar{iw}=zeros(size(fcalc{iw}));
                else
                    wcalc=func{iw}(w{iw},pars{:});
                    [fcalc{iw},fvar{iw},msk]=sigvar_get(wcalc);
                    fcalc{iw}=fcalc{iw}(msk);       % remove the points that we are told to ignore
                    fvar{iw}=fvar{iw}(msk);
                end
                fcalc{iw}=fcalc{iw}(:); % make column vector
                fvar{iw}=fvar{iw}(:);
                if store_vals
                    fcalc_store{iw}=fcalc{iw};
                    fvar_store{iw}=fvar{iw};
                end
                fcalculated(iw)=true;
            end
        end
    end
end


% Update background function calculated values for non-empty functions, and store if required
bcalculated=false(numel(bkdfunc),1);
if numel(bkdfunc)==1
    if ~isempty(bkdfunc{1})
        if ~isempty(store_filled) && store_filled && all(bp{1}==bpstore{1})
            for iw=1:numel(w)
                bcalc{iw}=bcalc_store{iw};
                bvar{iw}=bvar_store{iw};
            end
        else
            pars=parameter_set(bplist{1},bp{1});
            if ~iscell(pars), pars={pars}; end  % make a cell for convenience
            for iw=1:numel(w)
                multifit_store_state (isfitting,iw,false,store_vals)
                if xye(iw)
                    bcalc{iw}=bkdfunc{1}(w{iw}.x{:},pars{:});
                    bvar{iw}=zeros(size(bcalc{iw}));
                else
                    wcalc=bkdfunc{1}(w{iw},pars{:});
                    [bcalc{iw},bvar{iw},msk]=sigvar_get(wcalc);
                    bcalc{iw}=bcalc{iw}(msk);   	% remove the points that we are told to ignore
                    bvar{iw}=bvar{iw}(msk);
                end
                bcalc{iw}=bcalc{iw}(:); % make column vector
                bvar{iw}=bvar{iw}(:);
                if store_vals
                    bcalc_store{iw}=bcalc{iw};
                    bvar_store{iw}=bvar{iw};
                end
                bcalculated(iw)=true;
            end
        end
    end
else
    for iw=1:numel(w)
        if ~isempty(bkdfunc{iw})
            if ~isempty(store_filled) && store_filled && all(bp{iw}==bpstore{iw})
                bcalc{iw}=bcalc_store{iw};
                bvar{iw}=bvar_store{iw};
            else
                multifit_store_state (isfitting,iw,false,store_vals)
                pars=parameter_set(bplist{iw},bp{iw});
                if ~iscell(pars), pars={pars}; end  % make a cell for convenience
                if xye(iw)
                    bcalc{iw}=bkdfunc{iw}(w{iw}.x{:},pars{:});
                    bvar{iw}=zeros(size(bcalc{iw}));
                else
                    wcalc=bkdfunc{iw}(w{iw},pars{:});
                    [bcalc{iw},bvar{iw},msk]=sigvar_get(wcalc);
                    bcalc{iw}=bcalc{iw}(msk);       % remove the points that we are told to ignore
                    bvar{iw}=bvar{iw}(msk);
                end
                bcalc{iw}=bcalc{iw}(:); % make column vector
                bvar{iw}=bvar{iw}(:);
                if store_vals
                    bcalc_store{iw}=bcalc{iw};
                    bvar_store{iw}=bvar{iw};
                end
                bcalculated(iw)=true;
            end
        end
    end
end


% Update parameters in store
if store_vals
    store_filled=true;
    pstore=p;
    bpstore=bp;
end

% Create zeros for calculated function values for empty functions
% (There will be either a calculated foreground or calculated background for every dataset
%  We can only do this now because we have no way of knowing the size of the zero arrays for objects)
for iw=1:numel(w)
    if isempty(fcalc{iw}) && ~isempty(bcalc{iw})
        fcalc{iw}=zeros(size(bcalc{iw}));
        fvar{iw}=zeros(size(bvar{iw}));
    elseif ~isempty(fcalc{iw}) && isempty(bcalc{iw})
        bcalc{iw}=zeros(size(fcalc{iw}));
        bvar{iw}=zeros(size(fvar{iw}));
    elseif isempty(fcalc{iw}) && isempty(bcalc{iw})
        error('Logic error in multifit. See T.G.Perring')
    end
end

% Package data for return
ycalc = cell2mat(fcalc(:)) + cell2mat(bcalc(:));    % one long column vector
varcalc = cell2mat(fvar(:)) + cell2mat(bvar(:));    % one long column vector

% Write diagnostics to screen, if requested
if listing>2
    list_calculated_funcs(fcalculated,bcalculated)
end

%------------------------------------------------------------------------------
function list_calculated_funcs(f,b)
% List the indicies of datasets that were computed
str=iarray_to_str(find(f),80);
if numel(str)>0
    str{1}=['    Calculated foreground datasets:  ',str{1}];
    for i=1:numel(str)
        disp(str{i})
    end
else
    disp('    Calculated foreground datasets:  n/a')
end
str=iarray_to_str(find(b),80);
if numel(str)>0
    str{1}=['    Calculated background datasets:  ',str{1}];
    for i=1:numel(str)
        disp(str{i})
    end
else
    disp('    Calculated background datasets:  n/a')
end
disp(' ')
