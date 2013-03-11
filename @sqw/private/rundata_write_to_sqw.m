function [grid_size, urange] = rundata_write_to_sqw (run_file, sqw_file, grid_size_in, urange_in, instrument, sample)
% Read a single spe file and a detector parameter file, and create a single sqw file.
%
%   >> [grid_size, urange] = rundata_write_to_sqw (run_file, sqw_file, grid_size_in, urange_in, instrument, sample)
%
% Input:
% ------
%   run_file        Fully initiated by rundata information instance of @rundata class
%   sqw_file        Full file name of output sqw file
%   grid_size_in    Scalar or row vector of grid dimensions.
%   urange_in       Range of data grid for output. If not given, then uses smallest hypercuboid
%                  that encloses the whole data range
%   instrument      Structure or object containing instrument information
%   sample          Structure or object containing sample geometry information
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
% Note: algorithm updates only if not already read from disk
data = struct();
[data.S,data.ERR,data.en,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs,det]=...
    get_rundata(run_file,'S','ERR','en','efix','emode','alatt','angldeg','u','v',...
                         'psi','omega','dpsi','gl','gs','det_par','-hor','-rad','-nonan');

[data.filepath,data.filename]=get_source_fname(run_file);

% Get the list of all detectors, including the detectors correspondiong to masked detectors
det0 = get_rundata(run_file,'det_par','-hor');


% Create sqw object
% -----------------
[w, grid_size, urange]=calc_sqw(efix, emode, alatt, angdeg, u, v, psi,...
    omega, dpsi, gl, gs, data, det, det0, grid_size_in, urange_in, instrument, sample);

bigtoc('Time to convert from spe to sqw data:')


% Write sqw object
% ----------------
bigtic
save(w,sqw_file);
bigtoc('Time to save data to file:')
