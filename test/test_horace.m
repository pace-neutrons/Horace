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

data_folder = 'c:\temp\';
%% Create some full sqw files

% This was fone from original Horace, ~sept 2008
data_source = 'c:\data\Fe\sqw\Fe_ei787.sqw';

proj_110.u=[1,1,0];
proj_110.v=[-1,1,0];
proj_110.type='rrr';
proj_110.uoffset=[0,0,0,0];

cut_sqw (data_source, proj_110, [0.9,1.1], [1.0,1.2], [-0.05,0.05], [50,70],[data_folder 'w0a.sqw']);
cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [150,175],[data_folder 'w1a.sqw']);
cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [175,200],[data_folder 'w1b.sqw']);
cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [200,250],[data_folder 'w1c.sqw']);
cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [225,250],[data_folder 'w1d.sqw']);
cut_sqw (data_source, proj_110, [0.95,1.05], [0,0.05,1], [-0.05,0.05], [50,0,350],[data_folder 'w2a.sqw']);
cut_sqw (data_source, proj_110, [0.95,1.05], [0,0.05,1], [ 0.45,0.55], [50,0,350],[data_folder 'w2b.sqw']);
cut_sqw (data_source, proj_110, [0.9,0.05,1.1], [1.0,0.05,1.2], [-0.05,0.05,0.05], [50,0,70],[data_folder 'w4a.sqw']);


% Read in as sqw:
w0a_s=read_sqw([data_folder 'w0a.sqw']);
w1a_s=read_sqw([data_folder 'w1a.sqw']);
w1b_s=read_sqw([data_folder 'w1b.sqw']);
w1c_s=read_sqw([data_folder 'w1c.sqw']);
w1d_s=read_sqw([data_folder 'w1d.sqw']);
w2a_s=read_sqw([data_folder 'w2a.sqw']);
w2b_s=read_sqw([data_folder 'w2b.sqw']);
w4a_s=read_sqw([data_folder 'w4a.sqw']);

% Read in as dnd:
w0a_d=read_dnd([data_folder 'w0a.sqw']);
w1a_d=read_dnd([data_folder 'w1a.sqw']);
w1b_d=read_dnd([data_folder 'w1b.sqw']);
w1c_d=read_dnd([data_folder 'w1c.sqw']);
w1d_d=read_dnd([data_folder 'w1d.sqw']);
w2a_d=read_dnd([data_folder 'w2a.sqw']);
w2b_d=read_dnd([data_folder 'w2b.sqw']);
w4a_d=read_dnd([data_folder 'w4a.sqw']);

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
save(s0a,[data_folder 's0a.sqw'])
save(s1a,[data_folder 's1a.sqw'])
save(s1b,[data_folder 's1b.sqw'])
save(s1c,[data_folder 's1c.sqw'])
save(s1d,[data_folder 's1d.sqw'])
save(s2a,[data_folder 's2a.sqw'])
save(s2b,[data_folder 's2b.sqw'])
save(s4a,[data_folder 's4a.sqw'])

save(dd0a,[data_folder 'dd0a.d0d'])
save(dd1a,[data_folder 'dd1a.d1d'])
save(dd1b,[data_folder 'dd1b.d1d'])
save(dd1c,[data_folder 'dd1c.d1d'])
save(dd1d,[data_folder 'dd1d.d1d'])
save(dd2a,[data_folder 'dd2a.d2d'])
save(dd2b,[data_folder 'dd2b.d2d'])
save(dd4a,[data_folder 'dd4a.d4d'])

%% Test new Horace
% Read old files for comparison
s1a=read_horace([data_folder 's1a.sqw']);
s1b=read_horace([data_folder 's1b.sqw']);
s1c=read_horace([data_folder 's1c.sqw']);
s1d=read_horace([data_folder 's1d.sqw']);
s2a=read_horace([data_folder 's2a.sqw']);
s2b=read_horace([data_folder 's2b.sqw']);
s4a=read_horace([data_folder 's4a.sqw']);

dd0a=read_horace([data_folder 'dd0a.d0d']);
dd1a=read_horace([data_folder 'dd1a.d1d']);
dd1b=read_horace([data_folder 'dd1b.d1d']);
dd1c=read_horace([data_folder 'dd1c.d1d']);
dd1d=read_horace([data_folder 'dd1d.d1d']);
dd2a=read_horace([data_folder 'dd2a.d2d']);
dd2b=read_horace([data_folder 'dd2b.d2d']);
dd4a=read_horace([data_folder 'dd4a.d4d']);


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

save(w0a,[data_folder 'w0a.sqw'])
save(w1a,[data_folder 'w1a.sqw'])
save(w1b,[data_folder 'w1b.sqw'])
save(w1c,[data_folder 'w1c.sqw'])
save(w1d,[data_folder 'w1d.sqw'])
save(w2a,[data_folder 'w2a.sqw'])
save(w2b,[data_folder 'w2b.sqw'])
save(w4a,[data_folder 'w4a.sqw'])

%% Read data from file

w0a=read_horace([data_folder 'w0a.sqw']);
w1a=read_horace([data_folder 'w1a.sqw']);
w1b=read_horace([data_folder 'w1b.sqw']);
w1c=read_horace([data_folder 'w1c.sqw']);
w1d=read_horace([data_folder 'w1d.sqw']);
w2a=read_horace([data_folder 'w2a.sqw']);
w2b=read_horace([data_folder 'w2b.sqw']);
%w3a=read_horace[data_folder 'w3a.sqw']);
w4a=read_horace([data_folder 'w4a.sqw']);

p0a=read_dnd([data_folder 'w0a.sqw']);
p1a=read_dnd([data_folder 'w1a.sqw']);
p1b=read_dnd([data_folder 'w1b.sqw']);
p1c=read_dnd([data_folder 'w1c.sqw']);
p1d=read_dnd([data_folder 'w1d.sqw']);
p2a=read_dnd([data_folder 'w2a.sqw']);
p2b=read_dnd([data_folder 'w2b.sqw']);
p3a=read_dnd([data_folder 'w3a.sqw']);
p4a=read_dnd([data_folder 'w4a.sqw']);

%% Get some small data sets for tests
w2_tiny_a=section(w2a,[0.1999,0.40001],[100,130]);  % to avoid a rounding error problem
w2_tiny_b=section(w2a,[0.3999,0.60001],[100,130]);
d2_tiny_a=dnd(w2_tiny_a);
d2_tiny_b=dnd(w2_tiny_b);


%% Problems

% Currently have a fixup for display. See sqw/head
% --------------------------------------------------
xxx=head_dnd([data_folder 'dd2a.d2d']);   % *** currently have a fixup for display. See sqw/head


% Bins along x-axis are different. Why?
% --------------------------------------
% I think the problem is that rounding errors when reading w2a in from file (where stored as float32) result in boundaries not
% being quite what we think.
w2_tiny_a=section(w2a,[0.2,0.4],[100,130]);
w2_tiny_b=section(w2a,[0.4,0.6],[100,130]);


% colorsliders overlap titles, and move about
% -----------------------------------------------------
% dnd
proj_100.u=[1,0,0];
proj_100.v=[0,1,0];
proj_100.uoffset=[0,0,0,0];
w2ref=cut_sqw ('c:\data\Fe\sqw\Fe_ei787.sqw', proj_100, [0,0.1,2], [-1,0.05,2], [-0.1,0.1], [150,175]);

% sliders over the title:
da(w2ref)

% Now they get into the caption
lx 0.6 1.2
ly 0 1


% Cutting issues
% ------------------------------
% Default bins even when axes rotated: odd - but what else to do?
% Make simpler to look at how Q axes are handled:
proj_100.u=[1,0,0];
proj_100.v=[0,1,0];
proj_100.uoffset=[0,0,0,0];
w2ref=cut_sqw ('c:\data\Fe\sqw\Fe_ei787.sqw', proj_100, [0,0.1,2], [-1,0.05,2], [-0.1,0.1], [150,175]);
d2ref=dnd(w2ref);

% now use axes rotated w.r.t the above, but use 'default bins'
proj_110.u=[1,1,0];
proj_110.v=[-1,1,0];
proj_110.uoffset=[0,0,0,0];
w2=cut (w2ref, proj_110, [], [], [-0.1,0.1], [150,175]);
d2=dnd(w2);

% Remove range problem
% ------------------------------
% Make some test data
w1a=read_horace([data_folder 'w1a.sqw']);
w1b=read_horace([data_folder 'w1b.sqw']);
w1c=read_horace([data_folder 'w1c.sqw']);
w1d=read_horace([data_folder 'w1d.sqw']);
w2a=read_horace([data_folder 'w2a.sqw']);
w2b=read_horace([data_folder 'w2b.sqw']);

% Make three Gaussian peaks:
sqw1a=cut(w1a,[0.4,0.05,1]);
sqw1b=cut(w1b,[0.4,0.05,1]);
sqw1c=cut(w1c,[0.4,0.05,1]);

d1da=dnd(sqw1a);
d1db=dnd(sqw1b);
d1dc=dnd(sqw1c);

sqw_all=[sqw1a,sqw1b,sqw1c];

% Now the test
[wwref,ffref]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.05],@test_bkgd,[0.1,0],'list',2);

% There are error bars on the background for the object which is entirely removed.
[ww,ff]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.05],@test_bkgd,[0.1,0],'list',2,'remove',{[],[-1,3],[]});


%% Test libisis
x1a=IXTdataset_1d(w1a);
x1b=IXTdataset_1d(w1b);
x1c=IXTdataset_1d(w1c);
x1d=IXTdataset_1d(w1d);
x2a=IXTdataset_2d(w2a);
x2b=IXTdataset_2d(w2b);


%% Tests
% Read data
w1a=read_horace([data_folder 'w1a.sqw']);
w1b=read_horace([data_folder 'w1b.sqw']);
w1c=read_horace([data_folder 'w1c.sqw']);
w1d=read_horace([data_folder 'w1d.sqw']);
w2a=read_horace([data_folder 'w2a.sqw']);
w2b=read_horace([data_folder 'w2b.sqw']);


% % Tiny sqw object for explicit examination of pixels
% w0=cut_sqw (data_source, proj_110, [1,1.02], [0,0.02], [-0.02,0.02], [150,160]);    
% p0=dnd(w0);


% Make three Gaussian peaks:
sqw1a=cut(w1a,[0.4,0.05,1]);
sqw1b=cut(w1b,[0.4,0.05,1]);
sqw1c=cut(w1c,[0.4,0.05,1]);

d1da=dnd(sqw1a);
d1db=dnd(sqw1b);
d1dc=dnd(sqw1c);

sqw_all=[sqw1a,sqw1b,sqw1c];
d1d_all=dnd(sqw_all);


% To put various test functions on the path
% --------------------------------------------
addpath('T:\SVN_area\Horace_sqw\test');     



% Test dispersion
% -----------------
wd = dispersion(w2a,@bcc_hfm,40);




% Function evaluation:
% ---------------------
% 1D:
ww=func_eval(sqw1a,@test_gauss_bkgd,[0.15,0.7,0.05,0.1,0]);    % test function evaluation

ww=func_eval(sqw_all,@test_gauss_bkgd,[0.15,0.7,0.05,0.1,0]);

ww=sqw_eval(sqw_all,@test_sqw_model_1D_bkgd,[10,40,0.05,50,0.1,0]);



% Fit function:
[ww,ff]=fit_func(sqw1a,@test_gauss_bkgd,[0.15,0.7,0.05,0.1,0]);

[ww,ff]=fit_func(sqw1a,@test_gauss_bkgd,[0.15,0.7,0.05,0.1,0],'remove',[0.78,0.92],'sel'); % test the sel option with sqw object

[ww,ff]=fit_func(sqw_all,@test_gauss_bkgd,[0.15,0.7,0.05,0.1,0]);

[ww,ff]=fit_func(sqw_all,@test_gauss,[0.15,0.7,0.05],@test_bkgd,[0.1,0]);   % equivalent with background a separate function

[ww,ff]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.05],@test_bkgd,[0.1,0],'list',2);



% Fit sqw:
[ww,ff]=fit_sqw(sqw_all,@test_sqw_model_1D_bkgd,[10,40,0.05,50,0.1,0],[1,1,0,1,1,1]);   % fit each independently

% The following is not quite equivalent, because the background is calculated as func_eval, not sqw_eval
[ww,ff]=fit_sqw(sqw_all,@test_sqw_model,[10,40,0.05,50],[1,1,0,1],@test_bkgd,[0.1,0],'list',2);

% Now have global sqw model:
[ww2,ff2]=multifit_sqw(sqw_all,@test_sqw_model,[10,40,0.05,50],[1,1,0,1],@test_bkgd,[0.1,0],'list',2);




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
indir=[data_folder 'mnsi\'] ;     % source directory of spe files
par_file=[data_folder 'mnsi\mnsi_apr08.par'];  % detector parameter file
sqw_file=[data_folder 'mnsi\mnsi.sqw'];        % output sqw file

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

%% Test against mslice

spe_file='C:\data\Ni\data\EI_400-PSI_0-BASE.spe';
par_file='T:\experiments\nickel\data_analysis\map_4to1.par';
phx_file='T:\experiments\nickel\data_analysis\map_4to1.phx';

efix400=402.61;
emode=1;
alatt=[3.5128,3.5128,3.5128];   % low temperature value from literature
angdeg=[90,90,90];
u=[0.9775,1.022,0.015];         % determined from fitting
v=[0.0588,-0.0610,1.002];       % determined from fitting


% Read in data to Mslice, and make a slice and a cut
% ---------------------------------------------------
mslice_start
mslice_load_data (spe_file, phx_file, efix400, 1, 'S(Q,w)', '')
mslice_sample(alatt,angdeg,u,v,0)

% Tobyplot:
mslice_sample(alatt,angdeg,u,v,0)

mslice_calc_proj([0,0,1],[1,-1,0],[1,1,0],'L','K','H')
mslice_2d([0,0.025,1.5],[-0.1,0.1],[0.5,0.025,1.5],'file',[data_folder 'ni_slice.slc'])
mslice_1d([0,0.025,1.5],[-0.1,0.1],[0.95,1.05],'file',[data_folder 'ni_cut.cut'])


% Horace equivalent
% ------------------
sqw_file=[data_folder 'ni400.sqw'];          % output sqw file
omega=0;dpsi=0;gl=0;gs=0;
gen_sqw (spe_file, par_file, sqw_file, efix400, emode, alatt, angdeg, u, v, 0, omega, dpsi, gl, gs, [1,1,1,1]);

proj.u=[1,1,0];
proj.v=[0,0,1];
proj.lab={'H','L','K','E'};

w2=cut_sqw(sqw_file,proj,[0.5,0.025,1.5],[0,0.025,1.5],[-0.1,0.1],[-Inf,Inf]);
w1=cut_sqw(sqw_file,proj,[0.95,1.05],[0,0.025,1.5],[-0.1,0.1],[-Inf,Inf]);

% Another example from the same data
% -------------------------------------
% mslice:
mslice_calc_proj([0,0,0,1],[1,-1,0],[1,1,0],'E','K','H')
mslice_2d([50,0,130],[-0.1,0.1],[0.5,0.025,1.5])

w2b=cut_sqw(sqw_file,proj,[0.5,0.025,1.5],[-Inf,Inf],[-0.1,0.1],[50,0,130]);


% Mslice and Horace produced identical cuts
% Now use a finer grid - as cutting the spe file as a single file was too much in cut_data_from_array

sqw_file=[data_folder 'ni400_grid10.sqw'];          % output sqw file
omega=0;dpsi=0;gl=0;gs=0;
gen_sqw (spe_file, par_file, sqw_file, efix400, emode, alatt, angdeg, u, v, 0, omega, dpsi, gl, gs, [10,10,10,10]);

proj.u=[1,1,0];
proj.v=[0,0,1];
proj.lab={'H','L','K','E'};


