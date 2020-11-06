function wout = sqw_old (win)
% Convert input dnd-type object into sqw object
%
%   >> wout = sqw (win)

% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if numel(win)==1
    wout=sqw_old('$dnd',struct(win));
else
    wout=repmat(sqw_old,size(win));
    for i=1:numel(win)
        wout(i)=sqw_old('$dnd',struct(win(i)));
    end
end

