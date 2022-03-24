function [ok, mess, efix_out, emode_out, lattice] = gen_sqw_check_params...
    (nfile, efix, emode,varargin)
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
%   lattice         oriented_lattice() object, containing lattice [nfile,1]
%                   array build from lattice and goniometer parameters
%

% Initialise return arguments
ok=false;
efix_out=[]; emode_out=[];
lattice = [];
%
if ~isa(varargin(1),'oriented_lattice') && isnumeric(varargin{1})
    try
        lattice = convert_old_input_to_lat(varargin{:});
    catch ME
        if strcmp(ME.identifier,'HERBERT:convert_old_input:invalid_argument')
            mess = ME.message;
            return;
        else
            rethrow(ME);
        end
    end
end

% Determine number of files if not given
if ~isempty(nfile)
    % Check value provided is OK
    if nfile<1
        mess='Number of spe data sets must be a positive integer >= 1';
        return
    end
else
    % Get nfile from the sizes of the input arguments themselves
    nfile = numel(lattice);
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

% Fill error flags
ok=true;
mess='';
