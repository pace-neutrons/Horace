function [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(win)
% Fill various lookup tables and matrix transformations
%
%   >> [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(win)
%
% Special case of recovering the Monte Carlo contribution options
%   >> [ok,mess,mc_contr]=tobyfit_DGfermi_resconv_init
%
% Input:
% ------
%   win         Cell array of input sqw objects
%
% Output:
% -------
%   ok          Status flag: =true if all ok, =false otherwise
%   mess        Error message: empty if ok, contains error message if not ok
%   lookup      Cell array with one element: a structure containing lookup
%              tables and pre-calculated matricies etc.
%
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
%           ei          Incident energies (mev)     [Column vector]
%           x0          Moderator - chopper distance (m)    [Column vector]
%           xa          Beam defining aperture - chopper distance (m)       [Column vector]
%           x1          Chopper - sample distance (m)       [Column vector]
%           thetam      Angle of moderator normal to incident beam (rad)    [Column vector]
%           angvel      Chopper angular velocity (rad/s)    [Column vector]
%           wa          Aperture full width (m)
%           ha          Aperture full height (m)
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
    return
end


% Create lookup
% -------------
nw=numel(win);

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

for i=1:nw
    irun = win{i}.data.pix(5,:)';   % column vector
    idet = win{i}.data.pix(6,:)';   % column vector
    ien  = win{i}.data.pix(7,:)';   % column vector
    
    % Get energy transfer and bin sizes; could get eps directly from win{i}.data.pix(:,4)
    [deps,eps_lo,eps_hi,ne]=energy_transfer_info(win{i}.header);
    eps=(eps_lo(irun).*(ne(irun)-ien)+eps_hi(irun).*(ien-1))./(ne(irun)-1);
    
    % Get instrument information
    [ok,mess,ei{i},x0{i},xa{i},x1{i},thetam{i},angvel{i},moderator{i},aperture{i},chopper{i}]=...
        instpars_DGfermi(win{i}.header);
    if ~ok, return, end
    [wa{i}, ha{i}] = aperture_width_height (aperture{i});
    
    % Compute ki and kf
    ki{i}=sqrt(ei{i}/k_to_e);
    kf{i}=sqrt((ei{i}(irun)-eps)/k_to_e);
    
    % Get sample, and both s_mat and spec_to_rlu; each has size [3,3,nrun]
    [ok,mess,sample(i),s_mat{i},spec_to_rlu{i}]=sample_coords_to_spec_to_rlu(win{i}.header);
    if ~ok, return, end
    
    % Get detector information
    [d_mat{i}, detdcn{i}] = spec_coords_to_det (win{i}.detpar); % d_mat has size [3,3,ndet]; detdcn size [3,ndet]
    x2{i}=win{i}.detpar.x2(:);              % make column vector
    det_width{i}=win{i}.detpar.width(:);    % make column vector
    det_height{i}=win{i}.detpar.height(:);  % make column vector
    
    % Time width corresponding to energy bins for each pixel
    dt{i} = deps_to_dt*(x2{i}(idet).*deps(irun)./kf{i}.^3);
    
    % Calculate h,k,l (symmetrised objects will not have true pixel coordinates)
    qw{i} = cell(1,4);
    qw{i}(1:3) = calculate_q (ki{i}(irun), kf{i}, detdcn{i}(:,idet), spec_to_rlu{i}(:,:,irun));
    qw{i}{4} = eps;
   
    % Matrix that gives deviation in Q (in rlu) from deviations in tm, tch etc. for each pixel
    dq_mat{i} = dq_matrix_DGfermi (ki{i}(irun), kf{i},...
        x0{i}(irun), xa{i}(irun), x1{i}(irun), x2{i}(idet),...
        thetam{i}(irun), angvel{i}(irun), s_mat{i}(:,:,irun), d_mat{i}(:,:,idet),...
        spec_to_rlu{i}(:,:,irun), k_to_v, k_to_e);
    
end

% Lookup tables for moderator and chopper - repackages in such a way that repetitions
% of moderators for runs within an sqw and across sqw objects are squeezed to
% unique tables with index arrays to the tables
mod_table=moderator_sampling_table(moderator,ei,'fast');
fermi_table=fermi_sampling_table(chopper,'fast','nocheck');

% Package output as a structure, in cell array length unity
ok=true;
mess='';

lookup.mod_table=mod_table;
lookup.fermi_table=fermi_table;
lookup.ei=ei;
lookup.x0=x0;
lookup.xa=xa;
lookup.x1=x1;
lookup.thetam=thetam;
lookup.angvel=angvel;
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

lookup = {lookup};
