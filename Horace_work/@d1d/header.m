function header (w)
% HEADER Command window display of a 1D dataset. Synonym to DISPLAY
%
% Syntax:
%   >> header (w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

dnd_display(get(w));  % get a structure with the same fields as w
