function [ok, mess, efix_out, emode_out, alatt_out, angdeg_out, u_out, v_out,...
    psi_out, omega_out, dpsi_out, gl_out, gs_out] = gen_sqw_check_params...
    (nfile, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
% Check numeric input arguments to gen_sqw are valid, and return as arrays
%
%   >> [ok, mess, efix_out, emode_out, alatt_out, angdeg_out, u_out, v_out,...
%           psi_out, omega_out, dpsi_out, gl_out, gs_out] = gen_sqw_check_params...
%           (nfiles, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
%
% Input:
% ------
%   nfile           Number of spe data sets
%                   If [], then determine nfile from the sizes of the input arrays
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2, elastic=0    [scalar]
%   alatt           Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg)
%                                                      [scalar or vector length nfile]
%   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
%   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
%
%
% Output:
% -------
%   ok              Logical: true if all fine, false otherwise
%   mess            Error message if not ok; ='' if ok
%   efix_out        Fixed energy (meV)                 [column vector length nfile]
%   emode_out       Direct geometry=1, indirect geometry=2, elastic=0
%                                                      [column vector length nfile]
%   alatt_out       Lattice parameters (Ang^-1)        [nfile,3] array
%   angdeg_out      Lattice angles (deg)               [nfile,3] array
%   u_out           First vector (1x3) defining scattering plane    [nfile,3] array
%   v_out           Second vector (1x3) defining scattering plane   [nfile,3] array
%   psi_out         Angle of u w.r.t. ki (deg)         [column vector length nfile]
%   omega_out       Angle of axis of small goniometer arc w.r.t. notional u (deg)
%                                                      [column vector length nfile]
%   dpsi_out        Correction to psi (deg)            [column vector length nfile]
%   gl_out          Large goniometer arc angle (deg)   [column vector length nfile]
%   gs_out          Small goniometer arc angle (deg)   [column vector length nfile]


% Initialise return arguments
ok=false;
efix_out=[]; emode_out=[]; alatt_out=[]; angdeg_out=[]; u_out=[]; v_out=[];
psi_out=[]; omega_out=[]; dpsi_out=[]; gl_out=[]; gs_out=[];

% Determine number of files if not given
if ~isempty(nfile)
    % Check value provided is OK
    if nfile<1
        ok=false;
        mess='Number of spe data sets must be a positive integer >= 1';
        return
    end
else
    % Get nfile from the sizes of the input arguments themselves
    if rem(numel(alatt),3)==0 && rem(numel(angdeg),3)==0 &&...
            rem(numel(u),3)==0 && rem(numel(v),3)==0
        nfile=max([numel(efix), numel(alatt)/3, numel(angdeg)/3, numel(u)/3, numel(v)/3,...
            numel(psi), numel(omega), numel(dpsi), numel(gl), numel(gs)]);
    else
        ok=false;
        mess='Check the sizes of arrays alatt, angdeg, u and v';
        return
    end
end

% Expand the input variables to vectors where values can be different for each spe file
if emode ~= 2
    [efix_out,mess]=check_parameter_values_ok(efix,nfile,1,'efix',...
        'the number of spe files',[0,Inf],[false,true]);
else
    if numel(efix) == 1
        [efix_out,mess]=check_parameter_values_ok(efix,nfile,1,'efix',...
            'the number of spe files',[0,Inf],[false,true]);
    else
        if size(efix,2) == 1 % should be row
            efix = efix';
        end
        n_det_loc = size(efix,2);
        % size(efix,2) should be == n_detectors, but we can not make this
        % check here
        [efix_out,mess]=check_parameter_values_ok(efix,nfile,n_det_loc,...
            'efix','the number of spe files',...
            repmat([0;Inf],1,n_det_loc),false(2,n_det_loc));

    end
end
if ~isempty(mess), return; end

[emode_out,mess]=check_parameter_values_ok(round(emode),nfile,1,'emode',...
    'the number of spe files',[0,2]);
if ~isempty(mess), return; end

[alatt_out,mess]=check_parameter_values_ok(alatt,nfile,3,'alatt',...
    'the number of spe files',[0,0,0;Inf,Inf,Inf],false(2,3));
if ~isempty(mess), return; end

[angdeg_out,mess]=check_parameter_values_ok(angdeg,nfile,3,'angdeg',...
    'the number of spe files',[0,0,0;180,180,180],false(2,3));
if ~isempty(mess), return; end

[u_out,mess]=check_parameter_values_ok(u,nfile,3,'u','the number of spe files');
if ~isempty(mess), return; end

[v_out,mess]=check_parameter_values_ok(v,nfile,3,'v','the number of spe files');
if ~isempty(mess), return; end

small=1e-10;
umod=sqrt(dot(u_out,u_out,2));
vmod=sqrt(dot(v_out,v_out,2));
if any(umod<small) || any(vmod<small)
    mess='Check that no vectors u and v have zero (or almost zero) length'; return
elseif any(dot(u_out,v_out,2)./(umod.*vmod)>1-1e-6)
    mess='Check that u and v are not collinear or almost collinear'; return
end

[psi_out,mess]=check_parameter_values_ok(psi,nfile,1,'psi','the number of spe files');
if ~isempty(mess), return; end

[omega_out,mess]=check_parameter_values_ok(omega,nfile,1,'omega','the number of spe files');
if ~isempty(mess), return; end

[dpsi_out,mess]=check_parameter_values_ok(dpsi,nfile,1,'dpsi','the number of spe files');
if ~isempty(mess), return; end

[gl_out,mess]=check_parameter_values_ok(gl,nfile,1,'gl','the number of spe files');
if ~isempty(mess), return; end

[gs_out,mess]=check_parameter_values_ok(gs,nfile,1,'gs','the number of spe files');
if ~isempty(mess), return; end

% Fill error flags
ok=true;
mess='';
