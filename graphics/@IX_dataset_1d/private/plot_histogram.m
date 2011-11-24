function plot_histogram (w)
% Plot histograms
% If point data, simply steps halfway between points

%line_width=get_global_var('genieplot','line_width');
%line_style=get_global_var('genieplot','line_style');
%color=get_global_var('genieplot','color');
[line_width,line_style,color]=get(graph_config,'line_width','line_style','color');
%
nw = numel(w);
icol = mod(0:nw-1,length(color))+1;
ilin = mod(0:nw-1,length(line_style))+1;
iwid = mod(0:nw-1,length(line_width))+1;
for i=1:nw
    if i==2; hold on; end   % hold on for array input
    nx=length(w(i).x);
    ny=length(w(i).signal);

    xb=zeros(1,2*ny);    % x array for plotting histogram
    yb=zeros(1,2*ny);    % y array for plotting histograms

    if (nx==ny)         % point data
        if nx>1
            del0=0.5*(w(i).x(2)-w(i).x(1));
            xb(1)=w(i).x(1)-del0;
            xb(2:2:2*ny-2)=0.5*(w(i).x(2:ny)+w(i).x(1:ny-1));
            xb(3:2:2*ny-1)=0.5*(w(i).x(2:ny)+w(i).x(1:ny-1));
            del1=0.5*(w(i).x(ny)-w(i).x(ny-1));
            xb(2*ny)=w(i).x(ny)+del1;
        else
            xb=w(i).x+[-0.5,0.5];   % give it a false bin width of unity
            yb=[w(i).signal,w(i).signal];
        end
    else
        xb(1)=w(i).x(1);
        xb(2:2:2*ny-2)=w(i).x(2:ny);
        xb(3:2:2*ny-1)=w(i).x(2:ny);
        xb(2*ny)=w(i).x(nx);
    end
    
    yb(1:2:end)=w(i).signal;
    yb(2:2:end)=w(i).signal;
    
    % plot data
    plot(xb,yb,'Color',color{icol(i)},...
        'LineStyle',line_style{ilin(i)},'LineWidth',line_width(iwid(i)));
end

% Make linear or log axes as required
%xscale=get_global_var('genieplot','xscale');
%yscale=get_global_var('genieplot','yscale');
%
[xscale,yscale]=get(graph_config,'xscale','yscale');
%
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
