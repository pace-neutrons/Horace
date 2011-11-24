function wout = IX_dataset_2d (spe)
% Convert spe object into a IX_dataset_2d
%
%   >> wout=IX_dataset_2d(spe)
%
%   spe   	spe object
%
%   wout    IX_dataset_2d object. Will be histogram object

title=avoidtex(fullfile(spe.filepath,spe.filename));
s_axis = IX_axis ('Intensity');
x_axis = IX_axis ('Energy transfer (meV)');
y_axis = IX_axis ('Workspace index');

wout = IX_dataset_2d (title, spe.S, spe.ERR,...
    s_axis, spe.en, x_axis, true, 1:size(spe.S,2), y_axis, false);
