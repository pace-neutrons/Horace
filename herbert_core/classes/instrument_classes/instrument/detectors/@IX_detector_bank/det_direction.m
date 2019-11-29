function detdcn = det_direction (obj)
% Matrix to convert coordinates in spectrometer frame into secondary spectrometer frame
%
%   >> detdcn = det_direction (obj)
%
% Input:
% ------
%   obj         IX_detector_bank object
%
% Output:
% -------
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%               [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]

cp = cosd(obj.phi_);
sp = sind(obj.phi_);
cb = cosd(obj.azim_);
sb = sind(obj.azim_);

detdcn=[cp, cb.*sp, sb.*sp]';
