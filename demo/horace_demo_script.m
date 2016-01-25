%demo script, guiding you through the process of using the basic features
%of Horace from the Matlab command line

%First of all ensure that the current directory of Matlab is the directory
%in which this script file is located (otherwise the following line will
%not work).

%
%====================================
%% Generate Horace data files
%====================================

%Run the command below to obtain the data we will use for the demo. This
%process can take a few minutes - be patient!
%file_list=setup_demo_data();

%At the end of this you should have a set of files called
%HoraceDemoDataFileN.spe, where N is 1 to 23.

%We will now generate the SQW file that lies at the heart of Horace. It
%combines the data from several runs (23 in this case) into one single data
%source, data from which can then be cut and sliced along any direction in
%4-dimensional reciprocal space:

demo_dir=pwd;
indir=demo_dir;     % source directory of spe (or nxspe) files
par_file=[indir,filesep,'4to1_124.par'];     % detector parameter file
sqw_file=[indir,filesep,'fe_demo.sqw'];        % output sqw file
data_source =sqw_file;

% Set incident energy, lattice parameters etc.
efix=787;
emode=1;
alatt=[2.87,2.87,2.87];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;

% Create the list of file names and orientation angles
psi=[0:4:90];%the angle of the sample w.r.t. the incident beam for each run.
%psi=0 is defined when u is parallel to the incident beam (in this case
%u=[1,0,0] - see above).

nfiles=numel(psi);
if exist('file_list','var')
    spe_file = file_list;
else
    spe_file=cell(1,nfiles);
    for i=1:length(psi)
        spe_file{i}=[indir,filesep,'HoraceDemoDataFile',num2str(i),'.nxspe'];
        if ~exist(spe_file{i},'file')
            spe_file{i}=[indir,filesep,'HoraceDemoDataFile',num2str(i),'.spe'];
        end
    end
end

gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
    u, v, psi, omega, dpsi, gl, gs);

%====================================
%% Make plots etc
%====================================

%Viewing axes to look at the data. These can be any orthogonal set you like
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

%3D slice - view using sliceomatic
cc3=cut_sqw(sqw_file,proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],[0,16,700],'-nopix');
plot(cc3);
%notice the '-nopix' option - we chose not to retain in memory the
%information about every contributing detector pixel for this slice. Using
%-nopix means we use less memory, but also lose some information about the
%underlying data.

%2D slice
cc2=cut_sqw(sqw_file,proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],[100,16,400]);
plot(cc2);

%1D cut
cc1=cut_sqw(sqw_file,proj,[1.9,2.1],[-3,0.05,3],[-0.1,0.1],[180,220]);
plot(cc1);

% Cuts along hkl-directions
hklline = [0 0 0; 0.5 0.5 0.5; 0.5 0.5 0; 0 0.5 0; 0 0 0]; 
bzpts = {'\Gamma','R','M','X','\Gamma'};
bzcen = [2 2 0];
wsp=spaghetti_plot(hklline+repmat([2 2 0],size(hklline,1),1),sqw_file,'labels',bzpts, ...
    'ebin',[10,10,500],'qbin',0.1,'qwidth',1,'smooth',0,'logscale','clim',[0.5 2]);

%================================
%% Data manipulation
%================================

%Take a cut that we can use later as a background references:
backgroundcut=cut(cc2,[-0.05,0.05],[]);%keep the binning the same in 2nd axis, but integrate over
%a given range in the first to produce a 1d cut

%"replicate" this 1d cut so that it covers the full range of the 2d slice
%we took it from. But because we still have pixel info, and what we are
%doing "breaks" the relationship between the raw data and what we are
%plotting on the screen, we have to throw the pixel info away. We do this
%by converting from an sqw object to a d2d / d1d object:
backgroundcut=d1d(backgroundcut);
dd2=d2d(cc2);
wback = replicate(backgroundcut,dd2);  %NB the replicate method has not yet been implemented for SQW
plot(wback);

% Subtract from the 2D cut
wdiff = dd2 - wback;
plot(wdiff);

%==================================
%% Simulation and fitting
%==================================

cc2a=cut_sqw(sqw_file,proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],[180,220]);

% Simulate a model for S(Q,w):
% (This is an example where the user can provide the spectral weight as a
% function of (vector) Q and energy)
w_sqw=sqw_eval(cc2a,@demo_FM_spinwaves,[250 0 2.4 10 5]);
plot(w_sqw)
%Looks vaguely like the data.

%Do a fit. We'll fit parameters 1, 3 and 5 in our model, but leave 2 and 4
%fixed (2nd vector is list of free parameters). We will
%also have a backgound function (specified separately). The (optional) list
%argument gives a verbose output during the fitting process
[wfit,fitdata]=fit_sqw(cc2a,@demo_FM_spinwaves,[250 0 2.4 10 5],[1 0 1 0 1],...
    @constant_background,[0.05],[1],'list',2,'fit',[0.001 30 0.001]);


%% Symmetrising, and some other bits and bobs

%You can fold about some axis, to improve stats:
wsym=symmetrise_sqw(cc2a,[1,0,0],[0,0,1],[0,0,0]);%specify a plane using 2 vectors in it, and an
%offset of this plane from the origin. So the above should fold about the
%line h=0:

plot(wsym)

%You can perform binary operations using objects and scalars:
wadd=cc2a+27;
plot(wadd);%notice the changed limits of the colour scale!



%There is much much more in the Horace online manual:

%http://horace.isis.rl.ac.uk

%Please use that as your first port of call for reference material.

%Also, to get inline info about a particular function, type in Matlab
%>> help <function_name>







