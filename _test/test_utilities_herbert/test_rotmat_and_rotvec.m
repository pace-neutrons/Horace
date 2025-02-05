function test_rotmat_and_rotvec (opt)
% Test of rotation matrix and vector code
%
%   >> test_rotmat_and_rotvec           % checks on algorithms
%   >> test_rotmat_and_rotvec ('speed') % perform speed test as well
%
% Author: T.G.Perring

banner_to_screen(mfilename)

d2r=pi/180;
tol=1e-12;

% Consistency tests
% -----------------
% test rotvec_to_rotmat
tha_d=[20,40,17];
thb_d=[35,10,47];
thc_d=rand(3,1000);

tha_r=tha_d*d2r;
thb_r=thb_d*d2r;
thc_r=thc_d*d2r;

ma_0=rotvec_to_rotmat(tha_d);
mb_0=rotvec_to_rotmat(thb_d);
mc_0=rotvec_to_rotmat(thc_d);

ma_1=rotvec_to_rotmat(tha_d,1);
mb_1=rotvec_to_rotmat(thb_d,1);
mc_1=rotvec_to_rotmat(thc_d,1);

ma2_0=rotvec_to_rotmat_rad(tha_r);
mb2_0=rotvec_to_rotmat_rad(thb_r);
mc2_0=rotvec_to_rotmat_rad(thc_r);

ma2_1=rotvec_to_rotmat_rad(tha_r,1);
mb2_1=rotvec_to_rotmat_rad(thb_r,1);
mc2_1=rotvec_to_rotmat_rad(thc_r,1);

if max(abs(ma_0(:)-ma_1(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(mb_0(:)-mb_1(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(mc_0(:)-mc_1(:)))>tol, assertTrue(false,'Bad code!'), end

if max(abs(ma2_0(:)-ma2_1(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(mb2_0(:)-mb2_1(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(mc2_0(:)-mc2_1(:)))>tol, assertTrue(false,'Bad code!'), end

if max(abs(ma_0(:)-ma2_0(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(mb_0(:)-mb2_0(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(mc_0(:)-mc2_0(:)))>tol, assertTrue(false,'Bad code!'), end


% Test rotmat_to_rotvec
ma=ma_0;
mb=mb_0;
mc=mc_0;

tha_0=rotmat_to_rotvec(ma)*d2r;
thb_0=rotmat_to_rotvec(mb)*d2r;
thc_0=rotmat_to_rotvec(mc)*d2r;

tha_1=rotmat_to_rotvec(ma,1)*d2r;
thb_1=rotmat_to_rotvec(mb,1)*d2r;
thc_1=rotmat_to_rotvec(mc,1)*d2r;

tha2_0=rotmat_to_rotvec_rad(ma);
thb2_0=rotmat_to_rotvec_rad(mb);
thc2_0=rotmat_to_rotvec_rad(mc);

tha2_1=rotmat_to_rotvec_rad(ma,1);
thb2_1=rotmat_to_rotvec_rad(mb,1);
thc2_1=rotmat_to_rotvec_rad(mc,1);

if max(abs(tha_0(:)-tha_r(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(thb_0(:)-thb_r(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(thc_0(:)-thc_r(:)))>tol, assertTrue(false,'Bad code!'), end

if max(abs(tha_1(:)-tha_r(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(thb_1(:)-thb_r(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(thc_1(:)-thc_r(:)))>tol, assertTrue(false,'Bad code!'), end

if max(abs(tha2_0(:)-tha_r(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(thb2_0(:)-thb_r(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(thc2_0(:)-thc_r(:)))>tol, assertTrue(false,'Bad code!'), end

if max(abs(tha2_1(:)-tha_r(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(thb2_1(:)-thb_r(:)))>tol, assertTrue(false,'Bad code!'), end
if max(abs(thc2_1(:)-thc_r(:)))>tol, assertTrue(false,'Bad code!'), end

% Speed tests
% -----------
if nargin==1 && ischar(opt) && isequal(lower(opt),'speed')
    disp('--------------------------------------------------------------------------------')
    disp(' Speed tests for the two algorithms')
    
    nrot=10000;
    
    fac=300;     % factor larger number for fast algorithm
    th0=2*rand(3,fac*nrot)-1;
    th1=2*rand(3,nrot)-1;
    
    % Test rotvec_to_rotmat
    tic
    mat0=rotvec_to_rotmat_rad(th0);
    t0=toc;
    tic
    mat1=rotvec_to_rotmat_rad(th1,1);
    t1=toc;

    disp(' ')
    disp('rotvec_to_rotmat:')
    disp(['  Fast algorithm: ',num2str(t0*1e6/fac/nrot),' mms/matrix    Slow algorithm: ',num2str(t1*1e6/nrot),' mms/matrix'])
    disp(['           Ratio: ',num2str(fac*t1/t0)])
    
    
    % Test rotmat_to_rotvec
    tic
    th0=rotmat_to_rotvec_rad(mat0);
    t0=toc;
    tic
    th1=rotmat_to_rotvec_rad(mat1,1);
    t1=toc;
    
    disp(' ')
    disp('rotmat_to_rotvec:')
    disp(['  Fast algorithm: ',num2str(t0*1e6/fac/nrot),' mms/vector    Slow algorithm: ',num2str(t1*1e6/nrot),' mms/vector'])
    disp(['           Ratio: ',num2str(fac*t1/t0)])
    
elseif nargin~=0
    disp('*** Unrecognised option')
end


% Success announcement
% --------------------
banner_to_screen([mfilename,': Test(s) passed'],'bot')
