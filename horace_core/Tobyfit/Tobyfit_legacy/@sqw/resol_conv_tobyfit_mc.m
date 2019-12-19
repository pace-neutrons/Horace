function wout=resol_conv_tobyfit_mc(win,sqwfunc,pars,mc_contrib,mc_npoints,xtal,modshape)
% Calculate resolution broadened sqw object(s) for a model scattering function.
%
%   >> wout=resol_conv_tobyfit_mc(win,sqwfunc,pars,lookup)
%
% Input:
% ------
%   win         sqw object or array of objects
%
%   sqwfunc     Handle to function that calculates S(Q,w)
%               Most commonly used form is:
%                   weight = sqwfunc (qh,qk,ql,en,p)
%                where
%                   qh,qk,ql,en Arrays containing the coordinates of a set of points
%                   p           Vector of parameters needed by dispersion function
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                   weight      Array containing calculated energies; if more than
%                              one dispersion relation, then a cell array of arrays
%
%               More general form is:
%                   weight = sqwfunc (qh,qk,ql,en,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might want
%                              to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name for look-up
%                              table
%
%   pars        Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%   mc_contrib  Structure indicating which components contribute to the resolution
%              function. Each field is the name of a component, and its value is
%              either true or false
%
%   mc_npoints  Number of Monte Carlo points per pixel
%
%   xtal        Crystal refinement constants. Structure with fields:
%                   refine      Logical: true (refinement to be performed); false (not)
%                   urot        x-axis for rotation (r.l.u.)
%                   vrot        Defines y-axis for rotation (r.l.u.): y-axis in plane
%                              of urot and vrot, perpendicualr to urot with positive
%                              component along vrot
%
%   modshape    Moderator refinement constants. Structure with fields:
%                   refine      Logical: true (refinement to be performed); false (not)
%                   pulse_model Pulse shape model for the moderator pulse shape whose
%                              parameters will be refined
%                   pp          Initial pulse shape parameters
%                   ei          Incident energy for pulse shape calculation (this
%                              will be the common ei for all the sqw objects)
%
%
% Output:
% -------
%   wout        Output dataset or array of datasets with computed signal
%
%
% NOTE: Contributions to resolution are
%   yvec(1,...):   t_m      deviation in departure time from moderator surface
%   yvec(2,...):   y_a      y-coordinate of neutron at apperture
%   yvec(3,...):   z_a      z-coordinate of neutron at apperture
%   yvec(4,...):   t_ch'    deviation in time of arrival at chopper
%   yvec(5,...):   x_s      x-coordinate of point of scattering in sample frame
%   yvec(6,...):   y_s      y-coordinate of point of scattering in sample frame
%   yvec(7,...):   z_s      z-coordinate of point of scattering in sample frame
%   yvec(8,...):   x_d      x-coordinate of point of detection in detector frame
%   yvec(9,...):   y_d      y-coordinate of point of detection in detector frame
%   yvec(10,...):  z_d      z-coordinate of point of detection in detector frame
%   yvec(11,...):  t_d      deviation in detection time of neutron

wout = win;
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

% Unpack lookup tables and other pre-computed parameters
[ok,mess,lookup]=resol_conv_tobyfit_mc_init();
if ~ok
    error(mess)     % something went wrong!
end

mod_table=lookup.mod_table.table;
t_av=lookup.mod_table.t_av;
ind_mod=lookup.mod_table.ind;

wa=lookup.aperture.width;
ha=lookup.aperture.height;

fermi_table=lookup.fermi_table.table;
ind_fermi=lookup.fermi_table.ind;

[ind,rng_status]=resol_conv_tobyfit_mc_control; % get indicies of win to be computed and status of random number generator
if isempty(ind)
    ind=1:numel(win);
    rng_status=cell(size(win));
elseif numel(ind)~=numel(win)
    error('Inconsistency between number of input datasets and number passed from control routine')
elseif max(ind(:))>numel(lookup.sample)
    error('Inconsistency between dataset indicies passed from control routine and the lookup tables')
end

% Check refinement options are consistent
if xtal.refine && modshape.refine
    error('Cannot refine both crystal and moderator parameters. Error in logic flow - this should have been caught')
end

% Perform resolution broadening calculation
for i=1:numel(ind)
    iw=ind(i);
    if ~isempty(rng_status), rng(rng_status{i}), end

    % Catch case of refining crystal orientation
    if xtal.refine
        % Strip out crystal refinement parameters
        ptmp=multifit_gateway_parameter_get(pars);
        pars=multifit_gateway_parameter_set(pars, ptmp(1:end-9));
        alatt=ptmp(end-8:end-6);
        angdeg=ptmp(end-5:end-3);
        rotvec=ptmp(end-2:end);
        % Compute rotation matrix and new ub matrix
        rotmat=rotvec_to_rotmat2(rotvec);
        ub=ubmatrix(xtal.urot,xtal.vrot,bmatrix(alatt,angdeg));
        rlu_corr=ub\rotmat*xtal.ub0;
        % Reorient workspace
        win(i)=change_crystal(win(i),rlu_corr);
        
    elseif modshape.refine
        % Strip out moderator refinement parameters
        npmod=numel(modshape.pp);
        ptmp=multifit_gateway_parameter_get(pars);
        pars=multifit_gateway_parameter_set(pars, ptmp(1:end-npmod));
        pp=ptmp(end-npmod+1:end);
        % Get moderator lookup table for current moderator parameters
        [mod_table_refine,t_av_refine]=refine_moderator_sampling_table_buffer...
                                            (modshape.pulse_model,pp,modshape.ei);
        ind_mod_refine=ones(size(ind_mod{iw}));
    end
    
    qw = calculate_qw_pixels(win(i));   % get qw *after* changing crystal orientation
    npix = size(win(i).data.pix,2);
    irun = win(i).data.pix(5,:);
    idet = win(i).data.pix(6,:);
    
    for imc=1:mc_npoints
        yvec=zeros(11,1,npix);
        
        % Fill time deviations for moderator
        if mc_contrib.moderator
            if ~modshape.refine
                yvec(1,1,:)=moderator_times(mod_table,t_av',ind_mod{iw},irun');
            else
                yvec(1,1,:)=moderator_times(mod_table_refine,t_av_refine',ind_mod_refine,irun');
            end
        end
        
        % Aperture deviations
        if mc_contrib.aperture
            yvec(2,1,:)=wa{iw}(irun).*(rand(1,npix)-0.5);
            yvec(3,1,:)=ha{iw}(irun).*(rand(1,npix)-0.5);
        end
        
        % Fermi chopper deviations
        if mc_contrib.chopper
            yvec(4,1,:)=fermi_times(fermi_table,ind_fermi{iw},irun');
        end
        
        % Sample deviations
        if mc_contrib.sample
            yvec(5:7,1,:)=random_points(lookup.sample(iw),npix);
        end
        
        % Detector deviations
        if mc_contrib.detector_depth
            yvec(8,1,:)=0.015*(rand(1,npix)-0.5);     % approx dets as 25mm diameter, and take full width of 0.6 of diameter; 0.6*0.025=0.015
        end
        
        if mc_contrib.detector_area
            yvec(9,1,:) =win(i).detpar.width(idet).*(rand(1,npix)-0.5);
            yvec(10,1,:)=win(i).detpar.height(idet).*(rand(1,npix)-0.5);
        end
        
        % Energy bin
        if mc_contrib.energy_bin
            yvec(11,1,:)=lookup.dt{iw}.*(rand(1,npix)-0.5);
        end
        
        dq=squeeze(mtimesx_horace(lookup.dq_mat{iw},yvec))';
        if imc==1
            stmp=sqwfunc(qw{1}+dq(:,1),qw{2}+dq(:,2),qw{3}+dq(:,3),qw{4}+dq(:,4),pars{:});
        else
            stmp=stmp+sqwfunc(qw{1}+dq(:,1),qw{2}+dq(:,2),qw{3}+dq(:,3),qw{4}+dq(:,4),pars{:});
        end
    end
    wout(i).data.pix(8:9,:)=[stmp(:)'/mc_npoints;zeros(1,numel(stmp))];
    wout(i)=recompute_bin_data(wout(i));
end


%--------------------------------------------------------------------------------------------------
function t = moderator_times(table,t_av,ind,irun)
% Get a column vector of time deviations for moderator, one per pixel
%
% Here we require size(table)=[npnt,nmod], size(t_av)=[nmod,1], ind and irun column vectors

npix=numel(irun);
np_mod=size(table,1);

x=1+(np_mod-1)*rand(npix,1);        % position in open interval (1,np_mod) [column]
ix=np_mod*(ind(irun)-1)+floor(x);   % interval number in table that contains x (floor(x) in closed interval [1,np_mod-1]) [column]
dx=mod(x,1);                        % distance from lower index

t_red=(1-dx).*table(ix) + dx.*table(ix+1);
t = t_av(ind(irun)) .* (t_red./(1-t_red) - 1);      % must subtract first moment


%--------------------------------------------------------------------------------------------------
function t = fermi_times(table,ind,irun)
% Get a column vector of time deviations for Fermi chopper, one per pixel
%
% Here we require size(table)=[npnt,nchop], ind and irun column vectors

npix=numel(irun);
np_fermi=size(table,1);

x=1+(np_fermi-1)*rand(npix,1);      % position in open interval (1,np_fermi)
ix=np_fermi*(ind(irun)-1)+floor(x);% interval number in table that contains x (floor(x) in closed interval [1,np_fermi-1])
dx=mod(x,1);                        % distance from lower index

t=(1-dx).*table(ix) + dx.*table(ix+1);
