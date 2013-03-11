function [efix_out, emode_out, alatt_out, angdeg_out, u_out, v_out, psi_out, omega_out, dpsi_out, gl_out, gs_out] =...
    gen_sqw_check_params (nfile, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
% Check numeric input arguments to gen_sqw are valid, and return as arrays expanded as required by the number of spe files
%
%   >> [efix_out, emode_out, alatt_out, angdeg_out, u_out, v_out, psi_out, omega_out, dpsi_out, gl_out, gs_out] =...
%                           gen_sqw_check_params (nfiles, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
%
% Input:
% ------
%   nfile           Number of spe files
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2, elastic=0    [scalar]
%   alatt           Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
%   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
%
%
% Output:
% -------
%   efix_out        Fixed energy (meV)                 [column vector length nfile]
%   emode_out       Direct geometry=1, indirect geometry=2, elastic=0    [scalar]
%   alatt_out       Lattice parameters (Ang^-1)        [row vector]
%   angdeg_out      Lattice angles (deg)               [row vector]
%   u_out           First vector (1x3) defining scattering plane (r.l.u.)
%   v_out           Second vector (1x3) defining scattering plane (r.l.u.)
%   psi_out         Angle of u w.r.t. ki (deg)         [column vector length nfile]
%   omega_out       Angle of axis of small goniometer arc w.r.t. notional u (deg) [column vector length nfile]
%   dpsi_out        Correction to psi (deg)            [column vector length nfile]
%   gl_out          Large goniometer arc angle (deg)   [column vector length nfile]
%   gs_out          Small goniometer arc angle (deg)   [column vector length nfile]


% Expand the input variables to vectors where values can be different for each spe file

[efix_out,mess]=check_parameter_values_ok(efix,nfile,1,'efix','the number of spe files',[0,Inf],[false,true]);
if ~isempty(mess), error(mess), end

[emode_out,mess]=check_parameter_values_ok(emode,1,1,'emode','the number of spe files',[0,2]);
if ~isempty(mess), error(mess), end

[alatt_out,mess]=check_parameter_values_ok(alatt,1,3,'alatt','the number of spe files',[0,0,0;Inf,Inf,Inf],false(2,3));
if ~isempty(mess), error(mess), end

[angdeg_out,mess]=check_parameter_values_ok(angdeg,1,3,'angdeg','the number of spe files',[0,0,0;180,180,180],false(2,3));
if ~isempty(mess), error(mess), end

[u_out,mess]=check_parameter_values_ok(u,1,3,'u','');
if ~isempty(mess), error(mess), end

[v_out,mess]=check_parameter_values_ok(v,1,3,'v','');
if ~isempty(mess), error(mess), end

[psi_out,mess]=check_parameter_values_ok(psi,nfile,1,'psi','');
if ~isempty(mess), error(mess), end

[omega_out,mess]=check_parameter_values_ok(omega,nfile,1,'omega','');
if ~isempty(mess), error(mess), end

[dpsi_out,mess]=check_parameter_values_ok(dpsi,nfile,1,'dpsi','');
if ~isempty(mess), error(mess), end

[gl_out,mess]=check_parameter_values_ok(gl,nfile,1,'gl','');
if ~isempty(mess), error(mess), end

[gs_out,mess]=check_parameter_values_ok(gs,nfile,1,'gs','');
if ~isempty(mess), error(mess), end
