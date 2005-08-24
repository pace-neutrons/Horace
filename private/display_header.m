function display_header (d)
% Display useful information from the header of a binary spe, binary sqe or 01,2,3,4
% dimensional dataset to the screen
%
% Syntax:
%
%   >> display_header(d)    % d is a data structure read from one of the above types

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring


% NOTE: use sprintf to get fixed formatting of numbers (num2str strips trailing blanks)


disp(' ')
if strcmp(d.grid,'spe')||strcmp(d.grid,'sqe')
    disp([' ','Binary spe/sqe data:'])
elseif strcmp(d.grid,'orthogonal-grid')
    disp([' ',num2str(length(d.pax)),'-dimensional dataset:'])
end
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


%-----------------------------------------------------
% Binary spe or sqe file:
if strcmp(d.grid,'spe')||strcmp(d.grid,'sqe')
    disp( ' Extent of data: ')
    disp(['     Number of spe files: ',num2str(d.nfiles)])
    disp(' ')
    disp( '     Range of data (pixel centres):')
    ch_lo = cell(1,4);
    ch_hi = cell(1,4);
    for i=1:4
        ch_lo{i} = num2str(d.urange(1,i));
        ch_hi{i} = num2str(d.urange(2,i));
    end
    ch_lab = char(d.label);
    ch_lo = char(ch_lo);
    ch_hi = char(ch_hi);
    for i=1:4
        disp(['         ',ch_lab(i,:),':  ',ch_lo(i,:),'  to  ',ch_hi(i,:)])
    end
    disp(' ')
    disp( '     Energy bins of first .spe file:')
    nbin = round((d.en0(end)-d.en0(1))/d.ebin(1))+1;
    disp(['         ',num2str(d.en0(1)),' (',num2str(d.ebin(1)),') ',num2str(d.en0(end)),' meV   [',num2str(nbin),' bins]'])
    disp(' ')
    if d.ebin(2)~=d.ebin(3)
        disp([' WARNING: Minimum energy bin size less than maximum:  min.= ',num2str(d.ebin(2)),';  max.= ',num2str(d.ebin(3))])
        disp(' ')
    end
    
%-----------------------------------------------------
% Orthogonal grid:
elseif strcmp(d.grid,'orthogonal-grid')
    [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = dnd_cut_titles (d);
    if ~length(d.pax)==0
        np = zeros(1,length(d.pax));
        for i=1:length(d.pax)
            nam = ['p',num2str(i)];
            np(i) = length(d.(nam)) - 1;
        end
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

    % Print warning if no data in the cut, if full cut has been passed
    if isfield(d,'n')
        ntot = sum(reshape(d.n,1,prod(size(d.n))));
        if ntot < 0.5
            disp(' WARNING: The dataset contains no counts')
            disp(' ')
        end
    end
end


