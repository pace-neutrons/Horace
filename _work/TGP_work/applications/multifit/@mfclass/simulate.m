function [data_out, calcdata, ok, mess] = simulate (obj, varargin)
% Perform a fit of the data using the current functions and starting parameter values
%
%   >> [data_out, calcdata] = obj.simulate              % if ok false, throws error
%   >> [data_out, calcdata] = obj.simulate ('fore')     % calculate foreground only
%   >> [data_out, calcdata] = obj.simulate ('back')     % calculate background only
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
if nargout<3
    throw_error = true;
else
    throw_error = false;
end

% Check option
keyval_def = struct('foreground_evaluate',true,'background_evaluate',true);
flagnames = {'foreground_evaluate','background_evaluate'};
[args,keyval,present,~,ok,mess] = parse_arguments (varargin, keyval_def, flagnames);
if ok
    if numel(args)<=1
        if present.foreground_evaluate && ~present.background_evaluate
            keyval.background_evaluate = ~keyval.foreground_evaluate;
        elseif present.background_evaluate && ~present.foreground_evaluate
            keyval.foreground_evaluate = ~keyval.background_evaluate;
        end
        foreground_eval = keyval.foreground_evaluate;
        background_eval = keyval.background_evaluate;
    else
        ok = false; mess = 'Check number of arguments';
    end
end
if ~ok
    if throw_error, error_message(mess), else return, end
end

% Check that there is data present
if obj.ndatatot_ == 0
    ok = false; mess = 'No data has been provided for simulation';
    if throw_error, error_message(mess), else return, end
end

% Check that all functions are present
foreground_present = ~all(cellfun(@isempty,obj.fun_));
background_present = ~all(cellfun(@isempty,obj.bfun_));
if ~foreground_present && ~background_present
    ok = false; mess = 'No fit functions have been provided';
    if throw_error, error_message(mess), else return, end
end

% Get wrapped functions and parameters
[fun_wrap, pin_wrap, bfun_wrap, bpin_wrap] = get_wrapped_functions_ (obj);

% Mask the data
[wmask, msk_out, ok, mess] = mask_data_for_fit (obj.w_, obj.msk_);
if ~ok
    if throw_error, error_message(mess), else return, end
end

% Check that the parameters are OK, and for chisqr calculation that the data is fittable
[ok_sim, ok_fit, mess, pfin, p_info] = ptrans_initialise_ (obj);
if ~ok_sim
    ok = false;
    if throw_error, error_message(mess), else return, end
end

if numel(args)==1
    [pfin,ok_sim,mess] = ptrans_par_inverse(args{1}, p_info);
    if ~ok_sim
        ok = false;
        if throw_error, error_message(mess), else return, end
    end
end

% Now simulate the data
xye = cellfun(@isstruct, obj.w_);
selected = obj.options_.selected;
if selected
    wout = multifit_func_eval (wmask, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
        pfin, p_info, foreground_eval, background_eval);
    squeeze_xye = obj.options_.squeeze_xye;
    data_out = repackage_output_datasets (obj.data_, wout, msk_out, squeeze_xye);
else
    wout = multifit_func_eval (obj.w_, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
        pfin, p_info, foreground_eval, background_eval);
    squeeze_xye = false;
    msk_none = cellfun(@(x)true(size(x)),obj.msk_,'UniformOutput',false);   % no masking
    data_out = repackage_output_datasets (obj.data_, wout, msk_none, squeeze_xye);
end

% Package output fit results
nf = numel(pfin);
sig = zeros(1,nf);
cor = zeros(nf);
chisqr_red = NaN;
converged = false;
calcdata = repackage_output_parameters (pfin, sig, cor, chisqr_red, converged, p_info,...
    foreground_present, background_present);
