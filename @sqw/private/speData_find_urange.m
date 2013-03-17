function urange = speData_find_urange(spe_data, par_file,...
                             efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
% Find range of data in crystal Cartesian coordinates
%
%   >> [urange,u_to_rlu] = rundata_find_urange(run_files)
%
% Input: (in the following nfile is the number of spe files)
% ------
%   spe_data 	Cell array of initiated speData objects
%   par_file    Detector parameter file name
%   efix        Fixed energy (meV)                 [vector length nfile]
%   emode       Direct geometry=1, indirect geometry=2, elastic=0    [scalar]
%   alatt       Lattice parameters (Ang^-1)        [row vector]
%   angdeg      Lattice angles (deg)               [row vector]
%   u           First vector (1x3) defining scattering plane (r.l.u.)
%   v           Second vector (1x3) defining scattering plane (r.l.u.)
%   psi         Angle of u w.r.t. ki (deg)         [vector length nfile]
%   omega       Angle of axis of small goniometer arc w.r.t. notional u (deg) [vector length nfile]
%   dpsi        Correction to psi (deg)            [vector length nfile]
%   gl          Large goniometer arc angle (deg)   [vector length nfile]
%   gs          Small goniometer arc angle (deg)   [vector length nfile]
%
%
% Output:
% -------
%   urange    	2x4 array, describing min-max values in momentum/energy
%              transfer, in crystal Cartesian coordinates and meV.


% Get limits of data for grid on which to store sqw data
% ---------------------------------------------------------
% Use the fact that the lowest and highest energy transfer bin centres define the maximum extent in
% momentum and energy. We calculate using the full detector table i.e. do not account for masked detectors
% but this is reasonable so long as not many detectors are masked. 
% (*** In more systematic cases e.g. spe file is for MARI, and impose a mask file that leaves only the
%  low angle detectors, then the calculation will be off.)

nfiles = numel(spe_data);

disp('--------------------------------------------------------------------------------')
disp(['Calculating limits of data from ',num2str(nfiles),' spe files...'])

% Read in the detector parameters if they are present in spe_data
use_par_from_nxspe=get(hor_config,'use_par_from_nxspe');
if ~use_par_from_nxspe  % have to use par file;
    % Refer to public get_par which currently works with herbert only if file is not ASCII. If ascii, it refers to load_par below
    det=get_par(par_file,'-hor');       % should throw if par file is not found
else                    % get detectors from par file
    det=getPar(spe_data{1});
    if isempty(det)                     % try to find and analyse par file
        det=get_par(dummy,par_file);     % should throw if par file is not found
    end
end

% Get the maximum limits along the projection axes across all spe files
data.filename='';
data.filepath='';
ndet=length(det.group);
urange=[Inf, Inf, Inf, Inf;-Inf,-Inf,-Inf,-Inf];
for i=1:nfiles
    % If trying to use par from nxspe, each nxspe may have its own
    % detectors par, so -- reading in a loop; This would allow
    % combining different instruments?
    if use_par_from_nxspe
        det = getPar(spe_data{i});
        if isempty(det)  % try to use ascii par file as back-up option
            det=get_par(dummy,par_file);
        end
    end
    eps=(spe_data{i}.en(2:end)+spe_data{i}.en(1:end-1))/2;
    if length(eps)>1
        data.S=zeros(2,ndet);
        data.E=zeros(2,ndet);
        data.en=[eps(1);eps(end)];
    else
        data.S=zeros(1,ndet);
        data.E=zeros(1,ndet);
        data.en=eps;
    end
    [u_to_rlu, ucoords] = calc_projections (efix(i), emode, alatt, angdeg, u, v, psi(i), ...
        omega(i), dpsi(i), gl(i), gs(i), data, det);
    urange = [min(urange(1,:),min(ucoords,[],2)'); max(urange(2,:),max(ucoords,[],2)')];
end
