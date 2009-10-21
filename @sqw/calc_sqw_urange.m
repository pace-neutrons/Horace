function urange = calc_sqw_urange (dummy, efix, emode, eps_lo, eps_hi, det, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
% Compute range of data for a collection of data files given the projection axes and crystal orientation
%
% Normal use:
%   >> urange = calc_grid (efix, emode, eps_lo, eps_hi, det, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
%
% Input: (in the following, nfile = no. spe files)
%   dummy           Dummy sqw object  - used only to ensure that this service routine was called
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2    [scalar]
%   eps_lo          Lower energy transfer (meV)        [scalar or vector length nfile]
%   eps_hi          Upper energy transfer (meV)        [scalar or vector length nfile]
%   det             Name of detector .par file, or detector structure as read by get_par
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
% Output:
% --------
%   urange          Actual range of grid

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% Check that the first argument is sqw object
% -------------------------------------------
if ~isa(dummy,classname)    % classname is a private method 
    error('Check type of input arguments')
end

% Check input arguments
% ------------------------
% Determine nfile as being the greatest of the number of elements in the imput variables

nfiles=max([numel(efix), numel(eps_lo), numel(eps_hi), numel(psi), numel(omega), numel(dpsi), numel(gl), numel(gs)]);

% Expand the input variables to vectors where values can be different for each spe file
if isscalar(efix) && nfiles>1 && isnumeric(efix)
    efix=repmat(efix,[nfiles,1]);
elseif ~(isvector(efix) && length(efix)==nfiles && isnumeric(efix))
    error ('Efix must be a single number vector with length equal to the number of spe files')
end

if isscalar(eps_lo) && nfiles>1 && isnumeric(eps_lo)
    eps_lo=repmat(eps_lo,[nfiles,1]);
elseif ~(isvector(eps_lo) && length(eps_lo)==nfiles && isnumeric(eps_lo))
    error ('eps_lo must be a single number vector with length equal to the number of spe files')
end

if isscalar(eps_hi) && nfiles>1 && isnumeric(eps_hi)
    eps_hi=repmat(eps_hi,[nfiles,1]);
elseif ~(isvector(eps_hi) && length(eps_hi)==nfiles && isnumeric(eps_hi))
    error ('eps_hi must be a single number vector with length equal to the number of spe files')
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

if any(eps_lo>eps_hi)
    error('Must have eps_lo<=eps_hi')
end

if ischar(det) && size(det,1)==1
    det=get_par(det);
end
    
    
% Get limits of data for grid on which to store sqw data
% ---------------------------------------------------------
% Get the maximum limits along the projection axes across all spe files
data.filename='';
data.filepath='';
ndet=length(det.group);
data.S=zeros(2,ndet);
data.E=zeros(2,ndet);
urange=[Inf, Inf, Inf, Inf;-Inf,-Inf,-Inf,-Inf];
for i=1:nfiles
    data.en=[eps_lo(i);eps_hi(i)];
    [u_to_rlu, ucoords] = calc_projections (efix(i), emode, alatt, angdeg, u, v, psi(i), ...
        omega(i), dpsi(i), gl(i), gs(i), data, det);
    urange = [min(urange(1,:),min(ucoords,[],2)'); max(urange(2,:),max(ucoords,[],2)')];
end
