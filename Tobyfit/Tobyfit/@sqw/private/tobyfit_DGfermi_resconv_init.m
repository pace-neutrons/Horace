function [ok,mess,lookup,npix] = tobyfit_DGfermi_resconv_init (win, varargin)
% Fill various lookup tables and matrix transformations for resolution calculations
%
% For all pixels in the input sqw object(s):
%   >> [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(win)
%
% For specific pixels:
%   >> [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(win,indx)
%
% No lookup tables:
%   >> [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(...,'notables')
%
% Special case of recovering the Monte Carlo contribution options:
%   >> [ok,mess,mc_contr]=tobyfit_DGfermi_resconv_init
%
%
% This routine is used in Tobyfit resolution convolution, and by other methods
% that need to know about resolution functions. Note that for Tobyfit the
% constraints of the mfclass_class object for initialisation function have a very
% specific function call: [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(win) i.e
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
%               If 'tables', then moderator and Fermi chopper lookup tables
%              are added to the output argument lookup
%
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
%       Indexed lookup tables:
%           mod_table   Structure with fields:
%                      ind      Cell array of indicies into table, where
%                              ind{i} is a row vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                      table    Lookup table size(npnt,nmod), where nmod is
%                              the number of unique tables. Convert to time from
%                              reduced time using t = t_av * (t_red/(1-t_red))
%                      t_av     First moment of time distribution (row vector length nmod)
%                              Time here is in seconds (NOT microseconds)
%                 	   fwhh     Full width half height of distribution (row vector)
%                              Time here is in seconds (NOT microseconds)
%                      profile  Lookup table size(npnt,nmod), where nmod is
%                              the number of unique tables.
%                               Use the look-up table to get the pulse profile
%                              at reduced time deviation 0 <= t_red <= 1. Convert
%                              to true time using the equation
%                                   t = t_av * (t_red/(1-t_red))
%                               The pulse profile is normalised so that the peak
%                              value is unity.
%
%           fermi_table Structure with fields:
%                      ind      Cell array of indicies into table, where
%                              ind{i} is a row vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                      table    Lookup table size(npnt,nchop), where nchop is
%                              the number of unique tables. Note that the time
%                              is in seconds, NOT microseconds.
%
%
%       Cell array of arrays, one array per dataset, each array with length equal to
%      the number of runs in each dataset:
%           ei          Incident energies (mev)             [Column vector]
%           x0          Moderator - chopper distance (m)    [Column vector]
%           xa          Beam defining aperture - chopper distance (m)       [Column vector]
%           x1          Chopper - sample distance (m)       [Column vector]
%           thetam      Angle of moderator normal to incident beam (rad)    [Column vector]
%           angvel      Chopper angular velocity (rad/s)    [Column vector]
%           moderator   Moderator object                    [Column vector]
%           aperture    Aperture object                     [Column vector]
%           chopper     Fermi chopper object                [Column vector]
%           wa          Aperture full width (m)             [Column vector]
%           ha          Aperture full height (m)            [Column vector]
%
%       Cell arrays of incident and final wavevectors, one array per datasets
%           ki          Incident wavevectors [Column vector, length nruns]
%           kf          Final wavevectors [Column vector, length npix]
%
%       Sample:
%           sample      Array of sample objects, one per dataset
%
%       Cell arrays of arrays of transformation matricies, one array per dataset:
%           s_mat       Matrix to convert coords in sample frame to spectrometer frame.
%                      Size is [3,3,nrun], where nrun is the number of runs
%           spec_to_rlu Matrix to convert momentum in spectrometer coordinates to
%                      components in r.l.u.:
%                           v_rlu = spec_to_rlu * v_spec
%                      Size is [3,3,nrun], where nrun is the number of runs
%
%       Cell arrays of arrays of detector information, one array per datasets
%           d_mat       Matrix size [3,3,ndet] to take coordinates in spectrometer
%                      frame and convert in detector frame.
%
%           detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%
%           x2          Sample-detector distances (m) (size [ndet,1])
%           det_width   Detector width (m) (size [ndet,1])
%           det_height  Detector height (m) (size [ndet,1])
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
%   mc_contr    Cell array of character strings with the names of the
%              possible contributions e.g. {'chopper','moderator'}


% Catch case of inquiry about mc_contributions
% --------------------------------------------
if nargin==0
    ok=true;
    mess='';
    lookup={'moderator','aperture','chopper','sample',...
        'detector_depth','detector_area','energy_bin'};
    npix = [];
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

% Pre-calculate and store various quantities to save time during simulation and fitting
ei=cell(nw,1);          % element size [nrun,1]
x0=cell(nw,1);          %       "
xa=cell(nw,1);          %       "
x1=cell(nw,1);          %       "
thetam=cell(nw,1);      %       "
angvel=cell(nw,1);      %       "
moderator=cell(nw,1);   %       "
aperture=cell(nw,1);    %       "
chopper=cell(nw,1);     %       "
wa=cell(nw,1);          %       "
ha=cell(nw,1);          %       "
ki=cell(nw,1);          %       "
kf=cell(nw,1);          % element size [npix,1]
sample=repmat(IX_sample,nw,1);
s_mat=cell(nw,1);       % element size [3,3,nrun]
spec_to_rlu=cell(nw,1); % element size [3,3,nrun]
d_mat=cell(nw,1);       % element size [3,3,ndet]
detdcn=cell(nw,1);      % element size [3,ndet]
x2=cell(nw,1);          % element size [ndet,1]
det_width=cell(nw,1);   % element size [ndet,1]
det_height=cell(nw,1);  % element size [ndet,1]
dt=cell(nw,1);          % element size [npix,1]
qw=cell(nw,1);          % element is cell array size [1,4], each element size [npix,1]
dq_mat=cell(nw,1);      % element size [4,11,npix]

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
    
    % Get instrument information
    [ok,mess,ei{iw},x0{iw},xa{iw},x1{iw},thetam{iw},angvel{iw},moderator{iw},aperture{iw},chopper{iw}]=...
        instpars_DGfermi(wtmp.header);
    if ~ok, return, end
    [wa{iw}, ha{iw}] = aperture_width_height (aperture{iw});
    
    % Compute ki and kf
    ki{iw}=sqrt(ei{iw}/k_to_e);
    kf{iw}=sqrt((ei{iw}(irun)-eps)/k_to_e);
    
    % Get sample, and both s_mat and spec_to_rlu; each has size [3,3,nrun]
    [ok,mess,sample(iw),s_mat{iw},spec_to_rlu{iw}]=sample_coords_to_spec_to_rlu(wtmp.header);
    if ~ok, return, end
    
    % Get detector information
    [d_mat{iw}, detdcn{iw}] = spec_coords_to_det (wtmp.detpar); % d_mat has size [3,3,ndet]; detdcn size [3,ndet]
    x2{iw}=wtmp.detpar.x2(:);              % make column vector
    det_width{iw}=wtmp.detpar.width(:);    % make column vector
    det_height{iw}=wtmp.detpar.height(:);  % make column vector
    
    % Time width corresponding to energy bins for each pixel
    dt{iw} = deps_to_dt*(x2{iw}(idet).*deps(irun)./kf{iw}.^3);
    
    % Calculate h,k,l (symmetrised objects will not have true pixel coordinates)
    qw{iw} = cell(1,4);
    qw{iw}(1:3) = calculate_q (ki{iw}(irun), kf{iw}, detdcn{iw}(:,idet), spec_to_rlu{iw}(:,:,irun));
    qw{iw}{4} = eps;
    
    % Matrix that gives deviation in Q (in rlu) from deviations in tm, tch etc. for each pixel
    dq_mat{iw} = dq_matrix_DGfermi (ki{iw}(irun), kf{iw},...
        x0{iw}(irun), xa{iw}(irun), x1{iw}(irun), x2{iw}(idet),...
        thetam{iw}(irun), angvel{iw}(irun), s_mat{iw}(:,:,irun), d_mat{iw}(:,:,idet),...
        spec_to_rlu{iw}(:,:,irun), k_to_v, k_to_e);
    
end

% Lookup tables for moderator and chopper - repackages in such a way that repetitions
% of moderators for runs within an sqw and across sqw objects are squeezed to
% unique tables with index arrays to the tables
if keywrd.tables
    mod_table=moderator_sampling_table(moderator,ei,'fast');
    fermi_table=fermi_sampling_table(chopper,'fast','nocheck');
end

% Package output as a structure, in cell array length unity if win was a cell array
ok=true;
mess='';
lookup = struct();    % reinitialise

if keywrd.tables
    lookup.mod_table=mod_table;
    lookup.fermi_table=fermi_table;
end
lookup.ei=ei;
lookup.x0=x0;
lookup.xa=xa;
lookup.x1=x1;
lookup.thetam=thetam;
lookup.angvel=angvel;
lookup.moderator=moderator;
lookup.aperture=aperture;
lookup.chopper=chopper;
lookup.wa=wa;
lookup.ha=ha;
lookup.ki=ki;
lookup.kf=kf;
lookup.sample=sample;
lookup.s_mat=s_mat;
lookup.spec_to_rlu=spec_to_rlu;
lookup.d_mat=d_mat;
lookup.detdcn=detdcn;
lookup.x2=x2;
lookup.det_width=det_width;
lookup.det_height=det_height;
lookup.dt=dt;
lookup.qw=qw;
lookup.dq_mat=dq_mat;
lookup.k_to_v=k_to_v;
lookup.k_to_e=k_to_e;

if iscell(win)
    lookup = {lookup};
end
