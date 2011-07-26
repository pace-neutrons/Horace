% test_integrate_2d

%% Create some workspaces

x=20*sort(rand(1,20));
xb=20*sort(rand(1,21));
y=15*sort(rand(1,15));
yb=15*sort(rand(1,16));

ss1=5*(0.5+rand(20,15));
ee1=0.5+rand(20,15);

% Herbert objects
pp1=IX_dataset_2d(x,y,ss1,ee1,'pnt-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);
hp1=IX_dataset_2d(xb,y,ss1,ee1,'hist-pnt',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);
hh1=IX_dataset_2d(xb,yb,ss1,ee1,'hist-hist',IX_axis('Energy transfer','meV','$w'),'spectrum','Counts',true,false);


%% test integration

pp1_1d=IX_dataset_1d(pp1);

pp1t=transpose(pp1);
pp1t_1d=IX_dataset_1d(pp1t);

xlo=3;
xhi=5;
wi=integrate(pp1_1d,xlo,xhi);   % integration via 1D case






