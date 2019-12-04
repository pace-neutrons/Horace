function [wdisp,sf] = disp_bcc_hfm(qh,qk,ql,par)
% Spin wave dispersion relation for body centred cubic Heisenberg ferromagnet
%
%   >> [wdisp,sf] = disp_bcc_hfm (qh qk, ql, par)
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [Seff, gap, JS_p5p5p5, JS_100, JS_110, JS_3p5p5p5, JS_111]
%                   Seff        Intensity scale factor
%                   gap         Gap at zone centre
%                   JS_p5p5p5   First neighbour exchange constant
%                   JS_100      Second neighbour exchange constant
%                   JS_110      Third neighbour exchange constant
%                   JS_3p5p5p5  Fourth neighbour exchange constant
%                   JS_111      Fifth neighbour exchange constant
%
%              Note: each pair of spins in the Hamiltonian appears only once
% Output:
% -------
%   wdisp       Array of energies for the dispersion
%   sf          Array of spectral weights

Seff=par(1);
gap=par(2);
JS_p5p5p5=par(3);
JS_100=par(4);
JS_110=par(5);
JS_3p5p5p5=par(6);
JS_111=par(7);

w=gap*ones(size(qh));

% Precompute some arrays used in more than one exchange pathway
if JS_p5p5p5~=0 || JS_3p5p5p5~=0
    cos1h = cos(pi*qh);
    cos1k = cos(pi*qk);
    cos1l = cos(pi*ql);
end
if JS_110~=0 || JS_111~=0
    cos2h = cos((2*pi)*qh);
    cos2k = cos((2*pi)*qk);
    cos2l = cos((2*pi)*ql);
end

% Contributions to dispersion
if JS_p5p5p5~=0
    w = w + (8*JS_p5p5p5)*(1-cos1h.*cos1k.*cos1l);
end

if JS_100~=0
    w = w + (4*JS_100)*(sin(pi*qh).^2 + sin(pi*qk).^2 + sin(pi*ql).^2);
end

if JS_110~=0
    w = w + (4*JS_110)*(3 - cos2h.*cos2k - cos2k.*cos2l - cos2l.*cos2h);
end

if JS_3p5p5p5~=0
    cos3h = cos((3*pi)*qh);
    cos3k = cos((3*pi)*qk);
    cos3l = cos((3*pi)*ql);
    w = w + (8*JS_3p5p5p5)*(3 - cos3h.*cos1k.*cos1l - cos3k.*cos1l.*cos1h...
        - cos3l.*cos1h.*cos1k);
end

if JS_111~=0
    w = w + (8*JS_111)*(1-cos2h.*cos2k.*cos2l);
end

wdisp{1} = w;
sf{1} = (Seff/2)*ones(size(w));
