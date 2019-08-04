% Set up lattice and reflection we want to study
alatt = [4,4,4];
angdeg = [90,90,90];

bragg1 = [1,1,0];
bragg2 = [0,0,1];

npnt = 1e6;

% Set up sample
xgeom = [1,1,0];
ygeom = [0,0,1];
shape = 'cuboid';
pshape = [0.02,0.03,0.04];

xmos = [1,1,0];
ymos = [0,0,1];
eta =[...
    1,0,0;...
    0,4,5;...
    0,5,9 ...
    ];
mos = IX_mosaic (xmos,ymos,eta);

sample = IX_sample(xgeom,ygeom,shape,pshape,mos);

R = sample.rand_mosaic([1,npnt],alatt,angdeg);

%
ub = ubmatrix (bragg1, bragg2, bmatrix (alatt, angdeg));

% Create a
hkl = mtimesx_horace(R,bragg1(:));    % the hkl for the mosaic distribution
xyz = mtimesx_horace(ub,hkl);           % now in orthonormal frame
xyz = squeeze(xyz);

modQ = norm(ub*bragg1(:));    % length of bragg1 in Ang^-1

xyz = ((180/pi)/modQ)*xyz;  % convert to degrees



[N,Xedges,Yedges] = histcounts2(xyz(2,:),xyz(3,:));
w = IX_dataset_2d(Xedges,Yedges,N);
da(w)
aspect(1,1)
