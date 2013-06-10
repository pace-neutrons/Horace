function [efix,psi,omega,dpsi,gl,gs] = gensqw_check_input_arg(dummy, spe_file, par_file, sqw_file, efix,...
                                                    psi, omega, dpsi, gl, gs)
% Check input arguments
% ------------------------
% Input files
if ischar(spe_file) && size(spe_file,1)==1
    spe_file=cellstr(spe_file);
elseif ~iscellstr(spe_file)
    error('spe file input must be a single file name or cell array of file names')
end
nfiles = length(spe_file);
% Check that the spe files are all unique
if ~(size(unique(spe_file),2)==size(spe_file,2))
    error('One or more spe file name is repeated. All spe files must be unique')
end



% Check par file and output sqw file are character rows (easy mistake to think that cellstr are allowed input to gen_sqw)
if ~(ischar(par_file) && size(par_file,1)==1) || ~(ischar(sqw_file) && size(sqw_file,1)==1)
    error ('Just one each of detector parameter file and output sqw file permitted')
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
if exist(par_file,'file')~=2
    error(['File ',par_file,' not found'])
end


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

if ~is_herbert_used()
    % Convert input angles to radians (except lattice parameters); rundata
    % converts its data on-fly
    deg2rad=pi/180;
    psi = psi*deg2rad;
    omega = omega*deg2rad;
    dpsi = dpsi*deg2rad;
    gl = gl*deg2rad;
    gs = gs*deg2rad;
end

% Set default grid size if none given
if ~exist('grid_size_in','var')
    disp('--------------------------------------------------------------------------------')
    disp('Using default grid size of 50x50x50x50 for output sqw file')
    grid_size_in=[50,50,50,50];
elseif ~(isnumeric(grid_size_in)&&(isscalar(grid_size_in)||(isvector(grid_size_in)&&all(size(grid_size_in)==[1,4]))))
    error ('Grid size must be scalar or row vector length 4')
end


