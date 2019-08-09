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


% Create pointers to parts of lookup structure
% --------------------------------------------
mod_shape_mono_table = lookup.mod_shape_mono_table;
horiz_div_table = lookup.horiz_div_table;
vert_div_table = lookup.vert_div_table;
sample_table = lookup.sample_table;
detector_table = lookup.detector_table;

% Constants
k_to_v = lookup.k_to_v;
k_to_e = lookup.k_to_e;

mc_mod_shape_mono = [mc_contributions.moderator,...
    mc_contributions.shape_chopper, mc_contributions.mono_chopper];

% Perform resolution broadening calculation
% -----------------------------------------
% Package parameters as a cell for convenience
if ~iscell(pars), pars={pars}; end

% Catch case of refining moderator parameters
if refine_moderator
    % Get the (single) moderator to be refined. Assume that any checks
    % on moderator models in the sqw objects being fitted have been performed
    % searlier on so that here all moderators are replaced by a single one
    % derived from the first object in the lookup table.
    moderator = mod_shape_mono_table.object_store(1).moderator;
    
    % Strip out moderator refinement parameters and update moderator
    [moderator, pars{1}] = refine_moderator_strip_pars...
        (moderator, modshape, pars{1});
    
    % Replace moderator(s) in object lookup with updated moderator
    mod_shape_mono = mod_shape_mono_table.object_store;
    for i=1:numel(mod_shape_mono)
        mod_shape_mono.moderator = moderator;
    end
    mod_shape_mono_table.object_store = mod_shape_mono;
end

reset_state=caller.reset_state;
for i=1:numel(ind)
    % Get index of workspace into lookup tables
    iw=ind(i);

    % Set random number generator if necessary, and save if required for later
    if reset_state
        if ~isempty(state_in{i})
            rng(state_in{i})
        end
    else
        state_out{i} = rng;     % capture the random number generator state
    end
    
    % Create pointers to parts of lookup structure for the current dataset
    xa=lookup.xa{iw};
    x1=lookup.x1{iw};
    ki=lookup.ki{iw};
    kf=lookup.kf{iw};
    alatt=lookup.alatt{iw};
    angdeg=lookup.angdeg{iw};
    f_mat=lookup.f_mat{iw};
    d_mat=lookup.d_mat{iw};
    detdcn=lookup.detdcn{iw};
    x2=lookup.x2{iw};
    dt=lookup.dt{iw};
    qw=lookup.qw{iw};
    dq_mat=lookup.dq_mat{iw};
    
    % Run and detector for each pixel
    irun = win(i).data.pix(5,:)';   % column vector
    idet = win(i).data.pix(6,:)';   % column vector
    npix = size(win(i).data.pix,2);
    
    % Catch case of refining crystal orientation or moderator parameters
    if refine_crystal
        % Strip out crystal refinement parameters and reorientate datasets
        [win(i), pars{1}] = refine_crystal_strip_pars (win(i), xtal, pars{1});

        % Update s_mat and spec_to_rlu because crystal orientation will have changed
        [ok,mess,~,s_mat,spec_to_rlu,alatt,angdeg]=sample_coords_to_spec_to_rlu(win(i).header);
        if ~ok, error(mess), end

        % Recompute Q because crystal orientation will have changed (dont need to update qw{4})
        qw(1:3) = calculate_q (ki(irun), kf, detdcn(:,idet), spec_to_rlu(:,:,irun));
        
        % Recompute (Q,w) deviations matrix for same reason
        dq_mat{i} = dq_matrix_DGdisk (ki(irun), kf,...
            xa(irun), x1(irun), x2(idet),...
            s_mat(:,:,irun), f_mat(:,:,idet), d_mat(:,:,idet),...
            spec_to_rlu(:,:,irun), k_to_v, k_to_e);
    end
    
    % Find out if the crystal has a mosaic spread
    % -------------------------------------------
    mosaic_spread = mosaic_crystal(sample_table.object_elements(iw).eta);
    
    % Simulate the signal for the data set
    % ------------------------------------
    for imc=1:mc_points
        yvec=zeros(11,1,npix);
        
        % Deviations at the shaping and monochromating choppers
        yvec([1,4],1,:) = 1e-6 * mod_shape_mono_table.rand_ind(iw,irun,'options','mc',mc_mod_shape_mono);
        debugtools(@debug_histogram_array, (10^6)*yvec(1,1,:), 't_shape', 'microseconds')
     
        % Divergence
        if mc_contributions.horiz_divergence
            yvec(2,1,:) = horiz_div_table.rand_ind(iw,irun);
        end
        
        if mc_contributions.vert_divergence
            yvec(3,1,:) = vert_div_table.rand_ind(iw,irun);
        end
        
        % Sample deviations
        if mc_contributions.sample
            yvec(5:7,1,:) = sample_table.func_eval(iw,@rand,[1,npix]);
        end
        
        % Detector deviations
        if mc_contributions.detector_depth || mc_contributions.detector_area
            det_points = detector_table.func_eval(iw,@rand,idet,kf);
            if ~mc_contributions.detector_area
                yvec(8,1,:) = det_points(1,:);
            elseif ~mc_contributions.detector_depth
                yvec(9:10,1,:) = det_points(2:3,:);
            else
                yvec(8:10,1,:) = det_points;
            end
        end
        
        % Energy bin
        if mc_contributions.energy_bin
            yvec(11,1,:)=dt'.*(rand(1,npix)-0.5);
        end
        
        % Calculate the deviations in Q and energy, and then the S(Q,w) intensity
        % -----------------------------------------------------------------------
        dq = mtimesx_horace(dq_mat,yvec);
        q = dq + reshape([qw{1}';qw{2}';qw{3}';qw{4}'], size(dq));

        % Mosaic spread
        if mosaic_spread && mc_contributions.mosaic
            Rrlu = sample_table.func_eval(iw,@rand_mosaic,[1,npix],alatt,angdeg);
            q(1:3,:,:) = mtimesx_horace(Rrlu, q(1:3,:,:));
        end
        q = squeeze(q);    % 4 x 1 x npix ==> 4 x npix
        
        if imc==1
            stmp=sqwfunc(q(1,:)',q(2,:)',q(3,:)',q(4,:)',pars{:});
        else
            stmp=stmp+sqwfunc(q(1,:)',q(2,:)',q(3,:)',q(4,:)',pars{:});
        end
    end
    wout(i).data.pix(8:9,:)=[stmp(:)'/mc_points;zeros(1,numel(stmp))];
    wout(i)=recompute_bin_data(wout(i));
end
