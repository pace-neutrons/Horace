function [u_true, v_true, alatt_true, angdeg_true] = uv_correct2 (u, v, alatt, angdeg, rlu_corr)
% Return true values of h,k,l for the vectors that define the scattering plane, and matrix to convert notional r.l.u. into true r.l.u
%
%   >> [u_true, v_true] = uv_correct2 (u, v, rlu_corr, alatt, angdeg)
%
% This function can be used to correct the scattering plane vectors to the true wectors once the 
% misorientation angles and true lattice parameters have been determined.
%
% In particular, this can be used to get the true u and v for mslice after determining the misorientation parameters
% e.g. with Tobyfit. All that is required in mslice is to change u and v (and the lattice parameters to
% alatt_true and angdeg_true if these are different from alatt and angdeg). The value of psi as required by
% mslice does not need to be changed, as that is accounted for in the output vectors u_true and v_true.
%
% Input:
% --------
%   u,v                 Vectors (in rlu) used to define the scattering plane, as expressed in the notional lattice
%   alatt,              Lattice parameters of notional lattice [a,b,c] (Ang)
%   angdeg              Lattice angles of notional lattice [alf,bet,gam] (deg)
%   rlu_corr            Matrix to convert from coords in notional reciprocal lattice to true reciprocal lattice, 
%                      accounting for the misorientation of the lattice and the true lattice parameters. This
%                      matrix will have been obtained using the function refine_crystal (type
%                      >> help refine_crystal   for more information)
%
% Output:
% --------
%   u_true, v_true      True directions of input u, v, as expressed using the true lattice parameters
%                      These can be used in programs like mslice with the same value of psi but will now
%                      label data with the correct reciprocal lattice units if used with the same value of
%                      psi (and in Horace, dpsi=gl=gs=0).
%   alatt_true          True values for lattice parmeters [a,b,c] (Ang)
%   angdeg_true         True calues of lattice angles [alf,bet,gam] (deg)

u_true=rlu_corr*u(:);   % make u a column vector
v_true=rlu_corr*v(:);   % make v a column vector
[alatt_true,angdeg_true,rotmat,ok,mess]=rlu_corr_to_lattice(rlu_corr,alatt,angdeg);
if ~ok, error(mess), end

% Reshape output
u_true=reshape(u_true,size(u));
v_true=reshape(v_true,size(v));
