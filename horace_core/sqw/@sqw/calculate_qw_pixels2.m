function qw=calculate_qw_pixels2(win,coord_in_rlu,return_matrix)
% Calculate qh, qk, ql, en for the pixels in an sqw dataset from the experiment information
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
%  win          -- Input sqw object
% Optional:
%  coord_in_rlu -- default true. Returns pixel coordinates in reciprocal
%                  lattice units (projection onto rotated hkl coordinate
%                  system). If false, return pixel coordinates in Crystal
%                  Cartesial coordinate system
% return_matrix -- default false. Return pixel coordinates as cellarray of
%                  4 vectors. (See below)
%                  if true, return coordinates as [4 x n_pixels] array
%
%
% Output:
% -------
%   qw      Components of momentum (in rlu) and energy for each pixel in the dataset
%           Arrays are packaged as cell array of column vectors for convenience
%           with fitting routines etc.
%               i.e. qw{1}=qh, qw{2}=qk, qw{3}=ql, qw{4}=en

% Get some 'average' quantities for use in calculating transformations and bin boundaries
% *** assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines

if ~isscalar(win)
    error('HORACE:calculate_qw_pixels2:invalid_argument', ...
        'Only a single sqw object is valid - cannot take an array of sqw objects')
end
if nargin<2
    coord_in_rlu = true;
    return_matrix= false;
elseif nargin<3
    return_matrix= false;
end

% as column vectors
idx    = win.pix.all_indexes();
run_id  = idx(1,:)';
det_id  = idx(2,:)';
en_id   = idx(3,:)';

% if we want possible change in alatt during experiment, go to
%
alatt = win.data.alatt;
angdeg = win.data.angdeg;

experiment = win.experiment_info;
ix_exper   = experiment.expdata;
remapper   = win.experiment_info.runid_map;
%
% convert run_id in pixels into number of IX_experiment, corresponding to
% this pixel. Now irun represent number of IX_experiment in Experiment
% class or number of transformation matrix in list of all transformations
% (spec_to_rlu)
run_id     = remapper.get_values_for_keys(run_id,true); % retrieve experiment numbers which corresponds to pix run_id;

if coord_in_rlu % coordinates in rlu, lattice is aligned with beam in
    % a direction specified in IX_experiment
    n_matrix = 3;
else % coordinates in Crystan Cartesian
    n_matrix = 1;
end
% energies:
% incident/analysis
efix = experiment.get_efix();
% get unuque emodes. A unique instrument certainly have unique emode
all_modes= experiment.get_emode();
all_inst = experiment.instruments;
[~,unique_inst_run_idx] = all_inst.get_unique_objects_and_indices(true);
emode = zeros(1,numel(unique_inst_run_idx));
for i=1:numel(unique_inst_run_idx)
    emode(i) = all_modes(unique_inst_run_idx{i}(1));
end


% unique energy transfers arrays. It is common that every run has its own energy
% transfer values:
[en,unique_en_run_idx]   = experiment.get_en_transfer(true,true);
% unique detectors. Wider then unique instrumens, so use detectors
all_det = experiment.detector_arrays;
[unique_det, unique_inst_run_idx] = all_det.get_unique_objects_and_indices(true);
n_unique_det = numel(unique_inst_run_idx);

% identify bunch of enery transfer values, corresponding to each bunch of
% unique detectors
[en,ien_per_run_map] = merge_en_ranges(en,unique_en_run_idx,en_id,run_id,unique_inst_run_idx); % return
% cellarray of possible enery transfers for each bunch of runs with unique detectors.

qspec = cell(1,n_unique_det);
eni   = cell(1,n_unique_det);
inst_id=cell(1,n_unique_det);
for i=1:n_unique_det
    selected = ismemeber(run_id,unique_inst_run_idx{i});
    inst_id{i} = selected;
    idet_4_run = det_id(selected);
    detdcn= unique_det{i}.calc_detdcn(idet_4_run);
    [qspec{i},eni{i}] = calc_qspec(detdcn(1:3,:), efix{i}, en{i}, emode(i));
end


% obtain transformation matrices to convert each run's dector positions
% into common coordinate system related to crystal (hkl or crystal
% Cartesian)
spec_to_rlu  = arrayfun(...
    @(ex) calc_proj_matrix(ex,alatt, angdeg,n_matrix), ix_exper, 'UniformOutput', false);
% Join in 3rd rank leading to n x n x nhead
spec_to_rlu = cat(3, spec_to_rlu{:});

qw = zeros(4,numel(run_id));
for i=1:n_unique_det
    qtmp = mtimesx_horace (spec_to_rlu, reshape(qspec{i}), [3, 1, size(qspec{i},2)]);
    qtmp = squeeze(qtmp);
    qw(1:3,inst_id{i}) = qtmp;
    qw(4,inst_id{i})   = eni{i};
end


if ~return_matrix
    qw = num2cell(qw,2);
    for i=1:4
        qw{i} = qw{i}(:);
    end
end

end

