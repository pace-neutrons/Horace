function [data_out, calcdata] = simulate (obj, varargin)
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


% Default return values if there is an error
data_out = [];

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
[wmask, msk_out] = mask_data_for_fit (obj.w_, obj.msk_);

% Check that the parameters are OK, and for chisqr calculation that the data is fittable
[ok_sim, ~, mess, pfin, p_info] = ptrans_initialise_ (obj);
if ~ok_sim
    error("HERBERT:mfclass:bad_ptrans_init", mess)
end

% Allow for the case of input argument over-riding parameter values for simulation
if numel(args)==1
    pfin = ptrans_par_inverse(args{1}, p_info);
end

% Now simulate the data
xye = cellfun(@isstruct, obj.w_);
f_pass_caller = obj.wrapfun_.f_pass_caller;
bf_pass_caller = obj.wrapfun_.bf_pass_caller;

selected = obj.options_.selected;

pm = get(hpc_config, 'parallel_multifit');
if selected
    % Get wrapped functions and parameters after performing initialisation if required
    [fun_wrap, pin_wrap, bfun_wrap, bpin_wrap] = ...
        wrap_functions_and_parameters (obj.wrapfun_, wmask, obj.fun_, obj.pin_, obj.bfun_, obj.bpin_);

    % Now compute output

    if (pm)
        wout = parallel_call(@multifit_func_eval, ...
                             {wmask, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap, ...
                              f_pass_caller, bf_pass_caller, pfin, p_info, output_type});
    else
        wout = multifit_func_eval (wmask, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
                                   f_pass_caller, bf_pass_caller, pfin, p_info, output_type);
    end
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
    [fun_wrap, pin_wrap, bfun_wrap, bpin_wrap] = ...
        wrap_functions_and_parameters (obj.wrapfun_, obj.w_, obj.fun_, obj.pin_, obj.bfun_, obj.bpin_);

    % Now compute output
    if (pm)
        wout = parallel_call(@multifit_func_eval, ...
                             {obj.w_, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap, ...
                              f_pass_caller, bf_pass_caller, pfin, p_info, output_type});
    else
        wout = multifit_func_eval (obj.w_, xye, fun_wrap, bfun_wrap, pin_wrap, bpin_wrap,...
                                   f_pass_caller, bf_pass_caller, pfin, p_info, output_type);
    end
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

end
