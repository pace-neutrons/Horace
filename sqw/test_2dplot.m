function test_2dplot(signal)
% Creates the simplest 2D patch plot on earth. Why is it so difficult?

genie_figure_create ('Testplot_2D');
hold off;   % new plot
delete(gca)
axis([0.5 size(signal,2)+0.5 0.5 size(signal,1)+0.5]);
box;

% Create arrays for PATCH function
nx = size(signal,2);
ny = size(signal,1);
npatch = nx*ny;
p1 = [1:nx+1]-0.5;
p2 = [1:ny+1]-0.5;
x = [p1(1:end-1);p1(2:end);p1(2:end);p1(1:end-1)];
x = repmat(x,1,ny);
y = zeros(4,npatch);
nhi = 0;
for i=1:ny
    nlo = nhi + 1;
    nhi = nhi + nx;
    ypatch = [p2(i);p2(i);p2(i+1);p2(i+1)];
    y(:,nlo:nhi) = repmat(ypatch,1,nx);
end
signal=signal';
patch(x,y,signal(:)','facecolor','flat','cdatamapping','scaled','edgecolor','none');
colorbar;
drawnow;