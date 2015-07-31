function meta(fig)
% Make a copy of the current figure to meta file.
%
%   >> meta          % meta file from current figure
%   >> meta(fig)     % meta file from given figure
%
% Input:
% ------
%   fig         Figure name *OR* figure number *OR* figure handle
%
% On windows, this function puts the file in the clipboard so that it can
% be pasted directly into Word, Powerpoint etc.


if ~exist('fig','var'), fig=[]; end
[fig_handle,ok,mess]=get_figure_handle_single(fig);
if ok
    fig_num = get_figure_number(fig_handle);
    print('-dmeta','-noui',['-f',num2str(fig_num)]);
else
    error([mess,'; cannot create meta file.'])
end
