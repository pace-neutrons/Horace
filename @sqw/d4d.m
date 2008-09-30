function wout = d4d (win)
% Convert input 4-dimensional sqw object into corresponding d4d object
%
%   >> wout = d4d (win)

% Special case of dnd included for completeness

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


nd=dimensions(win);
if nd~=4
    error('Dimensionality of sqw object not equal to 4')
else
    wout=dnd(win);
end
