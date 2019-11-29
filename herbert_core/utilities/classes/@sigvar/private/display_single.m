function display_single (w)
% Display useful information from a single instance of an object i.e. a scalar instance
%
%   >> display_single(w)
%
% *** REQUIRED PRIVATE METHOD ***

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
