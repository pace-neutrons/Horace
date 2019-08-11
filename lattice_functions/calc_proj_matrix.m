function [spec_to_u, u_to_rlu, spec_to_rlu] = calc_proj_matrix (alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
% Calculate matrix that convert momentum from coordinates in spectrometer frame to
% projection axes defined by u1 || a*, u2 in plane of a* and b* i.e. crystal Cartesian axes
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see Tobyfit for conventions
%
%   >> [spec_to_u, u_to_rlu, spec_to_rlu] = ...
%    calc_proj_matrix (alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
%
% Input:
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

% T.G.Perring 15/6/07
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)


% Get matrix to convert from rlu to orthonormal frame defined by u,v; and 
b_matrix  = bmatrix(alatt, angdeg);       % bmat takes Vrlu to Vxtal_cart
ub_matrix = ubmatrix(u, v, b_matrix);     % ubmat takes Vrlu to V in orthonormal frame defined by u, v
u_matrix  = ub_matrix / b_matrix;         % u matrix takes V in crystal Cartesian coords to orthonormal frame defined by u, v

 
% Matrix to convert coords in orthormal frame defined by notional directions of u, v, to
% coords in orthonormal frame defined by true directions of u, v:
rot_dpsi= [cos(dpsi),-sin(dpsi),0; sin(dpsi),cos(dpsi),0; 0,0,1];
rot_gl  = [cos(gl),0,sin(gl); 0,1,0; -sin(gl),0,cos(gl)];
rot_gs  = [1,0,0; 0,cos(gs),-sin(gs); 0,sin(gs),cos(gs)];
rot_om  = [cos(omega),-sin(omega),0; sin(omega),cos(omega),0; 0,0,1];
corr = (rot_om * (rot_dpsi*rot_gl*rot_gs) * rot_om')';

% Matrix to convert from spectrometer coords to orthormal frame defined by notional directions of u, v
cryst = [cos(psi),sin(psi),0; -sin(psi),cos(psi),0; 0,0,1];

% Combine to get matrix to convert from spectrometer coordinates to crystal Cartesian coordinates
spec_to_u = u_matrix\corr*cryst;

% Matrix to convert from crystal Cartesian coords to r.l.u.
u_to_rlu = inv(b_matrix); 

% Matrix to convert from spectrometer coordinates to r.l.u.
spec_to_rlu = b_matrix\spec_to_u;
