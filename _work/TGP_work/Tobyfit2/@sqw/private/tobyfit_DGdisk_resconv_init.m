function [ok,mess,lookup]=tobyfit_DGdisk_resconv_init(win)
% Fill various lookup tables and matrix transformations
%
%   >> [ok,mess,lookup]=tobyfit_DGdisk_resconv_init(win,opt)
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
%       mod_table       Structure with fields:
%                      ind      Cell array of indicies into table, where
%                              ind{i} is column vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                      table    Lookup table size(npnt,nmod), where nmod is
%                              the number of unique tables. Convert to time from
%                              reduced time using t = t_av * (t_red/(1-t_red))
%                      profile  Lookup table size(npnt,nmod), where nmod is
%                              the number of unique tables. 
%                               Use the look-up table to get the pulse profile
%                              at reduced time deviation 0 <= t_red <= 1. Convert
%                              to true time using the equation
%                                   t = t_av * (t_red/(1-t_red))
%                               The pulse profile is normalised so that the peak
%                              value is unity.
%                      t_av     First moment of time distribution (row vector length nmod)
%                              Time here is in seconds (NOT microseconds)
%                      fwhh     Full width half height of distribution (row vector)
%                              Time here is in seconds (NOT microseconds)
%
%       chop_shape_fwhh Cell array of row vectors containing full width half
%                      heights of the pulse shaping chopper. Note that the
%                      time is in seconds, NOT microseconds.
%                       - number of row vectors = number of sqw objects
%                       - number of elements in a vector = number of runs
%                         in the corresponding sqw object
%
%       shape_mod       Cell array of logical vectors, one entry per
%                      dataset with size [1,npix], where true indicates that the
%                      initial pulse is largely determined by the shaping
%                      chopper i.e. fwhh due to the chopper is smaller than
%                      that of the moderator pulse (after geometric scaling)
%
%       x0              Cell array of column vectors, one per dataset,
%                      containing the moderator-sample distance (m). The
%                      number of elements in each column is equal to the
%                      number of contributiung runs in the corresponding
%                      sqw object.
%
%       xa              Cell array of column vectors, one per dataset,
%                      containing the shaping chopper-sample distance (m).
%                      The number of elements in each column is equal to the
%                      number of contributiung runs in the corresponding
%                      sqw object.
%
%       chop_mono_fwhh  Cell array of row vectors containing full width half
%                      heights of the monochromating chopper. Note that the
%                      time is in seconds, NOT microseconds.
%                       - number of row vectors = number of sqw objects
%                       - number of elements in a vector = number of runs
%                         in the corresponding sqw object
%
%       horiz_div_table Structure with fields:
%                      ind      Cell array of indicies into table, where
%                              ind{i} is column vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                      table    Lookup table size(npnt,nhdiv), where nhdiv is
%                              the number of unique tables. Note that the angle
%                              is in radians, NOT degrees.
%                      
%       vert_div_table Structure with fields:
%                      ind      Cell array of indicies into table, where
%                              ind{i} is column vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                      table    Lookup table size(npnt,nvdiv), where nhdiv is
%                              the number of unique tables. Note that the angle
%                              is in radians, NOT degrees.
%                      
%       
%
%       sample          Cell array of sample objects, one per dataset
%
%       dq_mat          Cell array of matricies, one per dataset with size [4,11,npix],
%                      to convert deviations in tm, tch etc. into deviations in Q in rlu
%
%       dt              Cell array of vectors, one entry per dataset with size [1,npix],
%                      with time widths corresponding to energy bins for each pixel


% Create lookup
% -------------
nw=numel(win);

% Get some constants
c=neutron_constants;
k_to_e = c.c_k_to_emev;     % E(mev)=k_to_e*(k(Ang^-1))^2
k_to_v = 1e6/c.c_t_to_k;    % v(m/s)=k_to_v*k(Ang^-1)
deps_to_dt = 0.5e-6*c.c_t_to_k/c.c_k_to_emev;   % dt(s)=deps_to_dt*x2(m)/kf(Ang^-1)^3 * deps(meV)

% Pre-calculate various quantities to save time during simulation and fitting
ei_all=cell(nw,1);
x0_all=cell(nw,1);
xa_all=cell(nw,1);
x1_all=cell(nw,1);
moderator_all=cell(nw,1);
chop_shape_all=cell(nw,1);
chop_mono_all=cell(nw,1);
horiz_div_all=cell(nw,1);
vert_div_all=cell(nw,1);
sample_all=repmat(IX_sample,nw,1);
s_mat_all=cell(nw,1);
spec_to_rlu_all=cell(nw,1);


% Get quantities and dervied quantities from the header
for i=1:nw
    % Get instrument data
    [ok,mess,ei,x0,xa,x1,moderator,chop_shape,chop_mono,horiz_div,vert_div]=...
        instpars_DGdisk(win{i}.header);
    if ~ok, return, end
    ei_all{i}=ei;
    x0_all{i}=x0;
    xa_all{i}=xa;
    x1_all{i}=x1;
    moderator_all{i}=moderator;
    chop_shape_all{i}=chop_shape;
    chop_mono_all{i}=chop_mono;
    horiz_div_all{i}=horiz_div;
    vert_div_all{i}=vert_div;
    
    % Get sample data
    [ok,mess,sample,s_mat,spec_to_rlu]=sample_coords_to_spec_to_rlu(win{i}.header);    % s_mat has size [3,3,nrun]
    if ~ok, return, end
    sample_all(i)=sample;
    s_mat_all{i}=s_mat;
    spec_to_rlu_all{i}=spec_to_rlu;
end

% Lookup tables for moderator and divergence
mod_table=moderator_sampling_table(moderator_all,ei_all,'fast');
horiz_div_table=divergence_sampling_table(horiz_div_all,'nocheck');
vert_div_table=divergence_sampling_table(vert_div_all,'nocheck');

% Get chopper widths, dq_mat and dt
shape_mod=cell(nw,1);
chop_shape_fwhh=cell(nw,1);
chop_mono_fwhh=cell(nw,1);
dq_mat=cell(nw,1);
dt=cell(nw,1);
for i=1:nw
    irun = win{i}.data.pix(5,:)';
    idet = win{i}.data.pix(6,:)';
    ien  = win{i}.data.pix(7,:)';
    
    % Get some instrument and sample parameters again
    ei=ei_all{i};
    x0=x0_all{i};
    xa=xa_all{i};
    x1=x1_all{i};
    chop_shape=chop_shape_all{i};
    chop_mono=chop_mono_all{i};
    s_mat=s_mat_all{i};
    spec_to_rlu=spec_to_rlu_all{i};

    % Kinematics
    [deps,eps_lo,eps_hi,ne]=energy_transfer_info(win{i}.header);
    eps=(eps_lo(irun).*(ne(irun)-ien)+eps_hi(irun).*(ien-1))./(ne(irun)-1);
    ki=sqrt(ei/k_to_e);
    kf=sqrt((ei(irun)-eps)/k_to_e);
    
    % Get chopper widths
    nrun=numel(chop_shape);
    pulse_width_shape=zeros(1,nrun);
    pulse_width_mono=zeros(1,nrun);
    for j=1:nrun
        [~,pulse_width_shape(j)]=pulse_width(chop_shape(j));
        [~,pulse_width_mono(j)]=pulse_width(chop_mono(j));
    end
    chop_shape_fwhh{i}=pulse_width_shape;
    chop_mono_fwhh{i}=pulse_width_mono;
    
    % Determine if the moderator pulse is dominant contributor
    shape_mod{i}=((x0(irun)./xa(irun)).*pulse_width_shape(irun)<mod_table.fwhh(mod_table.ind{i}(irun)))';     % row vector
    
    % Matrix that gives deviation in Q (in rlu) from deviations in tm, tch etc. for each pixel
    d_mat = spec_coords_to_det (win{i}.detpar);         % d_mat has size [3,3,ndet]
    x2=win{i}.detpar.x2(:); % make column vector
    dq_mat{i} = dq_matrix_DGdisk (ki(irun), kf, xa(irun), x1(irun), x2(idet),...
        s_mat(:,:,irun), d_mat(:,:,idet), spec_to_rlu(:,:,irun), k_to_v, k_to_e);
    
    % Time width corresponding to energy bins for each pixel
    dt{i} = deps_to_dt*(x2(idet).*deps(irun)./kf.^3)';  % row vector
    
end


% Package output
ok=true;
mess='';
lookup.mod_table=mod_table;
lookup.chop_shape_fwhh=chop_shape_fwhh;
lookup.shape_mod=shape_mod;
lookup.x0=x0_all;
lookup.xa=xa_all;
lookup.chop_mono_fwhh=chop_mono_fwhh;
lookup.horiz_div_table=horiz_div_table;
lookup.vert_div_table=vert_div_table;
lookup.sample=sample_all;
lookup.dq_mat=dq_mat;
lookup.dt=dt;

lookup = {lookup};
