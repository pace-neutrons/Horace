function [pix_range,ndet] = calc_sqw_pix_range (efix, emode, eps_lo, eps_hi, det, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
% Compute range of data for a collection of data files given the projection axes and crystal orientation
%
%   >> pix_range = calc_grid (efix, emode, eps_lo, eps_hi, det, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
%
% Input: (in the following, nfile = no. spe files)
% ------
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2    [scalar]
%   eps_lo          Lower energy transfer (meV)        [scalar or vector length nfile]
%   eps_hi          Upper energy transfer (meV)        [scalar or vector length nfile]
%   det             Name of detector .par file, or detector structure as read by get_par
%   alatt           Lattice parameters (Ang^-1)        [vector length 3 or array size [nfile,3]]
%   angdeg          Lattice angles (deg)               [vector length 3 or array size [nfile,3]]
%   u               First vector defining scattering plane (r.l.u.)
%                                                      [vector length 3 or array size [nfile,3]]
%   v               Second vector defining scattering plane (r.l.u.)
%                                                      [vector length 3 or array size [nfile,3]]
%   psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
%   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
%
% Output:
% --------
%   pix_range       Actual range of data in crystal Cartesian coordinates and
%                   energy transfer (2x4 array)
%   ndet            number of detectors positions, defined by the par file


% Original author: T.G.Perring
%
%

% Check that the first argument is sqw object
% -------------------------------------------

% Check input arguments
% ------------------------
% Check input arguments, and convert into arrays
[ok,mess,efix,emode,lattice]=...
    gen_sqw_check_params ([],efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
if ~ok, error(mess), end
nfiles=numel(efix);

[eps_lo,mess]=check_parameter_values_ok(eps_lo,nfiles,1,'eps_lo','the number of spe files');
if ~isempty(mess), return; end

[eps_hi,mess]=check_parameter_values_ok(eps_hi,nfiles,1,'eps_hi','the number of spe files');
if ~isempty(mess), return; end

if any(eps_lo>eps_hi)
    error('HORACE:calc_sqw_pix_range:invalid_argument',...
        'Must have eps_lo<=eps_hi')
end

% Invoke public get_par routine
if ischar(det) && size(det,1)==1
    det=get_par(det);
end
% Get pix_range
rd_list = rundatah.gen_runfiles(cell(1,numel(efix)),det,...
    efix,emode,lattice,'-allow_missing');
ndet = numel(det.group);
S = zeros(1,ndet);
ERR = S;
for i=1:numel(rd_list)
    rd_list{i}.S = S;
    rd_list{i}.ERR = ERR;
    rd_list{i}.en = [eps_lo(i);eps_hi(i)];
end
pix_range = rundata_find_pix_range(rd_list);
