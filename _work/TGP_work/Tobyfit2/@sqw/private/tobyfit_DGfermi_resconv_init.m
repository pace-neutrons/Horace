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
%         mod_table     Structure with fields:
%                      ind      Cell array of indicies into table, where
%                              ind{i} is column vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                      table    Lookup table size(npnt,nmod), where nmod is
%                              the number of unique tables. Convert to time from
%                              reduced time using t = t_av * (t_red/(1-t_red))
%                      t_av     First moment of time distribution (row vector length nmod)
%                              Time here is in seconds (NOT microseconds)
%                 	   fwhh     Full width half height of distribution (row vector)
%                              Time here is in seconds (NOT microseconds)
%
%         aperture      Structures with fields:
%                      width    Cell array of row vectors of full aperture widths
%                                - number of row vectors = number of sqw objects
%                                - number of elements in a vector = number of runs
%                                  in the corresponding sqw object
%
%                      height   Cell array of row vectors of full aperture heights
%                                - number of row vectors = number of sqw objects
%                                - number of elements in a vector = number of runs
%                                  in the corresponding sqw object
%
%         fermi_table   Structure with fields:
%                      ind      Cell array of indicies into table, where
%                              ind{i} is column vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                      table    Lookup table size(npnt,nchop), where nchop is
%                              the number of unique tables. Note that the time
%                              is in seconds, NOT microseconds.
%
%         sample        Cell array of sample objects, one per dataset
%
%         dq_mat        Cell array of matricies, one per dataset with size [4,11,npix],
%                      to convert deviations in tm, tch etc. into deviations in Q in rlu
%
%         dt            Cell array of vectors, one entry per dataset with size [1,npix],
%                      with time widths corresponding to energy bins for each pixel
%
% *OR*
%   mc_contr        Cell array of character strings with the names of the
%                  possible contributions e.g. {'chopper','moderator'}


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

% Pre-calculate various quantities to save time during simulation and fitting
moderator_all=cell(nw,1);
aperture_all=cell(nw,1);
chopper_all=cell(nw,1);
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
    
    [ok,mess,ei,x0,xa,x1,thetam,angvel,moderator,aperture,chopper]=...
        instpars_DGfermi(win{i}.header);
    if ~ok, return, end
    moderator_all{i}=moderator;
    aperture_all{i}=aperture;
    chopper_all{i}=chopper;
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
    dq_mat{i} = dq_matrix_DGfermi (ki(irun), kf, x0(irun), xa(irun), x1(irun), x2(idet),...
        thetam(irun), angvel(irun), s_mat(:,:,irun), d_mat(:,:,idet), spec_to_rlu(:,:,irun), k_to_v, k_to_e);
    
    % Time width corresponding to energy bins for each pixel
    dt{i} = deps_to_dt*(x2(idet).*deps(irun)./kf.^3)';  % row vector
    
end

% Lookup tables for moderator and chopper
mod_table=moderator_sampling_table(moderator_all,ei_all,'fast');
fermi_table=fermi_sampling_table(chopper_all,'fast','nocheck');

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
