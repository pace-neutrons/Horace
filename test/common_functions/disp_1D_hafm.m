function [wdisp,sf]=HAF_spin_chain(qh,qk,ql,par)
% Dispersion for a 1-D Heisenberg AF spin chain along ql direction
%
%   >> [w,s] = HAF_spin_half_chain(qh,qk,ql,c,par)
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [scale,J,gap]
%                   Seff    Intensity scale factor
%                   SJ      Exchange constant (dispersion maximum 2*SJ)
%                   gap     Gap at AF position
%
% Output:
% -------
%   wdisp       Array of energies for the dispersion
%   sf          Array of spectral weights

% *** Check definition of spectral intensity, s

Seff=par(1);
SJ=par(2);
gap=par(3);

SK=0.5*gap^2/(sqrt((2*SJ)^2+gap^2)+2*SJ);

wdisp=sqrt(((2*SJ)*sin(2*pi*ql)).^2 + gap^2);
sf=Seff*(2*SJ*(1-cos(2*pi*ql))+4*SK)./wdisp;
