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
%                   If [] then uses the smallest hyper-cuboid that encloses the whole data range.
%
%
% Output:
% --------
%   w               Output sqw object
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid - the specified range if it was given,
%                  or the range of the data if not.


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
[header,sqw_data]=calc_sqw_data_and_header(obj,detdcn);

% Flag if grid is in fact just a box i.e. 1x1x1x1
grid_is_unity = (isscalar(grid_size_in)&&grid_size_in==1)||(isvector(grid_size_in)&&all(grid_size_in==[1,1,1,1]));

% Set urange, and determine if all the data is on the surface or within the box defined by the ranges
if isempty(urange_in)
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
% If grid that is other than 1x1x1x1, or range was given, then sort pixels
if grid_is_unity && data_in_range   % the most work we have to do is just change the bin boundary fields
    for id=1:4
        sqw_data.p{id}=[urange(1,id);urange(2,id)];
    end
    grid_size = grid_size_in;
    
else
    if hor_log_level>-1
        disp('Sorting pixels ...')
    end
    
    [use_mex,nThreads]=config_store.instance().get_value('hor_config','use_mex','threads');
    if use_mex
        try
            % Verify the grid consistency and build axes along the grid dimensions,
            % c-program does not check the grid consistency;
            [grid_size,sqw_data.p]=construct_grid_size(grid_size_in,urange);
            
            sqw_fields   =cell(1,4);
            sqw_fields{1}=nThreads;
            %sqw_fields{1}=8;
            sqw_fields{2}=urange;
            sqw_fields{3}=grid_size;
            sqw_fields{4}=sqw_data.pix;
            clear sqw_data.s sqw_data.e sqw_data.npix;
            
            out_fields=bin_pixels_c(sqw_fields);
            
            sqw_data.s   = out_fields{1};
            sqw_data.e   = out_fields{2};
            sqw_data.npix= out_fields{3};
            sqw_data.pix = out_fields{4};
            
        catch
            warning('HORACE:using_mex','calc_sqw->Error: ''%s'' received from C-routine to rebin data, using matlab functions',lasterr());
            use_mex=false;
        end
    end
    if ~use_mex
        [ix,npix,p,grid_size,ibin]=sort_pixels(sqw_data.pix(1:4,:),urange,grid_size_in);
        
        sqw_data.p=p;   % added by RAE 10/6/11 to avoid crash when doing non-mex generation of sqw files
        sqw_data.pix=sqw_data.pix(:,ix);
        
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
    
    % If changed urange to something less than the range of the data, then must update true range
    if ~data_in_range
        sqw_data.urange(1,:)=min(sqw_data.pix(1:4,:),[],2)';
        sqw_data.urange(2,:)=max(sqw_data.pix(1:4,:),[],2)';
    end
end

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
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)


% Perform calculations
% -----------------------
% Get number of data elements
[ne,ndet]=size(obj.S);

% Calculate projections
[u_to_rlu,urange,pix] = obj.calc_projections_(detdcn,obj.qpsecs_cache);

p=cell(1,4);
for id=1:4
    p{id}=[urange(1,id);urange(2,id)];
end


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
header.uoffset = [0;0;0;0];
header.u_to_rlu = [[u_to_rlu;[0,0,0]],[0;0;0;1]];
header.ulen = [1,1,1,1];
header.ulabel = {'Q_\zeta','Q_\xi','Q_\eta','E'};
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
sqw_data.uoffset=[0;0;0;0];
sqw_data.u_to_rlu = [[u_to_rlu;[0,0,0]],[0;0;0;1]];
sqw_data.ulen = [1,1,1,1];
sqw_data.ulabel = {'Q_\zeta','Q_\xi','Q_\eta','E'};
sqw_data.iax=[];
sqw_data.iint=[];
sqw_data.pax=[1,2,3,4];
sqw_data.p=p;
sqw_data.dax=[1,2,3,4];
sqw_data.s=sum(obj.S(:));
sqw_data.e=sum(pix(9,:));   % take advantage of the squaring that has already been done for pix array
sqw_data.npix=ne*ndet;
sqw_data.urange=urange;
sqw_data.pix=pix;

