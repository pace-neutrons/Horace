function [w, data_range] = calc_sqw_(obj,grid_size_in, pix_db_range_in)
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
%   w              - Output sqw object
%   data_range     - Actual range of pixels and pixels data (2x9 array of min/max values.
%                    The pixels coordinates (first 4 columns) are inside of
%                    the input coordinate range.


hor_log_level = get(hor_config,'log_level');

% Fill header and data blocks
% ---------------------------
if hor_log_level>-1
    disp('Calculating projections...');
end

instproj = obj.get_projection();

axes_bl = instproj.get_proj_axes_block(pix_db_range_in,grid_size_in);
[exp_info,data] = calc_sqw_data_and_header (obj,axes_bl);

% in addition to standard operations, recalculates ortho_axes img_range if
% the range has not been defined before:
[data.npix,data.s,data.e,pix,run_id,det0,axes_bl] = ...
    instproj.bin_pixels(axes_bl,obj,data.npix,data.s,data.e);
[data.s, data.e] = normalize_signal(data.s, data.e, data.npix);
data.axes.img_range = axes_bl.img_range; % the range the data are binned on

exp_info.expdata(1).run_id = run_id;

data_range = pix.data_range; % the range pixels have

% Create sqw object (just a packaging of pointers, so no memory penalty)
% ----------------------------------------------------------------------
w=sqw();
w.main_header.nfiles = 1;
w.main_header.creation_date = datetime('now');
w.detpar = det0;
w.experiment_info = exp_info;
w.data = data;
w.pix=pix;
% move detector data from detpar into the experiment info detector arrays
w = w.check_combo_arg();

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
[~, u_to_rlu] = obj.lattice.calc_proj_matrix();
offset = [0;0;0;0];

% set projection lattice, which transforms initial pixel coordinates to
% initial image coordinates. As initial image coordinates are Crystal
% Cartesian, the initial projection does unary transformation
% from crystal Cartesian pixels to crystal Cartesian image.
% Initial crystal orientation vrt. the beam have been accounted for by
% transformation to spectrometer coordinate system
proj = ortho_proj('alatt',lat.alatt,'angdeg',lat.angdeg, 'type','aaa');



sqw_data = DnDBase.dnd(axes_bl,proj);

expdata = IX_experiment([fn,fe], [fp,filesep], ...
    obj.efix,obj.emode,lat.u,lat.v,...
    lat.psi,lat.omega,lat.dpsi,lat.gl,lat.gs,...
    obj.en,offset,  u_to_rlu, ...
    [1,1,1,1],sqw_data.label,obj.run_id);

detpar = obj.det_par;

if isempty(detpar)
    header = Experiment([],obj.instrument,obj.sample,expdata);
    % the detector arrays will be inserted later from detpar
else
    detector = IX_detector_array(obj.det_par);
    obj.compressed_detpars = obj.compressed_detpars.add(detector);

    header = Experiment(obj.compressed_detpars,obj.instrument,obj.sample,expdata);
end