function weight = testfunc_sqw_van (qh,qk,ql,en,pars)
% Dispersionless mode at non-zero energy en0
%
%   >> weight = testfunc_sqw_van (qh,qk,ql,en,pars)
%
%   qh, qk, ql, en   Arrays of Q and energy values at which to evaluate dispersion
%   pars            [Amplitude, en0, fwhh]

ampl=pars(1);
en0=pars(2);
sig=pars(3)/sqrt(log(256));

weight=(ampl/(sig*sqrt(2*pi)))*exp(-(en-en0).^2/(2*sig^2));
