% Test that the new and old code to create a rotation matrix give same results
tha=[20,40,17]';
thb=[35,10,47]';
thc=[tha,thb];

aa=rotvec_to_rotmat(tha);
bb=rotvec_to_rotmat(thb);
cc=rotvec_to_rotmat(thc);

aa2=rotvec_to_rotmat2((pi/180)*tha);
bb2=rotvec_to_rotmat2((pi/180)*thb');   % new code will also take row vector
cc2=rotvec_to_rotmat2((pi/180)*thc);

if max(abs(aa(:)-aa2(:)))>1e-15, error('Bad code!'), end
if max(abs(bb(:)-bb2(:)))>1e-15, error('Bad code!'), end
if max(abs(bb(:)-bb2(:)))>1e-15, error('Bad code!'), end

% Test the inverse. WE have rotations that are small enough that the multivalued rotation vector does not cause a problem on comparison
tha_ret=(180/pi)*rotmat_to_rotvec2(aa2);
thb_ret=(180/pi)*rotmat_to_rotvec2(bb2);
thc_ret=(180/pi)*rotmat_to_rotvec2(cc2);
if max(tha_ret-tha)>1e-12, error('Bad code!'), end
if max(thb_ret-thb)>1e-12, error('Bad code!'), end
if max(thc_ret(:)-thc(:))>1e-12, error('Bad code!'), end

% Speed test; new code is about 85 times slower!
n=10000;
thetadeg=300*(rand(3,n)-0.5);
thetarad=thetadeg*(pi/180);

tic
rot=rotvec_to_rotmat(thetadeg);
toc

tic
rot2=rotvec_to_rotmat2(thetarad);
toc

if max(abs(rot(:)-rot2(:)))>1e-14, error('Bad code!'), end

