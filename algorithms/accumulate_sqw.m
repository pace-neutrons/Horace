function [tmp_file,grid_size,urange] = accumulate_sqw (varargin)
% Read one or more spe files and a detector parameter file, and accumulate to an existing sqw file.
%
% Normal use:
% -----------
% The standard way to use accumulate_sqw is to pass the file names and parameters for
% all the runs that are *anticipated* to be combined, but might not yet exist. Initially
% call with the keyword 'clean' to force a fresh sqw file to be created:
% 
%   >> accumulate_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs, 'clean')
% 
% As the experiment continues, subsequent calls to accumulate_sqw can be made with the
% same argument list, apart from removing the keyword 'clean'. A check is made in the
% function to determine which of the spe files have already been accumulated to the sqw file
% and they will be skipped over:
%
%   >> accumulate_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs)
%
% You can always accumulate spe data that wasn't in your original list: the
% only thing you have to be aware of is that any data outside the range that was
% calculated for the original list of anticipated spe files and parameters will be
% ignored. (See 'Notes' below for the details why this is.)
%
%
% Sometimes you might want to allow an spe file to appear more than once in the list
% of input data - for example you are contructing a 'background' data set from just
% one spe file but for each of a set of crystal orientations. Normally accumulate_sqw
% will return an error, but to overide this behaviour call with the 'replicate' keyword
% in addition:
%
%   >> accumulate_sqw (..., 'replicate')
%
%
% Optional arguments (must appear before any keywords):
% -----------------------------------------------------
% Include instrument and sample information:
%
%   >> accumulate_sqw (..., instrument, sample,...)        
%
% If the sqw file does not yet exist, or you  specify 'clean', you can give fix
% the grid and data range:
%   >> accumulate_sqw (..., grid_size_in, urange_in)
%   >> accumulate_sqw (..., grid_size_in, urange_in, instrument, sample)
%
%
% If want output diagnostics:
% ---------------------------
%   >> [tmp_file,grid_size,urange] = accumulate_sqw (...)
%
% 
% Notes
% -----
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
%   'time',[yyyy,mm,dd,hh,mm,ss]    Specify a time at which file
%                   accumulation should start, in specified date-time
%                   format. This is for when file accumulation is very time
%                   consuming, so you may wish to start the process a few
%                   hours before you come in of a morning (for example).
%                   The program will be inactive (and not other Matlab
%                   commands may be issued) until the specified time is
%                   reached.
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
% New time feature added by R.A. Ewings (30/11/2015)
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)


% Gateway routine that calls sqw method
[tmp_file,grid_size,urange] = gen_sqw (varargin{:}, 'accumulate');

% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear tmp_file grid_size urange
end
