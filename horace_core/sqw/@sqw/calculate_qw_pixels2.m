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

remap = containers.Map(unique(irun), 1:numel(win.header));
irun = arrayfun(@(x) remap(x), irun);

if ~iscell(win.header)
    header = num2cell(win.header)';
else
    header = win.header;
end

end

emode = emode(1);

efix = cellfun(@(x) x.efix, header);
eps_lo = cellfun(@(x) 0.5*(x.en(1)+x.en(2)), header);
eps_hi = cellfun(@(x) 0.5*(x.en(end-1)+x.en(end)), header);
n_en = cellfun(@(x) numel(x.en)-1, header);


[~, ~, spec_to_rlu] = cellfun(...
    @(h) calc_proj_matrix(h.alatt, h.angdeg, ...
                          h.cu, h.cv, h.psi, ...
                          h.omega, h.dpsi, h.gl, h.gs), header, 'UniformOutput', false);

% Join in 3rd rank leading to n x n x nhead
spec_to_rlu = cat(3, spec_to_rlu{:});

eps_diff = (eps_lo(irun) .* (n_en(irun) - ien) + eps_hi(irun) .* (ien - 1)) ./ (n_en(irun) - 1);
detdcn = spec_coords_to_det(win.detpar);
kfix = sqrt(efix/k_to_e);

switch emode
  case 1
    ki = kfix(irun);
    kf = sqrt((efix(irun)-eps_diff)/k_to_e);
  case 2
    ki = sqrt((efix(irun)+eps_diff)/k_to_e);
    kf = kfix(irun);
  otherwise
    ki = kfix(irun);
    kf = ki;
end

qw = cell(4, 1);
qw(1:3) = calculate_q(ki, kf, detdcn(:, idet), spec_to_rlu(:, :, irun));
qw{4} = eps_diff;
% Join cell array into 4xN mat
qw = cat(2, qw{:})';
qw = win.data.proj.transform_hkl_to_pix(qw);

end

function detdcn = spec_coords_to_det (detpar)
% Matrix to convert coordinates in spectrometer (or laboratory) frame into detector frame
%
%   >> d_mat = spec_coords_to_det (detpar)
%
% Input:
% ------
%   detpar      Detector parameter structure with fields as read by get_par
%
% Output:
% -------
%   d_mat       Matrix size [3, 3, ndet] to take coordinates in spectrometer
%              frame and convert in detector frame.
%
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%               [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%
% The detector frame is one with x axis along kf, y radially outwards. This is the
% original Tobyfit detector frame.

%% TODO: Investigate use of transform_pix_to_hkl

detdcn = {};
for i=1:detpar.n_objects
    ndet = numel(detpar{i}.x2);

    cp = cosd(detpar{i}.phi);
    sp = sind(detpar{i}.phi);
    cb = cosd(detpar{i}.azim);
    sb = sind(detpar{i}.azim);

    detdcn{i} = [cp, cb.*sp, sb.*sp];
end

detdcn = cat(1, detdcn{:})';
end
