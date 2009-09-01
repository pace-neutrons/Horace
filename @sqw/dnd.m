function wout = dnd (win)
% Convert input sqw object into corresponding d0d, d1d,...d4d object
%
%   >> wout = dnd (win)

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

% Check that all elements in the array have same dimensionality
for i=1:numel(win)
    if i==1
        nd=dimensions(win(1));
    elseif dimensions(win(i))~=nd
        error('Not all elements in the array of sqw objects have same dimensionality')
    end
end

if nd<0||nd>4
    error('Dimensionality of sqw object must be 0,1,2..4')
end

for i=1:numel(win)
    if is_sqw_type(win(i))
        din=rmfield(win(i).data,{'urange','pix'});
    else
        din=win(i).data;
    end

    if i==1
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
        if numel(win)>1
            wout=repmat(wout,size(win));
        end
    else
        if nd==0
            wout(i)=d0d(din);
        elseif nd==1
            wout(i)=d1d(din);
        elseif nd==2
            wout(i)=d2d(din);
        elseif nd==3
            wout(i)=d3d(din);
        elseif nd==4
            wout(i)=d4d(din);
        end
    end
end
