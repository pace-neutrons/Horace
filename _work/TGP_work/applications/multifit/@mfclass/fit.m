function [data_out, fitdata, ok, mess] = fit (obj)
% Perform a fit of the data using the current functions and starting parameter values
%
%   >> [data_out, fitdata] = obj.fit            % if ok false, throws error
%
%   >> [data_out, fitdata, ok, mess] = obj.fit  % if ok false, still returns
%
%
% Output:
% -------
%  data_out Output with same form as input data but with y values evaluated
%           at the final fit parameter values. If the input was three separate
%           x,y,e arrays, then only the calculated y values are returned.
%
%           If there was a problem i.e. ok==false, then data_out=[].
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
%
% If ok is not a return argument, then if ok is false an error will be thrown.


% Cleanup multifit (should be just a precaution) and set cleanup object
multifit_cleanup    % initialise multifit
cleanupObj=onCleanup(@multifit_cleanup);

% Default return values if there is an error
data_out = [];
fitdata = [];

% Determine if not ok will throw an error
if nargout<3
    throw_error = true;
else
    throw_error = false;
end

% Check that there is data present
if obj.ndatatot_ == 0
    ok = false; mess = 'No data has been provided for fitting';
    if throw_error, error_message(mess), else return, end
end

% Check that all functions are present
foreground_present = ~all(cellfun(@isempty,obj.fun_));
background_present = ~all(cellfun(@isempty,obj.bfun_));
if ~foreground_present && ~background_present
    ok = false; mess = 'No fit functions have been provided';
    if throw_error, error_message(mess), else return, end
end

% Mask the data
[wmask, msk_out, ok, mess] = mask_data_for_fit (obj.w_, obj.msk_);
if ~ok
    if throw_error, error_message(mess), else return, end
end

% Get wrapped functions and parameters
[fun_wrap, pin_wrap, bfun_wrap, bpin_wrap] = get_wrapped_functions_ (obj);

% Check that there are parameters and unmasked data to be fitted
[~, ok, mess, pfin, p_info] = ptrans_initialise_ (obj);
if ~ok,
    if throw_error, error_message(mess), else return, end
end

% Now fit the data
xye = cellfun(@isstruct, obj.w_);
listing = obj.options_.listing;
fcp = obj.options_.fit_control_parameters;
perform_fit = true;

[pf, sig, cor, chisqr_red, converged, ok, mess] =...
    multifit_lsqr (wmask, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap, pfin, p_info,...
    listing, fcp, perform_fit);
if ~ok
    if throw_error, error_message(mess), else return, end
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
foreground_eval = true;
background_eval = true;
if selected
    wout = multifit_func_eval (wmask, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
        pf, p_info, foreground_eval, background_eval);
    squeeze_xye = obj.options_.squeeze_xye;
    data_out = repackage_output_datasets (obj.data_, wout, msk_out, squeeze_xye);
else
    wout = multifit_func_eval (obj.w_, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
        pf, p_info, foreground_eval, background_eval);
    squeeze_xye = false;
    msk_none = cellfun(@(x)true(size(x)),obj.msk_,'UniformOutput',false);   % no masking
    data_out = repackage_output_datasets (obj.data_, wout, msk_none, squeeze_xye);
end

% Package output fit results
fitdata = repackage_output_parameters (pf, sig, cor, chisqr_red, converged, p_info,...
    foreground_present, background_present);
