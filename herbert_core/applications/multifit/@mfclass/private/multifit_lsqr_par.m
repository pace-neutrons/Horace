function [p_best,sig,cor,chisqr_red,converged]=multifit_lsqr_par(w,xye,func,bfunc,pin,bpin,...
    f_pass_caller_info,bf_pass_caller_info,pfin,p_info,listing,fcp,perform_fit,nWorkers)
% Perform least-squares minimisation
%
%   >> [p_best,sig,cor,chisqr_red,converged]=...
%       multifit_lsqr_par(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing)
%
%   >> [p_best,sig,cor,chisqr_red,converged]=...
%       multifit_lsqr_par(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing,fcp)
%
%   >> [p_best,sig,cor,chisqr_red,converged]=...
%       multifit_lsqr_par(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing,fcp,perform_fit)
%
%   >> [p_best,sig,cor,chisqr_red,converged]=...
%       multifit_lsqr_par(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing,fcp,perform_fit,nWorkers)
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
%   listing     Control diagnostic output to the screen [Unused, here for compatibility]
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
%   nWorkers    Integer number of parallel workers to use. [Default: 1]
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
%               The first call from multifit_lsqr_par it will be set to [].
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
%
% ---------------------------------------------------------------------------------------
% History
% ---------------------------------------------------------------------------------------
%
% J. Wilkins  Jan 2021:
% ------------------------
% Initial development of parallel version
% Developed based on T.G.Perring's multifit_lsqr
%
% Previous history:
% -----------------
% Version 3.beta
% Levenberg-Marquardt nonlinear regression of f(x,p) to y(x)
% Richard I. Shrager (301)-496-1122
% Modified by A.Jutan (519)-679-2111
% Modified by Ray Muzic 14-Jul-1992

p = inputParser();
addOptional(p, 'fcp', [0.0001, 20, 0.001], @(n)(validateattributes(n,{'numeric'},{'vector','numel',3})));
addOptional(p, 'perform_fit', 1, @islognumscalar);
addOptional(p, 'nWorkers', 1, @isnumeric);
parse(p,fcp,perform_fit,nWorkers);

fcp = p.Results.fcp;
perform_fit = p.Results.perform_fit;

if abs(fcp(1))<1e-12
    error('HERBERT:mfclass:multifit_lsqr',...
        'Derivative step length must be greater than or equal 10^-12')
end
if fcp(2)<0
    error('HERBERT:mfclass:multifit_lsqr','Number of iterations must be >=0')
end

jd = JobDispatcher('ParallelMF');

% Allow splitting of bins if not averaged or dnd
pars = arrayfun(@(x) x.plist, pin, 'UniformOutput', false);
while any(cellfun(@iscell,pars)) % Flatten pars
    pars = [pars{cellfun(@iscell,pars)} pars(~cellfun(@iscell,pars))];
end

split_bins = any(cellfun(@(x) strcmp(x, '-ave'), pars)) || ...
    any(cellfun(@(x) isa(x, 'dndbase'), w));

% Potential issues follow if parallelism is used
% Special casing for Tobyfit where arguments need to be distributed
% as well as data. If functions require arguments distributing
% these will fail in parallel

tmp = cellfun(@functions, func);
if any(arrayfun(@(x) startsWith(x.function, 'tobyfit'), tmp))
    [loop_data, merge_data] = ...
        split_data(w, xye, [], [], nWorkers, split_bins, arrayfun(@(x)(x.plist{3}), pin, 'UniformOutput', false));
else
    [loop_data, merge_data] = split_data(w, xye, [], [], nWorkers, split_bins);
end

common_data = struct('func', {func}, ...
    'bfunc', {bfunc}, ...
    'pin', {pin}, ...
    'bpin', {bpin}, ...
    'f_pass_caller_info', {f_pass_caller_info}, ...
    'bf_pass_caller_info', {bf_pass_caller_info}, ...
    'p_info', {p_info}, ...
    'fcp', {fcp}, ...
    'merge_data', {merge_data}, ...
    'perform_fit', {perform_fit});
common_data.p = pfin;

[outputs, n_failed] = jd.start_job('MFParallel_Job', common_data, loop_data, true, nWorkers);

if n_failed
    jd.display_fail_job_results(outputs,n_failed,nWorkers)
    error('HERBERT:multifit_lsqr_par:parallel_error', ...
        'Error in MFParallel_Job, please see report')
else
    [p_best, sig, cor, chisqr_red, converged] = map_back(outputs{1});
end

end

function varargout = map_back(output)
fn = fieldnames(output);
nfn = numel(fn);
varargout = cell(nfn,1);
for i=1:nfn
    varargout{i} = output.(fn{i});
end
end

function [loop_data, merge_data] = split_data(w, xye, S, Store, nWorkers, split_bins, tobyfit)
% Split up sqws and divvy xyes in w

loop_data = cell(nWorkers, 1);
merge_data = arrayfun(@(x) struct('nelem', [], 'nomerge', []), zeros(numel(w), nWorkers));

for i=1:nWorkers
    loop_data{i} = struct('w', {cell(numel(w),1)}, 'xye', xye, 'S', S, 'Store', Store);
end

if ~all(cellfun(@(x) isa(x, 'SQWDnDBase') || isa(x, 'IX_dataset'), w) | xye)
    error('HERBERT:split_data:invalid_argument', ...
          'Unrecognised type: %s, data must be of type struct, SQWDnDBase or IX_dataset.', class(w{i}))
end


for i=1:numel(w)
    [data, md] = distribute(w{i}, nWorkers, split_bins);

    for j = 1:numel(md)
        merge_data(i,j).nelem = md(j).nelem;
        merge_data(i,j).nomerge = md(j).nomerge;
        merge_data(i,j).range = md(j).range;
        merge_data(i,j).pix_range = md(j).pix_range;
    end

    for j=1:nWorkers
        loop_data{j}.w{i} = data(j);
    end

end

if exist('tobyfit', 'var')
    a = RandStream.getGlobalStream();
    for i=1:nWorkers
        loop_data{i}.tobyfit_data = tobyfit;
        loop_data{i}.rng = a;
        for k = 1:numel(tobyfit)
            for j = 1:numel(tobyfit{k}.kf)

                pr = merge_data(j,i).pix_range;
                loop_data{i}.tobyfit_data{k}.kf{j}     = tobyfit{k}.kf{j}(pr(1):pr(2));
                loop_data{i}.tobyfit_data{k}.dt{j}     = tobyfit{k}.dt{j}(pr(1):pr(2));
                loop_data{i}.tobyfit_data{k}.dq_mat{j} = tobyfit{k}.dq_mat{j}(:,:,pr(1):pr(2));
                for l=1:4
                    loop_data{i}.tobyfit_data{k}.qw{j}{l} = tobyfit{k}.qw{j}{l}(pr(1):pr(2));
                end
            end
        end
    end
end
end
