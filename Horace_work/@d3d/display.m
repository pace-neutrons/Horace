function display (w)
% DISPLAY Command window display of a 3D dataset
%
% Syntax:
%   >> display (w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

data = get(w);  % get a structure with the same fields as w
data            % print to screen in standard Matlab fashion