function [u_true, v_true, rlu_corr] = uv_correct (u, v, alatt, angdeg, omega_deg, dpsi_deg, gl_deg, gs_deg, alatt_true, angdeg_true)
% Return true values of h,k,l for the vectors that define the scattering plane, and matrix to convert notional r.l.u. into true r.l.u
%
%   >> [u_true, v_true] = rlu_correct (u, v, alatt, angdeg, omega, dpsi, gl, gs, alatt_true, angdeg_true)
%   >> [u_true, v_true, rlu_corr] = rlu_correct (...)
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
% u,v                       Vectors (in rlu) used to define the scattering plane, as expressed in the notional lattice
% alatt, angdeg             Lattice parameters of notional lattice: [a,b,c], [alf,bet,gam] (in Ang and deg)
% omega, dpsi, gl, gs       Misorientation angles of the vectors u and v, as determined by, for example, Tobyfit (deg)
% alatt_true, angdeg_true   True lattice parameters: [a_true,b_true,c_true], [alf_true,bet_true,gam_true] (in Ang and deg)
%
% Output:
% --------
% u_true, v_true            True directions of input u, v, as expressed using the true lattice parameters
% rlu_corr                  Matrix to convert from coords in notional rlu to true rlu, accounting for 
%                          the misorientation of the lattice and the true lattice parameters.

deg2rad2=pi/180;
omega=omega_deg*deg2rad2;
dpsi=dpsi_deg*deg2rad2;
gl=gl_deg*deg2rad2;
gs=gs_deg*deg2rad2;

% Get matrix to convert from rlu to orthonormal frame defined by u,v;
b_matrix = bmatrix(alatt, angdeg);        % bmat takes Vrlu to Vxtal_cart
ub_matrix = ubmatrix(u, v, b_matrix);     % ubmat takes Vrlu to V in orthonormal frame defined by u, v

% Get matrix to convert from rlu defined by true lattice parameters to orthonormal frame defined by u,v;
b_matrix_true = bmatrix(alatt_true, angdeg_true);     % bmat takes Vrlu to Vxtal_cart
ub_matrix_true = ubmatrix(u, v, b_matrix_true);       % ubmat takes Vrlu to V in orthonormal frame defined by u, v

% Matrix to convert coords in orthormal frame defined by *true* directions of u, v, to
% coords in orthonormal frame defined by *notional* directions of u, v:
rot_dpsi= [cos(dpsi),-sin(dpsi),0; sin(dpsi),cos(dpsi),0; 0,0,1];
rot_gl  = [cos(gl),0,sin(gl); 0,1,0; -sin(gl),0,cos(gl)];
rot_gs  = [1,0,0; 0,cos(gs),-sin(gs); 0,sin(gs),cos(gs)];
rot_om  = [cos(omega),-sin(omega),0; sin(omega),cos(omega),0; 0,0,1];
corr = (rot_om * (rot_dpsi*rot_gl*rot_gs) * rot_om');

% If have components (h,k,l) of a vector in true reciprocal lattice, then components in orthonormal frame
% defined by directions of [uh,uk,ul] and [vh,vk,vl] in the notional reciprocal lattice
% is given by corr*ub_matrix_true. Then rlu in the notional lattice oriented by the notional u,v is
% inv(ub_matrix)*corr*ub_matrix_true. We want the inverse: to get true rlu in frame defined by true directions of u,v
% given the rlu in the notional frame defined by the notional directions of u,v

rlu_corr = inv(ub_matrix_true)*corr'*ub_matrix;
u_true=rlu_corr*u(:);   % make u a column vector
v_true=rlu_corr*v(:);   % make v a column vector

% Reshape output
u_true=reshape(u_true,size(u));
v_true=reshape(v_true,size(v));
