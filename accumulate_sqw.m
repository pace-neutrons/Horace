function [tmp_file,grid_size,urange] = accumulate_sqw (varargin)
% Read one or more spe files and a detector parameter file, and accumulate to an existing sqw file.
%
% Normal use:
% (Give arguments for all expected input, even if the spe files do not exist)
%   >> accumulate_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs)
%
%  Create a fresh sqw file from those spe files that currently exist:
%   >> accumulate_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs, 'clean')
%
%  To allow an spe file to appear more than once:
%   >> accumulate_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs, 'replicate')
%
% Optionally (before any keywords):
%   >> accumulate_sqw (..., instrument, sample,...)        % instrument and sample information
%
%  If the sqw file dones not yet exist, or specifty 'clean', you can give fix the grid and data range:
%   >> accumulate_sqw (..., grid_size_in, urange_in)   % grid size and range of data to retain
%   >> accumulate_sqw (..., grid_size_in, urange_in, instrument, sample)
%
% If want output diagnostics:
%   >> [tmp_file,grid_size,urange] = accumulate_sqw (...)
%
% 
% The goal of accumulate_spe is to allow you to create an sqw file which has a data
% range large enough to contain all anticipated spe files, even if you do not
% have all the data yet. It does this by using the crystal orientation and energy
% information (and assuming an energy transfer range for non-existent spe files on the
% basis of those that do exist). On subsequent calls, spe files that have subsequently
% been created are accumulated to the sqw file, and any that already exist in the sqw
% file are skipped. That is, the original call to accumulate_sqw simply adds newly
% create spe files. You can change any of the input arguments on the later call; any
% runs that were not in the original call will not be accumulated to the sqw file - 
% but any data tha is outside the data range of the sqw file will be lost.
%
%
%
% Input: (in the following, nfile = anticipated number of spe files)
% ------
%   spe_file        Full file name of spe file - character string or cell array of
%                  character strings for more than one file. Give dummy names for spe
%                  files that do not yet exist: either the anticipated name, or an empty
%                  string, ''.
%   par_file        Full file name of detector parameter file (Tobyfit format)
%   sqw_file        Full file name of output sqw file
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2, elastic=0    [scalar]
%   alatt           Lattice parameters (Ang)           [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
%   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
%
% Optional arguments:
%   grid_size_in    [Optional] Scalar or row vector of grid dimensions
%                   Default if not given or [] is is [50,50,50,50]
%   urange_in       [Optional] Range of data grid for output as a 2x4 matrix:
%                              [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]
%                   Default if not given or [] is the smallest hypercuboid that encloses the whole data range.
%   instrument      Structure or object containing instrument information [scalar or array length nfile]
%   sample          Structure or object containing sample geometry information [scalar or array length nfile]
%
% Optional keyword arguments: (can be used singly or together)
%   'clean'         Create the sqw file from fresh. It is possible to get confused about what 
%                  data has been included in an sqw file if it is built up slowly over
%                  an experiment. Use this option to start afresh.
%
%   'replicate'     Normally the function forbids an spe file from appearing more than once.
%                  This is to trap common typing errors. However, sometimes you might want to
%                  to create an sqw file using, for example, just one spe file as the source
%                  of data for all crystal orientations in order to construct a background from an
%                  empty piece of sample environment. In this case, use the keyword 'replicate'
%                  to override the uniqueness check.
%
%
% Output:
% --------
%   tmp_file        List of temporary files created by this call to gen_sqw (can be empty
%                  e.g. if a single spe file, when no temporary file is created)
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid


% Original author: T.G.Perring
% Modified by R.A. Ewings from gen_sqw
% Generalised by T.G.Perring and now calls gen_sqw
%
% $Revision: 301 $ ($Date: 2009-11-03 15:52:59 -0500 (Tue, 03 Nov 2009) $)


% Gateway routine that calls sqw method
[tmp_file,grid_size,urange] = gen_sqw (sqw, varargin{:}, 'accumulate');

% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear tmp_file grid_size urange
end
