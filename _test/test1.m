% Create some workspaces

x=20*sort(rand(1,20));
xb=20*sort(rand(1,21));
y=15*sort(rand(1,15));
yb=15*sort(rand(1,16));

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

% Herbert objects
p1=IX_dataset_1d(x,y1,e1);
p2=IX_dataset_1d(x,y2,e2);
p3=IX_dataset_1d(x,y3,e3);

h1=IX_dataset_1d(xb,y1,e1);
h2=IX_dataset_1d(xb,y2,e2);
h3=IX_dataset_1d(xb,y3,e3);

pp1=IX_dataset_2d(x,y,ss1,ee1,'pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);
pp2=IX_dataset_2d(xb,y,ss1,ee1,'hist-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);
pp3=IX_dataset_2d(xb,yb,ss1,ee1,'hist-hist',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);

% mgenie objects
sp1=spectrum(x,y1,e1);
sp2=spectrum(x,y2,e2);
sp3=spectrum(x,y3,e3);

sh1=spectrum(xb,y1,e1);
sh2=spectrum(xb,y2,e2);
sh3=spectrum(xb,y3,e3);



