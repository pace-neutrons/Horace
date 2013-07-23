function new=convert_IX_dataset_nd(oldmat)
% Convert IX_dataset_nd variables in a .mat file into new form (IX_axis containing tick information
% Dates from 5 June 2012.

old=load(oldmat);

new=old;
fname=fields(old);
n_unchanged=0;
for i=1:numel(fname)
    if isa(old.(fname{i}),'IX_dataset_1d') || isa(old.(fname{i}),'IX_dataset_2d') || isa(old.(fname{i}),'IX_dataset_3d')
        disp(['Converting: ',fname{i}])
        new.(fname{i})=convert_IX_dataset_nd_internal(old.(fname{i}));
    else
        disp(['Leaving unchanged: ',fname{i}])
        n_unchanged=n_unchanged+1;
    end
end

[fpath,fname,fext]=fileparts(oldmat);
save(fullfile('c:\temp',[fname,fext]),'-struct','new');
if n_unchanged>0
    disp('==============================================')
    disp([' Number of unchanged variables = ',num2str(n_unchanged)])
    disp('==============================================')
end


% ===================================================================================================
function wout=convert_IX_dataset_nd_internal(win)
% Convert IX_dataset_nd with old IX_axis class to new IX_axis class
%
% Assumes win has been read from mat file, with IX_axis fields converted to structures

nd=dimensions(win(1));

% Make output classes
if nd==1
    wout=repmat(IX_dataset_1d,size(win));
elseif nd==2
    wout=repmat(IX_dataset_2d,size(win));
elseif nd==3
    wout=repmat(IX_dataset_3d,size(win));
else
    error('Oh crap!')
end

% Convert all objects in the input array
ticks.positions=[];
ticks.labels={};

for i=1:numel(win)
    wstruct=struct(win(i));

    tmp=win.s_axis;
    tmp.ticks=ticks;
    tmp=IX_axis(tmp);
    wstruct.s_axis=tmp;
    
    if nd>=1
        tmp=win.x_axis;
        tmp.ticks=ticks;
        tmp=IX_axis(tmp);
        wstruct.x_axis=tmp;
    end
    
    if nd>=2
        tmp=win.y_axis;
        tmp.ticks=ticks;
        tmp=IX_axis(tmp);
        wstruct.y_axis=tmp;
    end
    
    if nd>=3
        tmp=win.z_axis;
        tmp.ticks=ticks;
        tmp=IX_axis(tmp);
        wstruct.z_axis=tmp;
    end
    
    if nd==1
        wout(i)=IX_dataset_1d(wstruct);
    elseif nd==2
        wout(i)=IX_dataset_2d(wstruct);
    elseif nd==3
        wout(i)=IX_dataset_3d(wstruct);
    end
    
    if numel(wout(i).signal)~=numel(win(i).signal)
        error('Convertion problem')
    end
end
