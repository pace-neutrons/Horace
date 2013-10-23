function [spec_to_proj, u_to_rlu] = calc_proj_matrix (this,sample,u,v)
% Calculate matrix that convert momentum from coordinates in spectrometer frame to
% projection axes defined by u1 || a*, u2 in plane of a* and b* i.e. crystal Cartesian axes
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see
% Tobyfit for conventions
%
%   >> [spec_to_proj, u_to_rlu] = ...
%    calc_proj_matrix (this,sample,u, v)
%
% Input:
%   u           First vector (1x3) defining scattering plane (r.l.u.)
%   v           Second vector (1x3) defining scattering plane (r.l.u.)
%
% Output:
%  spec_to_proj Matrix (3x3)to convert momentum from coordinates in spectrometer
%              frame to crystal Cartesian axes. 
%   u_to_rlu    Matrix (3x3) of crystal Cartesian axes in reciprocal lattice units
%              i.e. u_to_rlu(:,1) first vector - u(1:3,1) r.l.u. etc.
%              This matrix can be used to convert components of a vector in the
%              crystal Cartesian axes to r.l.u.: v_rlu = u_to_rlu * v_crystal_Cart
%              (Same as inv(B) in Busing and Levy convention)

% T.G.Perring 15/6/07
%
% $Revision$ ($Date$)
%

% Get matrix to convert from rlu to orthonormal frame defined by u,v; and 
[ub_matrix,b_matrix] = ubmatrix(sample,u,v);     % ubmat takes Vrlu to V in orthonormal frame defined by u, v
u_matrix = ub_matrix/(b_matrix);   % u matrix takes V in crystal Cartesian coords to orthonormal frame defined by u, v


% Matrix to convert coords in orthormal frame defined by notional directions of u, v, to
% coords in orthonormal frame defined by true directions of u, v:
rot_dpsi= [cos(this.dpsi),-sin(this.dpsi),0; sin(this.dpsi),cos(this.dpsi),0; 0,0,1];
rot_gl  = [cos(this.gl),0,sin(this.gl); 0,1,0; -sin(this.gl),0,cos(this.gl)];
rot_gs  = [1,0,0; 0,cos(this.gs),-sin(this.gs); 0,sin(this.gs),cos(this.gs)];
rot_om  = [cos(this.omega),-sin(this.omega),0; sin(this.omega),cos(this.omega),0; 0,0,1];
corr = (rot_om * (rot_dpsi*rot_gl*rot_gs) * rot_om')';

% Matrix to convert from spectrometer coords to orthormal frame defined by notional directions of u, v
cryst = [cos(this.psi),sin(this.psi),0; -sin(this.psi),cos(this.psi),0; 0,0,1];

% Combine to get matrix to convert from spectrometer coordinates to crystal Cartesian coordinates
spec_to_proj = u_matrix\corr*cryst;

% Matrix to convert from crystal Cartesian coords to r.l.u.
u_to_rlu = inv(b_matrix); 
