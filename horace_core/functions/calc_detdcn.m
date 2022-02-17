function detdcn = calc_detdcn(det,keep_detector_id)
% Compute the direction from the sample to the detector elements
%
%   >> detdcn = calc_detdcn(det,keep_detector_id)
%
% Input:
% ------
%   det     Detector structure as read by get_par [scalar structure]
%
% Optional:
% keep_detector_id -- if present, return also the detectors ID
%
% Output:
% -------
%   detdcn  Direction of detector in spectrometer coordinates ([3 x ndet] array)
%               [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
% or (if keep_detector_id is provided)
%   detdcn -

ex = cosd(det.phi);
ey = sind(det.phi).*cosd(det.azim);
ez = sind(det.phi).*sind(det.azim);
if nargin == 1
    detdcn = [ex;ey;ez];
else
    if isfield(det,'group')
        detdcn = [ex;ey;ez;det.group];
    else
        detdcn = [ex;ey;ez;1:numel(ex)];
    end
end
