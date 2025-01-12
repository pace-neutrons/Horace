function clearfigs (fig)
% Delete figure windows
%
%   >> clearfigs            % delete all figure windows
%   >> clearfigs (fig)      % delete indicated figures(s)
%   >> clearfigs ('-all')   % delete all figure windows (equivalent to no input)
%
% Input:
% ------
%   fig         Figure name or cell array of figure names
%          *OR* Figure number or array of figure numbers
%          *OR* Figure handle or array of figure handles


if nargin==0
    h = findall(0, 'Type', 'figure');
    if ~isempty(h)
        delete(h)
    end
else
    fig_handle = get_figure_handle (fig);
    delete(fig_handle)
end
