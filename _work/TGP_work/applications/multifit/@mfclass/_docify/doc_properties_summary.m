% Data to be fitted:
%   data         - datasets to be fitted or simulated
%   mask         - mask arrays to remove data points from fitting or simulation
%
% Fit functions:
%   fun          - foreground fit function handles
%   pin          - foreground function parameter values
%   free         - the foreground function parameters that can vary in a fit
%   bind         - binding of foreground parameters to free parameters
%
%   bfun         - foreground fit function handles
%   bpin         - foreground function parameter values
%   bfree        - the foreground function parameters that can vary in a fit
%   bbind        - binding of foreground parameters to free parameters
%
% To set functions as operating globally or local to a single dataset
%   global_foreground - true if a global foreground fit function
%   local_foreground  - true if a local foreground fit functions
%   global_background - true if a global background fit function
%   local_background  - true if a local background fit function(s)
%
% Options:
%   options      - options defining fit control parameters
