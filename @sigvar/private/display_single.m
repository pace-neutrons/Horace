function display_single (w)
% Display useful information from sigvar object
%
%   >> display_single(w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

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
