function obj = fit (obj)
% Perform a fit of the data using the current functions and starting parameter values
%
%   >> obj = obj.fit


% Check that there is data present
if obj.ndatatot_ == 0
    error ('No data has been provided for fitting')
end

% Check that all functions are present
if all(cellfun(@isempty,obj.fun_)) && all(cellfun(@isempty,obj.fun_))
    error ('No fit functions have been provided')
end

% Check that there are parameters and unmasked data to be fitted
[ok, mess, pfin, p_info] = ptrans_initialise_ (obj);
if ~ok,
    error_message (mess)
end

% Now fit the data
xye = cellfun(@isstruct, w);
listing = obj.options_.listing;
fcp = obj.options_.fit_control_parameters;
perform_fit = true;
[obj.pfit_, obj.sig_, obj.cor_, obj.chisqr_, obj.converged_, ok, mess] =...
    multifit_lsqr (obj.w_, xye, obj.fun_, obj.bfun_, pin, bpin, pfin, p_info, listing, fcp, perform_fit);



