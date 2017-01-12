function [ok,mess,lookup]=tobyfit_DGdisk_resconv_init(win,shape_mod)
% Fill various lookup tables and matrix transformations
%
%   >> [ok,mess,lookup]=tobyfit_DGdisk_resconv_init(win,opt)
%
% Input:
% ------
%   win         Cell array of input sqw objects
%
%   shape_mod   Option of how to treat the moderator and shaping chopper in
%              the resolution function.
%                   =false  Depending on the relative pulse FWHHs from the 
%                          moderator and shaping chopper, treat the initial
%                          pulse as arising solely from the moderator (i.e.
%                          ignore shaping chopper) or solely from the
%                          shaping chopper (i.e. treat source as continuous)
%                   =true   Use true function distribution from combination
%                          of moderator and shaping chopper
%
% Output:
% -------
%   ok          Status flag: =true if all ok, =false otherwise
%   mess        Error message: empty if ok, contains error message if not ok
%   lookup      Structure containing lookup tables and pre-calculated matricies etc.
%
%       mod_table       Structure with fields:
%                      ind      Cell array of indicies into table, where
%                              ind{i} is column vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                      table    Lookup table size(npnt,nmod), where nmod is
%                              the number of unique tables. Convert to time from
%                              reduced time using t = t_av * (t_red/(1-t_red))
%                      t_av     First moment of time distribution (row vector length nmod)
%                              Time here is in seconds (NOT microseconds)
%
%       chop_shape_fwhh Cell array of full width half heights of the
%                      monochromating chopper, one entry per dataset with
%                      size [nrun,1]. Note that the time is in seconds,
%                      NOT microseconds.
%
%       chop_mono_fwhh  Cell array of full width half heights of the
%                      monochromating chopper, one entry per dataset with
%                      size [nrun,1]. Note that the time is in seconds,
%                      NOT microseconds.
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
moderator_all=cell(nw,1);
chop_shape_all=cell(nw,1);
chop_mono_all=cell(nw,1);
horiz_div_all=cell(nw,1);
vert_div_all=cell(nw,1);
sample_all=repmat(IX_sample,nw,1);
ei_all=cell(nw,1);
dq_mat=cell(nw,1);
dt=cell(nw,1);
for i=1:nw
    irun = win{i}.data.pix(5,:)';
    idet = win{i}.data.pix(6,:)';
    ien  = win{i}.data.pix(7,:)';
    
    [deps,eps_lo,eps_hi,ne]=energy_transfer_info(win{i}.header);
    eps=(eps_lo(irun).*(ne(irun)-ien)+eps_hi(irun).*(ien-1))./(ne(irun)-1);
    
    [ok,mess,ei,x0,xa,x1,moderator,chop_shape,chop_mono,horiz_div,vert_div]=...
        instpars_DGdisk(win{i}.header);
    if ~ok, return, end
    moderator_all{i}=moderator;
    chop_shape_all{i}=chop_shape;
    chop_mono_all{i}=chop_mono;
    horiz_div_all{i}=horiz_div;
    vert_div_all{i}=vert_div;
    ei_all{i}=ei;
    
    ki=sqrt(ei/k_to_e);
    kf=sqrt((ei(irun)-eps)/k_to_e);
    
    % Get sample and s_mat
    [ok,mess,sample,s_mat,spec_to_rlu]=sample_coords_to_spec_to_rlu(win{i}.header);    % s_mat has size [3,3,nrun]
    if ~ok, return, end
    sample_all(i)=sample;
    
    % Get d_mat
    d_mat = spec_coords_to_det (win{i}.detpar);         % d_mat has size [3,3,ndet]
    x2=win{i}.detpar.x2(:); % make column vector
    
    % Matrix that gives deviation in Q (in rlu) from deviations in tm, tch etc. for each pixel
    dq_mat{i} = dq_matrix_DGdisk (ki(irun), kf, x0(irun), xa(irun), x1(irun), x2(idet),...
        s_mat(:,:,irun), d_mat(:,:,idet), spec_to_rlu(:,:,irun), k_to_v, k_to_e);
    
    % Time width corresponding to energy bins for each pixel
    dt{i} = deps_to_dt*(x2(idet).*deps(irun)./kf.^3)';  % row vector
    
end

% Lookup tables for moderator and divergence
mod_table=moderator_sampling_table(moderator_all,ei_all,'fast');
horiz_div_table=divergence_sampling_table(horiz_div_all,'nocheck');
vert_div_table=divergence_sampling_table(vert_div_all,'nocheck');

% Extract aperture information
ap_wh=aperture_width_height(aperture_all);

% Package output
ok=true;
mess='';
lookup.mod_table=mod_table;
lookup.aperture=ap_wh;
lookup.fermi_table=fermi_table;
lookup.sample=sample_all;
lookup.dq_mat=dq_mat;
lookup.dt=dt;

lookup = {lookup};
