function viewcolormap(colmap)
% Plot a bar chart of a color map so you can see the colors
%
%   >> viewcolormap (colmap)
%
%  The colormap can be obtained from the available maps in mycolormaps.m
% e.g. >> colmap=mycolormaps('babbyblue')
% (The full list is displayed if you type >> help mycolormaps)
%
%  More generally, use the built-in function colormap to set the colormap

% Uses Herbert graphics

nx=size(colmap,1);
ny=size(colmap,2);
if ny~=3 || nx<1 || numel(size(colmap))~=2 || ~isnumeric(colmap)
    error('Check the input is a valid colormap')
end

x=1:nx+1;
y=[0,1];
signal=(1:nx)';
w=IX_dataset_2d(x,y,signal);

% Get current colormap so we can reset it
current_colmap=colormap;
try
    colormap(colmap)
    da(w)
    htmp=figure;
    colormap(htmp,current_colmap)
    delete(htmp)
catch
    colormap(current_colmap)
    rethrow(lasterror)
end
