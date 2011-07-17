% Create some workspaces

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
p3h=IX_dataset_1d(x,y3(1:end-1),e3(1:end-1),'Histogram data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);

h1=IX_dataset_1d(xb,y1,e1,'Histogram data, distribution',IX_axis('Energy transfer','meV','$w'),'Counts',true);
h2=IX_dataset_1d(xb,y2,e2,'Histogram data, distribution',IX_axis('Energy transfer','meV','$w'),'Counts',true);
h3=IX_dataset_1d(xb,y3,e3,'Histogram data, distribution',IX_axis('Energy transfer','meV','$w'),'Counts',true);

pp1=IX_dataset_2d(x,y,ss1,ee1,'pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);
hp1=IX_dataset_2d(xb,y,ss1,ee1,'hist-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);
hh1=IX_dataset_2d(xb,yb,ss1,ee1,'hist-hist',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);

ppp1=IX_dataset_3d(x,y,z,sss1,eee1,'pnt-pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','temperature','Counts',...
    true,false,false);

%% Another set of Herbert objects
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

pp1_1=IX_dataset_2d(x_1,y_1,ss1_1,ee1_1,'pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);

pp1_2=IX_dataset_2d(x_2,y_2,ss1_2,ee1_2,'pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);

pp1_3=IX_dataset_2d(x_3,y_3,ss1_3,ee1_3,'pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);



%% Massive arrays of objects

% A big point array
% ------------------------------
tic
nw=50000;
nx0=500;
nx=nx0+round(0.2*nx0*rand(nw,1));
p1big=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=nx(i)*(sort(rand(1,nx(i)))-0.2*rand(1));
    y=3*(i+rand(1,nx(i)));
    e=0.5+rand(1,nx(i));
    p1big(i)=IX_dataset_1d(x,y,e,'Point data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);
end
toc

% % Rebin test, nw=500, nx0=50000
% tic; w=rebin(p1big,[10000,5,40000]); toc
% Elapsed time is 2.540335 seconds.

% A big histogram array
% ------------------------------
tic
nw=500;
nx0=500;
nx=nx0+round(0.2*nx0*rand(nw,1));
h1big=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=nx(i)*(sort(rand(1,nx(i)))-0.2*rand(1));
    y=3*(i+rand(1,nx(i)-1));
    e=0.5+rand(1,nx(i)-1);
    h1big(i)=IX_dataset_1d(x,y,e,'Point data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);
end
toc


% A big mixed point and histogram array
% --------------------------------------
tic
nw=500;
nx0=500;
nx=nx0+round(0.2*nx0*rand(nw,1));
hp1big=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=nx(i)*sort(rand(1,nx(i)));
    y=10*exp(-0.5*(((x-nx0/2)/(nx0/4)).^2 + ((i-nw/2)/(nw/4)).^2));
%    y=3*(i+rand(1,nx(i)));
    e=0.5+rand(1,nx(i));
    dn=round(rand(1));
    hp1big(i)=IX_dataset_1d(x,y(1:end-dn),e(1:end-dn),'Point data, distribution',IX_axis('Energy transfer','meV','$w'),'Counts',true);
end
toc


%% mgenie objects
sp1=spectrum(x,y1,e1);
sp2=spectrum(x,y2,e2);
sp3=spectrum(x,y3,e3);

sh1=spectrum(xb,y1,e1);
sh2=spectrum(xb,y2,e2);
sh3=spectrum(xb,y3,e3);

