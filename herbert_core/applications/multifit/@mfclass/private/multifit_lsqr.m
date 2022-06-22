function [p_best,sig,cor,chisqr_red,converged]=multifit_lsqr(w,xye,func,bfunc,pin,bpin,...
    f_pass_caller_info,bf_pass_caller_info,pfin,p_info,listing,fcp,perform_fit)
% Perform least-squares minimisation
% now handled by either multifit_lsqr_par or multifit_lsqr_ser
% depending on parallelisation options
%
%   >> [p_best,sig,cor,chisqr_red,converged]=...
%       multifit_lsqr(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing)
%
%   >> [p_best,sig,cor,chisqr_red,converged]=...
%       multifit_lsqr(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing,fcp)
%
%   >> [p_best,sig,cor,chisqr_red,converged]=...
%       multifit_lsqr(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing,fcp,perform_fit)
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
%   pin         Array of valid parameter lists, one list per foreground function,
%              with the initial parameter values at the lowest level.
%
%   bin         Array of valid parameter lists, one list per background function,
%              with the initial parameter values at the lowest level.
%
%   f_pass_caller_info  Determines the form of the foreground fit function argument lists:
%               If false:
%                   wout = my_func (win, @fun, plist, c1, c2, ...)
%               If true:
%                   [wout, state_out, store_out] = my_func (win, caller,...
%                           state_in, store_in, @fun, plist, c1, c2, ...)
%
%               For details of these two forms, see 'Notes on format of fit functions'
%               below.
%
%   bf_pass_caller_info Determines the form of the background fit function argument lists:
%               See f_pass_caller_info, and 'Notes on format of fit functions' below.
%
%   pf          Free parameter initial values (that is, the independently
%              varying parameters)
%
%   p_info      Structure with information needed to transform from pf to the
%              parameter values needed for function evaluation
%
%   listing     Control diagnostic output to the screen:
%               =0 for no printing to command window
%               =1 prints iteration summary to command window
%               =2 additionally prints parameter values at each iteration
%               =3 additionally lists which datasets were computed for the
%                  foreground and background functions. Diagnostic tool.
%
%   fcp         Fit control parameters:
%           fcp(1)  Relative step length for calculation of partial derivatives
%                   [Default: 1e-4]
%           fcp(2)  Maximum number of iterations [Default: 20]
%           fcp(3)  Stopping criterion: relative change in chi-squared
%                   i.e. stops if (chisqr_new-chisqr_old) < fcp(3)*chisqr_old
%                   [Default: 1e-3]
%
%   perform_fit Logical scalar = true if a fit is required, =false if
%              just need the value of chisqr. [Default: True]
%
%
% Output:
% -------
%   p_best      Column vector of final fit parameters - only for the
%              independently varying parameters.
%
%   sig         Column vector of estimated standard deviations
%
%   cor         Correlation matrix for the free parameters
%
%   chisqr_red  Reduced chi-squared at final fit parameters
%
%   converged   True if fit converged; false if not.
%
% Note that for the final fit parameters to be reliable, test that
% (ok && converged) is true.
%
%
% ---------------------------------------------------------------------------------------
% Notes on format of fit functions
% ---------------------------------------------------------------------------------------
%
% Certain syntax and rules of behaviour are required of the fit functions.
%
% If caller information is not required by the function (i.e. f_pass_caller_info or
% bf_pass_caller_info are false for the foreground and foreground functions, respectively):
%
%   >> wout = my_func (win, @fun, plist, c1, c2, ...)
%
% If caller information is required, either to index into lookup information
% or to interpret stored internal state information:
%
%   >> [wout, state_out, store_out] = my_func (win, caller, state_in, store_in,...
%                                                       @fun, plist, c1, c2, ...)
%
% where:
%   caller      Stucture that contains information from the caller routine. Fields
%                   reset_state     Logical scalar:
%                                   If true: then for each element of win the
%                                  internal state of my_func needs to be reset
%                                  to the corresponding value in state_in (see
%                                  below).
%                                   If false: the internal state required to
%                                  reproduce the same calculated output must be
%                                  returned in the corresponding element of state_out
%                                  (see below).
%                   ind             Indicies of data sets in the full set of data
%                                  sets that are being fitted. The number of elements
%                                  of ind must match the number of elements of win
%
%               reset_state should be used if the output of my_func depends on the
%              internal state of my_func e.g. the value of seeds for random number
%              generators.
%
%               The index array ind is useful if, for example, some lookup tables
%              have been created for the full set of data sets, and for which
%              the actual index or indicies are needed inside my_func to be
%              able to get to the relevant lookup table(s).
%
%   state_in    Cell array containing previously saved internal states for each
%              element of win. This is information that can be used to reset the
%              internal state (e.g. random number generators) so that calculations
%              can be reproduced exactly for the same input parameters in plist.
%               The number of elements must match the number of elements in win.
%               The case of an empty state i.e. isempty(state_in{i}) is the
%              case of no stored state. Appropriate default behaviour must be
%              implemented; this will be the case on the initial call from
%              mutlifit_lsqr.
%               If the internal state is not needed, then reset_state and state_in
%              can be ignored.
%
%   store_in    Stored information that could be used in the function evaluation,
%              for example lookup tables that accumulate. This should be
%              different from the state: the values of store should not affect
%              the values of the calculated function, only the speed at which the
%              values are calculated.
%               The first call from multifit_lsqr it will be set to [].
%               If no storage is needed, then it can be ignored.
%
%   state_out   Cell array containing internal states to be saved for a future call.
%               The number of elements must match the number of elements in win.
%               If the internal state is not needed, then state_out can be set
%              to cell(size(win)) - but it must be set to a cell array with
%              the same nmber of elements as win.
%
%   store_out   Updated stored values. Must always be returned, but can be
%              set to [] if not used.
%
%
%   Typical code fragment could be:
%
%   function [wout, state_out, store_out] = my_func (win, caller, state_in, store_in,...
%                                                       @fun, plist, c1, c2, ...)
%       :
%   state_out = cell(size(win));    % create output argument
%       :
%   ind = caller.ind;
%   for i=1:numel(ind)
%       iw=ind(i);                  % index of workspace into lookup tables
%       % Set random number generator if necessary, and save if required for later
%       if reset_state
%           if ~isempty(state_in{i})
%               rng(state_in{i})
%           end
%       else
%           state_out{i} = rng;     % capture the random number generator state
%       end
%        :
%   end

hc = hpc_config;

if hc.parallel_multifit
    [p_best,sig,cor,chisqr_red,converged] = multifit_lsqr_par(w,xye,func,bfunc,pin,bpin,...
        f_pass_caller_info,bf_pass_caller_info,...
        pfin,p_info,listing,fcp,perform_fit, hc.parallel_workers_number);
else
    [p_best,sig,cor,chisqr_red,converged] = multifit_lsqr_ser(w,xye,func,bfunc,pin,bpin,...
        f_pass_caller_info,bf_pass_caller_info,...
        pfin,p_info,listing,fcp,perform_fit);
end

end
