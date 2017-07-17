function plot_line (w)
% Plot lines

line_width=get_global_var('genieplot','line_width');
line_style=get_global_var('genieplot','line_style');
color=get_global_var('genieplot','color');

nw = numel(w);
icol = mod(0:nw-1,length(color))+1;
ilin = mod(0:nw-1,length(line_style))+1;
iwid = mod(0:nw-1,length(line_width))+1;
for i=1:nw
    if i==2; hold on; end   % hold on for array input
    nx=length(w(i).x_);
    ny=length(w(i).signal_);
    if (nx == ny)   % point data
        temp=w(i).x_;
    else
        temp=0.5*(w(i).x_(2:nx) + w(i).x_(1:nx-1));
    end
    plot(temp,w(i).signal_,'Color',color{icol(i)},'LineStyle',...
        line_style{ilin(i)},'LineWidth',line_width(iwid(i)));
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
