xin=3:0.5:15;

xb=[4,0.1,5]

xb=[4,-0.1,5,0,8,0.25,12]

nx=10000000;
xin=sort(nx*rand(1,nx)+0.1*(1:nx));
xb=[0,5,floor(nx/4),-0.01,floor(nx/2),0,floor(3*nx/4),10,nx];


rmpath('T:\SVN_area\Herbert\external_code\fortran'); addpath('T:\SVN_area\Herbert\external_code\matlab')
tic;xoutm=bin_boundaries_from_descriptor (xb, x_in);toc;

rmpath('T:\SVN_area\Herbert\external_code\matlab'); addpath('T:\SVN_area\Herbert\external_code\fortran')
tic;xoutf=bin_boundaries_from_descriptor (xb, xin);toc;

max(abs(xoutm-xoutf))

