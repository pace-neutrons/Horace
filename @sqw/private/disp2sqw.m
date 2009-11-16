function weight = disp2sqw(qh,qk,ql,en,dispreln,pars,fwhh)
% Calculate spectral weight at a set of points given dispersion relation and spectral weight
%
%   >> weight = disp2sqw(qh,qk,ql,en,dispreln,pars,fwhh)
%
%   qh,qk,ql,en Arrays containng points at which to evaulate sqw
%
%   dispreln    Handle to function that calculates the dispersion relation w(Q) and spectrl weight, s(Q)
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

% Evaluate dispersion relation(s)
if iscell(pars)
    [e,sf]=dispreln(qh,qk,ql,pars{:});
else
    [e,sf]=dispreln(qh,qk,ql,pars);
end

if ~iscell(e)   % convert to cell array for convenience
    e={e};
    sf={sf};
end

% Accumulate weight
sig=fwhh/sqrt(log(256));
weight=zeros(numel(qh),1);
for i=1:numel(e)
    weight=weight + sf{i}(:).*exp(-(e{i}(:)-en(:)).^2/(2*sig^2))/(sig*sqrt(2*pi));
end
weight=reshape(weight,size(qh));
