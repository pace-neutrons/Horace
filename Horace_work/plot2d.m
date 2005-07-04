function plot2d(din)
% Plot two-dimensional dataset
%
% Input:
% ------
% din         Data from which a reduced dimensional manifold is to be taken. Its fields are:
%   din.file  File from which (h,k,l,e) data was read
%   din.grid  Type of grid ('orthogonal-grid')
%   din.title Title contained in the file from which (h,k,l,e) data was read
%   din.a     Lattice parameters (Angstroms)
%   din.b           "
%   din.c           "
%   din.alpha Lattice angles (degrees)
%   din.beta        "
%   din.gamma       "
%   din.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   din.ulen  Length of vectors in Ang^-1 or meV [row vector]
%   din.label Labels of theprojection axes [1x4 cell array of charater strings]
%   din.p0    Offset of origin of projection [ph; pk; pl; pen]
%   din.pax   Index of plot axes in the matrix din.u  [row vector]
%               e.g. if data is 3D, din.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, din.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   din.p1    Column vector of bin boundaries along first plot axis
%   din.p2    Column vector of bin boundaries along second plot axis
%     :       (for as many plot axes as given by length of din.pax)
%   din.iax   Index of integration axes in the matrix din.u
%               e.g. if data is 2D, din.iax=[3,1] means summation has been performed along u3 and u1 axes
%   din.uint  Integration range along each of the integration axes. Dimensions are uint(2,length(iax))
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]
%   din.s     Cumulative signal.  [size(din.s)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.e     Cumulative variance [size(din.e)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   din.n     Number of contributing pixels [size(din.n)=(length(din.p1)-1, length(din.p2)-1, ...)]

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
