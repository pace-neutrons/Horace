function [ycalc,varcalc,S,Store]=multifit_lsqr_func_eval(w,xye,func,bfunc,plist,bplist,...
    f_pass_caller_info,bf_pass_caller_info,pf,p_info,store_calc,Sin,Store_in,listing)
% Calculate the intensities and variances for the data in multifit.
%
%   >> [ycalc,varcalc,S]=multifit_lsqr_func_eval(w,xye,func,bfunc,plist,bplist,...
%                   f_pass_caller_info,bf_pass_caller_info,pf,p_info,store_calc,Sin,listing)
%
%   >> multifit_lsqr_func_eval     % clean-up stored arguments
%
% Input:
% ------
%   w           Cell array where each element w(i) is either
%                 - an x-y-e triple with w(i).x a cell array of arrays, one
%                  for each x-coordinate,
%                 - a scalar object
%               All bad points will have been masked from an x-y-e triple
%               Objects will have their bad points internally masked too.
%
%   xye         Logical array, size(w): indicating which data are x-y-e
%              triples (true) or objects (false)
%
%   func        Handles to foreground functions:
%                 - A cell array with a single function handle (which will
%                  be applied to all the data sets);
%                 - Cell array of function handles, one per data set.
%               Some, but not all, elements of the cell array can be empty.
%              Empty elements are interpreted as not having a function to
%              evaluate for the corresponding data set.
%
%   bfunc       Handles to background functions; same format as func, above
%
%   plist       Array of valid parameter lists, one list per foreground function.
%
%   bplist      Array of valid parameter lists, one list per background function.
%
%   f_pass_caller_info  Keep internal state of foreground function evaluation e.g. seed of random
%               number generator. Dictates the format of the fit function argument list.
%
%   bf_pass_caller_info Keep internal state of background function evaluation e.g. seed of random
%               number generator. Dictates the format of the fit function argument list.
%
%   pf          Free parameter values (that is, the independently
%              varying parameters)
%
%   p_info      Structure with information needed to transform from pf to the
%              parameter values needed for function evaluation
%
%   store_calc  Logical scalar: =true if calculated signal and variance on
%              on calculation are to be stored; =false otherwise
%
%   Sin         Structure containing stored values and internal states of functions.
%               Can be an empty argument, in which case the output stored values
%              structure will be initialised.
%
%   Store_in    Stored values of e.g. expensively evaluated lookup tables that
%              have been accumulated to during evaluation of the fit functions
%
%   listing     Control diagnostic output to the screen:
%                - if >=3 then list which datasets were computed for the
%                  foreground and background functions
%
% Output:
% -------
%   ycalc       Calculated signal on those data points to be retained in fitting
%               A column vector of all the points.
%
%   varcalc     Estimated variance on the calculated values
%               A column vector of all the points.
%
%   S          Structure containing stored values and internal states of functions.
%              If store_calc is true, this will have been updated from S in by calls
%              to the fitting function.
%              In the case when store_calc is false, the structure will be
%              created with the correct fields, but they will be initialised
%              only as cell arrays with empty elements.
%
%   Store       Updated stored values of e.g. expensively evaluated lookup tables that
%              have been accumulated to during evaluation of the fit functions
%
%
% Notes on format of fit functions
% --------------------------------
% For details, see the help to multifit_lsqr
%
%   >> wout = my_func (win, @fun, plist, c1, c2, ...)
% OR
%   >> [wout, state_out, store_out] = my_func (win, caller, state_in, store_in,...
%                                           @fun, plist, c1, c2, ...)
%
% where:
%   caller      Structure that contains information from the caller routine. Fields
%                   reset_state     Logical scalar
%                   ind             Indices of data sets in the full set of data
%   state_in    Cell array containing previously saved internal states for each
%              element of win
%   store_in    Stored values of e.g. expensively evaluated lookup tables
%              passed from caller.
%   state_out   Cell array containing internal states to be saved for a future call.
%   store_out   Updated stored values.
%
% NOTES:
%  - The calculated intensities can be stored to minimise expensive calculation
%   of functions.
%  - If xye data, it is assumed that only those points which are being fitted have
%   been passed to this function. If data objects, then it is required that masked
%   points can be implicitly indicated in the object, so that the required method
%   sigvar_get for the object returns a mask array.


% Original author: T.G.Perring

% Initialise store if required

Store=Store_in;
if isempty(Store)
    Store.fore=[];
    Store.back=[];
end

[p,bp]=ptrans_par(pf,p_info);    % Get latest numerical parameters

S=Sin;
if isempty(S)
    base_names = {'par_store','calc_store','var_store','state_store'};    
    S.fg = init_sub_struct(base_names,p,size(w));
    S.bg = init_sub_struct(base_names,bp,size(w));
end

[fcalc,fvar,fcalc_filled,fcalculated,Store.fore,S.fg] = calculate_fun_on_ds( ...
    w,xye,func,p,plist, ...
    store_calc,f_pass_caller_info,Store.fore,S.fg);

[bcalc,bvar,bcalc_filled,bcalculated,Store.back,S.bg] = calculate_fun_on_ds( ...
    w,xye,bfunc,bp,bplist, ...
    store_calc,bf_pass_caller_info,Store.back,S.bg);

% Update parameters in store
if store_calc
    S.fg.store_filled=true;
    S.bg.store_filled=true;
    S.fg.par_store=p;
    S.bg.par_store=bp;
end

% Create zeros for calculated function values for empty functions
% (There will be either a calculated foreground or calculated background for every dataset
%  We can only do this now because we have no way of knowing the size of the zero arrays for objects)

if ~all(fcalc_filled | bcalc_filled)
    error('HERBERT:multifit_lsqr_func_eval:bad_output', 'Logic error in multifit. See T.G.Perring')
end

% Adding scalar zeros to array is equivalent without the need for excess memory
fcalc(~fcalc_filled) = {0}; %zeros(size(bcalc(~fcalc_filled)));
fvar(~fcalc_filled) = {0}; %zeros(size(bvar(~fcalc_filled)));

bcalc(~bcalc_filled) = {0}; %zeros(size(fcalc(~bcalc_filled)));
bvar(~bcalc_filled) = {0}; %zeros(size(fvar(~bcalc_filled)));

% the loop with pre-allocation is faster then cellfun on all recent MATLAB-s
ycalc = cell(1,numel(w));
varcalc = cell(1,numel(w));
for i=1:numel(w)
    ycalc{i}   = fcalc{i}+bcalc{i};
    varcalc{i} = fvar{i}+bvar{i};
end
% Write diagnostics to screen, if requested
if listing>2
    list_calculated_funcs(fcalculated,bcalculated)
end
end
%------------------------------------------------------------------------------
function [fcalc,fvar,calc_filled,calculated,state,S] = calculate_fun_on_ds( ...
    w,xye,func,p,plist, ...
    store_calc,pass_caller_info,state,S)
% Calculate function or set of provided functions (each per dataset) on the
% cellarray of input objects
%
caller.reset_state=~store_calc;
caller.ind=[];

nw=numel(w);
fcalc=cell(size(w)); fvar=cell(size(w));
% Get function calculated values for non-empty functions, and store if required
if isscalar(func)
    fnums = ones(1,nw); % all datasets use one function
else
    fnums = 1:nw;       % each dataset has its own function
end

calc_filled=false(nw,1);
calculated =false(nw,1);
for iw=1:nw
    caller.ind=iw;
    num_f = fnums(iw);
    if ~isempty(func{num_f})
        calc_filled(iw)=true;
        if S.store_filled && all(p{num_f}==S.par_store{num_f})
            fcalc{iw}=S.calc_store{iw};
            fvar{iw}=S.var_store{iw};
        else
            pars=plist_update(plist(num_f),p{num_f});
            if xye(iw)
                if ~pass_caller_info
                    fcalc{iw}=func{num_f}(w{iw}.x{:},pars{:});
                else
                    [fcalc{iw},fstate,state]=func{num_f}(w{iw}.x{:},caller,...
                        S.state_store(iw),state,pars{:});
                end
                fvar{iw}=zeros(size(fcalc{iw}));
            else
                if ~pass_caller_info
                    wcalc=func{num_f}(w{iw},pars{:});
                else
                    [wcalc,fstate,Store.fore]=func{num_f}(w{iw},caller,...
                        S.state_store(iw),state,pars{:});
                end
                [fcalc{iw},fvar{iw},msk]=sigvar_get(wcalc);
                fcalc{iw}=fcalc{iw}(msk);       % remove the points that we are told to ignore
                fvar{iw}=fvar{iw}(msk);
            end
            fcalc{iw}=fcalc{iw}(:); % make column vector
            fvar{iw}=fvar{iw}(:);
            if store_calc
                S.calc_store{iw}=fcalc{iw};
                S.var_store{iw}=fvar{iw};
                if pass_caller_info; S.state_store(iw)=fstate; end
            end
            calculated(iw)=true;
        end
    end
end
end
%------------------------------------------------------------------------------
function S = init_sub_struct(field_names,plist,ds_size)
% Initialize substructure used as storage for function values
%
field_val = {cell(size(plist)),cell(ds_size),cell(ds_size),cell(ds_size)};
S = cell2struct(field_val,field_names,2);
S.store_filled = false;
end
%------------------------------------------------------------------------------
function plist_cell = plist_update (plist, pnew)
% Take mfclass_plist object and replacement numerical parameter list with same number
% of elements, return cell array of parameters to pass to evaluation function.
tmp=plist;
tmp.p=reshape(pnew,size(plist.p));  % ensure same orientation
if iscell(tmp.plist)
    plist_cell=tmp.plist;           % case of {@func,plist,c1,c2,...}, {p,c1,c2,...}, {c1,c2,...} or {}
else
    plist_cell={tmp.plist};         % catch case of p or c1<0> (see mfclass_plist)
end
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
end
