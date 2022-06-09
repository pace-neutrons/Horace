function [data_out, fitdata] = fit (obj, varargin)
%-------------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_fit_intro = fullfile(mfclass_doc,'doc_fit_intro.m')
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_fit_intro> '' ''
% <#doc_end:>
%-------------------------------------------------------------------------------


% Original author: T.G.Perring
%


% Default return values if there is an error
data_out = [];

% Check option
opt_default = struct('sum',false,'components',false);
flagnames = {'sum','components'};
[args,opt,~,~,ok,mess] = parse_arguments (varargin, opt_default, flagnames);
if ok
    if numel(args)<=1
        lopt = cell2mat(struct2cell(opt));
        if sum(lopt)==0
            output_type = 'sum';
        elseif sum(lopt)==1
            output_type = flagnames{lopt};
        else
            error("HERBERT:mfclass:invalid_argument", 'Check the value of output option')
        end
    else
        error("HERBERT:mfclass:invalid_argument", 'Check number of input arguments')
    end
else
    error("HERBERT:mfclass:invalid_argument", mess)
end

% Check that there is data present
if obj.ndatatot_ == 0
    error("HERBERT:mfclass:invalid_argument", 'No data has been provided for fitting')
end

% Check that all functions are present
foreground_present = ~all(cellfun(@isempty,obj.fun_));
background_present = ~all(cellfun(@isempty,obj.bfun_));

if ~foreground_present && ~background_present
    error("HERBERT:mfclass:invalid_argument", 'No fit functions have been provided')
end

% Mask the data
[wmask, msk_out] = mask_data_for_fit(obj.w_, obj.msk_);

% Check that there are parameters and unmasked data to be fitted
[~, ok, mess, pfin, p_info] = ptrans_initialise_(obj);
if ~ok
    error("HERBERT:mfclass:bad_ptrans_init", mess)
end

% Allow for the case of input argument over-riding initial parameter values for fit
if numel(args)==1
    pfin = ptrans_par_inverse(args{1}, p_info);
end

% Get wrapped functions and parameters after performing initialisation if required
[fun_wrap, pin_wrap, bfun_wrap, bpin_wrap] = ...
    wrap_functions_and_parameters (obj.wrapfun_, wmask, obj.fun_, obj.pin_, obj.bfun_, obj.bpin_);

% Now fit the data
xye = cellfun(@isstruct, obj.w_);
f_pass_caller = obj.wrapfun_.f_pass_caller;
bf_pass_caller = obj.wrapfun_.bf_pass_caller;
listing = obj.options_.listing;
fcp = obj.options_.fit_control_parameters;
perform_fit = true;

[pf, sig, cor, chisqr_red, converged] =...
    multifit_lsqr (wmask, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
    f_pass_caller, bf_pass_caller, pfin, p_info, listing, fcp, perform_fit);

% Evaluate the data at the fitted parameter values
%  On the face of it, it should not be necessary to re-evaluate the function,
% as this will have been done in multifit_lsqr. However, there are two reasons
% why we perform an independent final function evaluation:
% (1) We may want to evaluate the output object for the whole function,
%    not just the fitted points.
% (2) The evaluation of the function inside multifit_lsqr retains only the
%    calculated values at the data points used in the evaluation of
%    chi-squared; the evaluation of the output object(s) may require other
%    fields to be evaluated. For example, when fitting Horace sqw objects,
%    the signal for each of the individual pixels needs to be recomputed.
% If the calculated objects were retained after each iteration, rather than
% just the values at the data points, then it would be possible to use the
% stored values to avoid this final recalculation for the case of
% obj.options_.selected==true.

selected = obj.options_.selected;
if selected
    % All initiliasation is up to date, as evaluating over the same data as was fitted
    % Now compute output
    wout = multifit_func_eval (wmask, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
        f_pass_caller, bf_pass_caller, pf, p_info, output_type);
    squeeze_xye = obj.options_.squeeze_xye;
    if ~opt.components
        data_out = repackage_output_datasets (obj.data_, wout, msk_out, squeeze_xye);
    else
        data_out.sum  = repackage_output_datasets (obj.data_, wout.sum , msk_out, squeeze_xye);
        data_out.fore = repackage_output_datasets (obj.data_, wout.fore, msk_out, squeeze_xye);
        data_out.back = repackage_output_datasets (obj.data_, wout.back, msk_out, squeeze_xye);
    end

else
    % Need to re-initialise because data is unmasked i.e. not the same as fitted
    % (if there is no initialisation to be done, then cheap call)
    [fun_wrap, pin_wrap, bfun_wrap, bpin_wrap] = ...
        wrap_functions_and_parameters (obj.wrapfun_, obj.w_, obj.fun_, obj.pin_, obj.bfun_, obj.bpin_);

    % Now compute output
    wout = multifit_func_eval (obj.w_, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
        f_pass_caller, bf_pass_caller, pf, p_info, output_type);
    squeeze_xye = false;
    msk_none = cellfun(@(x)true(size(x)),obj.msk_,'UniformOutput',false);   % no masking
    if ~opt.components
        data_out = repackage_output_datasets (obj.data_, wout, msk_none, squeeze_xye);
    else
        data_out.sum  = repackage_output_datasets (obj.data_, wout.sum , msk_none, squeeze_xye);
        data_out.fore = repackage_output_datasets (obj.data_, wout.fore, msk_none, squeeze_xye);
        data_out.back = repackage_output_datasets (obj.data_, wout.back, msk_none, squeeze_xye);
    end

end

% Package output fit results
fitdata = repackage_output_parameters (pf, sig, cor, chisqr_red, converged, p_info,...
    foreground_present, background_present);
end
