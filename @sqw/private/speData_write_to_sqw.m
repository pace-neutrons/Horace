function [grid_size, urange] = speData_write_to_sqw (spe_data, par_file, sqw_file,...
    efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in, instrument, sample)
% Read a single spe file and a detector parameter file, and create a single sqw file.
%
%   >> [grid_size, urange] = speData_write_to_sqw (run_file, sqw_file, grid_size_in, urange_in, instrument, sample)
%
% Input:
% ------
%   spe_data        Cell array of initiated speData objects
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
%   grid_size_in    Scalar or row vector of grid dimensions.
%   urange_in       Range of data grid for output. If not given, then uses smallest hypercuboid
%                  that encloses the whole data range
%   instrument      Structure or object containing instrument information
%   sample          Structure or object containing sample geometry information
%
%
% Output:
% -------
%   grid_size       Actual grid size used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid


% Original author: T.G.Perring
%
% $Revision: 634 $ ($Date: 2012-06-20 10:07:00 +0100 (Wed, 20 Jun 2012) $)


bigtic

% Read spe file and detector parameters
% -------------------------------------
% Masked detectors (i.e. containing NaN signal) are removed from data and detectors
[data,det,keep,det0]=get_data(spe_data, par_file);

% Create sqw object
% -----------------
[w, grid_size, urange]=calc_sqw(efix, emode, alatt, angdeg, u, v, psi,...
    omega, dpsi, gl, gs, data, det, det0, grid_size_in, urange_in, instrument, sample);

bigtoc('Time to convert from spe to sqw data:')
disp(' ')


% Write sqw object
% ----------------
bigtic
save(w,sqw_file);
bigtoc('Time to save data to file:')
