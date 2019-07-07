function [wdisp,sf] = testfunc_rbmnf3_disp (qh,qk,ql,par)
% Spin wave dispersion relation for simple cubic n.n. Heisenberg antiferromagnet
%
%   >> [wdisp,sf] = rbmnf3_disp (qh qk, ql, p)
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [Seff,SJ,gap]
%                   Seff    Intensity scale factor
%                   SJ      2zSJ Exchange constant (dispersion maximum; =9.6meV for RbMnF3)
%                   gap     Gap at Bragg positions
%
% Output:
% -------
%   wdisp       Array of energies for the dispersion
%   sf          Array of spectral weights
%
% *** Spectral intensity, sf, is not correct
% *** Gap is included ad hoc

Seff=par(1);
SJ=par(2);
gap=par(3);

gamma = (cos((2*pi).*qh) + cos((2*pi).*qk) + cos((2*pi).*ql)) / 3;
wdisp = SJ*sqrt(abs(1-gamma.^2+gap^2));
sf = Seff*ones(size(wdisp));

% Fudge until get correct intensity expression
sf=sf./wdisp;
sf(~isfinite(sf))=0;    % catch singularity at Bragg points if gap==0
