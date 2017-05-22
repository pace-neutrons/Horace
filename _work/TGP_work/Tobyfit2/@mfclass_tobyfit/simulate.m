function [data_out, calcdata, ok, mess] = simulate (obj, varargin)
% Perform a simulation of the data using the current functions and starting parameter values
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

% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_simulate_intro = fullfile(mfclass_doc,'doc_simulate_intro.m')
% <#doc_beg:> multifit
%   <#file:> <doc_simulate_intro>
% <#doc_end:>
% -----------------------------------------------------------------------------

% Check there is data
data = obj.data;
if isempty(data)
    error('No data sets have been set - nothing to simulate')
end

% Update parameter wrapping
obj_tmp = obj;
obj_tmp.wrapfun.p_wrap = append_args (obj_tmp.wrapfun.p_wrap, obj.mc_contributions, obj.mc_points, [], []);

% Perform simulation
[data_out, calcdata, ok, mess] = simulate@mfclass (obj_tmp, varargin{:});
