function plot_errors (w)
% Plot error bars

line_width=get_global_var('genieplot','line_width');
color=get_global_var('genieplot','color');

nw = numel(w);
icol = mod(0:nw-1,length(color))+1;
iwid = mod(0:nw-1,length(line_width))+1;
for i=1:nw
    if i==2; hold on; end   % hold on for array input
    nx=length(w(i).x_);
    ny=length(w(i).signal_);
    if (nx == ny)           % point data
        temp=w(i).x_;
    else
        temp=0.5*(w(i).x_(2:nx) + w(i).x_(1:nx-1));
    end
    custom_errorbars(temp,w(i).signal_,w(i).error_,color{icol(i)},...
        'none',line_width(iwid(i)),'none',6);   % need non-zero markersize
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
