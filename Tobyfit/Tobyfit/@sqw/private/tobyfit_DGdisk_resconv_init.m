function [ok,mess,lookup]=tobyfit_DGdisk_resconv_init(win)
% Fill various lookup tables and matrix transformations
%
%   >> [ok,mess,lookup]=tobyfit_DGdisk_resconv_init(win)
%
% Special case of recovering the Monte Carlo contribution options
%   >> [ok,mess,mc_contr]=tobyfit_DGdisk_resconv_init
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
%                      fwhh     Full width half height of distribution (row vector)
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
%           horiz_div_table Structure with fields:
%                      ind      Cell array of indicies into table, where
%                              ind{i} is a row vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                      table    Lookup table size(npnt,nhdiv), where nhdiv is
%                              the number of unique tables. Note that the angle
%                              is in radians, NOT degrees.
%                      
%           vert_div_table Structure with fields:
%                      ind      Cell array of indicies into table, where
%                              ind{i} is a row vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                      table    Lookup table size(npnt,nvdiv), where nhdiv is
%                              the number of unique tables. Note that the angle
%                              is in radians, NOT degrees.
%
%       Cell arrays of arrays of chopper information, one array per dataset, each
%      array with length equal to the number of runs in that dataset
%       
%           chop_shape_fwhh Full width half heights of the pulse shaping chopper.
%                          Note that the time is in seconds, NOT microseconds.
%                          [Column vector]
%
%           chop_mono_fwhh  Full width half heights of the monochromating chopper.
%                          Note that the time is in seconds, NOT microseconds.
%                          [Column vector]
%
%           shape_mod       Logical vectors where true indicates that the
%                          initial pulse is largely determined by the shaping
%                          chopper i.e. fwhh due to the chopper is smaller than
%                          that of the moderator pulse (after geometric scaling)
%
%       Cell array of arrays, one array per dataset, each array with length equal to
%      the number of runs in each dataset:
%           ei          Incident energies (mev)     [Column vector]
%           x0          Moderator - monochromating chopper distance (m)     [Column vector]
%           xa          Shaping chopper - monochromating chopper distance (m)   [Column vector]
%           x1          Monochromating chopper - sample distance (m)    [Column vector]
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
%           x2          Sample-detector distances (m) ([1 x ndet] array)
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
%   mc_contr        Cell array of character strings with the names of the
%                  possible contributions e.g. {'chopper','moderator'}


% Catch case of inquiry about mc_contributions
% --------------------------------------------
if nargin==0
    ok=true;
    mess='';
    lookup={'moderator','shape_chopper','mono_chopper',...
        'horiz_divergence','vert_divergence','sample',...
        'detector_depth','detector_area','energy_bin'}';
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

% Pre-calculate various quantities to save time during simulation and fitting
ei=cell(nw,1);          % element size [nrun,1]
x0=cell(nw,1);          %       "
xa=cell(nw,1);          %       "
x1=cell(nw,1);          %       "
moderator=cell(nw,1);   %       "
chop_shape=cell(nw,1);  %       "
chop_mono=cell(nw,1);   %       "
horiz_div=cell(nw,1);   %       "
vert_div=cell(nw,1);    %       "
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

% Get quantities and dervied quantities from the header
for i=1:nw
    irun = win{i}.data.pix(5,:)';   % column vector
    idet = win{i}.data.pix(6,:)';   % column vector
    ien  = win{i}.data.pix(7,:)';   % column vector

    % Get energy transfer and bin sizes; could get eps directly from win{i}.data.pix(:,4)
    [deps,eps_lo,eps_hi,ne]=energy_transfer_info(win{i}.header);
    eps=(eps_lo(irun).*(ne(irun)-ien)+eps_hi(irun).*(ien-1))./(ne(irun)-1);

    % Get instrument data
    [ok,mess,ei{i},x0{i},xa{i},x1{i},moderator{i},chop_shape{i},chop_mono{i},...
        horiz_div{i},vert_div{i}] = instpars_DGdisk(win{i}.header);
    if ~ok, return, end
    
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
    dq_mat{i} = dq_matrix_DGdisk (ki{i}(irun), kf{i}, xa{i}(irun), x1{i}(irun), x2{i}(idet),...
        s_mat{i}(:,:,irun), d_mat{i}(:,:,idet), spec_to_rlu{i}(:,:,irun), k_to_v, k_to_e);
    
end

% Lookup tables for moderator and divergence
mod_table=moderator_sampling_table(moderator,ei,'fast');
horiz_div_table=divergence_sampling_table(horiz_div,'nocheck');
vert_div_table=divergence_sampling_table(vert_div,'nocheck');

% Get chopper widths and determine if the moderator pulse is dominant contributor
shape_mod=cell(nw,1);
chop_shape_fwhh=cell(nw,1);
chop_mono_fwhh=cell(nw,1);

for i=1:nw
    nrun=numel(chop_shape{i});
    pulse_width_shape=zeros(nrun,1);
    pulse_width_mono=zeros(nrun,1);
    % Loop over runs as arrayfun doesn't work on the chopper objects (because old style matlab objects?)
    for j=1:nrun
        [~,pulse_width_shape(j)]=pulse_width(chop_shape{i}(j));
        [~,pulse_width_mono(j)]=pulse_width(chop_mono{i}(j));
    end
    chop_shape_fwhh{i}=1e-6*pulse_width_shape;  % convert to seconds
    chop_mono_fwhh{i}=1e-6*pulse_width_mono;    % convert to seconds
    
    % Determine if the moderator pulse is dominant contributor
    shape_mod{i} = ((x0{i}./xa{i}).*chop_shape_fwhh{i} < mod_table.fwhh(mod_table.ind{i}));
end


% Package output
ok=true;
mess='';

lookup.mod_table=mod_table;
lookup.horiz_div_table=horiz_div_table;
lookup.vert_div_table=vert_div_table;
lookup.chop_shape_fwhh=chop_shape_fwhh;
lookup.chop_mono_fwhh=chop_mono_fwhh;
lookup.shape_mod=shape_mod;
lookup.ei=ei;
lookup.x0=x0;
lookup.xa=xa;
lookup.x1=x1;
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
