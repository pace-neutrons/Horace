function weight = sqw_bcc_hfm_2_testfunc (qh,qk,ql,en,par)
% Spectral weight for bcc n.n. Heisenberg ferromagnet and with a false optic branch
%
%   >> weight = sqw_bcc_hfm_2_testfunc (qh,qk,ql,en,par)
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [Seff,SJ,gap,optic,gamma,bkconst]
%                   Seff    Intensity scale factor
%                   SJ      Exchange constant (dispersion maximum 24*SJ)
%                   gap     Gap at Bragg positions
%                   optic   Gap for a fake optic mode in addition to parameter gap above
%                   gamma   Inverse lifetime broadening applied as a Gaussian function
%                   bkconst Background constant
%
% Output:
% -------
%   weight      Spectral weight

gamma=par(5);
bkconst=par(6);
weight = disp2sqw(qh,qk,ql,en,@disp_bcc_hfm_2_testfunc,par(1:4),gamma) + bkconst;
