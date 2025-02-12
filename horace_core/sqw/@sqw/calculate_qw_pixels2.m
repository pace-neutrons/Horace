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
idx   = win.pix.all_indexes();
irun = idx(1,:)';
idet = idx(2,:)';
ien  = idx(3,:)';

% if we want possible change in alatt during experiment, go to 
% 
alatt = win.data.alatt;
angdeg = win.data.angdeg;

experiment = win.experiment_info;
ix_exper = experiment.expdata;
remapper = win.experiment_info.runid_map;
%
% convert run_id in pixels into number of IX_experiment, corresponding to
% this pixel. Now irun represent number of IX_experiment in Experiment 
% class or number of transformation matrix in list of all transformations
% (spec_to_rlu)
irun     = remapper.get_values_for_keys(irun,true); % retrieve experiment numbers which corresponds to pix run_id;

if coord_in_rlu % coordinates in hkl
    n_matrix = 3;
else % coordinates in Crystan Cartesian
    n_matrix = 1;    
end
% obtain transformation matrices to convert each run's dector positions
% into common coordinate system related to crystal (hkl or crystal
% Cartesian)
spec_to_rlu  = arrayfun(...
    @(ex) calc_proj_matrix(ex,alatt, angdeg,n_matrix), ix_exper, 'UniformOutput', false);

% energies
efix = experiment.get_efix();
[en,n_unique_en_idx]   = experiment.get_en_transfer(true);
% 
all_det = experiment.detector_arrays;
[unique_det, run_idx] = all_det.get_unique_objects_and_indices(true);

n_unique_det = numel(run_idx);
det_dir = cell(1,n_unique_det);
for i=1:n_unique_det 
    selected = irun == run_idx{i};
    idet_4_run = idet(selected);
    det_dir(i) = unique_det{i}.calc_detdcn(idet_4_run);
end



% 
% % Join in 3rd rank leading to n x n x n_experiments
% spec_to_rlu = cat(3, spec_to_rlu{:});
% 
% eps_diff = (eps_lo(irun) .* (n_en(irun) - ien) + eps_hi(irun) .* (ien - 1)) ./ (n_en(irun) - 1);
% detdcn = spec_coords_to_det(win.detpar);
% kfix = sqrt(efix/k_to_e);
% 
% switch emode
%   case 1
%     ki = kfix(irun);
%     kf = sqrt((efix(irun)-eps_diff)/k_to_e);
%   case 2
%     ki = sqrt((efix(irun)+eps_diff)/k_to_e);
%     kf = kfix(irun);
%   otherwise
%     ki = kfix(irun);
%     kf = ki;
% end
% 
% qw = cell(4, 1);
% qw(1:3) = calculate_q(ki, kf, detdcn(:, idet), spec_to_rlu(:, :, irun));
% qw{4} = eps_diff;
% Join cell array into 4xN mat
if return_matrix
    qw = cat(2, qw{:})';
end


end

