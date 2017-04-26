function [w, grid_size, urange] = calc_sqw_(obj,detdcn, det0, grid_size_in, urange_in)
% Create an sqw object, optionally keeping only those data points within a defined data range.
%
%   >> [w, grid_size, urange] = obj.calc_sqw(detdch, det0,grid_size_in,
%   urange_in)
%
% Input:
% ------
%   detdcn         Direction of detector in spectrometer coordinates ([3 x ndet] array)
%                       [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%   det0           Detector structure corresponding to unmasked detectors. This
%                  is what is used int the creation of the sqw object. It must
%                  be consistent with det.
%                  [If data has field qspec, then det is ignored]
%   grid_size_in    Scalar or [1x4] vector of grid dimensions
%   urange_in       Range of data grid for output as a [2x4] matrix:
%                     [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]
%                   If [] then uses the smallest hypercuboid that encloses the whole data range.
%
%
% Output:
% --------
%   w               Output sqw object
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid - the specified range if it was given,
%                  or the range of the data if not.


hor_log_level=config_store.instance().get_value('hor_config','log_level');

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
[header,sqw_data]=calc_sqw_data_and_header(obj,detdcn);
% TODO: aProjection for the time beeing, change to projection with
% appropriate constructor!
sqw_data.proj = aProjection(grid_size_in,urange_in);

[sqw_data.s,sqw_data.e,sqw_data.npix,sqw_data.pix]...
    = sqw_data.proj.sort_pixels_by_bins(sqw_data.pix,sqw_data.urange);

% Create sqw object (just a packaging of pointers, so no memory penalty)
% ----------------------------------------------------------------------
d.main_header=main_header;
d.header=header;
d.detpar=det0;
d.data=data_sqw_dnd(sqw_data);
w=sqw(d);


%------------------------------------------------------------------------------------------------------------------
function [header,sqw_data] = calc_sqw_data_and_header (obj,detdcn)
% Calculate sqw file header and data for a single spe file
%
%   >> [header,sqw_data] = calc_sqw_header_data (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det)
%
% Input:
% ------
%              [If data has field qspec, then det is ignored]
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%                   [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%
% Ouput:
% ------
%   header      Header information in data structure suitable for put_sqw_header
%   sqw_data    Data structure suitable for put_sqw_data

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Perform calculations
% -----------------------
% Get number of data elements
%[ne,ndet]=size(obj.S);

% Calculate projections of the instrument data into the q-space;
[u_to_rlu,urange,pix] = convert_to_cryst_frame_(obj,detdcn,obj.qpsecs_cash);

%p=cell(1,4);
%for id=1:4
%    p{id}=[urange(1,id);urange(2,id)];
%end


% Create header block
% -------------------
[fp,fn,fe]=fileparts(obj.data_file_name);

header.filename = [fn,fe];
header.filepath = [fp,filesep];
header.efix     = obj.efix;
header.emode = obj.emode;
%TODO: Wrap in lattice:
%header.lattice  = obj.lattice;
lat = obj.lattice.set_rad();
header.alatt = lat.alatt;
header.angdeg = lat.angdeg;
header.cu = lat.u;
header.cv = lat.v;
header.psi = lat.psi;
header.omega = lat.omega;
header.dpsi = lat.dpsi;
header.gl = lat.gl;
header.gs = lat.gs;
%<< -- end of lattice

header.en       = obj.en;
%>------------ a single file data projection! --> TODO: generalize to
%projection
header.uoffset = [0;0;0;0];
header.u_to_rlu = [[u_to_rlu;[0,0,0]],[0;0;0;1]];
header.ulen = [1,1,1,1];
header.ulabel = {'Q_\zeta','Q_\xi','Q_\eta','E'};
%<------------ a file projection!
% Update some header fields
header.instrument=obj.instrument;
header.sample=obj.sample;


% Now package the data
% --------------------
sqw_data.filename = '';
sqw_data.filepath = '';
sqw_data.title = '';
sqw_data.alatt = obj.lattice.alatt;
sqw_data.angdeg = obj.lattice.angdeg;
% %------------ projection:
% sqw_data.uoffset=[0;0;0;0];
% sqw_data.u_to_rlu = [[u_to_rlu;[0,0,0]],[0;0;0;1]];
% sqw_data.ulen = [1,1,1,1];
% sqw_data.ulabel = {'Q_\zeta','Q_\xi','Q_\eta','E'};
% sqw_data.iax=[];
% sqw_data.iint=[];
% sqw_data.pax=[1,2,3,4];
% sqw_data.p=p;
% sqw_data.dax=[1,2,3,4];
% <-----------
%sqw_data.s=sum(obj.S(:));
%sqw_data.e=sum(pix(9,:));   % take advantage of the squaring that has already been done for pix array
%sqw_data.npix=ne*ndet;
% pix_info:
sqw_data.urange=urange;
sqw_data.pix=pix;
