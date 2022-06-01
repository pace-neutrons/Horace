function [w, pix_range] = calc_sqw_(obj,grid_size_in, pix_db_range_in)
% Create an sqw object, optionally keeping only those data points within
% the defined data range.
%
%   >> [w, grid_size, pix_range] = obj.calc_sqw(grid_size_in,
%   pix_db_range_in)
%
% Input:
% ------
%   detdcn        - Direction of detector in spectrometer coordinates ([3 x ndet] array)
%                       [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%   det0           Detector structure corresponding to unmasked detectors. This
%                  is what is used int the creation of the sqw object.
%                  [If data has field qspec, then det is ignored]
% grid_size_in    - Scalar or [1x4] vector of grid dimensions
% pix_db_range_in - Range of data grid for bin pixels onto as a [2x4] matrix:
%                  [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]
%                  If [] then uses  obj.img_db_range which should be equal to
%                  the smallest hyper-cuboid that encloses the whole pixel range.
%
%
% Output:
% --------
%   w             - Output sqw object
%   grid_size     - Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   pix_db_range  - Actual range of grid - the specified range if it was given,
%                  or the range of the pixels if not. In this case, pix range
%                  is equivalent to image range


hor_log_level=config_store.instance().get_value('herbert_config','log_level');

% Fill output main header block
% -----------------------------
main_header.filename='';
main_header.filepath='';
main_header.title='';
main_header.nfiles=1;


% Fill header and data blocks
% ---------------------------
if hor_log_level>-1
    disp('Calculating projections...');
end

proj = obj.get_projection();

axes_bl = proj.get_proj_axes_block(pix_db_range_in,grid_size_in);
[exp_info,data] = calc_sqw_data_and_header (obj,axes_bl);

% in addition to standard operations, recalculates axes_block img_range if
% the range has not been defined before
[data.npix,data.s,data.e,pix,run_id,det0,axes_bl] = ...
    proj.bin_pixels(axes_bl,obj,data.npix,data.s,data.e);
[data.s, data.e] = normalize_signal(data.s, data.e, data.npix);

% either does nothing if img_range was defined before, or defines img_range
% equal to pix_range, if img_range was undefined
data.img_range = axes_bl.img_range;
exp_info.expdata(1).run_id = run_id;

data.pix=pix;
pix_range = pix.pix_range;


% Create sqw object (just a packaging of pointers, so no memory penalty)
% ----------------------------------------------------------------------

%data.u_to_rlu = eye(4); % conversion from pixels to image. Unity here?
%Different from what was in Horace 3.6.2
d.main_header=main_header;
d.experiment_info=exp_info;
d.detpar=det0;
d.data=data;
d.runid_map = containers.Map(run_id,1);

w=sqw(d);

%------------------------------------------------------------------------------------------------------------------
function [header,sqw_data] = calc_sqw_data_and_header (obj,axes_bl)
% Calculate sqw file header and data for a single spe file
%
% Input:
% ------
% Ouput:
% ------
%   header      Header information in data structure suitable for put_sqw_header
%   sqw_datstr    Data structure suitable for put_sqw_data

% Original author: T.G.Perring


% Create header block
% -------------------
[fp,fn,fe]=fileparts(obj.data_file_name);

lat = obj.lattice.set_rad();


sqw_data = data_sqw_dnd(axes_bl, ...
    'alatt',lat.alatt,'angdeg',lat.angdeg);
% Should be removed, and replaced by ortho_proj
[~, u_to_rlu] = obj.lattice.calc_proj_matrix();
ulen = [1,1,1,1];
uoffset = [0;0;0;0];
u_to_rlu =  [u_to_rlu,zeros(3,1);[0,0,0,1]];
%sqw_data.u_to_rlu = eye(4); % conversion from pixels to image. Sould it be
%unity here?
sqw_data.u_to_rlu =u_to_rlu;
% Old value creates confusion: sqw_data.u_to_rlu = u_to_rlu;
sqw_data.ulen = ulen;

expdata = IX_experiment([fn,fe], [fp,filesep], ...
    obj.efix,obj.emode,lat.u,lat.v,...
    lat.psi,lat.omega,lat.dpsi,lat.gl,lat.gs,...
    obj.en,uoffset,  u_to_rlu, ...
    ulen,sqw_data.label,obj.run_id);

header = Experiment([],obj.instrument,obj.sample,expdata);