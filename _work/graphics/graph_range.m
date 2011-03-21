function [xlo,xhi,ylo,yhi,ymin,ymax,zlo,zhi]=graph_range
% get the limits on x anad y for the present graphics window
% assume lines only
h=get(gca,'children');
a=cellstr(get(h,'type'));
xlim=get(gca,'xlim');
ylim=get(gca,'ylim');
xlo = inf;
ylo = inf;
zlo = inf;
xhi = -inf;
yhi = -inf;
zhi = -inf;
ymin = inf;
ymax = -inf;
for i=1:length(a)
    if strcmp(a{i},'line')|strcmp(a{i},'patch')|strcmp(a{i},'surface')
        xdata = get(h(i),'xdata');
        ydata = get(h(i),'ydata');
        if strcmp(a{i},'patch')|strcmp(a{i},'surface')
            cdata = get(h(i),'cdata');
        end
% limits of the data:
        xlo = min(min(reshape(xdata,1,prod(size(xdata)))),xlo);
        xhi = max(max(reshape(xdata,1,prod(size(xdata)))),xhi);
        ylo = min(min(reshape(ydata,1,prod(size(ydata)))),ylo);
        yhi = max(max(reshape(ydata,1,prod(size(ydata)))),yhi);
        if strcmp(a{i},'patch')|strcmp(a{i},'surface')
            zlo = min(min(reshape(cdata,1,prod(size(cdata)))),zlo);
            zhi = max(max(reshape(cdata,1,prod(size(cdata)))),zhi);
        end
% y limits in present x range
        lis_x = find(xdata>=xlim(1) & xdata<=xlim(2));
        lis_y = find(ydata>=ylim(1) & ydata<=ylim(2));
        ymin = min(min(ydata(lis_x)),ymin);
        ymax = max(max(ydata(lis_x)),ymax); 
% z limits:
% would like to find min and max of cdata in the current x,y range, but
% the interpretation of cdata is fairly sophisticated depending on the
% call to patch, surface and other plotting routines. We ignore the
% problem for the time-being
    end
end