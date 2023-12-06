function [wout,state_out,store_out]=tobyfit_DGfermi_resconv(win,caller,state_in,store_in,...
    sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape)
% Calculate resolution broadened sqw object(s) for a model scattering function.
%
%   >> [wout,state_out,store_out]=tobyfit_DGfermi_resconv(win,caller,state_in,store_in,...
%    sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape)
%
% Input:
% ------
%   win         sqw object or array of objects
%
%   caller      Structure that contains information from the caller routine.
%               Contains fields:
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
%              For details, see the help for function tobyfit_DGfermi_resconv_init
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
wout = copy(win);
state_out = cell(size(win));    % create output argument
store_out = [];


% Create pointers to parts of lookup structure
% --------------------------------------------
moderator_table = lookup.moderator_table;
aperture_table = lookup.aperture_table;
fermi_table = lookup.fermi_table;
sample_table = lookup.sample_table;
detector_table = lookup.detector_table;

% Constants
k_to_v = lookup.k_to_v;
k_to_e = lookup.k_to_e;


% Perform resolution broadening calculation
% -----------------------------------------
% Package parameters as a cell for convenience
if ~iscell(pars), pars={pars}; end

% Catch case of refining moderator parameters
if refine_moderator
    % Get the (single) moderator to be refined. Assume that any checks
    % on moderator models in the sqw objects being fitted have been performed
    % earlier on so that here all moderators are replaced by a single one
    % derived from the first object in the lookup table.
    moderator = moderator_table.object_store(1);

    % Strip out moderator refinement parameters and update moderator
    [moderator, pars{1}] = refine_moderator_strip_pars...
        (moderator, modshape, pars{1});

    % Replace moderator(s) in object lookup with updated moderator
    moderator_table.object_store = moderator;
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
    x0=lookup.x0{iw};
    xa=lookup.xa{iw};
    x1=lookup.x1{iw};
    thetam=lookup.thetam{iw};
    angvel=lookup.angvel{iw};
    ki=lookup.ki{iw};
    kf=lookup.kf{iw};
    s_mat=lookup.s_mat{iw};
    spec_to_rlu=lookup.spec_to_rlu{iw};
    alatt=lookup.alatt{iw};
    angdeg=lookup.angdeg{iw};
    dt=lookup.dt{iw};
    qw=lookup.qw{iw};

    % Run and detector for each pixel
    irun = win(i).pix.run_idx(:);       % column vector
    idet = win(i).pix.detector_idx(:);  % column vector
    npix = win(i).pix.num_pixels;

    %===========================================================================
    %HACK. TODO: do it properly (ticket #901)
    % *** The same hack appears in tobyfit_DGdisk_resconv. Fix together.
    max_irun = max(irun);
    if max_irun>win(i).main_header.nfiles
        rmp = win(i).runid_map;
        runid_array = rmp.keys;
        runid_array = [runid_array{:}];
        runid_val   = rmp.values;
        runid_val   = [runid_val{:}];
        max_id = max(runid_array);
        min_id = min(runid_array)-1;
        lookup_ind = inf(max_id-min_id+1,1);
        lookup_ind(runid_array-min_id) = runid_val;
        irun   = lookup_ind(irun-min_id);
    end
    %===========================================================================

    % Get detector information for each pixel in the sqw object
    % size(x2) = [npix,1], size(d_mat) = [3,3,npix], size(f_mat) = [3,3,npix]
    % and size(detdcn) = [3,npix]
    [x2, detdcn, d_mat, f_mat] = detector_table.func_eval_ind (iw, irun, idet, @detector_info);

    % Catch case of refining crystal orientation
    if refine_crystal
        % Strip out crystal refinement parameters and reorient datasets
        [win(i), pars{1}] = refine_crystal_strip_pars (win(i), xtal, pars{1});

        % Update s_mat, spec_to_rlu, alatt and angdeg because in general the
        % crystal orientation and lattice parameters will have changed
        [~,s_mat,spec_to_rlu,alatt,angdeg]=sample_coords_to_spec_to_rlu(win(i).experiment_info);

        % Recompute Q because crystal orientation will have changed (don't need to update qw{4})
        qw(1:3) = calculate_q (ki(irun), kf, detdcn, spec_to_rlu(:,:,irun));

    end

    % Compute (Q,w) deviations matrix
    % This is done on-the-fly for each sqw object because dq_mat is so large
    % (44 double precision numbers for each pixel)
    dq_mat = dq_matrix_DGfermi (ki(irun), kf,...
        x0(irun), xa(irun), x1(irun), x2, thetam(irun), angvel(irun),...
        s_mat(:,:,irun), f_mat, d_mat,...
        spec_to_rlu(:,:,irun), k_to_v, k_to_e);


    % Find out if the crystal has a mosaic spread
    % -------------------------------------------
    % Get array of mosaic spreads for the runs, and determine if any of them
    % have other than the default no spread
    mosaic = arrayfun (@(x)(x.eta), sample_table.object_array(iw));
    mosaic_spread = any(mosaic_crystal (mosaic));

    % Simulate the signal for the data set
    % ------------------------------------
    for imc=1:mc_points
        yvec=zeros(11,1,npix);

        % Fill time deviations for moderator
        if mc_contributions.moderator
            [~,mod_t_av] = moderator_table.func_eval_ind(iw, irun, @pulse_width);
            yvec(1,1,:) = (1e-6)*(moderator_table.rand_ind(iw, irun, @rand) - mod_t_av);
        end

        % Aperture deviations
        if mc_contributions.aperture
            yvec(2:3,1,:) = aperture_table.rand_ind(iw, irun, @rand);
        end

        % Fermi chopper deviations
        if mc_contributions.chopper
            yvec(4,1,:) = (1e-6)*(fermi_table.rand_ind(iw, irun, @rand));
        end

        % Sample deviations
        if mc_contributions.sample
            yvec(5:7,1,:) = sample_table.rand_ind (iw, irun, @rand);
        end

        % Detector deviations
        if mc_contributions.detector_depth || mc_contributions.detector_area
            det_points = detector_table.rand_ind (iw, irun, idet, 'split', @rand, kf);
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
            yvec(11,1,:) = dt'.*(rand(1,npix) - 0.5);
        end

        % Calculate the deviations in Q and energy, and then the S(Q,w) intensity
        % -----------------------------------------------------------------------
        dq = mtimesx_horace(dq_mat,yvec);
        q = dq + reshape([qw{1}';qw{2}';qw{3}';qw{4}'], size(dq));

        % Mosaic spread
        if mosaic_spread && mc_contributions.mosaic
            Rrlu = sample_table.rand_ind (iw, irun, @rand_mosaic, alatt, angdeg);
            q(1:3,:,:) = mtimesx_horace(Rrlu, q(1:3,:,:));
        end
        q = squeeze(q);    % 4 x 1 x npix ==> 4 x npix

        if imc==1
            stmp=sqwfunc(q(1,:)',q(2,:)',q(3,:)',q(4,:)',pars{:});
        else
            stmp=stmp+sqwfunc(q(1,:)',q(2,:)',q(3,:)',q(4,:)',pars{:});
        end
    end

    wout(i).pix.signal = stmp(:)'/mc_points;
    wout(i).pix.variance = zeros(1,numel(stmp));

    % TODO: #975 this have to be done during paging operations
    % *** The same TODO appears in tobyfit_DGfermi_resconv. Fix together.
    wout(i) = recompute_bin_data(wout(i));
end

end
