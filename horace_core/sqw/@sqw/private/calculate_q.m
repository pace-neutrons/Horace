function q = calculate_q (ki, kf, detdcn, spec_to_rlu)
% Calculate qh,qk,ql
%
%   >> q = calculate_q (ki, kf, detdcn, spec_to_rlu)
%
% Input:
% ------
%   ki          Incident wavevectors for each point [Column vector]
%   kf          Final wavevectors for each point    [Column vector]
%   detdcn      Array of unit vectors in the direction of the detectors
%               Size is [3,npnt]
%   spec_to_rlu Matrix to convert momentum in spectrometer coordinates to
%               components in r.l.u.:
%                   v_rlu = spec_to_rlu * v_spec
%               Size is [3,3,npnt]
%
% Output:
% -------
%   q           Components of momentum (in rlu) for each point
%               [Cell array of column vectors]
%               i.e. q{1}=qh, q{2}=qk, q{3}=ql

% Use in-place working to save memory (note: bsxfun not needed from 2016b an onwards)
q = -kf' .* detdcn;
q(1,:) = ki' + q(1,:);            % qspec proper now
q = mtimesx_horace (spec_to_rlu, reshape(q, [3, 1, numel(ki)]));
q = squeeze(q);

% Package output
q = num2cell(q', 1);

end
