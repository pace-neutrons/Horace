function [spec_to_u, u_to_rlu, spec_to_rlu] = calc_proj_matrix (obj)
% Calculate matrix that convert momentum from coordinates in spectrometer frame to
% projection axes defined by u1 || a*, u2 in plane of a* and b* i.e. crystal Cartesian axes
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see Tobyfit for conventions
%
%   >> [spec_to_u, u_to_rlu, spec_to_rlu] = obj.calc_proj_matrix()
%
%
% Output:
% -------
%   spec_to_u   Matrix (3x3)to convert momentum from coordinates in spectrometer
%              frame to crystal Cartesian axes:
%                   v_crystal_Cart = spec_to_u * v_spec
%
%   u_to_rlu    Matrix (3x3) of crystal Cartesian axes in reciprocal lattice units
%              i.e. u_to_rlu(:,1) first vector - u(1:3,1) r.l.u. etc.
%              This matrix can be used to convert components of a vector in
%              crystal Cartesian axes to r.l.u.:
%                   v_rlu = u_to_rlu * v_crystal_Cart
%              (Same as inv(B) in Busing and Levy convention)
%
%   spec_to_rlu Matrix (3x3) to convert from spectrometer coordinates to
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

% Get matrix to convert from rlu to orthonormal frame defined by u,v; and
b_matrix  = obj.bmatrix();       % bmat takes Vrlu to V_crystal_Cart
[~,u_matrix] = obj.ubmatrix(b_matrix);     % ubmat takes Vrlu to V in orthonormal frame defined by u, v
%u_matrix  = ub_matrix / b_matrix;         % u matrix takes V in crystal Cartesian coordinates to orthonormal frame defined by u, v


obj.angular_units = 'rad';
[spec_to_u, u_to_rlu, spec_to_rlu] = ...
    calc_proj_matrix(b_matrix,u_matrix, '', '', obj.psi, obj.omega, obj.dpsi, obj.gl, obj.gs);
