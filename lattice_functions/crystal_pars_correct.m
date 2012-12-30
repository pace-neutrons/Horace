function [alatt, angdeg, dpsi_deg, gl_deg, gs_deg] = crystal_pars_correct (u, v, alatt0, angdeg0, omega0_deg, dpsi0_deg, gl0_deg, gs0_deg, rlu_corr, varargin)
% Return correct lattice parameters and crystal orientation for gen_sqw from a matrix that corrects the r.l.u.
%
%   >> [alatt, angdeg, dpsi, gl, gs] = crystal_pars_correct (u, v, alatt0, angdeg0, omega0, dpsi0, gl0, gs0, rlu_corr)
%   >> [alatt, angdeg, dpsi, gl, gs] = crystal_pars_correct (u, v, alatt0, angdeg0, omega0, dpsi0, gl0, gs0, rlu_corr,...
%                                                                                                 u_new, v_new, omega_new)
%
% This functions returns the true lattice parameters and crystal misorientation angles for the generation
% of an sqw file. The input is the lattice parameters and crystal misorientation used to generate an
% sqw file, and a matrix that converts the indicies (h,k,l) to the correct values of (h,k,l). Optionally,
% the vectors u and v that define the scattering plane can be altered, and the angle omega that defines the
% orientation of the virtual gonoiometer.
%
% The rlu correction matrix can be estimated using the function refine_crystal (type
% >> help refine_crystal   for details). This matrix can be used directly to correct the crystal orientation and
% lattice parameters in an sqw object (type >> help change_crystal_horace   for details). However, it may be
% useful to compute the corrected lattice parameters and misorientation angles with this function to check
% the changes that will be performed by change_crystal, or if one wants to regenerate the sqw file directly.
%
% Input:
% --------
%   u,v                     Vectors (in rlu) used to define the scattering plane, as expressed in the notional lattice
%   alatt0, angdeg0         Lattice parameters of notional lattice: [a,b,c], [alf,bet,gam] (in Ang and deg)
%   omega0, dpsi0, gl0, gs0 Misorientation angles of the vectors u and v as used in the calculation of the sqw object (deg)
%   rlu_corr                 Matrix to convert notional rlu in the current crystal lattice to the rlu in the new
%                          crystal lattice together with any re-orientation of the crystal. The matrix is defined by
%                               qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
%                          This matrix can be obtained from refining the lattice and orientation with the function
%                          refine_crystal (type >> help refine_crystal  for more details).
% OPTIONAL:
%   u_new, v_new            Replacement vectors u, v that define the scattering plane. Normally these would not
%                          be given, and the input u and v will be used. The extent to which u_new and v_new do not
%                          correctly give the true scattering plane will be accommodated in the output
%                          misorientation angles dpsi, gl and gs below. (Default: input arguments u and v)
%   omega_new               Replacement value for the orientation of the virtual goniometer arcs with reference
%                          to which dpsi, gl, gs will be calculated. (Default: input argument omega) (deg)
%
% Output:
% --------
%   alatt, angdeg           True lattice parameters: [a_true,b_true,c_true], [alf_true,bet_true,gam_true] (in Ang and deg)
%   dpsi, gl, gs            Misorientation angles of the vectors u_new and v_new (deg)

deg2rad=pi/180;
omega0=omega0_deg*deg2rad;
dpsi0=dpsi0_deg*deg2rad;
gl0=gl0_deg*deg2rad;
gs0=gs0_deg*deg2rad;

% Check input arguments
if numel(varargin)==0
    u_new=u; v_new=v; omega_new=omega0;
elseif numel(varargin)==2
    u_new=varargin{1}; v_new=varargin{2}; omega_new=omega0;
elseif numel(varargin)==3
    u_new=varargin{1}; v_new=varargin{2}; omega_new=varargin{3}*deg2rad;
else
    error('Check number of input arguments')
end

% Get matrix to convert from rlu to orthonormal frame defined by u0,v0;
b_matrix0 = bmatrix(alatt0, angdeg0);        % bmat takes Vrlu to Vxtal_cart
ub_matrix0 = ubmatrix(u, v, b_matrix0);     % ubmat takes Vrlu to V in orthonormal frame defined by u, v

% Get matrix to convert from rlu defined by true lattice parameters to orthonormal frame defined by u,v;
[alatt,angdeg,rotmat,ok,mess]=rlu_corr_to_lattice(rlu_corr,alatt0,angdeg0);
if ~ok, error(mess), end
b_matrix = bmatrix(alatt, angdeg);     % bmat takes Vrlu to Vxtal_cart
ub_matrix = ubmatrix(u_new, v_new, b_matrix);       % ubmat takes Vrlu to V in orthonormal frame defined by u, v

% Matrix to convert coords in orthormal frame defined by directions of u, v after accounting for misorientation
% to coords in orthonormal frame defined by *notional* directions of u, v:
% (This orthonormal frame, S, is the one that is defined by rotation psi about vertical from spectrometer coordinates)
rot_dpsi0= [cos(dpsi0),-sin(dpsi0),0; sin(dpsi0),cos(dpsi0),0; 0,0,1];
rot_gl0  = [cos(gl0),0,sin(gl0); 0,1,0; -sin(gl0),0,cos(gl0)];
rot_gs0  = [1,0,0; 0,cos(gs0),-sin(gs0); 0,sin(gs0),cos(gs0)];
rot_om0  = [cos(omega0),-sin(omega0),0; sin(omega0),cos(omega0),0; 0,0,1];
corr0 = (rot_om0 * (rot_dpsi0*rot_gl0*rot_gs0) * rot_om0');
% Matrix to convert from rlu to orthonormal frame S
% (Vs = (Corr*UB)*Vrlu, where Corr=Om0 * M(dpsi0,gl0,gs0) * Om0')
rlu0_to_S = corr0*ub_matrix0; 

% Use the fact that Vs is also given by Vs=(Corr_true*UBtrue)*Vrlu_true, and Vrlu_true= rlu_corr*Vrlu, to determine M(dpsi,gl,gs):
% for true lattice:
rot_om_new  = [cos(omega_new),-sin(omega_new),0; sin(omega_new),cos(omega_new),0; 0,0,1];
M = rot_om_new' * rlu0_to_S / (rot_om_new' * ub_matrix * rlu_corr);

% Now extract dpsi, gl, gs from M
% This only works so long as gl is not 90 degrees (in this case dpsi and gl are rotations about the same axis)
sin_gl = -M(3,1);
small=1e-10;
if abs(sin_gl)<1-small
    gl_deg=asin(sin_gl)/deg2rad;    % in range -90 deg to +90 deg
    gs_deg=atan2(M(3,2),M(3,3))/deg2rad;
    dpsi_deg=atan2(M(2,1),M(1,1))/deg2rad;
else
    if sin_gl>0
        gl_deg=90;
        gs_deg=0;   % can only determine (dpsi-gs), so take gs=0
        dpsi_deg=atan2(M(2,3),M(1,3))/deg2rad;
    else
        gl_deg=-90;
        gs_deg=0;   % can only determine (dpsi-gs), so take gs=0
        dpsi_deg=atan2(-M(2,3),-M(1,3))/deg2rad;
    end
end
