function [tmp_file, grid_size, urange] = fake_sqw (varargin)
% Create an sqw file with dummy data from energy bins instead of spe file(s).
%
%   >> fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                    u, v, psi, omega, dpsi, gl, gs)
%
%   >> fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                    u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
% For afficionados:
%   >> [tmp_file, grid_size, urange] = fake_sqw (...)
%
% Input:
% ------
%   en              Energy bin boundaries (must be monotonically increasing
%                  and equally spaced)
%                   - array of energy bins, or
%                   - cell array of arrays of energy bin boundaries, one
%                     array per spe file
%   par_file        Full file name of detector parameter file
%   sqw_file        Full file name of output sqw file
%   efix            Fixed energy (meV)                 [scalar or vector]
%   emode           Direct geometry=1, indirect geometry=2    [scalar]
%   alatt           Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (deg)         [scalar or vector]
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg)
%                                                      [scalar or vector]
%   dpsi            Correction to psi (deg)            [scalar or vector]
%   gl              Large goniometer arc angle (deg)   [scalar or vector]
%   gs              Small goniometer arc angle (deg)   [scalar or vector]
%   grid_size_in    [Optional] Scalar or row vector of grid dimensions. The
%                  default size will depend on the product of energy bins 
%                  and detector elements summed across all the spe files.
%   urange_in       [Optional] Range of data grid for output. If not given,
%                  then uses smallest hypercuboid that encloses the whole
%                  data range.
%
% Output:
% --------
%   tmp_file        List of temporary files
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid
%
%
% Use to generate an sqw file that can be used for creating simulations.
% The syntax very similar to gen_sqw: the only difference is that the input
% spe data is replaced by energy bin boundaries.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Gateway routine that calls sqw method
[tmp_file, grid_size, urange] = fake_sqw (sqw, varargin{:});

% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear tmp_file grid_size urange
end
