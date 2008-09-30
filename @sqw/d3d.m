function wout = d3d (win)
% Convert input 3-dimensional sqw object into corresponding d3d object
%
%   >> wout = d3d (win)

% Special case of dnd included for completeness

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


nd=dimensions(win);
if nd~=3
    error('Dimensionality of sqw object not equal to 3')
else
    wout=dnd(win);
end
