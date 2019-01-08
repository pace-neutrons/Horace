function [allQE,widx,state_out,store_out]=gst_DGfermi_genpoints(win,caller,state_in,store_in,...
    pars,lookup,mc_contributions,mc_points,xtal,modshape)
% Calculate resolution broadened sqw object(s) for a model scattering function.
%
%   >> [wout,state_out,store_out]=tobyfit_DGfermi_resconv(win,caller,state_in,store_in,...
%    sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape)
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
%   lookup      A structure containing lookup tables and pre-calculated matricies etc.
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


% Use 3He cylindrical gas tube (ture) or Tobyfit original (false)
use_tube=false;


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
% Determine just how many QE points we will output:
total_pixels = sum( arrayfun(@(x)(size(x.data.pix,2)),win) );
noutput = mc_points * total_pixels;
% So that we can pre-allocate output arrays
allQE = zeros(noutput,4); % the generated (Q,E) points
widx  = zeros(noutput,1); % the index into win for each (Q,E) point
% objidx = zeros(noutput,1);% the index into the pixels for each (Q,E) points, e.g., win(widx(i)).data.pix(:,objidx(i))) %%%%% MAYBE USELESS
% Setup state and store output as well
state_out = cell(size(win));    % create output argument
store_out = [];


% Create pointers to parts of lookup structure
% --------------------------------------------
% Moderator
mod_table=lookup.mod_table.table;
mod_t_av=lookup.mod_table.t_av(:);    % ensure is a column vector

% Fermi chopper
fermi_table=lookup.fermi_table.table;

% Constants
k_to_v = lookup.k_to_v;
k_to_e = lookup.k_to_e;

% Detector
% --------
if use_tube
    He3det=IX_He3tube(0.0254,10,6.35e-4);   % 1" tube, 10atms, wall thickness=0.635mm
end


% Perform resolution broadening calculation
% -----------------------------------------
if ~iscell(pars), pars={pars}; end  % package parameters as a cell for convenience

reset_state=caller.reset_state;

% Generate the 'noutput' (Q,E) points for output 
offset = 0;
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
    mod_ind=lookup.mod_table.ind{iw}(:);        % ensure is a column vector
    fermi_ind=lookup.fermi_table.ind{iw}(:);    % ensure is a column vector
    x0=lookup.x0{iw};
    xa=lookup.xa{iw};
    x1=lookup.x1{iw};
    thetam=lookup.thetam{iw};
    angvel=lookup.angvel{iw};
    wa=lookup.wa{iw};
    ha=lookup.ha{iw};
    ki=lookup.ki{iw};
    kf=lookup.kf{iw};
    sample=lookup.sample(iw);
    s_mat=lookup.s_mat{iw};
    spec_to_rlu=lookup.spec_to_rlu{iw};
    d_mat=lookup.d_mat{iw};
    detdcn=lookup.detdcn{iw};
    x2=lookup.x2{iw};
    det_width=lookup.det_width{iw};
    det_height=lookup.det_height{iw};
    dt=lookup.dt{iw};
    qw=lookup.qw{iw};
    dq_mat=lookup.dq_mat{iw};
    
    % Run and detector for each pixel
    irun = win(i).data.pix(5,:)';   % column vector
    idet = win(i).data.pix(6,:)';   % column vector
    
    npix = size(win(i).data.pix,2); % or numel(irun), numel(idet)
    
    
    % Catch case of refining crystal orientation or moderator parameters
    if refine_crystal
        % Strip out crystal refinement parameters and reorientate datasets
        [win(i), pars{1}] = refine_crystal_strip_pars (win(i), xtal, pars{1});
        
        % Update s_mat and spec_to_rlu because crystal orientation will have changed
        [ok,mess,~,s_mat,spec_to_rlu]=sample_coords_to_spec_to_rlu(win(i).header);
        if ~ok, error(mess), end

        % Recompute Q because crystal orientation will have changed (dont need to update qw{4})
        qw(1:3) = calculate_q (ki(irun), kf, detdcn(:,idet), spec_to_rlu(:,:,irun));
        
        % Recompute (Q,w) deviations matrix for same reason
        dq_mat = dq_matrix_DGfermi (ki(irun), kf,...
            x0(irun), xa(irun), x1(irun), x2(idet),...
            thetam(irun), angvel(irun), s_mat(:,:,irun), d_mat(:,:,idet),...
            spec_to_rlu(:,:,irun), k_to_v, k_to_e);
    
    elseif refine_moderator
        % Strip out moderator refinement parameters and compute lookup table
        % Note we assume there is only one moderator to refine
        [mod_table_refine, mod_t_av_refine, ~, ~, store_out, pars{1}] = ...
            refine_moderator_strip_pars (modshape, store_in, pars{1});
    end
    
    % Generate (Q,E) points for the data set
    % ------------------------------------
    for imc=1:mc_points
        yvec=zeros(11,1,npix);
        
        % Fill time deviations for moderator
        if mc_contributions.moderator
            if ~refine_moderator
                t_red = rand_cumpdf_arr (mod_table, mod_ind(irun));
                yvec(1,1,:) = mod_t_av(mod_ind(irun)) .* (t_red./(1-t_red) - 1);    % must subtract first moment
            else
                t_red = rand_cumpdf_arr (mod_table_refine, ones(size(irun)));
                yvec(1,1,:) = mod_t_av_refine * (t_red./(1-t_red) - 1);    % must subtract first moment
            end
        end
        
        % Aperture deviations
        if mc_contributions.aperture
            yvec(2,1,:)=wa(irun)'.*(rand(1,npix)-0.5);
            yvec(3,1,:)=ha(irun)'.*(rand(1,npix)-0.5);
        end
        
        % Fermi chopper deviations
        if mc_contributions.chopper
            yvec(4,1,:)=rand_cumpdf_arr(fermi_table,fermi_ind(irun));
        end
        
        % Sample deviations
        if mc_contributions.sample
            yvec(5:7,1,:)=random_points(sample,npix);
        end
        
        % Detector deviations
        if use_tube
            % Use detecetor object random points method
            if mc_contributions.detector_depth || mc_contributions.detector_area
                if ~mc_contributions.detector_area
                    yvec(8,1,:) = random_points (He3det, kf);
                elseif ~mc_contributions.detector_depth
                    [~,yvec(9,1,:)] = random_points (He3det, kf);
                else
                    [yvec(8,1,:),yvec(9,1,:)] = random_points (He3det, kf);
                end
            end
            if mc_contributions.detector_area
                yvec(10,1,:)=det_height(idet).*(rand(1,npix)-0.5);
            end
        else
            % Use original Tobyfit method
            if mc_contributions.detector_depth
                yvec(8,1,:)=0.015*(rand(1,npix)-0.5);   % approx dets as 25mm diameter, and take full width of 0.6 of diameter; 0.6*0.025=0.015
            end
            
            if mc_contributions.detector_area
                yvec(9,1,:) =det_width(idet)'.*(rand(1,npix)-0.5);
                yvec(10,1,:)=det_height(idet)'.*(rand(1,npix)-0.5);
            end
        end
        
        % Energy bin
        if mc_contributions.energy_bin
            yvec(11,1,:)=dt'.*(rand(1,npix)-0.5);
        end
        
        % Calculate the deviations in Q and energy
        dq=squeeze(mtimesx_horace(dq_mat,yvec))';
        % And stash the full (Q,E) points away for output
        for j=1:4; allQE(offset+(1:npix),j) = qw{j} + dq(:,j); end
        % Also keep track of which win object these points came from
        widx(offset+(1:npix)) = i;
%         % And the index into win(i).data.pix for each point
%         objidx(offset+(1:npix)) = 1:npix;
        % Finally, increment the offset in preparation for the next points
        offset = offset + npix;
    end
end
