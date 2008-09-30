function wout = d0d (win)
% Convert input 0-dimensional sqw object into corresponding d0d object
%
%   >> wout = d0d (win)

% Special case of dnd included for completeness

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


nd=dimensions(win);
if nd~=0
    error('Dimensionality of sqw object not equal to 0')
else
    wout=dnd(win);
end
