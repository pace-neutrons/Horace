function [fig_, axes_, plot_] = plot_twod (w_in, newplot, plot_type, fig, varargin)
% Draw a two-dimensional plot
%
%   >> plot_twod (w_in, newplot, plot_type, fig)
%   >> plot_twod (w_in, newplot, plot_type, fig, xlo, xhi)
%   >> plot_twod (w_in, newplot, plot_type, fig, xlo, xhi, ylo, yhi)
%   >> plot_twod (w_in, newplot, plot_type, fig, xlo, xhi, ylo, yhi, zlo, zhi)
%
% Input:
% ------
%   w_in        IX_dataset_2d object, or array of IX_dataset_2d objects.
%               In the case of plot type 'surface2' it could be a cell array
%              of either two IX_dataset_2d arrays or an IX_dataset_2d scalar
%              and a numeric array.
%
%   newplot     True if new figure frame to be drawn (could be in existing
%              figure window however). False if should overplot on an
%              existing plot, depending on the value of fig.
%
%   plot_type   Type of plopt to be drawn:
%                   'area'      area plot
%                   'surface'   surface plot
%                   'surface2'  surface plot where the first object sets
%                              the z-scale, and the seconds sets the colour
%                              scale.
%
%   fig         Figure name, alternatively if newplot==false could be a
%              figure number or figure handle
%
%   xlo, xhi    x-axis limits
%
%   ylo, yhi    y-axis limits
%
%   zlo, zhi    z-axis limits


plot_types={'area','surface','surface2','contour'};

par=varargin;


% Check input arguments
% ---------------------
% Check spectrum is not too long an array
maxspec=get_global_var('genieplot','twod_maxspec');
if ~iscell(w_in), nspec=numel(w_in); else nspec=numel(w_in{1}); end
if nspec>maxspec
    mess=['This function can only be used to plot ',num2str(maxspec),' 2D datasets - check input object'];
    if nargout<=3, error(mess); end
end

% Get newplot argument
if islognumscalar(newplot)
    newplot=logical(newplot);   % in case numeric 0 or 1
else
    mess='Keyword ''newplot'' must be logical true or false';
    if nargout<=3, error(mess), end
end

% Get plot type
if is_string(plot_type) && ~isempty(plot_type)
    ind=stringmatchi(plot_type,plot_types);
    if ~isempty(ind)
        plot_type=plot_types{ind};
    else
        mess='Plot type not recognised';
        if nargout<=3, error(mess), end
    end
else
    mess='Plot type must be a (non-empty) character string';
    if nargout<=3, error(mess), end
end

% Get figure name or figure handle - used to branch later on
if strcmpi(plot_type,'area')        % area plot
    default_fig_name=get_global_var('genieplot','name_area');
elseif strcmpi(plot_type,'surface') % surface plot
    default_fig_name=get_global_var('genieplot','name_surface');
elseif strcmpi(plot_type,'surface2')% surface2 plot
    default_fig_name=get_global_var('genieplot','name_surface');
elseif strcmpi(plot_type,'contour') % contour plot
    default_fig_name=get_global_var('genieplot','name_contour');
else
    error('Logic error: unrecognised plot_type')
end
[fig_out,ok,mess]=genie_figure_target(fig,newplot,default_fig_name);
if ~ok
    error(mess);
end

% Check plot limits:
if ~newplot
    if ~isempty(par)
        mess='Cannot specify plot limits when overplotting';
        if nargout<=3, error(mess), end
    end
    % Need to specify xlims,ylims not give in case need to create a figure
    xlims=false;
    ylims=false;
    zlims=false;
else
    if isempty(par)
        xlims=false;
        ylims=false;
        zlims=false;
    elseif numel(par)==2||numel(par)==4||numel(par)==6
        bad=false;
        xlims=true;
        if isnumeric(par{1}) && isscalar(par{1}), xlo=par{1}; else bad=true; end
        if isnumeric(par{2}) && isscalar(par{2}), xhi=par{2}; else bad=true; end
        if numel(par)>=4
            ylims=true;
            if isnumeric(par{3}) && isscalar(par{3}), ylo=par{3}; else bad=true; end
            if isnumeric(par{4}) && isscalar(par{4}), yhi=par{4}; else bad=true; end
        else
            ylims=false;
        end
        if numel(par)>=6
            zlims=true;
            if isnumeric(par{5}) && isscalar(par{5}), zlo=par{5}; else bad=true; end
            if isnumeric(par{6}) && isscalar(par{6}), zhi=par{6}; else bad=true; end
        else
            zlims=false;
        end
        if bad
            mess='Plot limits must be numeric scalars';
            if nargout<=3, error(mess), end
        elseif xlims && xlo>=xhi
            mess='Plot limits along x axis must have xlo < xhi';
            if nargout<=3, error(mess), end
        elseif ylims && ylo>=yhi
            mess='Plot limits along y-axis must have ylo < yhi';
            if nargout<=3, error(mess), end
        elseif zlims && zlo>=zhi
            mess='Plot limits along signal axis must have zlo < zhi';
            if nargout<=3, error(mess), end
        end
    else
        mess='Check plot limits are numeric and the number of limits';
        if nargout<=3, error(mess), end
    end
end


% Perform plot
% ------------
% Create new graphics window if required
if is_string(fig_out)
    new_figure = genie_figure_create (fig_out);
    if new_figure
        newplot=true;   % if had to create a new figure window
    end
else
    figure(fig_out); % overplotting on existing plot; make the current figure
end

% If newplot, delete any axes
if newplot
    delete(gca)     % not necessary if new_figure, but doesn't do any harm
else
    hold on;        % hold plot for overplotting
end

% Make a copy of w_in for manipulations inside plot routines
nsmooth=get_global_var('genieplot','twod_nsmooth');
if nsmooth == 0
    w = w_in;
else
    w = w_in; % *** UNTIL SORT OUT SMOOTHING
end

% Plot data (already checked that it is valid)
if strcmpi(plot_type,'area')        % area plot
    plot_area (w)
    box on                          % put boundary box on plot
    set(gca,'layer','top')          % puts axes layer on the top

elseif strcmpi(plot_type,'surface') % surface plot
    if newplot, view(3); end        % set viewpoint if newplot
    plot_surface (w);
    set(gca,'layer','top')          % puts axes layer on the top

elseif strcmpi(plot_type,'surface2')% surface2 plot
    if newplot, view(3); end        % set viewpoint if newplot
    plot_surface2 (w);
    set(gca,'layer','top')          % puts axes layer on the top

elseif strcmpi(plot_type,'contour') % contour plot
    plot_contour (w);

end
hold off    % release plot

% Create/change title if a new plot
if (newplot)
    if ~iscell(w)
        [tx,ty,tz]=make_label(w(1));    % Create axis annotations
        tt=w(1).title(:);  % tt=[w(1).title(:);['Plot smoothing = ',num2str(nsmooth)]];
        xticks=w(1).x_axis.ticks;
        yticks=w(1).y_axis.ticks;
        zticks=w(1).s_axis.ticks;
    else
        [tx,ty,tz]=make_label(w{1}(1)); % Create axis annotations
        tt=w{1}(1).title(:);  % tt=[w(1).title(:);['Plot smoothing = ',num2str(nsmooth)]];
        xticks=w{1}(1).x_axis.ticks;
        yticks=w{1}(1).y_axis.ticks;
        zticks=w{1}(1).s_axis.ticks;
    end
    % Change titles:
    if any(contains(tt,'$'))
        inter= 'latex';
    else
        inter= 'tex';
    end
    title(tt,'FontWeight','normal','interpreter',inter);
    xlabel(tx);
    ylabel(ty);
    if ~strcmpi(plot_type,'area')   % don't try to plot along z axis if just an area plot
        zlabel(tz)
    end
    % Change ticks
    if ~isempty(xticks.positions), set(gca,'XTick',xticks.positions); end
    if ~isempty(xticks.labels), set(gca,'XTickLabel',xticks.labels); end
    if ~isempty(yticks.positions), set(gca,'YTick',yticks.positions); end
    if ~isempty(yticks.labels), set(gca,'YTickLabel',yticks.labels); end
    if ~isempty(zticks.positions), set(gca,'ZTick',zticks.positions); end
    if ~isempty(zticks.labels), set(gca,'ZTickLabel',zticks.labels); end
end

% Change limits if they are provided
if newplot
    axis tight
    if xlims, lx(xlo,xhi), end
    if ylims, ly(ylo,yhi), end
    if zlims, lc(zlo,zhi), end
end

% Add colorslider if a new plot
if newplot
    colorslider
end

% Get fig, axes and plot handles
[fig_, axes_, plot_] = genie_figure_all_handles;
