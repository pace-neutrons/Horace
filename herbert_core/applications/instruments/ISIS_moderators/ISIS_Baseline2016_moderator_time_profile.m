function [t, y] = ISIS_Baseline2016_moderator_time_profile (modStruct, ei, tmax)
% Get the time pulse from interpolating a lookup table
%
%   >> [t, y] = ISIS_Baseline2016_moderator_time_profile (source, ei)
%   >> [t, y] = ISIS_Baseline2016_moderator_time_profile (source, ei, tmax)
%
% Input:
% ------
%   source      Moderator file (.mat file), or structure as loaded from
%               a moderator .mat file by the function ISIS_Baseline2016_moderator_load
%
%   ei          Neutron energy
%
%   tmax        Maximum time for profile (microseconds)
%               Suitable values are 500 is for TS1, 2000 for TS2
%               Default: 2000
%
% Output:
% -------
%   t           Time (microseconds)
%   y           Intensity per microsecond per meV


% Interpolate on the logarithm of time and energy (the ISIS McStas files
% contain data in this form, and the energy spacing is relatively large
% e.g. for MAPS is 13.5% dE/E


if ischar(modStruct)
    modStruct = ISIS_Baseline2016_moderator_load (modStruct);
end

if nargin==2
    tmax = 2000;
end

intensity = modStruct.intensity;
tcent_log = log(modStruct.tcent);
encent_log = log(modStruct.encent);

% Truncate interpolated times to 500 microseconds maximum
t = modStruct.tcent;
keep = find(t<tmax);
t = t(keep);

% Interpolate
y = interp2(encent_log, tcent_log, intensity,...
    log(ei)*ones(size(t)), tcent_log(keep), 'linear',0);
y = y(:);
y = y(keep);
