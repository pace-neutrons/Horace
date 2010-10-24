function wout=disp2sqw_eval(win,dispreln,pars,fwhh,opt)
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
%   'ave'       [option] Requests that the calculated sqw be computed for the
%              average values of h,k,l of the pixels in a bin, not for each
%              pixel individually. Reduces cost of expensive calculations.
%               Applies only to the case of sqw object with pixel information - it is
%              ignored if dnd type object.
%
% Output:
% =======
%   wout        Output dataset or array of datasets 

% Essentially an interface to sqw_eval that looks after broadening the dispersion
if nargin==4
    wout=sqw_eval(win,@disp2sqw,{dispreln,pars,fwhh});
elseif nargin==5
    wout=sqw_eval(win,@disp2sqw,{dispreln,pars,fwhh},opt);
else
    error('Check number of arguments')
end
