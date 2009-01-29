function weight = test_sqw_model (qh,qk,ql,en,p)
% Spin waves for a Heisenberg ferromagnet with nearest
% neighbour exchange only - two modes, rigidly displaced
% Lorentzian broadening
%
%   >> weight = test_sqw (qh,qk,ql,en,p)
%
%   p   [scale, JS, gap, gamma]
%
scale=p(1);
js=p(2);
gap=p(3);
gam=p(4);
wdisp1 = (8*js)*(1-cos(pi*qh).*cos(pi*qk).*cos(pi*ql));
wdisp2 = wdisp1 + gap;

weight = (scale*(gam/pi))*(1./((en-wdisp1).^2+gam^2) + 1./((en-wdisp2).^2+gam^2));
