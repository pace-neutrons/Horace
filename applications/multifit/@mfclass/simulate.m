function [data_out, calcdata, ok, mess] = simulate (obj, varargin)
% Perform a simulation of the data using the current functions and parameter values
%
% Return calculated sum of foreground and background:
%   >> [data_out, calcdata] = obj.simulate                % if ok false, throws error
%
% Return foreground, background, sum or all three:
%   >> [data_out, calcdata] = obj.simulate ('sum')        % Equivalent to above
%   >> [data_out, calcdata] = obj.simulate ('foreground') % calculate foreground only
%   >> [data_out, calcdata] = obj.simulate ('background') % calculate background only
%
%   >> [data_out, calcdata] = obj.simulate ('components') % calculate foreground,
%                                                         % background and sum
%                                                         % (data_out is a structure)
%
% Continue execution even if an error condition is thrown:
%   >> [data_out, calcdata, ok, mess] = obj.simulate (...) % if ok false, still returns
%
% If the results of a previous fit are available, with the same number of foreground
% and background functions and parameters, then the fit parameter structure can be
% passed as the first argument as the values at which to simulate the output:
%   >> [data_out, fitdata] = obj.fit (...)
%               :
%   >> [...] = obj.simulate (fitdata, ...)
%
% (This is useful if you want to simulate the result of a fit without updating the
% parameter values function-by-function)
%
% Output:
% -------
%  data_out Output with same form as input data but with y values evaluated
%           at the initial parameter values. If the input was three separate
%           x,y,e arrays, then only the calculated y values are returned.
%           If there was a problem i.e. ok==false, then data_out=[].
%
%           If option is 'components', then data_out is a structure with fields
%           with the same format as above, as follows:
%               data_out.sum        Sum of foreground and background
%               data_out.fore       Foreground calculation
%               data_out.back       Background calculation
%           If there was a problem i.e. ok==false, then each field is =[].
%
%  calcdata Structure with result of the fit for each dataset. The fields are:
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
%           If there was a problem i.e. ok==false, then calcdata=[].
%
%   ok      True:  Simulation performed
%           False: Fundamental problem with the input arguments
%
%   mess    Message if ok==false; Empty string if ok==true.
%
%
% If ok is not a return argument, then if ok is false an error will be thrown.

%-------------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_simulate_intro = fullfile(mfclass_doc,'doc_simulate_intro.m')
%-------------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_simulate_intro>
% <#doc_end:>
%-------------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


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
opt_default = struct('sum',false,'foreground',false,'background',false,...
    'components',false);
flagnames = fieldnames(opt_default);
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
    ok = false; mess = 'No data has been provided for simulation';
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

% Check that the parameters are OK, and for chisqr calculation that the data is fittable
[ok_sim, ~, mess, pfin, p_info] = ptrans_initialise_ (obj);
if ~ok_sim
    ok = false;
    if throw_error, error_message(mess), else, return, end
end

% Allow for the case of input argument over-riding parameter values for simulation
if numel(args)==1
    [pfin,ok_sim,mess] = ptrans_par_inverse(args{1}, p_info);
    if ~ok_sim
        ok = false;
        if throw_error, error_message(mess), else, return, end
    end
end

% Now simulate the data
xye = cellfun(@isstruct, obj.w_);
f_pass_caller = obj.wrapfun_.f_pass_caller;
bf_pass_caller = obj.wrapfun_.bf_pass_caller;

selected = obj.options_.selected;
if selected
    % Get wrapped functions and parameters after performing initialisation if required
    [ok, mess, fun_wrap, pin_wrap, bfun_wrap, bpin_wrap] = ...
        wrap_functions_and_parameters (obj.wrapfun_, wmask, obj.fun_, obj.pin_, obj.bfun_, obj.bpin_);
    if ~ok
        if throw_error, error_message(mess), else, return, end
    end

    % Now compute output
    wout = multifit_func_eval (wmask, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
        f_pass_caller, bf_pass_caller, pfin, p_info, output_type);
    squeeze_xye = obj.options_.squeeze_xye;
    if ~opt.components
        data_out = repackage_output_datasets (obj.data_, wout, msk_out, squeeze_xye);
    else
        data_out.sum  = repackage_output_datasets (obj.data_, wout.sum,  msk_out, squeeze_xye);
        data_out.fore = repackage_output_datasets (obj.data_, wout.fore, msk_out, squeeze_xye);
        data_out.back = repackage_output_datasets (obj.data_, wout.back, msk_out, squeeze_xye);
    end

else
    % Get wrapped functions and parameters after performing initialisation if required
    [ok, mess, fun_wrap, pin_wrap, bfun_wrap, bpin_wrap] = ...
        wrap_functions_and_parameters (obj.wrapfun_, obj.w_, obj.fun_, obj.pin_, obj.bfun_, obj.bpin_);
    if ~ok
        if throw_error, error_message(mess), else, return, end
    end

    % Now compute output
    wout = multifit_func_eval (obj.w_, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
        f_pass_caller, bf_pass_caller, pfin, p_info, output_type);
    squeeze_xye = false;
    msk_none = cellfun(@(x)true(size(x)),obj.msk_,'UniformOutput',false);   % no masking
    if ~opt.components
        data_out = repackage_output_datasets (obj.data_, wout, msk_none, squeeze_xye);
    else
        data_out.sum  = repackage_output_datasets (obj.data_, wout.sum,  msk_none, squeeze_xye);
        data_out.fore = repackage_output_datasets (obj.data_, wout.fore, msk_none, squeeze_xye);
        data_out.back = repackage_output_datasets (obj.data_, wout.back, msk_none, squeeze_xye);
    end

end

% Package output fit results
nf = numel(pfin);
sig = zeros(1,nf);
cor = zeros(nf);
chisqr_red = NaN;
converged = false;
calcdata = repackage_output_parameters (pfin, sig, cor, chisqr_red, converged, p_info,...
    foreground_present, background_present);
