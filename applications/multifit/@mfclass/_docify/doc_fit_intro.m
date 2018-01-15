% Header to fit method
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%       extra_header = '#1'
%       extra_body   = '#2'
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Perform a fit of the data using the current functions and parameter values
%
% Return calculated fitted datasets and parameters:
%   >> [data_out, fitdata] = obj.fit                    % if ok false, throws error
%
% Return the calculated fitted signal, foreground and background in a structure:
%   >> [data_out, fitdata] = obj.fit ('components')     % if ok false, throws error
%
% Continue execution even if an error condition is thrown:
%   >> [data_out, fitdata, ok, mess] = obj.fit (...)    % if ok false, still returns
%
% If the results of a previous fit are available, with the same number of foreground
% and background functions and parameters, then the fit parameter structure can be
% passed as the first argument as the initial values at which to satart the fit:
%   >> [data_out, fitdata] = obj.fit (...)
%               :
%   >> [...] = obj.fit (fitdata, ...)
%
% (This is useful if you want to re-fit starting with the results of an earlier fit)
%
%   <#file:> <extra_header>
%
% Output:
% -------
%  data_out Output with same form as input data but with y values evaluated
%           at the final fit parameter values. If the input was three separate
%           x,y,e arrays, then only the calculated y values are returned.
%           If there was a problem i.e. ok==false, then data_out=[].
%
%           If option 'components' was given, then data_out is a structure with fields
%           with the same format as above, as follows:
%               data_out.sum        Sum of foreground and background
%               data_out.fore       Foreground calculation
%               data_out.back       Background calculation
%           If there was a problem i.e. ok==false, then each field is =[].
%
%   fitdata Structure with result of the fit for each dataset. The fields are:
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
%           If there was a problem i.e. ok==false, then fitdata=[].
%
%   ok      True: A fit coould be performed. This includes the cases of
%                 both convergence and failure to converge
%           False: Fundamental problem with the input arguments e.g. the
%                 number of free parameters equals or exceeds the number
%                 of data points
%
%   mess    Message if ok==false; Empty string if ok==true.
%
% If ok is not a return argument, then if ok is false an error will be thrown.
%   <#file:> <extra_body>
% <#doc_end:>
% -----------------------------------------------------------------------------
