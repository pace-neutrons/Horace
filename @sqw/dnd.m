function wout = dnd (win)
% Convert input sqw object into corresponding d0d, d1d,...d4d object
%
%   >> wout = dnd (win)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

nd=dimensions(win);
if nd<0||nd>4
    error('Dimensionality of sqw object must be 0,1,2..4')
end

if is_sqw_type(win)
    din=rmfield(win.data,{'urange','pix'});
else
    din=win.data;
end

if nd==0
    wout=d0d(din);
elseif nd==1
    wout=d1d(din);
elseif nd==2
    wout=d2d(din);
elseif nd==3
    wout=d3d(din);
elseif nd==4
    wout=d4d(din);
end
