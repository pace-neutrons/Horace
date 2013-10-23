function [wdisp,sf] = disp_fcc_hfm_testfunc (qh,qk,ql,p)
% Spin wave dispersion relation for a bcc Heisenberg ferromagnet with nearest
% neighbour exchange only.
%
%   >> [wdisp,sf] = disp_fcc_hfm_testfunc (qh,qk,ql,p)
%
%   qh, qk, ql      Arrays of Q values at which to evaluate dispersion
%   p               parameters for dispersion relation: p=[gap,js]
%               gap     Empirical gap at magnetic zone centres
%               js      J*S in Hamiltonian in which each pair of spins is counted once only

gap=p(1);
js=p(2);
wdisp{1} = gap + (4*js)*(3-cos(pi*qh).*cos(pi*qk)-cos(pi*qk).*cos(pi*ql)-cos(pi*ql).*cos(pi*qh));
sf{1}=ones(size(qh));
