function wout = sqw (win)
% Convert input dnd-type object into sqw object
%
%   >> wout = sqw (win)

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

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
