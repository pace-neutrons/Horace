function [grid_size, urange] = write_spe_to_sqw (dummy, spe_data, par_file, sqw_file, efix, emode, alatt, angdeg,...
                                                   u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
% Read a single spe file and a detector parameter file, and create a single sqw file.
% to file.
%
%   >> write_spe_to_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                                   u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
% Input:
%   dummy           Dummy sqw object  - used only to ensure that this service routine was called
%   spe_data        Source of spe data e.g. full file name of spe file or nxspe file
%   par_file        Full file name of detector parameter file (Tobyfit format)
%   sqw_file        Full file name of output sqw file
%
%   efix            Fixed energy (meV) (if elastic data ie. emode=0, the value will be ignored and set to zero internally)
%   emode           Direct geometry=1, indirect geometry=2, elastic=0
%   alatt           Lattice parameters (Ang^-1)
%   angdeg          Lattice angles (deg)
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (rad)
%   omega           Angle of axis of small goniometer arc w.r.t. notional u
%   dpsi            Correction to psi (rad)
%   gl              Large goniometer arc angle (rad)
%   gs              Small goniometer arc angle (rad)
%   grid_size_in    Scalar or row vector of grid dimensions. Default is [1x1x1x1]
%   urange_in       Range of data grid for output. If not given, then uses smallest hypercuboid
%                  that encloses the whole data range
%
% Output:
%   grid_size       Actual grid size used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Check that the first argument is sqw object
% -------------------------------------------
if ~isa(dummy,classname)    % classname is a private method
    error('Check type of input arguments')
end

% Check number of input arguments (necessary to get more useful error message because this is just a gateway routine)
% --------------------------------------------------------------------------------------------------------------------
if ~(nargin>=15 && nargin<=17)
    error('Check number of input arguments')
end
if is_herbert_used()
    if ~isa(spe_data,'speData')
        spe_file = spe_data;
    else
        error('WriteSpe2Sqw:InvalidArgument','Herbert IO do not understands speData yet');
    end
    run_file = gen_runfiles(spe_file,par_file,alatt,angdeg,efix,psi,omega,dpsi,gl,gs); 
    if numel(run_file)~=1
        error('Must only have one input data file');
    end
        
else
    if ~isa(spe_data,'speData') % if input parameter is the filename, we transform it into speData 
        spe_data = speData(spe_data);
    end
end


bigtic

% Set default grid size if none given
if ~exist('grid_size_in','var')
    grid_size_in=[1,1,1,1];
elseif ~(isnumeric(grid_size_in)&&(isscalar(grid_size_in)||(isvector(grid_size_in)&&all(size(grid_size_in)==[1,4]))))
    error ('Grid size must be scalar or row vector length 4')
end

% Check urange_in is valid, if provided
if exist('urange_in','var')
    if ~(isnumeric(urange_in) && length(size(urange_in))==2 && all(size(urange_in)==[2,4]) && all(urange_in(2,:)-urange_in(1,:)>=0))
        error('urange must be 2x4 array, first row lower limits, second row upper limits, with lower<=upper')
    end
else
    urange_in =[];
end

if is_herbert_used() % =============================> rundata files processing
    data = struct();
    % Read spe file and detector parameters if it has not been done before and
    % return the results, without NaN-s ('-nonan')
    [data.S,data.ERR,data.en,det]=get_rundata(run_file{1},'S','ERR','en',...
                                    'det_par', ...
                                     '-hor','-rad','-nonan');

    [data.filepath,data.filename]=fileparts(run_file{1}.loader.file_name);

    % get the list of all detectors, including the detectors, which produce
    % incorrect results (NaN-s) for this run
    det0 = det;
    
else
    % Read spe file and detector parameters
    [data,det,keep,det0]=get_data(spe_data, par_file);

end
%
[grid_size, urange]=calc_and_write_sqw(sqw_file, efix, emode, alatt, angdeg, u, v, psi,...
                                                      omega, dpsi, gl, gs, data, det, det0, grid_size_in, urange_in);
