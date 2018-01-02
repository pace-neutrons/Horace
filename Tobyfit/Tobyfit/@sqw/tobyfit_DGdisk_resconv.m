function [wout,state_out,store_out]=tobyfit_DGdisk_resconv(win,caller,state_in,store_in,...
    sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape)
% Calculate resolution broadened sqw object(s) for a model scattering function.
%
%   >> [wout,state_out,store_out]=tobyfit_DGdisk_resconv(win,caller,state_in,store_in,...
%    sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape)
%
% Input:
% ------
%   win         sqw object or array of objects
%
%   caller      Structure that contains information from the caller routine. Fields
%                   reset_state     Reset internal state to stored value in
%                                  state_in (logical scalar)
%                   ind             Indices into lookup tables. The number of elements
%                                  of ind must match the number of sqw objects in win
%
%   state_in    Cell array of internal state of this function for function evaluation.
%               If an element is not empty. then the internal state can be reset to this
%              stored state; if empty, then a default state must be used.
%               The number of elements must match numel(win); state_in must be a cell
%              array even if there is only a single input dataset.
%
%   store_in    Stored information that could be used in the function evaluation,
%              for example lookup tables that accumulate.
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
%   lookup      A structure containing lookup tables and pre-calculated matrices etc.
%              For details, see the help for function tobyfit_DGdisk_resconv_init
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
%                              of urot and vrot, perpendicular to urot with positive
%                              component along vrot
%                   ub0         ub matrix for lattice parameters in the input sqw objects
%               Empty if the crystal orientation is not going to be refined
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
%   store_out   Updated stored values. Must always be returned, but can be
%              set to [] if not used.
%
% NOTE: Contributions to resolution are
%   yvec(1,...):   t_sh     deviation in arrival time at pulse shaping chopper
%   yvec(2,...):   uh       horizontal divergence (rad)
%   yvec(3,...):   uv       vertical divergence (rad)
%   yvec(4,...):   t_ch     deviation in time of arrival at chopper
%   yvec(5,...):   x_s      x-coordinate of point of scattering in sample frame
%   yvec(6,...):   y_s      y-coordinate of point of scattering in sample frame
%   yvec(7,...):   z_s      z-coordinate of point of scattering in sample frame
%   yvec(8,...):   x_d      x-coordinate of point of detection in detector frame
%   yvec(9,...):   y_d      y-coordinate of point of detection in detector frame
%   yvec(10,...):  z_d      z-coordinate of point of detection in detector frame
%   yvec(11,...):  t_d      deviation in detection time of neutron


% Check consistency of caller information, stored internal state, and lookup tables
% ---------------------------------------------------------------------------------
ind=caller.ind;                 % indices into lookup tables
if numel(ind) ~= numel(win)
    error('Inconsistency between number of input datasets and number passed from control routine')
elseif numel(ind) ~= numel(state_in)
    error('Inconsistency between number of input datasets and number of internal function status stores')
elseif max(ind(:))>numel(lookup.sample)
    error('Inconsistency between dataset indices passed from control routine and the lookup tables')
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
store_out = [];


% Unpack the components of the lookup argument for convenience
% ------------------------------------------------------------
% Moderator
mod_ind=lookup.mod_table.ind;
mod_table=lookup.mod_table.table;
mod_t_av=lookup.mod_table.t_av;
mod_profile=lookup.mod_table.profile;

% Pulse shaping chopper
chop_shape_fwhh = lookup.chop_shape_fwhh;

% Moderator profile dominated by pulse shaping chopper
shape_mod = lookup.shape_mod;

% Distances
x0 = lookup.x0;
xa = lookup.xa;

% Monochromating chopper
chop_mono_fwhh = lookup.chop_mono_fwhh;

% Divergence
hdiv_ind=lookup.horiz_div_table.ind;
hdiv_table=lookup.horiz_div_table.table;
vdiv_ind=lookup.vert_div_table.ind;
vdiv_table=lookup.vert_div_table.table;

% Sample
sample=lookup.sample;

% Detector
He3det=IX_He3tube(0.0254,10,6.35e-4);   % 1" tube, 10atms, wall thickness=0.635mm
dt=lookup.dt;

% Final wavevector
kf=lookup.kf;

% Coordinate transformation
dq_mat=lookup.dq_mat;


% Perform resolution broadening calculation
% -----------------------------------------
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

reset_state=caller.reset_state;

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
        [win(i), pars{1}] = refine_crystal_strip_pars (win(i), xtal, pars{1});
        
    elseif refine_moderator
        % Strip out moderator refinement parameters
        [mod_table_refine, mod_t_av_refine, ~, mod_profile_refine, store_out, pars{1}] = ...
            refine_moderator_strip_pars (modshape, store_in, pars{1});
    end
    
    qw = calculate_qw_pixels(win(i));   % get qw *after* changing crystal orientation
    npix = size(win(i).data.pix,2);
    irun = win(i).data.pix(5,:);
    idet = win(i).data.pix(6,:);
    
    for imc=1:mc_points
        yvec=zeros(11,1,npix);
        
        % Monochromating chopper deviations
        % (Need to get these first, as needed to sample the shaped moderator pulse)
        if mc_contributions.mono_chopper
            t_ch = chop_mono_fwhh{iw}(irun).*rand_triangle([1,npix]);   % row vector
            yvec(4,1,:) = t_ch;
        else
            t_ch = zeros(1,npix);
        end
        
        % Fill time deviations at position of pulse shaping chopper.
        % We use shape_mod to determine which of the moderator pulse and the pulse
        % shaping chopper is the dominant determinant of the initial pulse. If
        % the moderator parameters are being refined then we still use the
        % values of shape_mod as determined by the initial moderator parameters
        % on the grounds that we should have started iwth a reasonable initial
        % set of parameters.
        
        if mc_contributions.moderator || mc_contributions.shape_chopper
            if ~refine_moderator
                yvec(1,1,:) = initial_pulse_DGdisk (...
                    mc_contributions.moderator, mc_contributions.shape_chopper,...
                    shape_mod{iw}, t_ch, x0{iw}(irun), xa{iw}(irun),...
                    mod_ind{iw}(irun), mod_table, mod_profile, mod_t_av,...
                    chop_shape_fwhh{iw}(irun));
            else
                yvec(1,1,:) = initial_pulse_DGdisk (...
                    mc_contributions.moderator, mc_contributions.shape_chopper,...
                    shape_mod{iw}, t_ch, x0{iw}(irun), xa{iw}(irun),...
                    ones(size(irun)), mod_table_refine, mod_profile_refine, mod_t_av_refine,...
                    chop_shape_fwhh{iw}(irun));
            end
        end
        
        % Divergence
        if mc_contributions.horiz_divergence
            yvec(2,1,:)=rand_cumpdf_arr(hdiv_table,hdiv_ind{iw}(irun));
        end
        
        if mc_contributions.vert_divergence
            yvec(3,1,:)=rand_cumpdf_arr(vdiv_table,vdiv_ind{iw}(irun));
        end
        
        % Sample deviations
        if mc_contributions.sample
            yvec(5:7,1,:)=random_points(sample(iw),npix);
        end
        
        % Detector deviations
        if mc_contributions.detector_depth || mc_contributions.detector_area
            if ~mc_contributions.detector_area
                yvec(8,1,:) = random_points (He3det, kf{iw});
            elseif ~mc_contributions.detector_depth
                [~,yvec(9,1,:)] = random_points (He3det, kf{iw});
            else
                [yvec(8,1,:),yvec(9,1,:)] = random_points (He3det, kf{iw});
            end
        end
        if mc_contributions.detector_area
            yvec(10,1,:)=win(i).detpar.height(idet).*(rand(1,npix)-0.5);
        end
        
        % Energy bin
        if mc_contributions.energy_bin
            yvec(11,1,:)=dt{iw}.*(rand(1,npix)-0.5);
        end
        
        dq=squeeze(mtimesx_horace(dq_mat{iw},yvec))';
        if imc==1
            stmp=sqwfunc(qw{1}+dq(:,1),qw{2}+dq(:,2),qw{3}+dq(:,3),qw{4}+dq(:,4),pars{:});
        else
            stmp=stmp+sqwfunc(qw{1}+dq(:,1),qw{2}+dq(:,2),qw{3}+dq(:,3),qw{4}+dq(:,4),pars{:});
        end
    end
    wout(i).data.pix(8:9,:)=[stmp(:)'/mc_points;zeros(1,numel(stmp))];
    wout(i)=recompute_bin_data(wout(i));
end
