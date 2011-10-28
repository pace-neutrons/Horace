function [grid_size, urange,sqw_file_name] = rundata_write_to_sqw (dummy,run_file,emode,u,v,grid_size_in, urange_in)
% Read a single spe file and a detector parameter file, and create a single sqw file.
% to file.
%
%   >> write_spe_to_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                                   u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
% Input:
%   dummy           Dummy sqw object  - used only to ensure that this service routine was called
%   run_file        Fully initiated by rundata information instance of @rundata class
%   sqw_file        Full file name of output sqw file
%
%   emode           Direct geometry=1, indirect geometry=2
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
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
% $Revision: 552 $ ($Date: 2011-06-13 12:42:02 +0100 (Mon, 13 Jun 2011) $)



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
end

data = struct();
% Read spe file and detector parameters if it has not been done before;
[data.S,data.ERR,data.en,det,efix,alatt,angdeg,...
 psi,omega,dpsi,gl,gs]=get_rundata(run_file,'S','ERR','en',...
                                    'det_par','efix','alatt', 'angldeg',...
                                    'psi','omega', 'dpsi', 'gl', 'gs',...
                                     '-hor','-rad');

[data.filepath,data.filename]=fileparts(run_file.loader.file_name);

[sqw_path,sqw_name]=get_sqw_fname(run_file);
sqw_file_name =fullfile(sqw_path,sqw_name); 

det0 = det;

[grid_size, urange]=calc_and_write_sqw(sqw_file_name,grid_size_in,urange_in, ...
                                       efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det,det0);

