function [fig_, axes_, plot_, ok, mess] = plot_oned (w_in, varargin)
% Draw a one-dimensional plot
%
%   >> plot_oned (w_in, xlo, xhi)
%   >> plot_oned (w_in, xlo, xhi, ylo, yhi)
%   >> plot_oned (...,key1, val1, key2, val2,...)
%
%   Valid keywords and values
%       'name'      Name of figure window
%       'newplot'   True if new window to be created, false if use existing window if possible
%       'type'      'e'     errors =  error bars
%                   'h'     histogram =  histogram plot
%                   'l'     line   =  line
%                   'm'     markers = marker symbols
%                   'd'     data   =  markers, error bars, lines
%                   'p'     points =  markers and error bars

plot_types={'errors','histogram','line','markers','data','points'};
default_fig_name=get_global_var('genieplot','name_oned');
default_plot_type='data';

arglist = struct('name',default_fig_name,...
    'newplot',true,...
    'type',default_plot_type);

[par,keyword] = parse_arguments(varargin,arglist);

fig_=[]; axes_=[]; plot_=[];
ok=true; mess='';

% Check input arguments
% ---------------------
% Check spectrum is not too long an array
maxspec=get_global_var('genieplot','oned_maxspec');
if numel(w_in)>maxspec
    ok=false; mess=['This function can only be used to plot ',num2str(maxspec),' spectra - check input object'];
    if nargout<=3, error(mess), else return, end
end

% Get newplot argument
if islognumscalar(keyword.newplot)
    newplot=logical(keyword.newplot);   % in case numeric 0 or 1
else
    ok=false; mess='Keyword ''newplot'' must be logical true or false';
    if nargout<=3, error(mess), else return, end
end

% Get figure name or figure number: if not given, use default one-dimensional plot name
% Only one of fig_name or fig_handle will be created - used to branch later on
if isstring(keyword.name)
    if ~isempty(keyword.name)
        fig_name=keyword.name;
    else
        fig_name=default_fig_name;
    end
elseif isnumeric(keyword.name) && isscalar(keyword.name) && ~newplot
    tmp_fig_name = genie_figure_name(keyword.name);
    if ~isempty(tmp_fig_name)
        fig_handle=keyword.name;
    else    % figure doesnt exist
        disp('The numbered figure does not exist; following default overplotting action')
        fig_name=default_fig_name;
    end
else
    ok=false; 
    if newplot
        mess='Figure name must be a character string for a new plot';
    else
        mess='Figure name must be a character string or figure number for overplotting';
    end
    if nargout<=3, error(mess), else return, end
end

% Get plot type
if isstring(keyword.type)
    if ~isempty(keyword.type)
        ind=string_find(keyword.type,plot_types);
        if ind>0
            plot_type=plot_types{ind};
        else
            ok=false; mess='Plot type not recognised';
            if nargout<=3, error(mess), else return, end
        end
    else
        plot_type=default_plot_type;
    end
else
    ok=false; mess='Plot type must be a character string';
    if nargout<=3, error(mess), else return, end
end

% Check plot limits:
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
    ok=false; mess='Check numer of plot limits (must be none, xlo & xhi, or xlo,xhi,ylo & yhi)';
    if nargout<=3, error(mess), else return, end
end


% Perform plot
% ------------
% Create new graphics window if one is not currently active, and make the current graphics window
% Determine if newplot required (overrides any value given as keyword argument)
if exist('fig_name','var')
    new_figure = genie_figure_create (fig_name);
    if new_figure
        newplot=true;   % if had to create a new figure window, then create axes etc.
    end
else
    figure(fig_handle); % overplotting on existing plot; make the current figure
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
    % w = w_in; % *** UNTIL SORT OUT REBUNCH
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
    plot_markers (w)
    hold on
    plot_errors (w)
    plot_line (w)
elseif plot_type(1)=='p'
    plot_markers (w)
    hold on
    plot_errors (w)
end
hold off    % release plot (could have been held for overplotting, or by 'dd' for example

% Create/change title if a new plot
if (newplot)
    [tx,ty]=make_label(w(1));  % Create axis annotations
    tt=w(1).title(:);   % tt=[w(1).title(:);['Plot binning = ',num2str(binning)]];
    % change titles:
    title(tt);
    xlabel(tx);
    ylabel(ty);
%     % calculate space for titles:
%     nt = numel(tt);
%     nx = numel(tx);
%     ny = numel(ty);
%     % units per single height of line (quick fix assuming default aspect ratio and font size)
%     h = 0.03833;
%     % allow for up to 4 lines in tx and ty, and 5 lines in tt:
%     xplo=min(0.13+(ny-1)*h,0.245);  yplo=min(0.11+(nx-1)*h,0.225);  xphi=0.905;   yphi=max(0.925-(nt-1)*h,0.772);
%     pos = [xplo,yplo,xphi-xplo,yphi-yplo];
%     set(gca,'position',pos)
    % change ticks
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
end
if xlims, lx(xlo,xhi), end
if ylims, ly(ylo,yhi), end

% Get fig, axes and plot handles
[fig_, axes_, plot_] = genie_figure_all_handles;
