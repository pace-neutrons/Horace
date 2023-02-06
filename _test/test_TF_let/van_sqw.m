function weight = van_sqw (qh,qk,ql,en,pars)
% Dispersionless mode at non-zero energy en0 approximated as a Gaussian in energy
%
%   >> weight = van_sqw (qh,qk,ql,en,pars)
%
% Input:
% ------
%   qh, qk, ql, en  Arrays of Q and energy values at which to evaluate dispersion
%   pars            [Amplitude, en0, fwhh] - the area, centre at FWHH of a
%                   dispersionless mode
% Output:
% -------
%   weight          Spectral weight

ampl=pars(1);
en0=pars(2);
sig=pars(3)/sqrt(log(256));

weight=(ampl/(sig*sqrt(2*pi)))*exp(-(en-en0).^2/(2*sig^2));
