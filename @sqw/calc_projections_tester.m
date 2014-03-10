function [u_to_rlu, ucoords] = ...
    calc_projections_tester(sqw,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det)
	% service routine used in tests only to allow testing private mex/nomex routines without changing working folder	
%
% $Revision: 791 $ ($Date: 2013-11-15 22:54:46 +0000 (Fri, 15 Nov 2013) $)


[u_to_rlu, ucoords] = ...
    calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);
