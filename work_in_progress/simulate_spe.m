function simulate_spe (spe_in_file, par_file, spe_out_file, sqwfunc, pars, ...
                                efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
% Read one or more spe files and a detector parameter file, and create an output sqw file.
%
%   >> simulate_spe (spe_in_file, par_file, spe_out_file, sqwfunc, pars, ...
%                               efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
%
% Input:
%   spe_file        Full file name of spe file (character string)
%                OR Energy bin boundaries (must be equally spaced)
%   par_file        Full file name of detector parameter file (Tobyfit format)
%   sqw_file        Full file name of output spe file
%   efix            Fixed energy (meV)                 [scalar]
%   emode           Direct geometry=1, indirect geometry=2    [scalar]
%   alatt           Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (deg)         [scalar]
%   omega           [Optional] Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar]
%   dpsi            [Optional] Correction to psi (deg)            [scalar]
%   gl              [Optional] Large goniometer arc angle (deg)   [scalar]
%   gs              [Optional] Small goniometer arc angle (deg)   [scalar]

% T.G.Perring  18 May 2009


% Check number of input arguments (necessary to get more useful error message because this is just a gateway routine)
% --------------------------------------------------------------------------------------------------------------------
if ~(nargin==12 || nargin==16)
    error('Check number of input arguments')
end

% Check input arguments
% ------------------------
% Input files
if ischar(spe_in_file)
    if size(spe_in_file,1)>1
        error('Input spe file name must be a character string')
    elseif exist(spe_in_file,'file')~=2
        error(['File ',spe_in_file,' not found'])
    end
elseif isnumeric(spe_in_file) && isvector(spe_in_file) && numel(spe_in_file)>1
    en=spe_in_file;     % just so that the name reflects what the contents are
    den=diff(en);
    if any(den~=0)
        error('Energy bins must all be same size')
    end
else
    error('spe file input must be a single file name or array of equally spaced energy bin boundaries')
end

% Check par file exists
if ischar(par_file) && size(par_file,1)==1
    if exist(par_file,'file')~=2
        error(['File ',par_file,' not found'])
    end
else
    error('Input detector par file must be a character string')
end

% Check output file will open
if ischar(spe_out_file) && size(spe_out_file,1)==1
    
else
    error('Output spe file name must be a character string')
end


% Check that output file does not appear in input file name list
if ~isempty(strmatch(par_file,spe_file,'exact'))
    error('Detector parameter file name matches one of the input spe file names')
elseif ~isempty(strmatch(sqw_file,spe_file,'exact'))
    error('Output sqw file name matches one of the input spe file names')
elseif strcmpi(par_file,sqw_file)
    error('Detector parameter file and output sqw file name match')
end
% Check par file exists


% Expand the input variables to vectors where values can be different for each spe file
if isscalar(efix) && nfiles>1 && isnumeric(efix)
    efix=repmat(efix,[nfiles,1]);
elseif ~(isvector(efix) && length(efix)==nfiles && isnumeric(efix))
    error ('Efix must be a single number vector with length equal to the number of spe files')
end

if isscalar(psi) && nfiles>1 && isnumeric(psi)
    psi=repmat(psi,[nfiles,1]);
elseif ~(isvector(psi) && length(psi)==nfiles && isnumeric(psi))
    error ('psi must be a single number vector with length equal to the number of spe files')
end

if isscalar(omega) && nfiles>1 && isnumeric(omega)
    omega=repmat(omega,[nfiles,1]);
elseif ~(isvector(omega) && length(omega)==nfiles && isnumeric(omega))
    error ('omega must be a single number vector with length equal to the number of spe files')
end

if isscalar(dpsi) && nfiles>1 && isnumeric(dpsi)
    dpsi=repmat(dpsi,[nfiles,1]);
elseif ~(isvector(dpsi) && length(dpsi)==nfiles && isnumeric(dpsi))
    error ('dpsi must be a single number vector with length equal to the number of spe files')
end

if isscalar(gl) && nfiles>1 && isnumeric(gl)
    gl=repmat(gl,[nfiles,1]);
elseif ~(isvector(gl) && length(gl)==nfiles && isnumeric(gl))
    error ('gl must be a single number vector with length equal to the number of spe files')
end

if isscalar(gs) && nfiles>1 && isnumeric(gs)
    gs=repmat(gs,[nfiles,1]);
elseif ~(isvector(gs) && length(gs)==nfiles && isnumeric(gs))
    error ('gs must be a single number vector with length equal to the number of spe files')
end

% Convert input angles to radians (except lattice parameters)
deg2rad=pi/180;
psi = psi*deg2rad;
omega = omega*deg2rad;
dpsi = dpsi*deg2rad;
gl = gl*deg2rad;
gs = gs*deg2rad;
