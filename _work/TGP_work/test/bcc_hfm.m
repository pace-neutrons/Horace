function wdisp = bcc_hfm (qh,qk,ql,js)
% Spin wave dispersion relation for a Heisenberg ferromagnet with nearest
% neighbour exchange only.
wdisp = (8*js)*(1-cos(pi*qh).*cos(pi*qk).*cos(pi*ql));
