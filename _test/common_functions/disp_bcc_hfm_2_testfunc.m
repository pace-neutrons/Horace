function [wdisp,sf] = disp_bcc_hfm_2_testfunc (qh,qk,ql,par)
% Spin wave dispersion relation for bcc n.n. Heisenberg ferromagnet and with a false optic branch
%
%   >> [wdisp,sf] = disp_bcc_hfm_2 (qh,qk,ql,par)
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [Seff,SJ,gap,optic]
%                   Seff    Intensity scale factor
%                   SJ      Exchange constant (dispersion maximum 24*SJ)
%                   gap     Gap at Bragg positions
%                   optic   Gap for a fake optic mode in addition to parameter gap above
%
% Output:
% -------
%   wdisp       Array of energies for the dispersion
%   sf          Array of spectral weights

Seff=par(1);
SJ=par(2);
gap=par(3);
optic=par(4);

wdisp{1} = gap + (8*SJ)*(1-cos(pi*qh).*cos(pi*qk).*cos(pi*ql));
wdisp{2} = gap + (8*js)*(1-cos(pi*qh).*cos(pi*qk).*cos(pi*ql)) + optic;
sf{1}=Seff*ones(size(qh));
sf{2}=(0.5*Seff)*ones(size(qh));
