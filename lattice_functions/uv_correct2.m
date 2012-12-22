function [u_true, v_true] = uv_correct2 (u, v, rlu_corr)
% Return true values of h,k,l for the vectors that define the scattering plane, and matrix to convert notional r.l.u. into true r.l.u
%
%   >> [u_true, v_true] = rlu_correct (u, v, rlu_corr)
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
%   u,v                     Vectors (in rlu) used to define the scattering plane, as expressed in the notional lattice
%   rlu_corr                Matrix to convert from coords in notional rlu to true rlu, accounting for 
%                          the misorientation of the lattice and the true lattice parameters.
%
% Output:
% --------
%   u_true, v_true          True directions of input u, v, as expressed using the true lattice parameters

u_true=rlu_corr*u(:);   % make u a column vector
v_true=rlu_corr*v(:);   % make v a column vector

% Reshape output
u_true=reshape(u_true,size(u));
v_true=reshape(v_true,size(v));
