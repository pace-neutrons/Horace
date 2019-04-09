function data = make_sqw_detpar
% Make a valid detpar field
%
% Syntax:
%   >> data = make_sqw_detpar
%
% Output:
% -------
% The default is to create an empty structure, so that the sqw structure neatly
% resembles the old d0d, d1d,...
%
% In the general case, the fields would be:
%
%   data         Structure containing fields read from file (details below)
%
%   data.filename   Name of file excluding path
%   data.filepath   Path to file including terminating file separator
%   data.group      Row vector of detector group number
%   data.x2         Row vector of secondary flightpath (m)
%   data.phi        Row vector of scattering angles (deg)
%   data.azim       Row vector of azimuthal angles (deg)
%                 (West bank=0 deg, North bank=90 deg etc.)
%   data.width      Row vector of detector widths (m)
%   data.height     Row vector of detector heights (m)
%

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)

data = struct([]);  % empty structure
