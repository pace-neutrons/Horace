function detdcn = calc_detdcn(det,varargin)
% Compute the direction from the sample to the detector elements
%
%   >> detdcn = calc_detdcn(det)
%
% Input:
% ------
%   det     Detector structure as read by get_par [scalar structure]
%
% Optional:
% keep_detector_id -- if present, return array, also containing the
%           detectors ID row. If these id-s are missing from input detector
%           group, the detectors are numbered from 1 to number of elements
%           in detectors array.
%
% Output:
% -------
%  detdcn   [3 x ndet] array of unit vectors, pointing to the detector's
%           positions in the spectrometer coordinate system (X-axis
%           along the beam direction). ndet -- number of detectors
%           Can be later assigned to the next rundata object
%           property "detdcn_cache" to accelerate calculations. (not
%           fully implemented and currently works with MATLAB code only)
%           [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]

ex = cosd(det.phi);
ey = sind(det.phi).*cosd(det.azim);
ez = sind(det.phi).*sind(det.azim);
% the assumption here is that det will have row vectors, however it is now
% very possible that they may be columns. So convert ex/y/z to rows
ex = make_row(ex);
ey = make_row(ey);
ez = make_row(ez);
if nargin == 1
    detdcn = [ex;ey;ez];
else
    if isfield(det,'group')
        detdcn = [ex;ey;ez;det.group];
    else
        detdcn = [ex;ey;ez;1:numel(ex)];
    end
end
