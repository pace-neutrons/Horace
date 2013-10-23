function [wdisp,sf] = disp_bcc_hfm_2_testfunc (qh,qk,ql,p)
% Spin wave dispersion relation for a Heisenberg ferromagnet with nearest
% neighbour exchange only, with a fake optic branch for testing purposes
%
%   >> [wdisp,sf] = disp_bcc_hfm_2 (qh,qk,ql,js)
%
%   qh, qk, ql      Arrays of Q values at which to evaluate dispersion
%   p               parameters for dispersion relation: p=[gap,js,optic]
%               gap     Empirical gap at magnetic zone centres
%               js      J*S in Hamiltonian in which each pair of spins is counted once only
%               optic   Gap for a fake optic mode

gap=p(1);
js=p(2);
optic=p(3);
wdisp{1} = gap + (8*js)*(1-cos(pi*qh).*cos(pi*qk).*cos(pi*ql));
wdisp{2} = gap + (8*js)*(1-cos(pi*qh).*cos(pi*qk).*cos(pi*ql)) + optic;
sf{1}=ones(size(qh));
sf{2}=0.5*ones(size(qh));
