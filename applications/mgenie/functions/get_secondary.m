function [delta, twotheta, azimuth, x2] = get_secondary
% Get secondary spectrometer information for all detectors for the currently assigned run
%
%   >> [delta, twotheta, azimuth, x2] = get_secondary
%
%   Output arguments are row vectors

delta = gget('delt');
x2 = gget('len2');
twotheta = gget('tthe');

if double(gget('nuse'))>=1
    azimuth = gget('ut1');
else
    azimuth = zeros(1,gget('ndet'));
end
