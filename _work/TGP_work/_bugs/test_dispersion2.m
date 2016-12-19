function [wdisp,weight] = test_dispersion2 (qh,qk,ql,p)
% Spin waves for a Heisenberg ferromagnet with nearest
% neighbour exchange only - two modes, rigidly displaced.
% Spectral weight just some function that varies for testing purposes.
%
%   >> weight = test_dispersion (qh,qk,ql,p)
%
%   p   [JS, gap]
%
js=p(1);
gap=p(2);
wdisp1 = (8*js)*(1-cos(pi*qh).*cos(pi*qk).*cos(pi*ql));
wdisp2 = wdisp1 + abs(gap);

wdisp={wdisp1,wdisp2};
weight={sqrt(1+wdisp1),(32*js)./sqrt(wdisp2)};
