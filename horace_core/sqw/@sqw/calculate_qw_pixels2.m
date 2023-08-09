function qw=calculate_qw_pixels2(win)
% Calculate qh, qk, ql, en for the pixels in an sqw dataset from the headers
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

c = neutron_constants;
k_to_e = c.c_k_to_emev;

% as column vectors
irun = win.pix.get_fields('run_idx')';
idet = win.pix.get_fields('detector_idx')';
ien = win.pix.get_fields('energy_idx')';

if ~iscell(win.header)
    header = {win.header};
else
    header = win.header;
end

emode = cellfun(@(x) x.emode, header);

if ~all(emode==emode(1))
    error('HORACE:calculate_qw_pixels2:invalid_argument', ...
          'Contributing runs to an sqw object must be all be direct geometry or all indirect geometry')
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
[~, detdcn] = spec_coords_to_det(win.detpar);
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

qw = cell(1, 4);
qw(1:3) = calculate_q (ki, kf, detdcn(:, idet), spec_to_rlu(:, :, irun));
qw{4} = eps_diff;

end

function [d_mat, detdcn] = spec_coords_to_det (detpar)
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

ndet = numel(detpar.x2);

cp = reshape(cosd(detpar.phi), [1, 1, ndet]);
sp = reshape(sind(detpar.phi), [1, 1, ndet]);
cb = reshape(cosd(detpar.azim), [1, 1, ndet]);
sb = reshape(sind(detpar.azim), [1, 1, ndet]);

d_mat = [cp, cb.*sp, sb.*sp;...
         -sp, cb.*cp, sb.*cp;...
         zeros(1, 1, ndet), -sb, cb];

detdcn = [cp; cb.*sp; sb.*sp];

end

function q = calculate_q (ki, kf, detdcn, spec_to_rlu)
% Calculate qh, qk, ql for direct geometry instrument
%
%   >> q = calculate_q (ki, kf, detdcn, spec_to_rlu)
%
% Input:
% ------
%   ki          Incident wavevectors for each point [Column vector]
%   kf          Final wavevectors for each point    [Column vector]
%   detdcn      Array of unit vectors in the direction of the detectors
%               Size is [3, npnt]
%   spec_to_rlu Matrix to convert momentum in spectrometer coordinates to
%               components in r.l.u.:
%                   v_rlu = spec_to_rlu * v_spec
%               Size is [3, 3, npnt]
%
% Output:
% -------
%   q           Components of momentum (in rlu) for each point
%               [Cell array of column vectors]
%               i.e. q{1}=qh, q{2}=qk, q{3}=ql

% Use in-place working to save memory (note: bsxfun not needed from 2016b an onwards)
qtmp = -kf' .* detdcn;
qtmp(1, :) = ki' + qtmp(1, :);            % qspec proper now
qtmp = mtimesx_horace (spec_to_rlu, reshape(qtmp, [3, 1, numel(ki)]));
qtmp = squeeze(qtmp);

% Package output
q = num2cell(qtmp', 1);

end
