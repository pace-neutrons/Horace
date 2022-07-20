function weight = testfunc_sqw_bcc_hfm (qh,qk,ql,en,pars)
% Spin wave dispersion relation for a Heisenberg ferromagnet with nearest
% neighbour exchange only.
%
%   >> weight = testfunc_sqw_bcc_hfm (qh,qk,ql,en,pars)
%
%   qh, qk, ql, en   Arrays of Q and energy values at which to evaluate dispersion
%   pars            [Amplitude, J*S, fwhh]

ampl=pars(1);
js=pars(2);
sig=pars(3)/sqrt(log(256));

[wdisp,sf] = testfunc_disp_bcc_hfm (qh,qk,ql,js);
weight=(ampl/(sig*sqrt(2*pi)))*sf{1}.*exp(-(en-wdisp{1}).^2/(2*sig^2));
