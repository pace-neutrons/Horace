function [wsqw,wdnd]=fudge_data(win)
% Fudge an old sqw structure to match the new format

% Make sqw structure
% ------------------
wsqw=win;

% Add the new fields
wsqw.data.filename=win.main_header.filename;
wsqw.data.filepath=win.main_header.filepath;
wsqw.data.title=win.main_header.title;
if win.main_header.nfiles==1
    wsqw.data.alatt=win.header.alatt;
    wsqw.data.angdeg=win.header.angdeg;
elseif win.main_header.nfiles>2
    wsqw.data.alatt=win.header{1}.alatt;
    wsqw.data.angdeg=win.header{1}.angdeg;
end

% Normalise the signal and error for the new format
wsqw.data.s=win.data.s./win.data.npix;
wsqw.data.e=win.data.e./(win.data.npix.^2);
nopix=(win.data.npix(:)==0);
wsqw.data.s(nopix)=0;
wsqw.data.e(nopix)=0;

% Reorder fields to match new structure
oldfields=fieldnames(win.data);
fields=cell(5+numel(oldfields),1);
fields(1:5)={'filename';'filepath';'title';'alatt';'angdeg'};
fields(6:end)=oldfields;
wsqw.data=orderfields(wsqw.data,fields); 

% Make dnd structure
% ------------------
wdnd=wsqw.data;
wdnd=rmfield(wdnd,{'urange','pix'});

    
