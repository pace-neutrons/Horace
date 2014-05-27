function [grid_size, urange] = write_qspec_to_sqw (dummy, qspec_file, sqw_file, efix, emode, alatt, angdeg,...
                                                   u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
% Read ascii column data and create a single sqw file.
%
%   >> write_qspec_to_sqw (dummy, qspec_file, sqw_file, efix, emode, alatt, angdeg,...
%                                                   u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
% Input:
% ------
%   dummy           Dummy sqw object  - used only to ensure that this service routine was called
%   qspec_file      Full file name of ascii file containing qx-qy-qz-eps-signal-error column data.
%                   Here qz  is the component of momentum along ki (Ang^-1)
%                        qy  is component vertically upwards (Ang^-1)
%                        qx  defines a hight-hand coordinate frame with qy' and qz'
%                        S   signal
%                        ERR standard deviation
%                       
%   sqw_file        Full file name of output sqw file
%
%   efix            Fixed energy (meV) (if elastic data ie. emode=0, the value will be ignored)
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
% -------
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
if ~(nargin>=14 && nargin<=16)
    error('Check number of input arguments')
end

bigtic

% Check input grid size, if given (will set default grid size if none given later)
if exist('grid_size_in','var') && ~(isnumeric(grid_size_in)&&(isscalar(grid_size_in)||(isvector(grid_size_in)&&all(size(grid_size_in)==[1,4]))))
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

% Read qx-qy-qz-signal-error file
if exist(qspec_file,'file')
    [data,det,is_mat_file]=get_mat_column_data(qspec_file);
    if ~is_mat_file
        [data,det]=get_ascii_column_data(qspec_file);
    end
    detdcn=calc_detdcn(det);
    if ~exist('grid_size_in','var')
        npnt=size(data.qspec,2);
        is_elastic=(all(data.qspec(4,:)==0));
        grid_size_in=make_grid_size(npnt,is_elastic);
    end
else
    error(['File does not exist: ',qspec_file])
end

% Calculate sqw object and save to file
efix=0;
emode=0;
instrument_default=struct;  % default 1x1 struct *** Should generalise
sample_default=struct;      % default 1x1 struct *** Should generalise
[w,grid_size, urange]=calc_sqw(efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det, detdcn, det,...
    grid_size_in, urange_in, instrument_default, sample_default);
save(w,sqw_file);

%-------------------------------------------------------------------------------------
function grid_size=make_grid_size(npnt,is_elastic)
% Make a first estimate of grid size to use in sqw file
npnt_per_bin=1000;
if ~is_elastic
    nbin=ceil(sqrt(sqrt(ceil(npnt/npnt_per_bin))));
    grid_size=[nbin,nbin,nbin,nbin];
else
    nbin=ceil((ceil(npnt/npnt_per_bin))^(1/3));
    grid_size=[nbin,nbin,nbin,1];
end
