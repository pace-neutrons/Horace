function [wdisp,sf] = disp_sc_hfm(qh,qk,ql,par)
% Spin wave dispersion relation for simple cubic Heisenberg ferromagnet
%
%   >> [wdisp,sf] = disp_sc_hfm (qh qk, ql, par)
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [Seff, gap, JS_100, JS_110, JS_111, JS_200]
%                   Seff    Intensity scale factor
%                   gap     Gap at zone centre
%                   JS_100  First neighbour exchange constant
%                           (If dispersion maximum 12*JS_100)
%                   JS_110  Second neighbour exchange constant
%                   JS_111  Third neighbour exchange constant
%                   JS_200  Fourth neighbour exchange constant
%
%              Note: each pair of spins in the Hamiltonian appears only once
% Output:
% -------
%   wdisp       Array of energies for the dispersion
%   sf          Array of spectral weights

Seff=par(1);
gap=par(2);
JS_100=par(3);
JS_110=par(4);
JS_111=par(5);
JS_200=par(6);

w=gap*ones(size(qh));

% Precompute some arrays used in more than one exchange pathway
if JS_110~=0 || JS_111~=0
    cos2h = cos((2*pi)*qh);
    cos2k = cos((2*pi)*qk);
    cos2l = cos((2*pi)*ql);
end

if JS_100~=0
    w = w + (4*JS_100)*(sin(pi*qh).^2 + sin(pi*qk).^2 + sin(pi*ql).^2);
end

if JS_110~=0
    w = w + (4*JS_110)*(3 - cos2h.*cos2k - cos2k.*cos2l - cos2l.*cos2h);
end

if JS_111~=0
    w = w + (8*JS_111)*(1-cos2h.*cos2k.*cos2l);
end

if JS_200~=0
    w = w + (4*JS_200)*(sin((2*pi)*qh).^2 + sin((2*pi)*qk).^2 + sin((2*pi)*ql).^2);
end

wdisp{1} = w;
sf{1} = (Seff/2)*ones(size(w));
