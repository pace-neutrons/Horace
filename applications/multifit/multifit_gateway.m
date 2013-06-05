function [ok,mess,varargout] = multifit_gateway (varargin)
% Gateway function to multifit_main
%
%   >> [ok,mess,wout,fitdata] = multifit_gateway (...)
%
% Input:
% ------
%   ...         Arguments as they would be passed to multifit
%
% Output:
% -------
%   ok          True if all ok, false if there was a problem during fitting
%              for example the fit did not converge.
%
%   mess        Character string containing error message if ~ok; '' if ok
%
%   wout        Array or cell array of the objects evaluated at the fitted parameter
%              values Has the same form as the input data.
%               If x,y,e data were given as the input data as three separate
%              arrays, only ycalc is returned.
%               If there was a problem i.e. ok==false, wout=[]
%
%   fitdata     Structure with result of the fit for each dataset. The fields are:
%               p      - Best fit foreground function parameter values
%                          If only one function, a row vector
%                          If more than one function: a row cell array of row vectors
%               sig    - Estimated errors of foreground parameters (=0 for fixed parameters)
%                          If only one function, a row vector
%                          If more than one function: a row cell array of row vectors
%               bp     - Background parameter values
%                          If only one function, a row vector
%                          If more than one function: a row cell array of row vectors
%               bsig   - Estimated errors of background (=0 for fixed parameters)
%                          If only one function, a row vector
%                          If more than one function: a row cell array of row vectors
%               corr   - Correlation matrix for free parameters
%               chisq  - Reduced Chi^2 of fit i.e. divided by:
%                           (no. of data points) - (no. free parameters))
%               pnames - Foreground parameter names
%                          If only one function, a cell array (row vector) of names
%                          If more than one function: a row cell array of row vector cell arrays
%               bpnames- Background parameter names
%                          If only one function, a cell array (row vector) of names
%                          If more than one function: a row cell array of row vector cell arrays


[ok,mess,parsing,output]=multifit_main(varargin{:},'noparsefunc_');
nout=nargout-2;
varargout(1:nout)=output(1:nout);   % appears towork even if nout<=0
