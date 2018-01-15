function [data_out, fitdata, ok, mess] = fit (obj, varargin)
% Perform a fit of the data using the current functions and parameter values
%
% Return calculated fitted datasets and parameters:
%   >> [data_out, fitdata] = obj.fit                    % if ok false, throws error
%
% Return the calculated fitted signal, foreground and background in a structure:
%   >> [data_out, fitdata] = obj.fit ('components')     % if ok false, throws error
%
% Continue execution even if an error condition is thrown:
%   >> [data_out, fitdata, ok, mess] = obj.fit (...)    % if ok false, still returns
%
% If the results of a previous fit are available, with the same number of foreground
% and background functions and parameters, then the fit parameter structure can be
% passed as the first argument as the initial values at which to satart the fit:
%   >> [data_out, fitdata] = obj.fit (...)
%               :
%   >> [...] = obj.fit (fitdata, ...)
%
% (This is useful if you want to re-fit starting with the results of an earlier fit)
%
%
% Output:
% -------
%  data_out Output with same form as input data but with y values evaluated
%           at the final fit parameter values. If the input was three separate
%           x,y,e arrays, then only the calculated y values are returned.
%           If there was a problem i.e. ok==false, then data_out=[].
%
%           If option 'components' was given, then data_out is a structure with fields
%           with the same format as above, as follows:
%               data_out.sum        Sum of foreground and background
%               data_out.fore       Foreground calculation
%               data_out.back       Background calculation
%           If there was a problem i.e. ok==false, then each field is =[].
%
%   fitdata Structure with result of the fit for each dataset. The fields are:
%           p      - Foreground parameter values (if foreground function(s) present)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           sig    - Estimated errors of foreground parameters (=0 for fixed
%                    parameters)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           bp     - Background parameter values (if background function(s) present)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           bsig   - Estimated errors of background (=0 for fixed parameters)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           corr   - Correlation matrix for free parameters
%           chisq  - Reduced Chi^2 of fit i.e. divided by:
%                       (no. of data points) - (no. free parameters))
%           converged - True if the fit converged, false otherwise
%           pnames - Foreground parameter names
%                      If only one function, a cell array (row vector) of names
%                      If more than one function: a row cell array of row vector
%                                                 cell arrays
%           bpnames- Background parameter names
%                      If only one function, a cell array (row vector) of names
%                      If more than one function: a row cell array of row vector
%                                                 cell arrays
%
%           If there was a problem i.e. ok==false, then fitdata=[].
%
%   ok      True: A fit coould be performed. This includes the cases of
%                 both convergence and failure to converge
%           False: Fundamental problem with the input arguments e.g. the
%                 number of free parameters equals or exceeds the number
%                 of data points
%
%   mess    Message if ok==false; Empty string if ok==true.
%
% If ok is not a return argument, then if ok is false an error will be thrown.

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
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


% Default return values if there is an error
data_out = [];
fitdata = [];

% Determine if not ok will throw an error
if nargout<3
    throw_error = true;
else
    throw_error = false;
end

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
            ok = false; mess = 'Check the value of output option';
        end
    else
        ok = false; mess = 'Check number of input arguments';
    end
end
if ~ok
    if throw_error, error_message(mess), else, return, end
end

% Check that there is data present
if obj.ndatatot_ == 0
    ok = false; mess = 'No data has been provided for fitting';
    if throw_error, error_message(mess), else, return, end
end

% Check that all functions are present
foreground_present = ~all(cellfun(@isempty,obj.fun_));
background_present = ~all(cellfun(@isempty,obj.bfun_));
if ~foreground_present && ~background_present
    ok = false; mess = 'No fit functions have been provided';
    if throw_error, error_message(mess), else, return, end
end

% Mask the data
[wmask, msk_out, ok, mess] = mask_data_for_fit (obj.w_, obj.msk_);
if ~ok
    if throw_error, error_message(mess), else, return, end
end

% Check that there are parameters and unmasked data to be fitted
[~, ok, mess, pfin, p_info] = ptrans_initialise_ (obj);
if ~ok
    if throw_error, error_message(mess), else, return, end
end

% Allow for the case of input argument over-riding initial parameter values for fit
if numel(args)==1
    [pfin,ok_sim,mess] = ptrans_par_inverse(args{1}, p_info);
    if ~ok_sim
        ok = false;
        if throw_error, error_message(mess), else, return, end
    end
end

% Get wrapped functions and parameters after performing initialisation if required
[ok, mess, fun_wrap, pin_wrap, bfun_wrap, bpin_wrap] = ...
    wrap_functions_and_parameters (obj.wrapfun_, wmask, obj.fun_, obj.pin_, obj.bfun_, obj.bpin_);
if ~ok
    if throw_error, error_message(mess), else, return, end
end

% Now fit the data
xye = cellfun(@isstruct, obj.w_);
f_pass_caller = obj.wrapfun_.f_pass_caller;
bf_pass_caller = obj.wrapfun_.bf_pass_caller;
listing = obj.options_.listing;
fcp = obj.options_.fit_control_parameters;
perform_fit = true;

[pf, sig, cor, chisqr_red, converged, ok, mess] =...
    multifit_lsqr (wmask, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
    f_pass_caller, bf_pass_caller, pfin, p_info, listing, fcp, perform_fit);
if ~ok
    if throw_error, error_message(mess), else, return, end
end

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
    [ok, mess, fun_wrap, pin_wrap, bfun_wrap, bpin_wrap] = ...
        wrap_functions_and_parameters (obj.wrapfun_, obj.w_, obj.fun_, obj.pin_, obj.bfun_, obj.bpin_);
    if ~ok
        if throw_error, error_message(mess), else, return, end
    end

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
