function weight = sqw_bcc_hfm_testfunc (qh,qk,ql,en,par)
% Spectral weight for bcc n.n. Heisenberg ferromagnet
%
%   >> weight = sqw_bcc_hfm_testfunc (qh,qk,ql,en,par)
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [Seff,SJ,gap,gamma,bkconst]
%                   Seff    Intensity scale factor
%                   SJ      Exchange constant (dispersion maximum 24*SJ)
%                   gap     Gap at Bragg positions
%                   gamma   Inverse lifetime broadening applied as a Gaussian function
%                   bkconst Background constant
%
% Output:
% -------
%   weight      Spectral weight

gamma=par(4);
bkconst=par(5);
weight = disp2sqw(qh,qk,ql,en,@disp_bcc_hfm_testfunc,par(1:3),gamma) + bkconst;
