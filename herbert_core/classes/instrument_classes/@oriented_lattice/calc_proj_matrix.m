function mat = calc_proj_matrix (obj,n_matrix)
% Calculate matrix that convert momentum from coordinates in spectrometer frame to
% projection axes defined by u1 || a*, u2 in plane of a* and b* i.e. crystal Cartesian axes
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see Tobyfit for conventions
%
%   >> [spec_to_u, u_to_rlu, spec_to_rlu] = obj.calc_proj_matrix(n_matrix)
%
%  n_matrix -- number from 1 to 3, identifying one of 3 matrix to return.
%              If out of 1-3 range, first martix is returned.
%
% Output:      Depending on n_matrix, function returns:
% -------
% 1-- spec_to_u   Matrix (3x3)to convert momentum from coordinates in
%               spectrometer frame to crystal Cartesian axes:
%                   v_crystal_Cart = spec_to_u * v_spec
%
% 2-- u_to_rlu    Matrix (3x3) of crystal Cartesian axes in reciprocal lattice units
%              i.e. u_to_rlu(:,1) first vector - u(1:3,1) r.l.u. etc.
%              This matrix can be used to convert components of a vector in
%              crystal Cartesian axes to r.l.u.:
%                   v_rlu = u_to_rlu * v_crystal_Cart
%              (Same as inv(B) in Busing and Levy convention)
%
% 3-- spec_to_rlu Matrix (3x3) to convert from spectrometer coordinates to
%              r.l.u.:
%                   v_rlu = spec_to_rlu * v_spec
%              (This matrix is entirely equivalent to u_to_rlu*spec_to_u)
%
% Uses the following crystal lattice fields:
% ------
%   alatt       Lattice parameters (Ang^-1)
%   angdeg      Lattice angles (deg)
%   u           First vector (1x3) defining scattering plane (r.l.u.)
%   v           Second vector (1x3) defining scattering plane (r.l.u.)
%   psi         Angle of u w.r.t. ki (rad)
%   omega       Angle of axis of small goniometer arc w.r.t. notional u
%   dpsi        Correction to psi (rad)
%   gl          Large goniometer arc angle (rad)
%   gs          Small goniometer arc angle (rad)


mat = calc_proj_matrix@Goniometer(obj,obj.alatt_,obj.angdeg_,n_matrix);
