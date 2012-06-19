%% test_rotmat_average

% Test the function insode refine_crystal_orientation

% Create bunch of vectors in orthonormal frame
nv=10;
delta=0.02;

v0=rand(3,nv);
rotvec=(pi/180)*[10,20,-17]';
rotmat=rotvec_to_rotmat2(rotvec);

v=rotmat*v0;
v=v+delta*(rand(3,nv)-0.5);

[rotmat_ave,rotvec_ave] = rotmat_average (v0,v)
