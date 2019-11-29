function [fig_, axes_, plot_, ok, mess] = plot_oned (w_in, newplot, plot_type, fig, varargin)
% Draw a one-dimensional plot
%
%   >> plot_oned (w_in, newplot, plot_type, fig)
%   >> plot_oned (w_in, newplot, plot_type, fig, xlo, xhi)
%   >> plot_oned (w_in, newplot, plot_type, fig, xlo, xhi, ylo, yhi)
%
% Input:
% ------
%   w_in        IX_dataset_1d object, or array of IX_dataset_1d objects
%
%   newplot     True if new figure frame to be drawn (could be in existing
%              figure window however). False if should overplot on an
%              existing plot, depending on the value of fig.
%
%   plot_type   Type of plopt to be drawn:
%                   'e'     errors =  error bars
%                   'h'     histogram =  histogram plot
%                   'l'     line   =  line
%                   'm'     markers = marker symbols
%                   'd'     data   =  markers, error bars, lines
%                   'p'     points =  markers and error bars
%
%   fig         Figure name, alternatively if newplot==false could be a
%              figure number or figure handle
%
%   xlo, xhi    x-axis limits
%
%   ylo, yhi    y-axis limits


plot_types={'errors','histogram','line','markers','data','points'};
default_fig_name=get_global_var('genieplot','name_oned');

par=varargin;

fig_=[]; axes_=[]; plot_=[];


% Check input arguments
% ---------------------
% Check spectrum is not too long an array
maxspec=get_global_var('genieplot','oned_maxspec');
if numel(w_in)>maxspec
    ok=false; mess=['This function can only be used to plot ',num2str(maxspec),' spectra - check input object'];
    if nargout<=3, error(mess), else return, end
end

% Get newplot argument
if islognumscalar(newplot)
    newplot=logical(newplot);   % in case numeric 0 or 1
else
    ok=false; mess='Keyword ''newplot'' must be logical true or false';
    if nargout<=3, error(mess), else return, end
end

% Get plot type
if is_string(plot_type) && ~isempty(plot_type)
    ind=stringmatchi(plot_type,plot_types);
    if ~isempty(ind)
        plot_type=plot_types{ind};
    else
        ok=false; mess='Plot type not recognised';
        if nargout<=3, error(mess), else return, end
    end
else
    ok=false; mess='Plot type must be a (non-empty) character string';
    if nargout<=3, error(mess), else return, end
end

% Get figure name or figure handle - used to branch later on
[fig_out,ok,mess]=genie_figure_target(fig,newplot,default_fig_name);
if ~ok
    if nargout<=3, error(mess), else return, end
end

% Check plot limits:
if ~newplot
    if ~isempty(par)
        ok=false; mess='Cannot specify plot limits when overplotting';
        if nargout<=3, error(mess), else return, end
    end
    % Need to specify xlims,ylims not give in case need to create a figure
    xlims=false;
    ylims=false;
else
    if isempty(par)
        xlims=false;
        ylims=false;
    elseif numel(par)==2||numel(par)==4
        bad=false;
        xlims=true;
        if isnumeric(par{1}) && isscalar(par{1}), xlo=par{1}; else bad=true; end
        if isnumeric(par{2}) && isscalar(par{2}), xhi=par{2}; else bad=true; end
        if numel(par)==4
            ylims=true;
            if isnumeric(par{3}) && isscalar(par{3}), ylo=par{3}; else bad=true; end
            if isnumeric(par{4}) && isscalar(par{4}), yhi=par{4}; else bad=true; end
        else
            ylims=false;
        end
        if bad
            ok=false; mess='Plot limits must be numeric scalars';
            if nargout<=3, error(mess), else return, end
        elseif xlims && xlo>=xhi
            ok=false; mess='Plot limits along x axis must have xlo < xhi';
            if nargout<=3, error(mess), else return, end
        elseif ylims && ylo>=yhi
            ok=false; mess='Plot limits along signal axis must have ylo < yhi';
            if nargout<=3, error(mess), else return, end
        end
    else
        ok=false; mess='Check plot limits are numeric and the number of limits (must be none, xlo & xhi, or xlo,xhi,ylo & yhi)';
        if nargout<=3, error(mess), else return, end
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
binning=get_global_var('genieplot','oned_binning');
if binning <= 1   % accepts value of zero
    w = w_in;
else
    w = rebunch(w_in,binning);
end

% Plot data (already checked that it is valid)
if plot_type(1)=='e'
    plot_errors (w)
elseif plot_type(1)=='h'
    plot_histogram (w);
elseif plot_type(1)=='l'
    plot_line (w)
elseif plot_type(1)=='m'
    plot_markers (w)
elseif plot_type(1)=='d'
    plot_markers_errors_lines(w)
elseif plot_type(1)=='p'
    plot_markers_errors(w)
end
hold off    % release plot (could have been held for overplotting, for example

% Create/change title if a new plot
if (newplot)
    [tx,ty]=make_label(w(1));  % Create axis annotations
    tt=w(1).title(:);   % tt=[w(1).title(:);['Plot binning = ',num2str(binning)]];
    % Change titles:
    title(tt,'FontWeight','normal');
    xlabel(tx);
    ylabel(ty);
    % Change ticks
    xticks=w(1).x_axis.ticks;
    if ~isempty(xticks.positions), set(gca,'XTick',xticks.positions); end
    if ~isempty(xticks.labels), set(gca,'XTickLabel',xticks.labels); end
    yticks=w(1).s_axis.ticks;
    if ~isempty(yticks.positions), set(gca,'YTick',yticks.positions); end
    if ~isempty(yticks.labels), set(gca,'YTickLabel',yticks.labels); end
    
end

% Change limits if they are provided
if newplot
    axis tight
    if xlims, lx(xlo,xhi), end
    if ylims, ly(ylo,yhi), end
end

% Get fig, axes and plot handles
[fig_, axes_, plot_] = genie_figure_all_handles;
