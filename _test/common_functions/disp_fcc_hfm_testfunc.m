function [wdisp,sf] = disp_fcc_hfm_testfunc (qh,qk,ql,par)
% Spin wave dispersion relation for fcc n.n. Heisenberg ferromagnet
%
%   >> [wdisp,sf] = disp_fcc_hfm_testfunc (qh,qk,ql,par)
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

wdisp{1} = gap + (4*SJ)*(3-cos(pi*qh).*cos(pi*qk)-cos(pi*qk).*cos(pi*ql)-cos(pi*ql).*cos(pi*qh));
sf{1}=Seff*ones(size(qh));
