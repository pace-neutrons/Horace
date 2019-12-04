function [wdisp,sf] = disp_fcc_hfm(qh,qk,ql,par)
% Spin wave dispersion relation for face centred cubic Heisenberg ferromagnet
%
%   >> [wdisp,sf] = disp_fccc_hfm (qh qk, ql, par)
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [Seff, gap, JS_p5p50, JS_100, JS_1p5p5, JS_110]
%                   Seff        Intensity scale factor
%                   gap         Gap at zone centre
%                   JS_p5p50    First neighbour exchange constant
%                   JS_100      Second neighbour exchange constant
%                   JS_1p5p5    Third neighbour exchange constant
%                   JS_110      Fourth neighbour exchange constant
%
%              Note: each pair of spins in the Hamiltonian appears only once
% Output:
% -------
%   wdisp       Array of energies for the dispersion
%   sf          Array of spectral weights

Seff=par(1);
gap=par(2);
JS_p5p50=par(3);
JS_100=par(4);
JS_1p5p5=par(5);
JS_110=par(6);

w=gap*ones(size(qh));

% Precompute some arrays used in more than one exchange pathway
if JS_p5p50~=0 || JS_1p5p5
    cos1h = cos(pi*qh);
    cos1k = cos(pi*qk);
    cos1l = cos(pi*ql);
end

if JS_1p5p5~=0 || JS_110~=0
    cos2h = cos((2*pi)*qh);
    cos2k = cos((2*pi)*qk);
    cos2l = cos((2*pi)*ql);
end

% 1st nn
if JS_p5p50~=0
    w = w + (4*JS_p5p50)*(3 - cos1h.*cos1k - cos1k.*cos1l - cos1l.*cos1h);
end

% 2nd nn
if JS_100~=0
    w = w + (4*JS_100)*(sin(pi*qh).^2 + sin(pi*qk).^2 + sin(pi*ql).^2);
end

% 3rd nn
if JS_1p5p5~=0
    w = w + (8*JS_1p5p5)*(3 - cos2h.*cos1k.*cos1l - cos2k.*cos1l.*cos1h...
        - cos2l.*cos1h.*cos1k);
end

% 4th nn
if JS_110~=0
    w = w + (4*JS_110)*(3 - cos2h.*cos2k - cos2k.*cos2l - cos2l.*cos2h);
end

wdisp{1} = w;
sf{1} = (Seff/2)*ones(size(w));
