function plot_errors (w)
% Plot error bars

line_width=get_global_var('genieplot','line_width');
color=get_global_var('genieplot','color');

nw = numel(w);
icol = mod(0:nw-1,length(color))+1;
iwid = mod(0:nw-1,length(line_width))+1;
for i=1:nw
    if i==2; hold on; end   % hold on for array input
    nx=length(w(i).x);
    ny=length(w(i).signal);
    xb=zeros(1,3*ny);       % x array for plotting error bars
    if (nx == ny)           % point data
        xb(1:3:end)=w(i).x;
        xb(2:3:end)=w(i).x;
        xb(3:3:end)=NaN;
    else
        temp=0.5*(w(i).x(2:nx) + w(i).x(1:nx-1));
        xb(1:3:end)=temp;
        xb(2:3:end)=temp;
        xb(3:3:end)=NaN;
    end
    yb=zeros(1,3*ny);       % y array for plotting error bars
    yb(1:3:end)=w(i).signal-w(i).error;
    yb(2:3:end)=w(i).signal+w(i).error;
    yb(3:3:end)=NaN;

    % plots data
    plot(xb,yb,'Color',color{icol(i)},'LineWidth',line_width(iwid(i)));
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
