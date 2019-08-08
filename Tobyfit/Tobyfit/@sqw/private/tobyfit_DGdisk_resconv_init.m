function [ok,mess,lookup,npix] = tobyfit_DGdisk_resconv_init (win, varargin)
% Fill various lookup tables and matrix transformations for resolution calculations
%
% For all pixels in the input sqw object(s):
%   >> [ok,mess,lookup]=tobyfit_DGdisk_resconv_init(win)
%
% For specific pixels:
%   >> [ok,mess,lookup]=tobyfit_DGdisk_resconv_init(win,indx)
%
% No lookup tables:
%   >> [ok,mess,lookup]=tobyfit_DGdisk_resconv_init(...,'notables')
%
% Special case of recovering the Monte Carlo contribution options:
%   >> [ok,mess,mc_contr]=tobyfit_DGdisk_resconv_init
%
%
% This routine is used in Tobyfit resolution convolution, and by other methods
% that need to know about resolution functions. Note that for Tobyfit the
% constraints of the mfclass_class object for initialisation function have a very
% specific function call: [ok,mess,lookup]=tobyfit_DGdisk_resconv_init(win) i.e
% no other optional paratmeters.
%
% Input:
% ------
%   win         Array of sqw objects, or cell array of scalar sqw objects
%
%  [Optional]
%   indx        Pixel indicies:
%
%               Single sqw object:
%               ------------------
%                 - ipix            Array of pixels indicies
%            *OR* - {irun,idet,ien} Arrays of run, detector and energy bin index
%                                   Dimension expansion is performed on scalar
%                                  quantities i.e. each must be a scalar or array
%                                  with arrays having the same length
%
%               Multiple sqw objects:
%               ---------------------
%                 - As above, assumed to apply to all sqw objects,
%            *OR* - Cell array of the above, one cell array per sqw object
%                  e.g. if two sqw objects:
%                       {ipix1, ipix2}
%                       {{irun1,idet1,ien1}, {irun2,idet2,ien2}}
%
%   opt         Option: 'tables' (default) or 'notables'
%               If 'tables', then moderator and divergence lookup tables
%              are added to the output argument lookup
%
% Output:
% -------
%   ok          Status flag: =true if all ok, =false otherwise
%
%   mess        Error message: empty if ok, contains error message if not ok
%
%   lookup      Lookup tables and pre-calculated matricies etc.
%               - If win was an sqw object or array of sqw objects, then lookup
%                is a structure
%               - If win was a cell array of sqw objects, then lookup is a cell
%                array with that structure as the single element
%
%               For details of contents of lookup, see below.
%
%   npix        Array of number of pixels for each workspace after selecting
%               with the indexing argument indx. (Array has same size as win)
%
%
% Contents of output argument: lookup
% -----------------------------------
%       Indexed lookup tables: object_lookup objects
%           mod_shape_mono_table    Index: [isqw, irun] (note: times in microseconds)
%           horiz_div_table         Index: [isqw, irun] (note: angle in radians)
%           vert_div_table          Index: [isqw, irun] (note: angle in radians)
%           sample_table            Index: [1, isqw]
%           detector_table          Index: [1, isqw]
%
%       Cell array of arrays, one array per dataset, each array with length equal to
%      the number of runs in each dataset:
%           ei          Incident energies (mev)     [Column vector]
%           x0          Moderator - monochromating chopper distance (m)     [Column vector]
%           xa          Shaping chopper - monochromating chopper distance (m)   [Column vector]
%           x1          Monochromating chopper - sample distance (m)        [Column vector]
%           shaped_mod  Logical vectors where true indicates that the       [Column vector]
%                       initial pulse is largely determined by the shaping  [Column vector]
%                       chopper i.e. fwhh due to the chopper is smaller than
%                       that of the moderator pulse (after geometric scaling)
%
%       Cell arrays of incident and final wavevectors, one array per dataset
%           ki          Incident wavevectors [Column vector, length nruns]
%           kf          Final wavevectors [Column vector, length npix]
%
%       Cell arrays of arrays of transformation matricies, one array per dataset:
%           s_mat       Matrix to convert coords in sample frame to spectrometer frame.
%                      Size is [3,3,nrun], where nrun is the number of runs
%           spec_to_rlu Matrix to convert momentum in spectrometer coordinates to
%                      components in r.l.u.:
%                           v_rlu = spec_to_rlu * v_spec
%                      Size is [3,3,nrun], where nrun is the number of runs
%           alatt       Lattice parameters (Angstroms), vector size[1,3]
%           angdeg      Lattice angles in degrees (Angstroms), vector size[1,3]
%
%       Cell arrays of arrays of detector information, one array per datasets
%           f_mat       Array size [3,3,ndet] to take coordinates in spectrometer
%                      frame and convert into secondary spectrometer frame.
%
%           d_mat       Array size [3,3,ndet] to take coordinates in detector
%                      frame and convert into secondary spectrometer frame.
%
%           detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%
%           x2          Sample-detector distances (m) (size [ndet,1])
%
%       Cell array of widths of energy bins, one array per dataset
%           dt          Time widths for each pixel (s), size [npix,1]
%
%       Cell arrays of q,w and transformation arrays, one array per dataset
%           qw          Cell array size [1,4] with components of momentum (in rlu) and energy
%                      for each pixel [Columns]
%
%           dq_mat      Array of matricies, size [4,11,npix],  to convert deviations in
%                      tm, tch etc. into deviations in Q in rlu
%
%       Constants:
%           k_to_e      Constant in E(mev)=k_to_e*(k(Ang^-1))^2
%           k_to_v      Constant in v(m/s)=k_to_v*k(Ang^-1)
%
%
% *OR*
%   mc_contr        Cell array of character strings with the names of the
%                  possible contributions e.g. {'chopper','moderator'}


% Use 3He cylindrical gas tube (ture) or Tobyfit original (false)
use_tubes=true;

% Catch case of inquiry about mc_contributions
% --------------------------------------------
if nargin==0
    ok=true;
    mess='';
    lookup={'moderator','shape_chopper','mono_chopper',...
        'horiz_divergence','vert_divergence','sample',...
        'detector_depth','detector_area','energy_bin','mosaic'}';
    return
end


% Initialise output lookup
% ------------------------
nw = numel(win);
lookup = struct([]);    % empty structure with no fields
if iscell(win)
    lookup = {lookup};
end
npix = zeros(size(win));


% Check optional arguments
% ------------------------
keywrd_def = struct('tables',1);
flags = {'tables'};
[args,keywrd] = parse_arguments (varargin,keywrd_def,flags);
if numel(args)==1
    indx = args{1};
elseif numel(args)>0
    ok = false;
    mess = 'Check the number of input arguments';
    return
end


% Check pixel indexing is valid
% -----------------------------
if exist('indx','var')
    all_pixels = false;
    [ok,mess] = parse_pixel_indicies (win,indx);
    if ~ok, return, end
else
    all_pixels = true;
end


% Create lookup
% -------------
% Get some constants
c=neutron_constants;
k_to_e = c.c_k_to_emev;     % E(mev)=k_to_e*(k(Ang^-1))^2
k_to_v = 1e6/c.c_t_to_k;    % v(m/s)=k_to_v*k(Ang^-1)
deps_to_dt = 0.5e-6*c.c_t_to_k/c.c_k_to_emev;   % dt(s)=deps_to_dt*x2(m)/kf(Ang^-1)^3 * deps(meV)

% Pre-calculate various quantities to save time during simulation and fitting
ei=cell(nw,1);          % element size [nrun,1]
x0=cell(nw,1);          %       "
xa=cell(nw,1);          %       "
x1=cell(nw,1);          %       "
mod_shape_mono=cell(nw,1);  %   "
horiz_div=cell(nw,1);   %       "
vert_div=cell(nw,1);    %       "
ki=cell(nw,1);          %       "
kf=cell(nw,1);          % element size [npix,1]
sample=repmat(IX_sample,nw,1);
s_mat=cell(nw,1);       % element size [3,3,nrun]
spec_to_rlu=cell(nw,1); % element size [3,3,nrun]
alatt=cell(nw,1);       % element size [1,3]
angdeg=cell(nw,1);      % element size [1,3]
detectors=repmat(IX_detector_array,nw,1);
f_mat=cell(nw,1);       % element size [3,3,ndet]
d_mat=cell(nw,1);       % element size [3,3,ndet]
detdcn=cell(nw,1);      % element size [3,ndet]
x2=cell(nw,1);          % element size [ndet,1]
dt=cell(nw,1);          % element size [npix,1]
qw=cell(nw,1);          % element is cell array size [1,4], each element size [npix,1]
dq_mat=cell(nw,1);      % element size [4,11,npix]

% Get quantities and dervied quantities from the header
for iw=1:nw
    % Get pointer to a specific sqw pobject
    if iscell(win)
        wtmp = win{iw};
    else
        wtmp = win(iw);
    end
    
    % Pixel indicies
    if all_pixels
        [ok,mess,irun,idet,ien] = parse_pixel_indicies (wtmp);
    else
        [ok,mess,irun,idet,ien] = parse_pixel_indicies (wtmp,indx,iw);
    end
    if ~ok, return, end
    npix(iw) = numel(irun);
    
    % Get energy transfer and bin sizes
    % (Could get eps directly from wtmp.data.pix(:,4), but this does not work if the
    %  pixels have been shifted, so recalculate)
    [deps,eps_lo,eps_hi,ne]=energy_transfer_info(wtmp.header);
    if ne>1
        eps=(eps_lo(irun).*(ne(irun)-ien)+eps_hi(irun).*(ien-1))./(ne(irun)-1);
    else
        eps=eps_lo;     % only one bin, so ne=1 eps_lo=eps_hi, and the above line fails
    end
    
    % Get instrument data
    [ok,mess,ei{iw},x0{iw},xa{iw},x1{iw},mod_shape_mono{iw},...
        horiz_div{iw},vert_div{iw}] = instpars_DGdisk(wtmp.header);
    if ~ok, return, end
    
    % Compute ki and kf
    ki{iw}=sqrt(ei{iw}/k_to_e);
    kf{iw}=sqrt((ei{iw}(irun)-eps)/k_to_e);
    
    % Get sample, and both s_mat and spec_to_rlu; each has size [3,3,nrun]
    [ok,mess,sample(iw),s_mat{iw},spec_to_rlu{iw},alatt{iw},angdeg{iw}] =...
        sample_coords_to_spec_to_rlu(wtmp.header);
    if ~ok, return, end
    
    % Get detector information
    % Because detpar only contains minimal information, hardwire in the detector type here
    detpar = wtmp.detpar;   % just get a pointer
    if use_tubes
        detectors(iw) = IX_detector_array (detpar.group, detpar.x2(:), detpar.phi(:), detpar.azim(:),...
            IX_det_He3tube (detpar.width, detpar.height, 6.35e-4, 10));   % 10atms, wall thickness=0.635mm
    else
        detectors(iw) = IX_detector_array (detpar.group, detpar.x2(:), detpar.phi(:), detpar.azim(:),...
            IX_det_TobyfitClassic (detpar.width, detpar.height));
    end
    x2{iw} = detectors(iw).x2;
    d_mat{iw} = detectors(iw).dmat;
    f_mat{iw} = spec_to_secondary(detectors(iw));
    detdcn{iw} = det_direction(detectors(iw));
    
    % Time width corresponding to energy bins for each pixel
    dt{iw} = deps_to_dt*(x2{iw}(idet).*deps(irun)./kf{iw}.^3);
    
    % Calculate h,k,l (symmetrised objects will not have true pixel coordinates)
    qw{iw} = cell(1,4);
    qw{iw}(1:3) = calculate_q (ki{iw}(irun), kf{iw}, detdcn{iw}(:,idet), spec_to_rlu{iw}(:,:,irun));
    qw{iw}{4} = eps;
    
    % Matrix that gives deviation in Q (in rlu) from deviations in tm, tch etc. for each pixel
    dq_mat{iw} = dq_matrix_DGdisk (ki{iw}(irun), kf{iw},...
        xa{iw}(irun), x1{iw}(irun), x2{iw}(idet),...
        s_mat{iw}(:,:,irun), f_mat{iw}(:,:,idet), d_mat{iw}(:,:,idet),...
        spec_to_rlu{iw}(:,:,irun), k_to_v, k_to_e);
    
end

% Package output
ok=true;
mess='';
lookup = struct();    % reinitialise

if keywrd.tables    % lookup tables to minimise memory and optimiose speed of random sampling
    lookup.mod_shape_mono_table = object_lookup(mod_shape_mono);
    lookup.horiz_div_table = object_lookup(horiz_div);
    lookup.vert_div_table = object_lookup(vert_div);
    lookup.sample_table = object_lookup(sample);
    lookup.detector_table = object_lookup(detectors);
end
lookup.ei=ei;
lookup.x0=x0;
lookup.xa=xa;
lookup.x1=x1;
lookup.ki=ki;
lookup.kf=kf;
lookup.s_mat=s_mat;
lookup.spec_to_rlu=spec_to_rlu;
lookup.alatt=alatt;
lookup.angdeg=angdeg;
lookup.f_mat=f_mat;
lookup.d_mat=d_mat;
lookup.detdcn=detdcn;
lookup.x2=x2;
lookup.dt=dt;
lookup.qw=qw;
lookup.dq_mat=dq_mat;
lookup.k_to_v=k_to_v;
lookup.k_to_e=k_to_e;

if iscell(win)
    lookup = {lookup};
end
