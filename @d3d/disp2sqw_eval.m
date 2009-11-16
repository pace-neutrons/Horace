function wout=disp2sqw_eval(win,varargin)
% Calculate sqw for a model scattering function
%
%   >> wout = disp2sqw_eval(win,dispreln,pars,fwhh,opt)
%
%   win         Dataset that provides the axes and points for the calculation
%
%   dispreln    Handle to function that calculates the dispersion relation w(Q) and
%              spectral weight, s(Q)
%              Must have form:
%                   [w,s] = dispreln (qh,qk,ql,p)
%               where
%                   qh,qk,ql    Arrays containing the coordinates of a set of points
%                              in reciprocal lattice units
%                   p           Vector of parameters needed by dispersion function 
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   w           Array of corresponding energies, or, if more than
%                              one dispersion relation, a cell array of arrays.
%
%              More general form is:
%                   [w,s] = dispreln (qh,qk,ql,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might want 
%                              to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name for look-up
%                              table.
%
%   pars        Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%   fwhh        Full-width half-height of Gaussian broadening to dispersion relation(s)
%
%   'all'       [option] Requests that the calculated sqw be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data.
%               Applies only to input with no pixel information - it is ignored if
%              full sqw object.
%
% Output:
% =======
%   wout        Output dataset or array of datasets 

wout=dnd(disp2sqw_eval(sqw(win),varargin{:}));
