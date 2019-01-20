% To set data:
%   set_data     - Set data, clearing any existing datasets
%   append_data  - Append further datasets to the current set of datasets
%   remove_data  - Remove one or more dataset(s)
%   replace_data - Replace one or more dataset(s)
%
% To mask data points:
%   set_mask     - Mask data points
%   add_mask     - Mask additional data points
%   clear_mask   - Clear masking for one or more dataset(s)
%
% To set fitting functions:
%   set_fun      - Set foreground fit functions
%   clear_fun    - Clear one or more foreground fit functions
%
%   set_bfun     - Set background fit functions
%   clear_bfun   - Clear one or more background fit functions
%
% To set initial function parameter values:
%   set_pin      - Set foreground fit function parameters
%   clear_pin    - Clear parameters for one or more foreground fit functions
%
%   set_bpin     - Set background fit function parameters
%   clear_bpin   - Clear parameters for one or more background fit functions
%
% To set which parameters are fixed or free:
%   set_free     - Set free or fix foreground function parameters
%   clear_free   - Clear all foreground parameters to be free for one or more data sets
%
%   set_bfree    - Set free or fix background function parameters
%   clear_bfree  - Clear all background parameters to be free for one or more data sets
%
% To bind parameters:
%   set_bind     - Bind foreground parameter values in fixed ratios
%   add_bind     - Add further foreground function bindings
%   clear_bind   - Clear parameter bindings for one or more foreground functions
%
%   set_bbind    - Bind background parameter values in fixed ratios
%   add_bbind    - Add further background function bindings
%   clear_bbind  - Clear parameter bindings for one or more background functions
%
% To set functions as operating globally or local to a single dataset
%   set_global_foreground - Specify that there will be a global foreground fit function
%   set_local_foreground  - Specify that there will be local foreground fit function(s)
%
%   set_global_background - Specify that there will be a global background fit function
%   set_local_background  - Specify that there will be local background fit function(s)
%
% To fit or simulate:
%   fit          - Fit data
%   simulate     - Simulate datasets at the initial parameter values
%
% Fit control parameters and other options:
%   set_options  - Set options
%   get_options  - Get values of one or more specific options
