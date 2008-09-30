%=============================================
% Test sort_pixels
%=============================================

u=rand(4,10000000);
urange=[0,0.2,0.2,0;0.8,0.8,0.8,0.8];
grid_size_in=2;

bigtic
[ix,npix,p,grid_size,ibin]=sort_pixels(u,urange,grid_size_in);
bigtoc('sort_pixels')


