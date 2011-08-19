%% =====================================================================================================================
%  Create some workspaces
% ======================================================================================================================

x=20*sort(rand(1,20));
xb=20*sort(rand(1,21));
y=15*sort(rand(1,15));
yb=15*sort(rand(1,16));
z=10*sort(rand(1,10));
zb=10*sort(rand(1,11));

y1=5*(0.5+rand(1,20));
e1=0.5+rand(1,20);
y2=5*(0.5+rand(1,20));
e2=0.5+rand(1,20);
y3=5*(0.5+rand(1,20));
e3=0.5+rand(1,20);

ss1=5*(0.5+rand(20,15));
ee1=0.5+rand(20,15);
ss2=5*(0.5+rand(20,15));
ee2=0.5+rand(20,15);
ss3=5*(0.5+rand(20,15));
ee3=0.5+rand(20,15);
sss1=5*(0.5+rand(20,15,10));
eee1=0.5+rand(20,15,10);

% Herbert objects
p1=IX_dataset_1d(x,y1,e1,'Point data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);
p2=IX_dataset_1d(x,y2,e2,'Point data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);
p3=IX_dataset_1d(x,y3,e3,'Point data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);

h1=IX_dataset_1d(xb,y1,e1,'Histogram data, distribution',IX_axis('Energy transfer','meV','$w'),'Counts',true);
h2=IX_dataset_1d(xb,y2,e2,'Histogram data, distribution',IX_axis('Energy transfer','meV','$w'),'Counts',true);
h3=IX_dataset_1d(xb,y3,e3,'Histogram data, distribution',IX_axis('Energy transfer','meV','$w'),'Counts',true);

pp1=IX_dataset_2d(x,y,ss1,ee1,'pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',false,false);
hp1=IX_dataset_2d(xb,y,ss1,ee1,'hist-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);
ph1=IX_dataset_2d(x,yb,ss1,ee1,'pnt-hist',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',false,true);
hh1=IX_dataset_2d(xb,yb,ss1,ee1,'hist-hist',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,true);

ppp1=IX_dataset_3d(x,y,z,sss1,eee1,'pnt-pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','temperature','Counts',...
    true,false,false);


% --------------------------------------
% Another set of Herbert objects
% --------------------------------------
nx1=16;   ny1=12;
x_1=nx1*sort(rand(1,nx1));
y_1=ny1*sort(rand(1,ny1));

nx2=20;   ny2=9;
x_2=nx2*sort(rand(1,nx2));
y_2=ny2*sort(rand(1,ny2))+ny1+2;

nx3=12;   ny3=16;
x_3=nx3*sort(rand(1,nx3));
y_3=ny3*sort(rand(1,ny3))+ny1+ny2+5;

ss1_1=5*(0.5+rand(nx1,ny1));
ee1_1=0.5+rand(nx1,ny1);

ss1_2=5*(0.5+rand(nx2,ny2));
ee1_2=0.5+rand(nx2,ny2);

ss1_3=5*(0.5+rand(nx3,ny3));
ee1_3=0.5+rand(nx3,ny3);

pp2_1=IX_dataset_2d(x_1,y_1,ss1_1,ee1_1,'pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',false,false);

pp2_2=IX_dataset_2d(x_2,y_2,ss1_2,ee1_2,'pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',false,false);

pp2_3=IX_dataset_2d(x_3,y_3,ss1_3,ee1_3,'pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',false,false);


% --------------------------------------
% A big mixed point and histogram array
% --------------------------------------
tic
nw=100;
nx0=500;
nx=nx0+round(0.2*nx0*rand(nw,1));
hp_1d_big=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=nx(i)*sort(rand(1,nx(i)));
    y=10*exp(-0.5*(((x-nx0/2)/(nx0/4)).^2 + ((i-nw/2)/(nw/4)).^2));
    e=0.5+rand(1,nx(i));
    dn=round(rand(1));
    hp_1d_big(i)=IX_dataset_1d(x,y(1:end-dn),e(1:end-dn),'Point data, distribution',IX_axis('Energy transfer','meV','$w'),'Counts',true);
end
toc

pp_1d_big=hist2point(hp_1d_big);
hh_1d_big=point2hist(hp_1d_big);

%% Save objects
opfile='T:\SVN_area\Herbert\_test\test_data.mat';
save(opfile,'p1','p2','p3','h1','h2','h3','pp1','hp1','ph1','hh1','ppp1','pp2_1','pp2_2','pp2_3','hp_1d_big','pp_1d_big','hh_1d_big')
clear p1 p2 p3 h1 h2 h3 pp1 hp1 ph1 hh1 ppp1 pp2_1 pp2_2 pp2_3 hp_1d_big pp_1d_big hh_1d_big

%% Load the objects
opfile='T:\SVN_area\Herbert\_test\test_data_1.mat';
load(opfile)






%% =====================================================================================================================
%  Massive arrays of objects
% ======================================================================================================================

% A big point array
% ------------------------------
tic
nw=500;
nx0=500;
xrange=10;
nx=nx0+round(0.2*nx0*rand(nw,1));
p_1d_huge=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=xrange*((1+0.1*rand(1,1))*sort(rand(1,nx(i)))-0.05*rand(1,1));
    y=10*exp(-0.5*(((x-xrange/2)/(xrange/4)).^2 + ((i-nw/2)/(nw/4)).^2));
    e=0.5+rand(1,nx(i));
    p_1d_huge(i)=IX_dataset_1d(x,y,e,'Point data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);
end
toc

% A big histogram array
% ------------------------------
tic
nw=500;
nx0=500;
xrange=10;
nx=nx0+round(0.2*nx0*rand(nw,1));
h_1d_huge=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=xrange*((1+0.1*rand(1,1))*sort(rand(1,nx(i)))-0.05*rand(1,1));
    y=10*exp(-0.5*(((x-xrange/2)/(xrange/4)).^2 + ((i-nw/2)/(nw/4)).^2));
    e=0.5+rand(1,nx(i));
    h_1d_huge(i)=IX_dataset_1d(x,y,e,'Point data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);
end
toc

% A big mixed histogram and point array
% -------------------------------------
tic
nw=500;
nx0=500;
xrange=10;
nx=nx0+round(0.2*nx0*rand(nw,1));
hp_1d_huge=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=xrange*((1+0.1*rand(1,1))*sort(rand(1,nx(i)))-0.05*rand(1,1));
    y=10*exp(-0.5*(((x-xrange/2)/(xrange/4)).^2 + ((i-nw/2)/(nw/4)).^2));
    e=0.5+rand(1,nx(i));
    dn=round(rand(1));
    hp_1d_huge(i)=IX_dataset_1d(x,y(1:end-dn),e(1:end-dn),'Point data, distribution',IX_axis('Energy transfer','meV','$w'),'Counts',true);
end
toc


% Big array in 2D
% ---------------

nx0=5000;
ny0=3000;

xrange=10;
yrange=6;

x=xrange*sort(rand(1,nx0));
y=yrange*sort(rand(1,ny0));
[xx,yy]=ndgrid(x,y);
signal=10*exp(-0.5*(((xx-xrange/2)/(xrange/4)).^2 + ((yy-yrange/2)/(yrange/4)).^2));
err=0.5+rand(nx0,ny0);
    
hp_huge=IX_dataset_2d(x,y,signal(1:end-1,:),err(1:end-1,:),'hist-pnt',IX_axis('Energy transfer','meV','$w'),'Temperature','Counts',false,false);

clear signal err

% -----------------------------------------------
% Some timing tests with huge 1D arrays
% -----------------------------------------------
% With nx0=500; nw=500:
%    if point 'ave', then matlab and Fortran are comparable;
%    if point 'int', then matlab can be grossly more time-consuming
%                   for rebind(p_1d_huge, [1,0.002,6],'int') is 30 times slower.
%                   (this is when the number of bins is comparable in the input and output dataset)
del=[0.1,0.01,0.002];
for i=1:numel(del)
    disp(['Del=',num2str(del(i))])
    use_mex(true)
    disp('- fortran:')
    tic; wpa_ref=rebind(p_1d_huge, [1,del(i),6],'ave'); toc
    tic; wpi_ref=rebind(p_1d_huge, [1,del(i),6],'int'); toc
    tic; wh_ref =rebind(h_1d_huge, [1,del(i),6]); toc
    tic; whp_ref=rebind(hp_1d_huge,[1,del(i),6]); toc
    use_mex(false)
    disp('- matlab:')
    tic; wpa_mat=rebind(p_1d_huge, [1,del(i),6],'ave'); toc
    tic; wpi_mat=rebind(p_1d_huge, [1,del(i),6],'int'); toc
    tic; wh_mat =rebind(h_1d_huge, [1,del(i),6]); toc
    tic; whp_mat=rebind(hp_1d_huge,[1,del(i),6]); toc
end



% -----------------------------------------------
% Some timing tests with huge 2D arrays
% -----------------------------------------------
% With nx0=5000; ny0=3000: conclude Matlab is about 40% faster!
del=[0.1,0.01,0.002];
for i=1:numel(del)
    use_mex(true)
    tic; wref=rebind(hp_huge,[1,del(i),6],[2,del(i),4],'int'); toc
    use_mex(false)
    tic; wmat=rebind(hp_huge,[1,del(i),6],[2,del(i),4],'int'); toc
    delta_IX_dataset_nd(wref,wmat,-1e-14)
end
% Elapsed time is 0.952300 seconds.
% Elapsed time is 0.456290 seconds.
% Elapsed time is 1.288882 seconds.
% Elapsed time is 0.797968 seconds.
% Elapsed time is 3.029477 seconds.
% Elapsed time is 1.960267 seconds.
for i=1:numel(del)
    use_mex(true)
    tic; wref=rebind(hp_huge,[1,del(i),6],[2,del(i),4],'ave'); toc
    use_mex(false)
    tic; wmat=rebind(hp_huge,[1,del(i),6],[2,del(i),4],'ave'); toc
    delta_IX_dataset_nd(wref,wmat,-1e-14)
end
% Elapsed time is 0.928720 seconds.
% Elapsed time is 0.481735 seconds.
% Elapsed time is 1.305833 seconds.
% Elapsed time is 0.790645 seconds.
% Elapsed time is 2.855406 seconds.
% Elapsed time is 1.887153 seconds.



