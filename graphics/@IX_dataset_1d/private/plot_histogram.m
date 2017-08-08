function plot_histogram (w)
% Plot histograms
% If point data, simply steps halfway between points

line_width=get_global_var('genieplot','line_width');
line_style=get_global_var('genieplot','line_style');
color=get_global_var('genieplot','color');

nw = numel(w);
icol = mod(0:nw-1,length(color))+1;
ilin = mod(0:nw-1,length(line_style))+1;
iwid = mod(0:nw-1,length(line_width))+1;
for i=1:nw
    if i==2; hold on; end   % hold on for array input
    x  = w(i).x;
    nx=length(x);
    ny=length(w(i).signal_);
    
    xb=zeros(1,2*ny);    % x array for plotting histogram
    yb=zeros(1,2*ny);    % y array for plotting histograms
    
    if (nx==ny)         % point data
        if nx>1
            del0=0.5*(x(2)-x(1));
            xb(1)=x(1)-del0;
            xb(2:2:2*ny-2)=0.5*(x(2:ny)+x(1:ny-1));
            xb(3:2:2*ny-1)=0.5*(x(2:ny)+x(1:ny-1));
            del1=0.5*(x(ny)-x(ny-1));
            xb(2*ny)=x(ny)+del1;
        else
            xb=x+[-0.5,0.5];   % give it a false bin width of unity
            yb=[w(i).signal_,w(i).signal_];
        end
    else
        xb(1)=x(1);
        xb(2:2:2*ny-2)=x(2:ny);
        xb(3:2:2*ny-1)=x(2:ny);
        xb(2*ny)=x(nx);
    end
    
    yb(1:2:end)=w(i).signal_;
    yb(2:2:end)=w(i).signal_;
    
    % plot data
    plot(xb,yb,'Color',color{icol(i)},...
        'LineStyle',line_style{ilin(i)},'LineWidth',line_width(iwid(i)));
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
