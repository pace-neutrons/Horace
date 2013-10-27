function [wdisp,sf] = disp_sc_hfm_testfunc(qh,qk,ql,par)
% Spin wave dispersion relation for simple cubic n.n. Heisenberg ferromagnet
%
%   >> [wdisp,sf] = disp_sc_hfm_testfunc (qh qk, ql, par)
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [Seff,SJ,gap]
%                   Seff    Intensity scale factor
%                   SJ      Exchange constant (dispersion maximum 24*SJ)
%                   gap     Gap at Bragg positions
%
% Output:
% -------
%   wdisp       Array of energies for the dispersion
%   sf          Array of spectral weights

Seff=par(1);
SJ=par(2);
gap=par(3);

wdisp{1}=gap+8*SJ*(sin(pi*qh).^2 + sin(pi*qk).^2 + sin(pi*ql).^2);
sf{1}=Seff*ones(size(wdisp));
