% Test sqw conversion of Horace
% -----------------------------


%% Initialise Horace

% This is how TGP turns off new Horace and sets up paths for new:
% Make sure you have start_app.m on your path
horace_off; start_app('horace','T:\SVN_area\Horace')

% ...and vice versa
horace_off; start_app('horace','T:\SVN_area\Horace_sqw')

% Make sure have libisis_start on your path to run the new Horace graphics:
libisis_root = 'C:\mprogs\libisis_2008_08_22_1110';
libisis_start(libisis_root)

%% Create some full sqw files

% This was fone from original Horace, ~sept 2008
data_source = 'c:\data\Fe\sqw\Fe_ei787.sqw';

proj_110.u=[1,1,0];
proj_110.v=[-1,1,0];
proj_110.type='rrr';
proj_110.uoffset=[0,0,0,0];

cut_sqw (data_source, proj_110, [0.9,1.1], [1.0,1.2], [-0.05,0.05], [50,70], 'c:\temp\w0a.sqw');
cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [150,175], 'c:\temp\w1a.sqw');
cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [175,200], 'c:\temp\w1b.sqw');
cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [200,250], 'c:\temp\w1c.sqw');
cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [225,250], 'c:\temp\w1d.sqw');
cut_sqw (data_source, proj_110, [0.95,1.05], [0,0.05,1], [-0.05,0.05], [50,0,350], 'c:\temp\w2a.sqw');
cut_sqw (data_source, proj_110, [0.95,1.05], [0,0.05,1], [ 0.45,0.55], [50,0,350], 'c:\temp\w2b.sqw');
cut_sqw (data_source, proj_110, [0.9,0.05,1.1], [1.0,0.05,1.2], [-0.05,0.05,0.05], [50,0,70], 'c:\temp\w4a.sqw');


% Read in as dnd:
w0a_p=read_sqw('c:\temp\w0a.sqw','-pix');
w1a_p=read_sqw('c:\temp\w1a.sqw','-pix');
w1b_p=read_sqw('c:\temp\w1b.sqw','-pix');
w1c_p=read_sqw('c:\temp\w1c.sqw','-pix');
w1d_p=read_sqw('c:\temp\w1d.sqw','-pix');
w2a_p=read_sqw('c:\temp\w2a.sqw','-pix');
w2b_p=read_sqw('c:\temp\w2b.sqw','-pix');
w4a_p=read_sqw('c:\temp\w4a.sqw','-pix');

% Apply fixup to make the sqw structures match the new format
% (Change setup to new Horace, and set working directory to ...\Horace_sqw\test)

% New structures
[w0a_s,w0a_d]=fudge_data(w0a_p);
[w1a_s,w1a_d]=fudge_data(w1a_p);
[w1b_s,w1b_d]=fudge_data(w1b_p);
[w1c_s,w1c_d]=fudge_data(w1c_p);
[w1d_s,w1d_d]=fudge_data(w1d_p);
[w2a_s,w2a_d]=fudge_data(w2a_p);
[w2b_s,w2b_d]=fudge_data(w2b_p);
[w4a_s,w4a_d]=fudge_data(w4a_p);

save('T:\SVN_area\test_horace.mat','w0a_s','w0a_d',...
    'w1a_s','w1a_d','w1b_s','w1b_d','w1c_s','w1c_d','w1d_s','w1d_d',...
    'w2a_s','w2a_d','w2b_s','w2b_d','w4a_s','w4a_d')


% Read in some new format sqw files to test conversion of Horace
load('T:\SVN_area\test_horace.mat')

% Make objects
s0a=sqw(w0a_s);
s1a=sqw(w1a_s);
s1b=sqw(w1b_s);
s1c=sqw(w1c_s);
s1d=sqw(w1d_s);
s2a=sqw(w2a_s);
s2b=sqw(w2b_s);
s4a=sqw(w4a_s);

dd0a=d0d(w0a_d);
dd1a=d1d(w1a_d);
dd1b=d1d(w1b_d);
dd1c=d1d(w1c_d);
dd1d=d1d(w1d_d);
dd2a=d2d(w2a_d);
dd2b=d2d(w2b_d);
dd4a=d4d(w4a_d);

% Save objects to file
save(s0a,'c:\temp\s0a.sqw')
save(s1a,'c:\temp\s1a.sqw')
save(s1b,'c:\temp\s1b.sqw')
save(s1c,'c:\temp\s1c.sqw')
save(s1d,'c:\temp\s1d.sqw')
save(s2a,'c:\temp\s2a.sqw')
save(s2b,'c:\temp\s2b.sqw')
save(s4a,'c:\temp\s4a.sqw')

save(dd0a,'c:\temp\dd0a.d0d')
save(dd1a,'c:\temp\dd1a.d1d')
save(dd1b,'c:\temp\dd1b.d1d')
save(dd1c,'c:\temp\dd1c.d1d')
save(dd1d,'c:\temp\dd1d.d1d')
save(dd2a,'c:\temp\dd2a.d2d')
save(dd2b,'c:\temp\dd2b.d2d')
save(dd4a,'c:\temp\dd4a.d4d')

%% Test new Horace
% Read old files for comparison
s1a=read_horace('c:\temp\s1a.sqw');
s1b=read_horace('c:\temp\s1b.sqw');
s1c=read_horace('c:\temp\s1c.sqw');
s1d=read_horace('c:\temp\s1d.sqw');
s2a=read_horace('c:\temp\s2a.sqw');
s2b=read_horace('c:\temp\s2b.sqw');
s4a=read_horace('c:\temp\s4a.sqw');

dd0a=read_horace('c:\temp\dd0a.d0d');
dd1a=read_horace('c:\temp\dd1a.d1d');
dd1b=read_horace('c:\temp\dd1b.d1d');
dd1c=read_horace('c:\temp\dd1c.d1d');
dd1d=read_horace('c:\temp\dd1d.d1d');
dd2a=read_horace('c:\temp\dd2a.d2d');
dd2b=read_horace('c:\temp\dd2b.d2d');
dd4a=read_horace('c:\temp\dd4a.d4d');


%% Make cuts with new Horace
data_source = 'c:\data\Fe\sqw\Fe_ei787.sqw';

proj_110.u=[1,1,0];
proj_110.v=[-1,1,0];
proj_110.type='rrr';
proj_110.uoffset=[0,0,0,0];

w0a=cut_sqw (data_source, proj_110, [0.9,1.1], [1.0,1.2], [-0.05,0.05], [50,70]);
w1a=cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [150,175]);
w1b=cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [175,200]);
w1c=cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [200,250]);
w1d=cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [225,250]);
w2a=cut_sqw (data_source, proj_110, [0.95,1.05], [0,0.05,1], [-0.05,0.05], [50,0,350]);
w2b=cut_sqw (data_source, proj_110, [0.95,1.05], [0,0.05,1], [ 0.45,0.55], [50,0,350]);
w3a=cut_sqw (data_source, proj_110, [-1.5,0.05,1.5], [-2,0.05,2], [-0.05,0.05], [0,0,350],'c:\temp\s2b.sqw');
w4a=cut_sqw (data_source, proj_110, [0.9,0.05,1.1], [1.0,0.05,1.2], [-0.05,0.05,0.05], [50,0,70]);

save(w0a,'c:\temp\w0a.sqw')
save(w1a,'c:\temp\w1a.sqw')
save(w1b,'c:\temp\w1b.sqw')
save(w1c,'c:\temp\w1c.sqw')
save(w1d,'c:\temp\w1d.sqw')
save(w2a,'c:\temp\w2a.sqw')
save(w2b,'c:\temp\w2b.sqw')
save(w4a,'c:\temp\w4a.sqw')

w1a=read_horace('c:\temp\w1a.sqw');
w1b=read_horace('c:\temp\w1b.sqw');
w1c=read_horace('c:\temp\w1c.sqw');
w1d=read_horace('c:\temp\w1d.sqw');
w2a=read_horace('c:\temp\w2a.sqw');
w2b=read_horace('c:\temp\w2b.sqw');
% w3a=read_horace('c:\temp\w3a.sqw');
w4a=read_horace('c:\temp\w4a.sqw');

p1a=read_dnd('c:\temp\w1a.sqw');
p1b=read_dnd('c:\temp\w1b.sqw');
p1c=read_dnd('c:\temp\w1c.sqw');
p1d=read_dnd('c:\temp\w1d.sqw');
p2a=read_dnd('c:\temp\w2a.sqw');
p2b=read_dnd('c:\temp\w2b.sqw');
p3a=read_dnd('c:\temp\w3a.sqw');
p4a=read_dnd('c:\temp\w4a.sqw');

%% Get some small data sets for tests
w2_tiny_a=section(w2a,[0.1999,0.40001],[100,130]);  % to avoid a rounding error problem
w2_tiny_b=section(w2a,[0.3999,0.60001],[100,130]);
d2_tiny_a=dnd(w2_tiny_a);
d2_tiny_b=dnd(w2_tiny_b);


%% Problems

% Currently have a fixup for display. See sqw/head
% --------------------------------------------------
xxx=head_dnd('c:\temp\dd2a.d2d');   % *** currently have a fixup for display. See sqw/head


% Titling issue: rounding errors in cut?
% ------------------------------------------
% Both the following give strange captions for the secondary cut, rounding erros and bin centre/boundary issue on energy caption
w1a=read_horace('c:\temp\w1a.sqw');
wtest=cut(w1a,[0.4,0.05,1]);
dl(w1a)
kf
dl(wtest)

w1a=cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [150,175]);
wtest=cut(w1a,[0.4,0.05,1]);
dl(w1a)
kf
dl(wtest)

% Bins along x-axis are different. Why?
% I think the problem is that rounding errors when reading w2a in from file (where stored as float32) result in boundaries not
% being quite what we think. 
w2_tiny_a=section(w2a,[0.2,0.4],[100,130]);
w2_tiny_b=section(w2a,[0.4,0.6],[100,130]);


%% Tests

addpath('T:\SVN_area\Horace_sqw\test');     % to put various test functions on the path

% Function evaluation
w0=cut_sqw (data_source, proj_110, [1,1.02], [0,0.02], [-0.02,0.02], [150,160]);    % tiny sqw object for explicit examination of pixels
p0=dnd(w0);

% Test function evaluation
% --------------------------
% Make three Gaussian peaks:
sqw1a=cut(w1a,[0.4,0.05,1]);
sqw1b=cut(w1b,[0.4,0.05,1]);
sqw1c=cut(w1c,[0.4,0.05,1]);

d1da=dnd(sqw1a);
d1db=dnd(sqw1b);
d1dc=dnd(sqw1c);

% Function evaluation:
% ---------------------
% 1D:
ww=func_eval(sqw1a,@test_gauss_bkgd,[0.15,0.7,0.05,0.1,0]);    % test function evaluation

sqw_all=[sqw1a,sqw1b,sqw1c];

ww=func_eval(sqw_all,@test_gauss_bkgd,[0.15,0.7,0.05,0.1,0]);

ww=sqw_eval(sqw_all,@test_sqw_model_1D_bkgd,[10,40,0.05,50,0.1,0]);



% Fit function:
[ww,ff]=fit(sqw1a,@test_gauss_bkgd,[0.15,0.7,0.05,0.1,0]);

[ww,ff]=fit(sqw_all,@test_gauss_bkgd,[0.15,0.7,0.05,0.1,0]);

[ww,ff]=fit(sqw1a,@test_gauss_bkgd,[0.15,0.7,0.05,0.1,0],'remove',[0.78,0.92],'sel'); % test the sel option with sqw object

% Fit sqw:
[ww,ff]=fit_sqw(sqw_all,@test_sqw_model_1D_bkgd,[10,40,0.05,50,0.1,0]);


% 2D:
% Shift w2b to separate the plots
w2test=w2b; w2test.data.p{1}=w2b.data.p{1}+1.2;
w_all=[w2a,w2test];
da(w_all)
ww=func_eval(w_all,@gauss2d,[50,1,150,0.04,0,1000]);
ww=func_eval(w_all,@gauss2d,[50,1,150,0.04,0,1000],'all'); % as sqw, option is ignored
ww=func_eval(dnd(w_all),@gauss2d,[50,1,150,0.04,0,1000],'all'); % as dnd, option is valid

ww=sqw_eval(w2a,@test_sqw_model,[5,30,10,10]);

% Function fitting
% ------------------
ww3=cut_sqw (data_source, proj_110, [0.5,0.05,0.7], [0,0.05,0.1], [-0.05,0.05], [100,0,120]);

%% Create big sqw file
indir='C:\temp\mnsi\';     % source directory of spe files
par_file='C:\temp\mnsi\mnsi_apr08.par';  % detector parameter file
sqw_file='C:\temp\mnsi\mnsi.sqw';        % output sqw file

efix=80;
emode=1;
alatt=[4.05,4.05,4.05];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;

nfiles=3;
psi=[0,0.5,1];
spe_file=cell(1,nfiles);
for i=1:length(psi)
    spe_file{i}=[indir,'mer00',num2str(848+i),'_fixed.spe'];
end

gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);

proj.u=[1,1,0];
proj.v=[-1,1,0];
proj.type='rrr';
proj.uoffset=[0,0,0,0];
w2test=cut_sqw(sqw_file,proj,[-1,0.1,2],[-5,0.1,1],[-1,1],[30,35]);
w1test=cut_sqw(sqw_file,proj,[-1,0.1,2],[-4.1,-3.9],[-1,1],[30,35]);

w2tiny=cut_sqw(sqw_file,proj,[0.6,0.1,0.9],[-3.8,0.1,-3.4],[-1,1],[30,35]);
w1tiny=cut_sqw(sqw_file,proj,[0.5,0.1,1],[-4.1,-3.9],[-1,1],[30,35]);
