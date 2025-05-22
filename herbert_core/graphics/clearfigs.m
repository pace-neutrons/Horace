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
%
%               If fig is not given, or is set to '-all', the function deletes
%              all figures.
%
%               An empty character string or one containing just whitespace
%              is a valid name: the name is '' i.e. the empty string.


if nargin==0
    fig = '-all';
end

fig_handle = get_figure_handle (fig);
if ~isempty(fig_handle)
    delete(fig_handle)
end
