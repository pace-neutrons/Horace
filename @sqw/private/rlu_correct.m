function [u_true, v_true, rlu_corr] = rlu_correct (u, v, alatt, angdeg, omega, dpsi, gl, gs, alatt_true, angdeg_true)
% Return matrix to convert notional r.l.u. into true r.l.u
%
% Input:
% --------
% u,v                       Vectors in rlu that define the scattering plane
% alatt, angdeg             Lattice parameters (in Ang^-1 and deg) of notional lattice
% omega, dpsi, gl, gs       Misorientation angles of the scattering plane, as determined by Tobyfit (rad)
% alatt_true, angdeg_true   True lattice parameters
%
% Output:
% --------
% u_true, v_true            True directions of input u, v, as expressed using the true lattice parameters
% rlu_corr                  Matrix to convert from coords in notional rlu to true rlu, accounting for 
%                          the misorientation of the lattice and the true lattice parameters


% Get matrix to convert from rlu to orthonormal frame defined by u,v;
b_matrix = bmat (alatt, angdeg);        % bmat takes Vrlu to Vxtal_cart
ub_matrix = ubmat (u, v, b_matrix);     % ubmat takes Vrlu to V in orthonormal frame defined by u, v

% Get matrix to convert from rlu defined by true lattice parameters to orthonormal frame defined by u,v;
b_matrix_true = bmat (alatt_true, angdeg_true);     % bmat takes Vrlu to Vxtal_cart
ub_matrix_true = ubmat (u, v, b_matrix_true);       % ubmat takes Vrlu to V in orthonormal frame defined by u, v

% Matrix to convert coords in orthormal frame defined by *true* directions of u, v, to
% coords in orthonormal frame defined by *notional* directions of u, v:
rot_dpsi= [cos(dpsi),-sin(dpsi),0; sin(dpsi),cos(dpsi),0; 0,0,1];
rot_gl  = [cos(gl),0,sin(gl); 0,1,0; -sin(gl),0,cos(gl)];
rot_gs  = [1,0,0; 0,cos(gs),-sin(gs); 0,sin(gs),cos(gs)];
rot_om  = [cos(omega),-sin(omega),0; sin(omega),cos(omega),0; 0,0,1];
corr = (rot_om * (rot_dpsi*rot_gl*rot_gs) * rot_om');

% If have a vector in true r.l.u., then components in orthonormal frame defined by notional directions of u,v
% is given by corr*ub_matrix_true. Then rlu in the notional lattice oriented by the notional u,v is
% inv(ub_matrix)*corr*ub_matrix_true. We want the inverse: to get true rlu in frame defined by true directions of u,v
% given the rlu in the notional frame defined by the notional directions of u,v

rlu_corr = inv(ub_matrix_true)*corr'*ub_matrix;
u_true=rlu_corr*u(:);   % make u a column vector
v_true=rlu_corr*v(:);   % make v a column vector
