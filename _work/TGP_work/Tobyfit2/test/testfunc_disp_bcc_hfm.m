function [wdisp,sf] = testfunc_disp_bcc_hfm (qh,qk,ql,js)
% Spin wave dispersion relation for a Heisenberg ferromagnet with nearest
% neighbour exchange only.
%
%   >> [wdisp,sf] = disp_bcc_hfm (qh,qk,ql,js)
%
%   qh, qk, ql      Arrays of Q values at which to evaluate dispersion
%   js              J*S (in Hamiltonian in which each pair of spins is counted once only)

wdisp{1} = (8*js)*(1-cos(pi*qh).*cos(pi*qk).*cos(pi*ql));
sf{1}=ones(size(qh));
