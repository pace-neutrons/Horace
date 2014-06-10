function [u_to_rlu, urange,pix] = ...
    calc_projections_tester(sqw,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det,varargin)
	% service routine used in tests only to allow testing private mex/nomex routines without changing working folder	
%
% $Revision$ ($Date$)

detdcn=calc_detdcn(det);
[u_to_rlu, urange,pix] = ...
    calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det, detdcn,varargin{:});
