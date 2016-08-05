function [data_out, calcdata, ok, mess] = simulate (obj, opt)
% Perform a fit of the data using the current functions and starting parameter values
%
%   >> [data_out, calcdata] = obj.simulate              % if ok false, throws error
%   >> [data_out, calcdata] = obj.simulate ('fore')     % calculate foreground only
%   >> [data_out, calcdata] = obj.simulate ('back'')    % calculate background only
%
%   >> [data_out, calcdata, ok, mess] = obj.simulate (...) % if ok false, still returns
%
% Output:
% -------
%  data_out Output with same form as input data but with y values evaluated
%           at the initial parameter values. If the input was three separate
%           x,y,e arrays, then only the calculated y values are returned.
%
%           If there was a problem i.e. ok==false, then data_out=[].
%
%   chisq   Reduced chi-squared, that is:
%               chi-squared / (no. of data points) - (no. free parameters))
%
%           If there was a problem i.e. ok==false, then chisq=[].
%
%   ok      True:  Simulation performed
%           False: Fundamental problem with the input arguments
%
%   mess    Message if ok==false; Empty string if ok==true.
%
%
% If ok is not a return argument, then if ok is false an error will be thrown.


% Default return values if there is an error
data_out = [];
calcdata = [];

% Determine if not ok will throw an error
if nargout<2
    throw_error = true;
else
    throw_error = false;
end

% Check option
eval_foreground = true;
eval_background = true;
if exist('opt','var')
    if is_string(opt) && strncmpi(opt,'foreground',numel(opt))
        eval_background = false;
    elseif is_string(opt) && strncmpi(opt,'background',numel(opt))
        eval_foreground = false;
    else
        ok = false; mess = 'Unrecognised optional argument';
        if throw_error, error_message(mess), else return, end
    end
end

% Check that there is data present
if obj.ndatatot_ == 0
    ok = false; mess = 'No data has been provided for simulation';
    if throw_error, error_message(mess), else return, end
end

% Check that all functions are present
if all(cellfun(@isempty,obj.fun_)) && all(cellfun(@isempty,obj.fun_))
    ok = false; mess = 'No fit functions have been provided';
    if throw_error, error_message(mess), else return, end
end

% Mask the data
[wmask, msk_out, ok, mess] = mask_data_for_fit (obj.w_, obj.msk_);
if ~ok
    if throw_error, error_message(mess), else return, end
end

% Check that there are parameters and unmasked data to be fitted
[ok, mess, pfin, p_info] = ptrans_initialise_ (obj);
if ~ok,
    if throw_error, error_message(mess), else return, end
end

% Now simulate the data
selected = obj.options_.selected;
if selected
    wout = multifit_func_eval (wmask, xye, obj.fun_, obj.bfun_, obj.pin_, obj.bpin_,...
        pfin, p_info, eval_foreground, eval_background);
    squeeze_xye = obj.options_.squeeze_xye;
    data_out = repackage_output_datasets (obj.data_, wout, msk_out, squeeze_xye);
else
    wout = multifit_func_eval (obj.w_, xye, obj.fun_, obj.bfun_, obj.pin_, obj.bpin_,...
        pfin, p_info, eval_foreground, eval_background);
    squeeze_xye = false;
    msk_none = cellfun(@(x)true(size(x)),obj.msk_,'UniformOutput',false);   % no masking
    data_out = repackage_output_datasets (obj.data_, wout, msk_none, squeeze_xye);
end

% Package output fit results
nf = numel(pfin);
sig = zeros(1,nf);
cor = zeros(nf);
chisqr_red = NaN;
calcdata = repackage_output_parameters (pfin, sig, cor, chisqr_red, converged, p_info);
