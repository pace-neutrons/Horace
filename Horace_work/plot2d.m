function plot2d(din)
% Plot two-dimensional dataset
%
% Input:
% ------
% din         Data from which a reduced dimensional manifold is to be taken. Its fields are:

if length(din.pax)~=2
    error ('ERROR: Must be two-dimensional dataset')
end

% Create new genie graphics window if one is not currently active
genie_figure_create
hold off;   % new plot
delete(gca)

% Create arrays for PATCH function
nx = length(din.p1)-1;
ny = length(din.p2)-1;
npatch = nx*ny;

x = [din.p1(1:end-1)';din.p1(2:end)';din.p1(2:end)';din.p1(1:end-1)'];
x = repmat(x,1,ny);

y = zeros(4,npatch);
nhi = 0;
for i=1:ny
    nlo = nhi + 1;
    nhi = nhi + nx;
    ypatch = [din.p2(i);din.p2(i);din.p2(i+1);din.p2(i+1)];
    y(:,nlo:nhi) = repmat(ypatch,1,nx);
end

ndouble = din.n;
ndouble(find(ndouble==0)) = nan;    % replace infinities with NaN
c = reshape(din.s,1,npatch)./reshape(ndouble,1,npatch);

% Create graphics output
axis([din.p1(1) din.p1(end) din.p2(1) din.p2(end)]);
box;

[title_main, title_pax, energy_axis] = cut_titles(din);
xlabel(title_pax{1});
ylabel(title_pax{2});
title(title_main);

if din.pax(1)~=energy_axis & din.pax(2)~=energy_axis    % both plot axes are Q axes
    x_ulen = din.ulen(din.pax(1));
    y_ulen = din.ulen(din.pax(2));
    set(gca,'DataAspectRatioMode','manual');
    a=get(gca,'DataAspectRatio');
    set(gca,'DataAspectRatio',[1/x_ulen 1/y_ulen (1/x_ulen+1/y_ulen)/(a(1)+a(2))*a(3)]);
end

patch(x,y,c,'facecolor','flat','cdatamapping','scaled','edgecolor','none');

colorbar;
drawnow;
