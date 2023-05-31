function obj = check_combo_arg_(obj)
% verify consistency of IX_detector_bank_objects
%
% Inputs:
% obj  -- the initialized instance of IX_detector_bank
%
% Returns:   unchanged object if IX_detector_bank components are consistent,
%            Throws HORACE:Experiment:invalid_argument with details of the
%            issue if they are not

ndet_id = numel(obj.id_);
ndet_det = obj.det.ndet;

if ndet_id ~= ndet_det
    error('HERBERT:IX_detector_bank:invalid_argument', ...
          'number of ids does not match number in detector object');
end

if numel(obj.x2) ~= ndet_id
    error('HERBERT:IX_detector_bank:invalid_argument', ...
          'number of x2s does not match number of detectors');
end
    
if numel(obj.phi) ~= ndet_id
    error('HERBERT:IX_detector_bank:invalid_argument', ...
          'number of phis does not match number of detectors');
end
    
if numel(obj.azim) ~= ndet_id
    error('HERBERT:IX_detector_bank:invalid_argument', ...
          'number of azims does not match number of detectors');
end
    
if size(obj.dmat, 3) ~= ndet_id
    error('HERBERT:IX_detector_bank:invalid_argument', ...
          'number of dmats does not match number of detectors');
end

end
