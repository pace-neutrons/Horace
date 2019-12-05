function wout = sqw (win)
% Convert input dnd-type object into sqw object
%
%   >> wout = sqw (win)

% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if numel(win)==1
    wout=sqw('$dnd',struct(win));
else
    wout=repmat(sqw,size(win));
    for i=1:numel(win)
        wout(i)=sqw('$dnd',struct(win(i)));
    end
end

