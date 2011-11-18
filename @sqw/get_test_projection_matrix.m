function [spec_to_proj, u_to_rlu] = get_test_projection_matrix(sqw,alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
% Calculate matrix that convert momentum from coordinates in spectrometer frame to
% projection axes defined by u1 || a*, u2 in plane of a* and b* i.e. crystal Cartesian axes
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see
% Tobyfit for conventions and private function calc_proj_matrix for
% the detailfs of the implementation
%
%
%It is an interface function to private cal_proj_matrix function, 
%
% the interface is used to compare the results, obtained from this function with e.g. Mantid results;
%
psi_rad = psi*pi/180;
omg_rad = omega*pi/180;
dpsi_rad= dpsi*pi/180;
gl_rad  = gl*pi/180;
gs_rad  = gs*pi/180;

[spec_to_proj, u_to_rlu]=calc_proj_matrix (alatt, angdeg, u, v, psi_rad, omg_rad, dpsi_rad, gl_rad, gs_rad);

end
