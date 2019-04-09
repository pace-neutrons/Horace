function [grid_size, urange] = write_spe_to_sqw (varargin)
% Read a single spe file and a detector parameter file, and create a single sqw file.
%
%   >> write_spe_to_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                                   u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
% *** DEPRECATED FUNCTION **********************************************************
% 
% Calls to this function should be replaced by a call to gen_sqw. The only
% differences are:
%   - The angles psi, omega, dpsi, gl, gs are entered in degrees
%     in gen_sqw, but are radians in write-spe_to_sqw
%   - [Rarely used] The output from gen_sqw will return an empty parameter as the 
%     first argument. The second and third argument output arguments are the 
%     same as the first and second from write_spe_to_sqw
%
% **********************************************************************************
%
% Input:
% ------
%   spe_file        Full file name of spe data e.g. spe file or nxspe file
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
%   grid_size_in    [Optional] Scalar or row vector of grid dimensions. Default is [1x1x1x1]
%   urange_in       [Optional] Range of data grid for output. If not given, then uses smallest hypercuboid
%                  that encloses the whole data range
%
% Output:
% -------
%   grid_size       Actual grid size used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)


% Gateway routine that calls sqw method
[grid_size,urange] = write_spe_to_sqw (sqw, varargin{:});

% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear grid_size urange
end
