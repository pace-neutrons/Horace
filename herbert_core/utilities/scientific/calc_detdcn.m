function detdcn = calc_detdcn(phi,azim,varargin)
% Compute the direction from the sample to the detector elements
%
%   >> detdcn = calc_detdcn(det)
%
% Input:
% ------
%   phi       -- polar angle (deviation from z-axis) of a detector 
%   azim      -- azimthal angle 
% Optional:
%   det_group -- detector ID in the list of detectors. In the simples case
%                it is just detector number, in more complex -- special number
%                identifying detector in the detector array.
%Note:
% phi and azim come from  det struct structure as read by get_par 
% [scalar structure]
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

ex = cosd(phi);
sp = sind(phi);
ey = sp.*cosd(azim);
ez = sp.*sind(azim);
% the assumption here is that det will have row vectors, however it is now
% very possible that they may be columns. So convert ex/y/z to rows
ex = ex(:)';
ey = ey(:)';
ez = ez(:)';
if nargin < 3
    detdcn = [ex;ey;ez];
else
    det_group = varargin{1};
    detdcn = [ex;ey;ez;det_group(:)'];    
end
