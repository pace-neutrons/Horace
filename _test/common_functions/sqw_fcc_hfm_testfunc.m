function weight = sqw_fcc_hfm_testfunc (qh,qk,ql,en,p)
% Wrapper function around dispersion relation to return spectral weight as needed by fitting routines
%
%   >> weight = sqw_fcc_hfm_testfunc (qh,qk,ql,en,p)
%
%   qh, qk, ql      Arrays of Q values at which to evaluate dispersion
%   p               parameters for dispersion relation: p=[scale,gap,js,gamma]
%               gap     Empirical gap at magnetic zone centres
%               js      J*S in Hamiltonian in which each pair of spins is counted once only
%               scale   Overall scaling factor
%               gamma   Inverse lifetime broadening applied as a Gaussian function
%               bkconst Background constant

weight = p(3)*disp2sqw(qh,qk,ql,en,@disp_fcc_hfm_testfunc,p(1:2),p(4)) + p(5);
