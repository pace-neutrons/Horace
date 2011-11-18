function [u_to_rlu, ucoords]= get_test_calc_projections(sqw,...
                              efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det)
% Transform in an spe file with coords in the 4D space defined by crystal Cartesian coordinates
% and energy transfer. 
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see Tobyfit for conventions
%
%
%
%
% It is an interface function to private cal_proj_matrix function, 
%
% the interface is used to compare the results, obtained from this function
% with e.g. Mantid results;
%
psi_rad = psi*pi/180;
omg_rad = omega*pi/180;
dpsi_rad= dpsi*pi/180;
gl_rad  = gl*pi/180;
gs_rad  = gs*pi/180;
    
[u_to_rlu, ucoords]=calc_projections (efix, emode, alatt, angdeg, u, v, psi_rad, omg_rad, dpsi_rad, gl_rad, gs_rad, data, det);


end

