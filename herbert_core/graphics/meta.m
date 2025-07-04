function meta (fig)
% Make a meta file copy of the indicated figure
%
%   >> meta         % meta file from current figure
%   >> meta (fig)   % meta file from given figure
%
% On windows, this function puts the file in the clipboard so that it can
% be pasted directly into Word, Powerpoint etc.
%
% Input:
% ------
%   fig         Figure name *OR* figure number *OR* figure handle
%
%               An empty character string or one containing just whitespace
%              is a valid name: the name is '' i.e. the empty string.
%
%               If fig is not given, or is an empty argument apart from an
%              empty character string (which is a valid name, see above),
%              the function returns the figure handle for the current
%              figure, if one exists.


% Determine the figure handle - ensuring there is one and only one figure
% indicated by input argument fig (throws an error if otherwise)
if ~exist('fig', 'var')
    fig_handle = get_figure_handle('-single');  % current figure, if it exists
else
    fig_handle = get_figure_handle(fig, '-single');
end

% Create meta file
fig_num = get(fig_handle, 'Number');
if ispc
    print('-dmeta','-noui',['-f',num2str(fig_num)]);
else
    print('-clipboard','-dbitmap','-noui',['-f',num2str(fig_num)]);
end
