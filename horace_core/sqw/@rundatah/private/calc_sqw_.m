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
[header,sqw_datstr] = calc_sqw_data_and_header (obj,axes_bl);

[sqw_datstr.npix,sqw_datstr.s,sqw_datstr.e,pix,run_id] = ...
    proj.bin_pixels(ax_block,obj);

sqw_datstr.pix=pix;
pix_range = pix.pix_range;


% % Calculate projections
% [u_to_rlu,pix_range,pix] = obj.calc_projections_(detdcn,obj.qpsecs_cache);
% 
% [header,sqw_datstr]=calc_sqw_data_and_header(obj,detdcn);
% %pix_range = sqw_datstr.pix.pix_range;
% 
% % Flag if grid is in fact just a box i.e. 1x1x1x1
% grid_is_unity = (isscalar(grid_size_in)&&grid_size_in==1)||(isvector(grid_size_in)&&all(grid_size_in==[1,1,1,1]));
% 
% % Set pix_range, and determine if all the data is on the surface or within the box defined by the ranges
% if isempty(pix_db_range_in)
%     pix_db_range = sqw_datstr.img_db_range;   % range of the data
%     data_in_range = true;
% else
%     pix_db_range = pix_db_range_in;         % use input pix_range
%     if any(pix_db_range(1,:)>sqw_datstr.img_db_range(1,:)) || any(pix_db_range(2,:)<sqw_datstr.img_db_range(2,:))
%         data_in_range = false;
%     else
%         data_in_range = true;
%     end
% end
% % set up img range to the global range, used for binning
% sqw_datstr.img_db_range = pix_db_range;
% 
% % If grid that is other than 1x1x1x1, or range was given, then sort pixels
% if grid_is_unity && data_in_range   % the most work we have to do is just change the bin boundary fields
%     sqw_datstr.img_range = pix_db_range;
%     sqw_datstr.img_db_range = pix_db_range;    
%     grid_size = grid_size_in;
%     
% else
%     if hor_log_level>-1
%         disp('Sorting pixels ...')
%     end
%     
%     [use_mex,nThreads]=config_store.instance().get_value('hor_config','use_mex','threads');
%     if use_mex
%         try
%             % Verify the grid consistency and build axes along the grid dimensions,
%             % c-program does not check the grid consistency;
%             [grid_size,sqw_datstr.p]=construct_grid_size(grid_size_in,pix_db_range);
%             
%             sqw_fields   =cell(1,4);
%             sqw_fields{1}=nThreads;
%             %sqw_fields{1}=8;
%             sqw_fields{2}=pix_db_range;
%             sqw_fields{3}=grid_size;
%             sqw_fields{4}=sqw_datstr.pix.data;
%             clear sqw_datstr.s sqw_datstr.e sqw_datstr.npix;
%             
%             out_fields=bin_pixels_c(sqw_fields);
%             
%             sqw_datstr.s   = out_fields{1};
%             sqw_datstr.e   = out_fields{2};
%             sqw_datstr.npix= out_fields{3};
%             sqw_datstr.pix = PixelData(out_fields{4});
%         catch ME
%             warning('HORACE:using_mex','calc_sqw->Error: ''%s'' received from C-routine to rebin data, using matlab functions', ...
%                 ME.message);
%             use_mex=false;
%         end
%     end
%     if ~use_mex
%         [ix,npix,p,grid_size,ibin]=sort_pixels_by_bins(sqw_datstr.pix.coordinates,pix_db_range,grid_size_in);
%         
%         sqw_datstr.p=p;   % added by RAE 10/6/11 to avoid crash when doing non-mex generation of sqw files
%         sqw_datstr.pix=sqw_datstr.pix.get_pixels(ix);
%         
%         sqw_datstr.s=reshape(accumarray(ibin,sqw_datstr.pix.signal,[prod(grid_size),1]),grid_size);
%         sqw_datstr.e=reshape(accumarray(ibin,sqw_datstr.pix.variance,[prod(grid_size),1]),grid_size);
%         sqw_datstr.npix=reshape(npix,grid_size);      % All we do is write to file, but reshape for consistency with definition of sqw data structure
%         sqw_datstr.s=sqw_datstr.s./sqw_datstr.npix;       % normalise data
%         sqw_datstr.e=sqw_datstr.e./(sqw_datstr.npix).^2;  % normalise variance
%         clear ix ibin   % biggish arrays no longer needed
%         nopix=(sqw_datstr.npix==0);
%         sqw_datstr.s(nopix)=0;
%         sqw_datstr.e(nopix)=0;
%         
%         clear nopix     % biggish array no longer needed
%     end
%     
% end
% id = obj.run_id;
% if isnan(id)
%     id = 1;
% end

% Create sqw object (just a packaging of pointers, so no memory penalty)
% ----------------------------------------------------------------------
data = data_sqw_dnd(sqw_datstr);
data.u_to_rlu = u_to_rlu;
d.main_header=main_header;
d.experiment_info=header;
d.detpar=det0;
d.data=data;
d.runid_map = containers.Map(run_id,1);

w=sqw(d);


%------------------------------------------------------------------------------------------------------------------
function [header,sqw_datstr] = calc_sqw_data_and_header (obj,axes_bl)
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

header = Experiment([],obj.instrument,obj.sample);

sqw_datstr = data_sqw_dnd(axes_bl, ...
    'alatt',lat.alatt,'angdeg',lat.angdeg);
% Should be removed, and replaced by ortho_proj
[~, u_to_rlu] = obj.lattice.calc_proj_matrix();
sqw_datstr.u_to_rlu = u_to_rlu;
sqw_datstr.ulen = ones(1,4);


header.expdata = IX_experiment([fn,fe], [fp,filesep], ...
    obj.efix,obj.emode,lat.u,lat.v,...
    lat.psi,lat.omega,lat.dpsi,lat.gl,lat.gs,...
    obj.en,uoffset,u_to_rlu,ulen,ulabel);
