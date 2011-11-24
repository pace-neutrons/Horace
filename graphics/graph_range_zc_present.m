function [zpresent,cpresent]=graph_range_zc_present (fig)
% Get the limits on x,y for current figure or named figure
%
%   >> [zpresent,cpresent] = graph_range
%   >> [zpresent,cpresent] = graph_range (fig)

% Determine which figure to get handles
if ~exist('fig','var')||(isempty(fig)),
    if isempty(findall(0,'Type','figure'))
        error('No current figure exists - no ranges can be returned.')
    else
        fig=gcf;
    end
else
    [fig,ok,mess]=genie_figure_handle(fig);
    if ~ok, error(mess), end
    if isempty(fig)
        error('No figure with given name or figure number - no ranges can be returned.')
    elseif numel(fig)>1
        error('Can return ranges for one figure only.')
    end
end

% Get plot handles
[fig_h, axes_h, plot_h, plot_type] = genie_figure_all_handles (fig);

zpresent=false;
cpresent=false;
for i=1:numel(plot_h)
    if ~strcmp(plot_type{i},'line')
        zdata = get(plot_h(i),'ZData');
        if ~isempty(zdata)
            zpresent=true;
        end
    end
    if isprop(plot_h(i),'CData')
        cpresent=true;
    end
end
