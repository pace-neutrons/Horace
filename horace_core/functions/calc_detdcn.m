function detdcn = calc_detdcn(det)
% Compute the direction from the sample to the detector elements
%
%   >> detdcn = calc_detdcn(det)
%
% Input:
% ------
%   det     Detector structure as read by get_par [scalar structure]
% 
% Output:
% -------
%   detdcn  Direction of detector in spectrometer coordinates ([3 x ndet] array)
%               [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]

detdcn = [cosd(det.phi); sind(det.phi).*cosd(det.azim); sind(det.phi).*sind(det.azim)];
