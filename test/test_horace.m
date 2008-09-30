% Test sqw conversion of Horace
% -----------------------------


%% Initialise Horace

% This is how TGP turns off old Horace and sets up paths for new:
% Make sure you have start_app.m on your path
horace_off; start_app('horace','T:\SVN_area\Horace')

% ...and vice versa
horace_off; start_app('horace','T:\SVN_area\Horace_sqw')

% Make sure have libisis_start on your path to run the new Horace graphics:
libisis_root = 'C:\mprogs\libisis_2008_08_22_1110';
libisis_start(libisis_root)

%% Create some full sqw files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create using existing Horace                                            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% data_source = 'c:\tgp_data\fe.sqw';
data_source = 'E:\fe\fe787\fe.sqw';

proj_110.u=[1,1,0];
proj_110.v=[-1,1,0];
proj_110.type='rrr';
proj_110.uoffset=[0,0,0,0]';

cut_sqw (data_source, proj_110, [0.9,1.1], [1.0,1.2], [-0.05,0.05], [50,70], 'c:\temp\w0a.sqw');

cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [150,175], 'c:\temp\w1a.sqw');
cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [175,200], 'c:\temp\w1b.sqw');
cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [200,250], 'c:\temp\w1c.sqw');
cut_sqw (data_source, proj_110, [0.9,1.1], [-2,0.05,2], [-0.1,0.1], [225,250], 'c:\temp\w1d.sqw');

cut_sqw (data_source, proj_110, [0.95,1.05], [0,0.05,1], [-0.05,0.05], [50,0,350], 'c:\temp\w2a.sqw');
cut_sqw (data_source, proj_110, [0.95,1.05], [0,0.05,1], [ 0.45,0.55], [50,0,350], 'c:\temp\w2b.sqw');

cut_sqw (data_source, proj_110, [0.9,0.05,1.1], [1.0,0.05,1.2], [-0.05,0.05,0.05], [50,0,70], 'c:\temp\w4a.sqw');


%% Read in as dnd:
% Read using existing Horace as sqw structures:
w0a_p=read_sqw('c:\temp\w0a.sqw','-pix');

w1a_p=read_sqw('c:\temp\w1a.sqw','-pix');
w1b_p=read_sqw('c:\temp\w1b.sqw','-pix');
w1c_p=read_sqw('c:\temp\w1c.sqw','-pix');
w1d_p=read_sqw('c:\temp\w1d.sqw','-pix');

w2a_p=read_sqw('c:\temp\w2a.sqw','-pix');
w2b_p=read_sqw('c:\temp\w2b.sqw','-pix');

w4a_p=read_sqw('c:\temp\w4a.sqw','-pix');

%% Apply fixup to make the sqw structures match the new format

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change setup to new Horace, and set working directory to ...\Horace_sqw\test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


%% Read in some new format sqw files to test conversion of Horace

load('T:\SVN_area\test_horace.mat')

% Make objects
s1a=sqw(w1a_s);
s1b=sqw(w1b_s);
s1c=sqw(w1c_s);
s1d=sqw(w1d_s);

s2a=sqw(w2a_s);
s2b=sqw(w2b_s);

s4a=sqw(w4a_s);

dd1a=d1d(w1a_d);
dd1b=d1d(w1b_d);
dd1c=d1d(w1c_d);
dd1d=d1d(w1d_d);

dd2a=d2d(w2a_d);
dd2b=d2d(w2b_d);

dd4a=d4d(w4a_d);


% Plot a couple of structures: go via libisis

dp(IXTdataset_1d(dd1a))

da(IXTdataset_2d(s2a))



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

