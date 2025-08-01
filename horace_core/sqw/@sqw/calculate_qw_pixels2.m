function qw=calculate_qw_pixels2(win,coord_in_rlu,return_array)
% Calculate qh, qk, ql, en for the pixels in an sqw dataset from the
% experiment information
%
%   >> qw = calculate_qw_pixels2(win)
%   >> qw = calculate_qw_pixels2(win,coord_in_hkl)
%   >> qw = calculate_qw_pixels2(win,coord_in_hkl,return_matrix)
%
% This method differs from calculate_qw_pixels because it recomputes the values
% of momentum and energy from efix, emode and the detector information. This is
% necessary if the sqw object contains symmetrised data, for example.
%
% Input:
% ------
%  win         --  Input sqw object which works as container for pixelData
%                  and Experiment info used for processing pixel's coordinates 
%                  from pixel's indices and experiment information. SQW
%                  object's imags is not used.
% Optional:
% coord_in_rlu --  default true. Returns pixel coordinates in reciprocal
%                  lattice units (projection onto rotated hkl coordinate
%                  system). If false, return pixel coordinates in Crystal
%                  Cartesial coordinate system
% return_array --  default false. Return pixel coordinates as cellarray of
%                  4 vectors. (See below)
%                  if true, return coordinates as [4 x n_pixels] array
%
%
% Output:
% -------
%   qw
%    either      --
%           [4xnpix] array of q-de coordinates in rlu or Crystal Cartesian
%    or          --
%           Components of momentum (in rlu or CC) and energy for each pixel
%           in the dataset. Arrays are packaged as cell array of column
%           vectors for convenience with fitting routines etc.
%               i.e. qw{1}=qh, qw{2}=qk, qw{3}=ql, qw{4}=en
%
%  This method currently fully maintains initial order of pixels present in
%  input sqw object. This may change if pixels are processed in parallel
%  but this, in turn, will request usage of sqw objet's image (npix field)
%  currenlty not used by the routine.
%  

% NOTE: Routine assumes that all the contributing spe files have the same
% lattice parameters. This could be generalised later
% - but with repercussions in many routines

if ~isscalar(win)
    error('HORACE:calculate_qw_pixels2:invalid_argument', ...
        'Only a single sqw object is valid - cannot take an array of sqw objects')
end
if nargin<2
    coord_in_rlu = true;
    return_array= false;
elseif nargin<3
    return_array= false;
end

% as column vectors
idx    = win.pix.all_indexes();
run_id  = idx(1,:)';
det_id  = idx(2,:)';
en_id   = idx(3,:)';
experiment = win.experiment_info;

% convert run_id in pixels into index of IX_experiment corresponding to
% this pixel. After that irun represents index of IX_experiment element in
% Experiment.expdata array or index of transformation matrix in list of
% all transformations (spec_to_rlu)
remapper   = experiment.runid_map;
run_id     = remapper.get_values_for_keys(run_id,true); % retrieve IX_experiment array indices
%                                                       % which corresponds to pixels run_id;
idx(1,:)   = run_id;

% build map to use for placing calculated q-e values into appropriate
% positions of the input pixel array.
[lng_idx,mm_range] = long_idx(idx);
res_reorder_map = fast_map(double(lng_idx),1:numel(lng_idx));


% TODO: possible improvement.
%----------------- the methods used below may use caches precalculated
% before the calling here and running calculations
%  over pixels pages. See also one in runid loop below, around row 145
%
% if we want possible change in alatt during experiment, go to sampe in
% experiment and add it here. Currently lattice is unchanged during
% experiment
alatt = win.data.alatt;
angdeg = win.data.angdeg;


ix_exper   = experiment.expdata;
if coord_in_rlu % Requests coordinates in rlu, lattice is aligned with beam
    % in a direction specified in IX_experiment.
    matrix_id = 3; % this is defined by matrix_idx == 3 of
    % oriented_lattice.calc_proj_matrix method
else % Requests coordinates in Crystan Cartesian.
    matrix_id = 1; % this is defined by matrix_idx == 1 of
    % oriented_lattice.calc_proj_matrix method
end
% energies:
% compact_array containing incident for direct or analysis for indirect
% energies.
efix_info  = experiment.get_efix(true);
% get unuque emodes. A unique instrument certainly have unique emode
emodes= experiment.get_emode();

% unique detectors. It is possible to have mutliple instruments but Only
% detectors are used here and their number expected to coincide with the
% number of unique instruments. As no separate indices exists for
% instruments themselves, unique_detectors is all that means here.
% Here we select all detector arrays known to sqw object (sqw-experiment
% used to return specific unique references array)
all_det = experiment.detector_arrays;
[unique_det, unique_det_run_idx] = all_det.get_unique_objects_and_indices(true);
undet_info = compact_array(unique_det_run_idx,unique_det);
n_unique_det_arrays = undet_info.n_unique;


% unique energy transfers arrays. Although it is common that runs have the
% same energy transf value, it can often happen (e.g. data reduced with
% auto-ei and relative bin edges) that every run has its own energy
% transfer values:
en_tr_info   = experiment.get_en_transfer(true,true);

%----------------- Code is operating on the basis of metadata and caches,
% constructed above. If such metadata and caches are available, it would
% work fully independently of sqw object provided as input for this
% routine.
%
% identify bunch of incident energies and energy transfer values,
% corresponding to each bunch of unique detectors
[efix_info,en_tr_info,en_tr_idx] = retrieve_en_ranges( ...
    efix_info,en_tr_info,undet_info,run_id,en_id);
% return compact_arrays of possible incident energies and enery transfers
% for each bunch of runs with unique detectors.


% obtain transformation matrices to convert each run's dector positions
% into common coordinate system related to crystal (hkl or crystal
% Cartesian depending on input)
spec_to_rlu  = arrayfun(...
    @(ex) calc_proj_matrix(ex,alatt, angdeg,matrix_id), ix_exper, 'UniformOutput', false);

% allocate common space for result with size equal to number of pixels processed.
qw = zeros(4,size(idx,2)); %  Improves performance.
%
for i=1:n_unique_det_arrays
    run_idx_selected = undet_info.nonunq_idx{i};
    run_selected     = ismember(run_id,run_idx_selected);
    det_id_selected  = det_id(run_selected);  % detector ids contribured into runs with these detectors
    idet_4_runs = unique(det_id_selected);    % unique detector ids contribured into runs with these detectors

    % calculate detectors directions in instrument coordinate frame.
    % TODO: Possible future improvements:
    % [Ideally, the values here should be precalculated before call to
    % cacluate_qw_pixels2 and call here would just picks up cached
    % values]
    detdcn= unique_det{i}.calc_detdcn(idet_4_runs);

    % allocate caches for intermediate calculations
    n_runs = numel(run_idx_selected);  % runs which correspond to current detectors array
    qspec_i_cache  = cell(1,n_runs);
    eni_i_cache    = cell(1,n_runs);
    short_idx_cache= cell(1,n_runs);
    %

    %prepare processing for the particular run number i.
    efix_info_i = efix_info{i};
    en_tr_info_i = en_tr_info{i};
    en_tr_idx_i  = en_tr_idx{i};
    n_unique_efix= efix_info_i.n_unique;
    n_unique_entr= en_tr_info_i.n_unique;
    % create fast map for rapid addition/extraction of unique q-dE spectra
    mapper = fast_map();
    % allocate optimization array for known number of elements to insert
    mapper = mapper.optimize([0,n_unique_entr*n_unique_efix-1]);
    for run_id_number=1:n_runs
        % obtain efixed and information if this efixed was used before
        [efix,efix_info_i,unique_efix_num,used_efix]  = efix_info_i.get(run_id_number);
        % obtain energy transfer and information if these transfer values
        % were used before
        [en_tr,en_tr_info_i,unique_en_tr_num,used_en] = en_tr_info_i.get(run_id_number);
        % calculate unique number which define unique incident
        % energy/energy transfer scales
        q_spec_idx = n_unique_efix*(unique_en_tr_num-1)+unique_efix_num-1;
        en_tr_idx_per_run = en_tr_idx_i{unique_en_tr_num};

        % check if the incident energy and energy transfer scales were
        % calculated before in the else block below.
        if used_efix && used_en
            spec_idx = mapper.get(q_spec_idx);
            qspec_     = qspec_i_cache{spec_idx};
            eni_       = eni_i_cache{spec_idx};
            calc_idx_  = short_idx_cache{spec_idx};
            % would not occupy much space as COW. done just to simlify logic
            qspec_i_cache{run_id_number}   = qspec_;
            eni_i_cache{run_id_number}     = eni_   ;
            short_idx_cache{run_id_number} = calc_idx_;
        else % if not calculated, calculate qspec and enegry transfer values
            % contributing to sqw pixels
            % store used qspec index to know that we have already
            % calculated it in the future cycles
            mapper = mapper.add(q_spec_idx,run_id_number);
            % calculate energy transfers and momentum transfers in the
            % spectrometer frame
            [qspec_,eni_] = calc_qspec(detdcn(1:3,:), efix,en_tr, emodes(run_id_number));
            %
            % store cacluated values in cache per run number
            qspec_i_cache{run_id_number} = qspec_;
            eni_i_cache{run_id_number}   = eni_;
            % calc_q_spec replicates used detectors and energies into martix.
            % here we need to make the same replication for detector
            % indices and energy indices.
            [X,Y] = ndgrid(en_tr_idx_per_run(:),idet_4_runs(:));
            calc_idx_  = {Y(:)',X(:)'};
            short_idx_cache{run_id_number} = calc_idx_;
        end
        % TODO: MUST BE OPTIMIZED AND MOVED OUTSIDE OF THE LOOP [on the basis of
        % mtimesx_horace with pivot which will calculate matrix production
        % using cellarray of input oritnation martices and input kf_de
        % matrices (which do contain multiple pointers to the same matrices).
        % Sorting and duplicate dropping should be also included
        % into C routine for performance.]
        %
        % found indices of the run, energy bins and detector used in q-dE
        % calculations in the frame of the input indices
        run_idx = [repmat(run_idx_selected(run_id_number),1,numel(calc_idx_{1}));calc_idx_(:)];
        lng_run_idx       = long_idx(run_idx,mm_range);
        accounted_for     = ismember(lng_run_idx,lng_idx);
        lng_run_idx       = lng_run_idx(accounted_for);
        if ~isempty(lng_run_idx)
            % found this run transformation matrix
            spec_to_rlu_mat = spec_to_rlu{run_id_number};
            % and transform q-coordinates from sectrometer to crystal
            % Cartesian or hkl as requested
            qspec_ = mtimesx_horace(spec_to_rlu_mat,reshape(qspec_(:,accounted_for), [3, 1, numel(lng_run_idx)]));
            qspec_ = squeeze(qspec_);

            % found the positons of the calculated q-dE values in the
            % pixel(i.e. Crystal Cartesian or hkl coordinates)
            % array with input indices.
            res_places   = res_reorder_map.get_values_for_keys(lng_run_idx);
            qw(1:3,res_places) = qspec_;
            qw(4,res_places)   = eni_(accounted_for);
            % NB: only Crystal Cartesian can be stored in PixelDataBase
        end
    end
end

if ~return_array
    % return cellarray of 4 vectors
    qw = num2cell(qw,2);
    for i=1:4
        qw{i} = qw{i}(:);
    end
end

end
