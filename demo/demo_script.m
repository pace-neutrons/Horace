%This is a Matlab script file to demonstrate some of the basic features of
%Horace. For a description of what each function is doing, and pictures of
%what the various plots should look like, visit
%http://horace.isis.rl.ac.uk/Getting_started

%In order to run this demo you may need to change some of the directory and
%file names in order to match up to your own operating system and file
%structure. It has been assumed that Horace can be found in
%C:\mprogs\Horace

%==========================================================================
%Unzip the data contained in the demo folder
%==========================================================================
%demo_root_dir = 'C:\mprogs\Horace\demo\';
demo_root_dir = [pwd filesep];
unzip([demo_root_dir 'Horace_demo.zip'],demo_root_dir);

% =========================================================================
% Script to create sqw file
% =========================================================================
indir=demo_root_dir;     % source directory of spe files
par_file=[demo_root_dir 'demo_par.PAR'];     % detector parameter file
sqw_file=[demo_root_dir 'fe_demo.sqw'];        % output sqw file

efix=787;
emode=1;
alatt=[2.87,2.87,2.87];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;


nfiles1=24;
psi1=linspace(0,-1*(nfiles1-1),nfiles1);
spe_file1=cell(1,nfiles1);
for i=1:length(psi1)
    spe_file1{i}=[indir,'MAP',num2str(11012+(2*i)),'.SPE'];
    tmp_file{i}=[indir,'MAP',num2str(11012+(2*i)),'.tmp'];
end


gen_sqw (spe_file1, par_file, sqw_file, efix, emode, alatt, angdeg,...
         u, v, psi1, omega, dpsi, gl, gs);

write_nsqw_to_sqw(tmp_file,sqw_file);

%==========================================================================
%==========================================================================
% Now we wish to plot some of our data:
%%
data_source =[demo_root_dir 'fe_demo.sqw'];
proj_100.u = [1,0,0];
proj_100.v = [0,1,0];
proj_100.type = 'rrr';
proj_100.uoffset = [0,0,0,0];

w100_2 = cut_sqw(data_source,proj_100,[-0.2,0.2],0.05,[-0.2,0.2],[0,0,500]);

%1d cut:
w100_1 = cut_sqw(data_source,proj_100,[-0.2,0.2],0.05,[-0.2,0.2],[60,70]);

%3d sliceomatic figure:
w100_3 = cut_sqw(data_source,proj_100,[-0.2,0.2],0.05,0.05,[0,0,500]);


%==========================================================================
%==========================================================================

%Data manipulation:
%(note that at present replicate does not exist for sqw, so we must use
%dnd):
w110_2a = cut_sqw(data_source,proj_100,[-0.2,0.2],[1,0.05,3],[-0.2,0.2],[0,0,150],'-nopix');

wbackcut = cut(w110_2a,[2.8,3],[]);

wback = replicate(wbackcut,w110_2a);%NB the replicate method has not yet been
%implemented for SQW
plot(wback);

wdiff = w110_2a - wback;
plot(wdiff);
lz 0 1


%==========================================================================
%==========================================================================

%Test some simulation and fitting functions:
%
%make a template d2d:
w_template=cut_sqw(data_source,proj_100,[-0.4,0.2],[0,0.05,3],[-0.5,0.05,3],[30,40]);
plot(w_template); lz 0 4;
keep_figure;

%simulate the 4 peaks.
w_sim=func_eval(w_template,@demo_4gauss_2dQ,[6 1 1 0.1 2 1 1]);
plot(w_sim); lz 0 4;
keep_figure;

%do FM spinwave simulation:
w_sqw=sqw_eval(w_template,@demo_FM_spinwaves_2dSlice_sqw,[300 0 2 10 2]);
plot(w_sqw); keep_figure;


%==========================================================================
%==========================================================================
%Try doing some fitting now:

[w_fit1,fitdata1]=fit(w_template,@demo_4gauss_2dQ,[6 1 1 0.1 2 1 1],[1 1 1 1 0 0 1],'list',2);
plot(w_fit1); lz 0 4;
keep_figure;

%==
%do a dodgy fixup to use the sqw FM spinwaves model to do a fit:
getit=get(d2d(w_sqw));
getit.s = getit.s + (rand(size(getit.s))).*getit.s;%add some noise to the simulation.
getit.e = (rand(size(getit.e))).*getit.s;%make dummy errorbars.
w_fixup=d2d(getit);
plot(w_fixup);
%==

%Now fit this fake data:
[w_fit2,fitdata2]=fit_sqw(w_fixup,@demo_FM_spinwaves_2dSlice_sqw,...
    [200 0 2 10 2],[1 1 1 0 1],'list',1);
plot(w_fit2); keep_figure;



