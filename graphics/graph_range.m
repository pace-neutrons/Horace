function [xrange,yrange,ysubrange,zrange,zsubrange,crange]=graph_range (fig)
% Get the limits on x,y for current figure or named figure
%
%   >> [fig_h, axes_h, plot_h] = genie_range
%   >> [fig_h, axes_h, plot_h] = genie_range (fig)

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

xlim=get(axes_h,'XLim');
ylim=get(axes_h,'YLim');
xlo = Inf; xhi = -Inf;
ylo = Inf; yhi = -Inf;
zlo = Inf; zhi = -Inf;
clo = Inf; chi = -Inf;
ymin = Inf; ymax = -Inf;
zmin = Inf; zmax = -Inf;

zpresent=false;
cpresent=false;
for i=1:numel(plot_h)
    xdata = get(plot_h(i),'XData');
    ydata = get(plot_h(i),'YData');
    xlo = min(min(xdata(:)),xlo);
    xhi = max(max(xdata(:)),xhi);
    ylo = min(min(ydata(:)),ylo);
    yhi = max(max(ydata(:)),yhi);
    % Get y limits in the present x-range
    ok_x = xdata>=xlim(1) & xdata<=xlim(2);
    ymin = min(min(ydata(ok_x)),ymin);
    ymax = max(max(ydata(ok_x)),ymax);
    if ~strcmp(plot_type{i},'line')
        zdata = get(plot_h(i),'ZData');
        if ~isempty(zdata)
            zpresent=true;
            zlo = min(min(zdata(:)),zlo);
            zhi = max(max(zdata(:)),zhi);
            % Get z limits in the present x-range and y-range
            ok_y = ydata>=ylim(1) & ydata<=ylim(2);
            zmin = min(min(zdata(ok_x&ok_y)),zmin);
            zmax = max(min(zdata(ok_x&ok_y)),zmax);
        end
    end
    if isprop(plot_h(i),'CData')
        cpresent=true;
        cdata = get(plot_h(i),'CData');
        clo = min(min(cdata(:)),clo);
        chi = max(max(cdata(:)),chi);
        % Would also like to find min and max of cdata in the current x,y range,
        % but the interpretation of cdata is fairly sophisticated depending on
        % the call to patch, surface and other plotting routines. We ignore the
        % problem for the time-being
    end
end
xrange=[xlo,xhi];
yrange=[ylo,yhi];
ysubrange=[ymin,ymax];
if zpresent
    zrange=[zlo,zhi];
    zsubrange=[zmin,zmax];
else
    zrange=[];
    zsubrange=[];
end
if cpresent
    crange=[clo,chi];
else
    crange=[];
end
