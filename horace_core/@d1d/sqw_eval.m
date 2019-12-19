function wout=sqw_eval(win,varargin)
% Calculate sqw for a model scattering function
%
%   >> wout=sqw(win,sqwfunc,p)
%
% Input:
% ------
%   win         Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc     Handle to function that calculates S(Q,w)
%               Most commonly used form is:
%                   weight = sqwfunc (qh,qk,ql,en,p)
%                where
%                   qh,qk,ql,en Arrays containing the coordinates of a set of points
%                   p           Vector of parameters needed by dispersion function 
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   weight      Array containing calculated spectral weight
%
%               More general form is:
%                   weight = sqwfunc (qh,qk,ql,en,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might want 
%                              to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name for look-up
%                              table
%
%   pars        Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%   'all'       [option] Requests that the calculated sqw be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data.
%               Applies only to input with no pixel information - it is ignored if
%              full sqw object.
%
%   'ave'       [option] Requests that the calculated sqw be computed for the
%              average values of h,k,l of the pixels in a bin, not for each
%              pixel individually. Reduces cost of expensive calculations.
%               Applies only to the case of sqw object with pixel information - it is
%              ignored if dnd type object.
%
% Output:
% -------
%   wout        Output dataset or array of datasets 

wout=dnd(sqw_eval(sqw(win),varargin{:}));
