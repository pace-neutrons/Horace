function [tmp_file,grid_size,urange] = gen_sqw (varargin)
% Read one or more spe files and a detector parameter file, and create an output sqw file.
%
% Normal use:
%   >> gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs)
%
%  To allow an spe file to appear more than once:
%   >> gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs, 'replicate')
%
% Optionally (before the keyword 'replicate' if present):
%   >> gen_sqw (..., instrument, sample,...)        % instrument and sample information
%   >> gen_sqw (..., grid_size_in, urange_in,...)   % grid size and range of data to retain
%   >> gen_sqw (..., grid_size_in, urange_in, instrument, sample,...)
%
%
% If want output diagnostics:
%   >> [tmp_file,grid_size,urange] = gen_sqw (...)
%
%
% Input: (in the following, nfile = number of spe files)
% ------
%   spe_file        Full file name of spe file - character string or cell array of
%                  character strings for more than one file
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
% Optional keyword argument:
%   'replicate'     Normally the function forbids an spe file from appearing more than once.
%                  This is to trap common typing errors. However, sometimes you might want to
%                  to create an sqw file using, for example, just one spe file as the source
%                  of data for all crystal orientations in order to construct a background from an
%                  empty piece of sample environment. In this case, use the keyword 'replicate'
%                  to override the uniqueness check on file name.
%
%  'transform_sqw' Keyword, followed by the function, which actually
%                  transforms sqw object. The function should have the
%                  form:
%                  wout = f(win) where win is input sqw object and wout -- 
%                  the transformed one. For example f can symmeterize sqw file: 
% i.e:
%   >> gen_sqw(...,...,...,'transform_sqw',@(x)(symmetrise_sqw(x,[0,1,0],[0,0,1],[0,0,0])))
%                  would symmeterize pixels of the generated sqw file by
%                  reflecting them in the plane specified by vectors
%                  [0,1,0], and [0,0,1] (see symmeterise_sqw for details)
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
%
% $Revision$ ($Date$)


% Gateway routine that calls sqw method
[tmp_file,grid_size,urange] = gen_sqw (sqw, varargin{:});


% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear tmp_file grid_size urange
end
