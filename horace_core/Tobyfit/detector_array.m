function detectors = detector_array (wtmp, use_tubes)
% Get detector information from a single sqw object.
%
%   >> detectors = detector_array (wtmp, use_tubes)
%
% This is a function for temporary use until the transition to exclusively
% using IX_detector_array data in the experiment_info has been completed.
%
% Requires that each run in the sqw object has the same detpar structure or
% IX_detector_array
%
% Input:
% ------
%   wtmp        sqw object
%   use_tubes   Logical flag if detector information is not held in wtmp as an
%               IX_detector_array object in wtmp.experiment_info:
%               - true: use IX_det_He3tube with wall thickness 6.35e-4 m and 10
%                 atms 3He partial pressures alongside detpar data on detector
%                 sizes
%               - false: use IX_det_TobyfitClassic as detector type alongside
%                 detpar data data on detector sizes
%
% Output:
% -------
%   detectors   The single IX_detector_array object use for each of the runs


% Because detpar only contains minimal information, either hardwire in
% the detector type here or use the info now available in the detector
% arrays
detpar = wtmp.detpar();   % just get a pointer
det = wtmp.experiment_info.detector_arrays;
if isempty(det) || det.n_runs == 0
    % no detector info was available when the sqw was populated, so
    % continue with the old detector initialisation from detpar
    if use_tubes
        detectors = IX_detector_array (detpar.group, detpar.x2(:), ...
            detpar.phi(:), detpar.azim(:),...
            IX_det_He3tube (detpar.width, detpar.height, 6.35e-4, 10));   % 10atms, wall thickness=0.635mm
    else
        detectors = IX_detector_array (detpar.group, detpar.x2(:), detpar.phi(:), detpar.azim(:),...
            IX_det_TobyfitClassic (detpar.width, detpar.height));
    end
else
    % make a new detector object based on value of use_tubes and insert
    % it into the detector_array info extracted from the sqw
    if det.n_unique_objects>1
        error('HORACE:detector_info:incorrect_size', ...
            ['all sqw runs must have identical detectors with this ', ...
            'implementation']);
    else
        det = det{1}; % first run detector array element is the same for all runs
        % so equivalent to the content in detpar
        bank = det.det_bank; % get out its detector bank
        % create a new detector object for this based on the detector
        % bank info stored in the sqw object
        current_detobj = bank.det;
        width = current_detobj.dia;
        height = current_detobj.height;
        if use_tubes
            % wall thickness 6.35e-4 and pressure 10 remain hardwired
            detobj = IX_det_He3tube(width, height, 6.35e-4, 10);
        else
            detobj = IX_det_TobyfitClassic(width, height);
        end
        % restore detector object to the bank
        bank.det  = detobj;
        % and restore the bank to the detector array
        det.det_bank = bank;
        % and store the array in the initializer for the detector
        % object lookup below.
        % NOTE that the detectors in experiment_info have not
        % themselves been updated.
        detectors = det;
    end
end

end
