function [wout,state_out]=tobyfit_DGfermi_resconv(win,caller,state_in,sqwfunc,pars,...
    lookup,mc_contributions,mc_points,xtal,modshape)
% Calculate resolution broadened sqw object(s) for a model scattering function.
%
%   >> [wout,state_out]=tobyfit_DGfermi_resconv(win,caller,state_in,sqwfunc,pars,...
%    lookup,mc_contributions,mc_points,xtal,modshape)
%
% Input:
% ------
%   win         sqw object or array of objects
%
%   caller      Stucture that contains ionformation from the caller routine. Fields
%                   reset_state     Reset internal state to stored value in
%                                  state_in (logical scalar)
%                   ind             Indicies into lookup tables. The number of elements
%                                  of ind must match the number of sqw objects in win
%
%   state_in    Cell array of internal state of this function for function evaluation.
%               If an element is not empty. then the internal state can be reset to this
%              stored state; if empty, then a default state must be used.
%               The number of elements must match numel(win); state_in must be a cell
%              array even if there is only a single input dataset.
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
%   mc_contributions    Structure indicating which components contribute to the resolution
%              function. Each field is the name of a component, and its value is
%              either true or false
%
%   mc_points   Number of Monte Carlo points per pixel
%
%   xtal        Crystal refinement constants. Structure with fields:
%                   urot        x-axis for rotation (r.l.u.)
%                   vrot        Defines y-axis for rotation (r.l.u.): y-axis in plane
%                              of urot and vrot, perpendicualr to urot with positive
%                              component along vrot
%                   ub0         ub matrix for lattice parameters in the input sqw objects
%               Empty if the crystal oreintation is not going to be refined
%
%   modshape    Moderator refinement constants. Structure with fields:
%                   pulse_model Pulse shape model for the moderator pulse shape whose
%                              parameters will be refined
%                   pin         Initial pulse shape parameters
%                   ei          Incident energy for pulse shape calculation (this
%                              will be the common ei for all the sqw objects)
%               Empty if the moderator is not going to be refined
%
%
% Output:
% -------
%   wout        Output dataset or array of datasets with computed signal
%
%   state_out   Cell array of internal state of this function for future evaluation.
%               The number of elements must match numel(win); state_in must be a cell
%              array even if there is only a single input dataset.
%
% NOTE: Contributions to resolution are
%   yvec(1,...):   t_m      deviation in departure time from moderator surface
%   yvec(2,...):   y_a      y-coordinate of neutron at aperture
%   yvec(3,...):   z_a      z-coordinate of neutron at aperture
%   yvec(4,...):   t_ch'    deviation in time of arrival at chopper
%   yvec(5,...):   x_s      x-coordinate of point of scattering in sample frame
%   yvec(6,...):   y_s      y-coordinate of point of scattering in sample frame
%   yvec(7,...):   z_s      z-coordinate of point of scattering in sample frame
%   yvec(8,...):   x_d      x-coordinate of point of detection in detector frame
%   yvec(9,...):   y_d      y-coordinate of point of detection in detector frame
%   yvec(10,...):  z_d      z-coordinate of point of detection in detector frame
%   yvec(11,...):  t_d      deviation in detection time of neutron


% Check consistency of caller information, stored internal state, and lookup tables
% ---------------------------------------------------------------------------------
ind=caller.ind;                 % indicies into lookup tables
if numel(ind) ~= numel(win)
    error('Inconsistency between number of input datasets and number passed from control routine')
elseif numel(ind) ~= numel(state_in)
    error('Inconsistency between number of input datasets and number of internal function status stores')
elseif max(ind(:))>numel(lookup.sample)
    error('Inconsistency between dataset indicies passed from control routine and the lookup tables')
end


% Check refinement options are consistent
% ---------------------------------------
refine_crystal = ~isempty(xtal);
refine_moderator = ~isempty(modshape);
if refine_crystal && refine_moderator
    error('Cannot refine both crystal and moderator parameters. Error in logic flow - this should have been caught')
end


% Initialise output arguments
% ---------------------------
wout = win;
state_out = cell(size(win));    % create output argument


% Unpack the components of the lookup argument for convenience
% ------------------------------------------------------------
% Moderator
mod_table=lookup.mod_table.table;
t_av=lookup.mod_table.t_av;
ind_mod=lookup.mod_table.ind;

% Aperture
wa=lookup.aperture.width;
ha=lookup.aperture.height;

% Fermi chopper
fermi_table=lookup.fermi_table.table;
ind_fermi=lookup.fermi_table.ind;

% Sample
sample=lookup.sample;

% Detector
dt=lookup.dt;

% Coordinate transformation
dq_mat=lookup.dq_mat;


% Perform resolution broadening calculation
% -----------------------------------------
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

reset_state=caller.reset_state;
if refine_moderator, dummy_sqw = sqw; end
dummy_mfclass = mfclass;

for i=1:numel(ind)
    iw=ind(i);
    % Set random number generator if necessary, and save if required for later
    if reset_state
        if ~isempty(state_in{i})
            rng(state_in{i})
        end
    else
        state_out{i} = rng;     % capture the random number generator state
    end

    % Catch case of refining crystal orientation
    if refine_crystal
        % Strip out crystal refinement parameters
        ptmp=mfclass_gateway_parameter_get(dummy_mfclass, pars);
        pars=mfclass_gateway_parameter_set(dummy_mfclass, pars, ptmp(1:end-9));
        alatt=ptmp(end-8:end-6);
        angdeg=ptmp(end-5:end-3);
        rotvec=ptmp(end-2:end);
        % Compute rotation matrix and new ub matrix
        rotmat=rotvec_to_rotmat2(rotvec);
        ub=ubmatrix(xtal.urot,xtal.vrot,bmatrix(alatt,angdeg));
        rlu_corr=ub\rotmat*xtal.ub0;
        % Reorient workspace
        win(i)=change_crystal(win(i),rlu_corr);
        
    elseif refine_moderator
        % Strip out moderator refinement parameters
        npmod=numel(modshape.pin);
        ptmp=mfclass_gateway_parameter_get(dummy_mfclass, pars);
        pars=mfclass_gateway_parameter_set(dummy_mfclass, pars, ptmp(1:end-npmod));
        pp=ptmp(end-npmod+1:end);
        % Get moderator lookup table for current moderator parameters
        [mod_table_refine,t_av_refine]=refine_moderator_sampling_table_buffer...
                                            (dummy_sqw,modshape.pulse_model,pp,modshape.ei);
        ind_mod_refine=ones(size(ind_mod{iw}));
    end
    
    qw = calculate_qw_pixels(win(i));   % get qw *after* changing crystal orientation
    npix = size(win(i).data.pix,2);
    irun = win(i).data.pix(5,:);
    idet = win(i).data.pix(6,:);
    
    for imc=1:mc_points
        yvec=zeros(11,1,npix);
        
        % Fill time deviations for moderator
        if mc_contributions.moderator
            if ~refine_moderator
                yvec(1,1,:)=moderator_times(mod_table,t_av',ind_mod{iw},irun');
            else
                yvec(1,1,:)=moderator_times(mod_table_refine,t_av_refine',ind_mod_refine,irun');
            end
        end
        
        % Aperture deviations
        if mc_contributions.aperture
            yvec(2,1,:)=wa{iw}(irun).*(rand(1,npix)-0.5);
            yvec(3,1,:)=ha{iw}(irun).*(rand(1,npix)-0.5);
        end
        
        % Fermi chopper deviations
        if mc_contributions.chopper
            yvec(4,1,:)=fermi_times(fermi_table,ind_fermi{iw},irun');
        end
        
        % Sample deviations
        if mc_contributions.sample
            yvec(5:7,1,:)=random_points(sample(iw),npix);
        end
        
        % Detector deviations
        if mc_contributions.detector_depth
            yvec(8,1,:)=0.015*(rand(1,npix)-0.5);     % approx dets as 25mm diameter, and take full width of 0.6 of diameter; 0.6*0.025=0.015
        end
        
        if mc_contributions.detector_area
            yvec(9,1,:) =win(i).detpar.width(idet).*(rand(1,npix)-0.5);
            yvec(10,1,:)=win(i).detpar.height(idet).*(rand(1,npix)-0.5);
        end
        
        % Energy bin
        if mc_contributions.energy_bin
            yvec(11,1,:)=dt{iw}.*(rand(1,npix)-0.5);
        end
        
        dq=squeeze(mtimesx(dq_mat{iw},yvec))';
        if imc==1
            stmp=sqwfunc(qw{1}+dq(:,1),qw{2}+dq(:,2),qw{3}+dq(:,3),qw{4}+dq(:,4),pars{:});
        else
            stmp=stmp+sqwfunc(qw{1}+dq(:,1),qw{2}+dq(:,2),qw{3}+dq(:,3),qw{4}+dq(:,4),pars{:});
        end
    end
    wout(i).data.pix(8:9,:)=[stmp(:)'/mc_points;zeros(1,numel(stmp))];
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
