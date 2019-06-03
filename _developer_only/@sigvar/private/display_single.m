function display_single (w)
% Display useful information from sigvar object
%
%   >> display_single(w)

% Original author: T.G.Perring
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)

disp(' ')
disp(' Object of class: sigvar')
disp(' ')

if ~isempty(w.s)
    sz=size(w.s);
    str='[';
    for i=1:numel(sz)
        str=[str,num2str(sz(i)),'x'];
    end
    str(end:end)=']';
    disp(['    s: ',str,' array'])
else
    disp( '    s: []')
end

if ~isempty(w.e)
    sz=size(w.e);
    str='[';
    for i=1:numel(sz)
        str=[str,num2str(sz(i)),'x'];
    end
    str(end:end)=']';
    disp(['    e: ',str,' array'])
else
    disp( '    e: []')
end

disp(' ')
