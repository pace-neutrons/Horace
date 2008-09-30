function [grid_size, urange] = write_spe_to_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
                                                   u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
% Read a single spe file and a detector parameter file, and create a single sqw file.
% to file.
%
%   >> write_spe_to_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                                   u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
% Input:
%   spe_file        Full file name of spe file
%   par_file        Full file name of detector parameter file (Tobyfit format)
%   sqw_file        Full file name of output sqw file
%
%   efix            Fixed energy (meV)
%   emode           Direct geometry=1, indirect geometry=2
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
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

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

% Fill output main header block
[path,name,ext,ver]=fileparts(strtrim(sqw_file));
main_header.filename=[name,ext,ver];
main_header.filepath=[path,filesep];
main_header.title='';
main_header.nfiles=1;

% Read spe file and detector parameters
[data,det,keep,det0]=get_data(spe_file, par_file);

% Calculate projections and fill data blocks to be written to file
disp('Calculating projections...')
[header,sqw_data]=calc_sqw (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);
sqw_data.filename=main_header.filename;
sqw_data.filepath=main_header.filepath;
sqw_data.title=main_header.title;

clear data det  % Clear large variables from memory before start writing - writing seems to use lots of temporary memory

% flag if grid is in fact just a box i.e. 1x1x1x1
grid_is_unity = (isscalar(grid_size_in)&&grid_size_in==1)||(isvector(grid_size_in)&&all(grid_size_in==[1,1,1,1]));

% Set urange, and determine if all the data is on the surface or within the box defined by the ranges
if ~exist('urange_in','var')
    urange = sqw_data.urange;   % range of the data
    data_in_range = true;
else
    urange = urange_in;         % use input urange
    if any(urange(1,:)>sqw_data.urange(1,:)) || any(urange(2,:)<sqw_data.urange(2,:))
        data_in_range = false;
    else
        data_in_range = true;
    end
end

% if grid that is other than 1x1x1x1, or range was given, then sort pixels
% (Recall that urange does NOT need to be changed, as urange is the true range of the pixels)

if grid_is_unity && data_in_range   % the most work we have to do is just change the bin boundary fields
    for id=1:4
        sqw_data.p{id}=[urange(1,id);urange(2,id)];
    end
    grid_size = grid_size_in;
else
    disp('Sorting pixels ...')
    [ix,npix,p,grid_size,ibin]=sort_pixels(sqw_data.pix(1:4,:),urange,grid_size_in);
    sqw_data.pix=sqw_data.pix(:,ix);
    sqw_data.p=p;
    sqw_data.s=reshape(accumarray(ibin,sqw_data.pix(8,:),[prod(grid_size),1]),grid_size);
    sqw_data.e=reshape(accumarray(ibin,sqw_data.pix(9,:),[prod(grid_size),1]),grid_size);
    sqw_data.npix=reshape(npix,grid_size);      % All we do is write to file, but reshape for consistency with definition of sqw data structure
    sqw_data.s=sqw_data.s./sqw_data.npix;       % normalise data
    sqw_data.e=sqw_data.e./(sqw_data.npix).^2;  % normalise variance
    clear ix ibin   % biggish arrays no longer needed
    nopix=(sqw_data.npix==0);
    sqw_data.s(nopix)=0;
    sqw_data.e(nopix)=0;
    clear nopix     % biggish array no longer needed
end


% Write header, detector parameters and processed data
% -------------------------------------------------------
disp(['Writing sqw data to ',sqw_file,' ...'])

% Open output file
fid=fopen(sqw_file,'W');    % upper case 'W' means no automatic flushing of buffer - can be faster
if fid<0
    error(['Unable to open file output file ',sqw_file])
end

mess=sqw_put (fid,main_header,header,det0,sqw_data);
fclose(fid);
if ~isempty(mess)
    error('Error writing data to file %s \n %s',sqw_file,mess)
end

% Display timings
bigtoc('Time to convert from spe to sqw file:')
