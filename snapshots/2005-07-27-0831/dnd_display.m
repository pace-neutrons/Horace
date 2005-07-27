function dnd_display (d)
% Display useful information about a dataset structure to the screen
%
%   >> dnd_display(d)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring


% NOTE: use sprintf to get fixed formatting of numbers (num2str strips trailing blanks)

[title_main, title_pax, display_pax, display_iax, energy_axis] = dnd_cut_titles (d);

disp(' ')
disp([' ',num2str(length(d.pax)),'-dimensional dataset:'])
disp(' ----------------------')

if ~isempty(d.file)
    disp([' Original datafile: ',d.file])
else
    disp([' Original datafile: ','<none>'])
end

disp(['         Grid type: ',d.grid])

if ~isempty(d.title)
    disp(['             Title: ',d.title])
else
    disp(['             Title: ','<none>'])
end

disp(' ')
disp( ' Lattice parameters (Angstroms and degrees):')
disp(['         a=',sprintf('%-11.4g',d.a),    '    b=',sprintf('%-11.4g',d.b),   '     c=',sprintf('%-11.4g',d.c)])
disp(['     alpha=',sprintf('%-11.4g',d.alpha),' beta=',sprintf('%-11.4g',d.beta),' gamma=',sprintf('%-11.4g',d.gamma)])
disp(' ')

if ~length(d.pax)==0
    np=size(d.s);
    npchar = '[';
    for i=1:length(np)
        npchar = [npchar,num2str(np(i)),'x'];
    end
    npchar(end)=']';
    disp([' Size of ',num2str(length(d.pax)),'-dimensional dataset: ',npchar])
end
if length(d.pax)~=0
    disp( '     Plot axes:')
    for i=1:length(d.pax)
        disp(['         ',display_pax{i}])
    end
    disp(' ')
end
if length(d.iax)~=0
    disp( '     Integration axes:')
    for i=1:length(d.iax)
        disp(['         ',display_iax{i}])
    end
    disp(' ')
end


