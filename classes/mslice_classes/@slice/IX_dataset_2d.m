function wout = IX_dataset_2d (slice)
% Convert slice object into a IX_dataset_2d
%
%   >> wout=IX_dataset_2d(slice)
%
%   slice   slice object
%
%   wout    IX_dataset_2d object. Will be histogram object

nx = size(slice.xbounds,2) - 1;
ny = size(slice.ybounds,2) - 1;
signal = reshape(slice.c,nx,ny);
err = reshape(slice.e,nx,ny);

% set title:
if ~isempty(slice.SliceDir)||~isempty(slice.SliceFile)  % there is a slice file name
    temp = cellstr(slice.title);   % add file name to top of the title
    ltemp = length(temp);
    ltitle = ltemp + 1;
    title{1} = avoidtex(fullfile(slice.SliceDir,slice.SliceFile));
    title(2:ltitle) = temp(1:ltemp);
else
    title=cellstr(slice.title);
end

s_axis = IX_axis (slice.z_label);
x_axis = IX_axis (slice.x_label);
y_axis = IX_axis (slice.y_label);

wout = IX_dataset_2d (title, signal, err,...
    s_axis, slice.xbounds, x_axis, false, slice.ybounds, y_axis, false);
