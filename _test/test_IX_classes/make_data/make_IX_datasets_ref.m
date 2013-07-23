function make_IX_datasets_ref
% Create some workspaces for testing IX objects
%
%   >> make_IX_datasets_ref
%
% The objects are different everytime this is run, as a random number generator is used.
% Objects created are:
%
%   p1 p2 p3            IX_dataset_1d point objects;
%                      All have same x axes, but different signals and errors
%   h1 h2 h3            IX_dataset_1d histogram objects;
%                      All have same x axes, but different signal and errors
%                      Signal and errors match corresponding p1, p2, p3
%
%   pp1 hp1 ph1 hh1     IX_datset_2d objects, variously point or histogram along x,y axes
%                      x-axes match those of the point or histogram 1D objects
%                      Signals and errors are all the same.
%
%   ppp1                IX_dataset_3d object
%
%   pp2_1 pp2_2 pp2_3   IX_datset_2d point objects with different x,y,signal,error arrays
%
%   hp_1d_big           Array of 500 IX_dataset_1d objects, all with different x, signal error
%                      arrays, mixed histogram and point datasets
%   pp_1d_big           The above converted to all point datasets using hist2point
%   hh_1d_big           The above converted to all histogram datasets using point2hist
%
% These will be saved in the file test_IX_datasets_ref.mat in the system specific
% temporary folder returned by matlab function tempdir (type >> help tempdir
% for information about the system specific location returned by tempdir)

output_file=fullfile(tempdir,'test_IX_datasets_ref.mat');

% Generate data
% ---------------
% axes values
x=20*sort(rand(1,20));
xb=20*sort(rand(1,21));
y=15*sort(rand(1,15));
yb=15*sort(rand(1,16));
z=10*sort(rand(1,10));
zb=10*sort(rand(1,11));

% Intensities and error bars
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

% Save objects
save(output_file,'p1','p2','p3','h1','h2','h3','pp1','hp1','ph1','hh1','ppp1','pp2_1','pp2_2','pp2_3','hp_1d_big','pp_1d_big','hh_1d_big')
