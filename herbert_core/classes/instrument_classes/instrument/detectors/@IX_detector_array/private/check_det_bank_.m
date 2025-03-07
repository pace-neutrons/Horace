function val = check_det_bank_(val)
%Validate if input detectir banks set contains unique detector id-s
% and is acceptable as input for detectors_array
if iscell(val)
    is_detector_bank = cellfun(@(x)(isa(x,'IX_detector_bank')), val);
    if ~all(is_detector_bank )
        error('HERBERT:IX_detector_array:invalid_argument',...
            'Input cellarray contains objects which are not a Detector bank(s)')
    end
    % All inputs have class IX_detector_bank
    % Concatenate into a single array
    tmp = cellfun (@(x)(x(:)), val, 'uniformOutput', false);
    val = cat(1,tmp{:});
    clear tmp;
end

if ~isa(val,'IX_detector_bank') || isempty(val)
    error('HERBERT:IX_detector_array:invalid_argument',...
        'Detector bank(s) must be a non-empty IX_detector_bank array')
end


% Check that the detector identifiers are all unique
id = arrayfun (@(O)(O.id), val, 'uniformOutput', false);
id_all = cat(1,id{:});
if ~is_integer_id (id_all)
    error ('HERBERT:IX_detector_array:invalid_argument',...
        'Detector identifiers must all be unique')
end
