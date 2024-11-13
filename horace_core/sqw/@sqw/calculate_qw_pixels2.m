function qw=calculate_qw_pixels2(win)
% Calculate qh, qk, ql, en for the pixels in an sqw dataset from the experiment information
%
%   >> qw = calculate_qw_pixels2(win)
%
% This method differs from calculate_qw_pixels because it recomputes the values
% of momentum and energy from efix, emode and the detector information. This is
% necessary if the sqw object contains symmetrised data, for example.
%
% Input:
% ------
%   win     Input sqw object
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

efix = win.experiment_info.get_efix();
emode = win.experiment_info.get_emode();
en = win.experiment_info.en;
det_direction = win.experiment_info.detector_arrays.det_direction;

[qspec, en] = calc_qspec(det_direction, efix, en, emode);

qw = {qspec(:, 1), qspec(:, 2), qspec(:, 3), en};

end
