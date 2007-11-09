function slice=load_slice(filename)

% function cut=load_slice(filename)
% function to read a .slc file, but ignores pixel information
% return structure with fields (n=number of data points)
%         header_info: [1 x 6 double]  nx, ny, xorig, yorig, dx, dy
%         x: [1 x nx double]
%         y: [1 x ny double]
%         c: [1 x nx.ny double]
%         e: [1 x nx.ny double]
%
% Format of slice file:
%   first line:
%     <nx = no. x bins>  <ny = no. y bins>  <x coord of centre of bin(1,1)>  <y coord of same>  <x bin width>  <y bin width>
%
%   then for each bin in the order (1,1)...(nx,1), (1,2)...(nx,2),  ... , (1,ny)...(nx,ny):
%      x(av)   y(av)   I(av)   err(I(av))   npix
%      det_no(1)      eps_centre(1)     d_eps(1)     x(1)     y(1)     I(1)     err(1)
%         .                 .              .           .        .        .        .
%      det_no(npix)   eps_centre(npix)  d_eps(npix)  x(npix)  y(npix)  I(npix)  err(npix)

% open <filename> for reading
fid=fopen(filename,'rt');
if fid==-1,
   disp([ 'Error opening file ' filename ]);
   slice=[];
   return
end

% read x,y,e and complete pixel information
tline = fgets(fid);
slice.header_info = sscanf(tline,'%d %d %g %g %g %g',6);	% number of data points in the slice
drawnow;
nx = slice.header_info(1);
ny = slice.header_info(2);
xorig = slice.header_info(3);
yorig = slice.header_info(4);
dx = slice.header_info(5);
dy = slice.header_info(6);
slice.x=xorig+dx.*(linspace(0,nx,nx+1)-0.5);
slice.y=yorig+dy.*(linspace(0,ny,ny+1)-0.5);
nbin = nx*ny;

slice.c=zeros(1,nbin);	% intensities
slice.e=zeros(1,nbin);	% errors
for i=1:nbin
   tline = fgets(fid);
   temp=sscanf(tline,'%g',5);
   if (temp(3) > -1.0e30)
       slice.c(i)=temp(3);
       slice.e(i)=temp(4);
   else
       slice.c(i)=NaN;
       slice.e(i)=0;
   end
   npix=temp(5);
   if (npix ~=0)
       for j=1:npix
           tline = fgets(fid);
       end
   end
end

% read 
slice.f = read_labels (fid);

fclose(fid);
disp(['Loading .slice ( ' num2str(nbin) ' data points) from file : ']);
disp(filename);
