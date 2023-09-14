%Worked example script to correct for sample misalignment and symmetrise
%data to improve the statistics

%Christian Balz 25/07/2022

%In order to symmetrise data we first need to correct for any existing
%sample misalingment. As the symmetrisation routines will asume the sample
%to be perfectly alignetd they will create false results if it is not done
%in this order. We will start with a raw sqw file and apply the sample
%alignment corrections after fitting a set of Bragg peaks. Then we
%will take this corrected sqw and see what the symmetrisation routines can
%do for us.

%Set the data folder
folder = '/mnt/nomachine/pace/docs/04_06_align_and_symmetrise/';

%Load the example raw sqw file
sqw_file = [folder 'T15K_B3T_5p50meV.sqw'];

%Create a series of 3 perpendicular slices to see the misalignment
proj.u=[1,1,0]; proj.v=[1,-1,2]; proj.uoffset=[0,0,0,0]; proj.type='rrr';

slice1=cut_sqw(sqw_file,proj,0.02,0.02,[-0.2,0.2],[-0.25,0.25]);
plot(compact(slice1));lz 0 10;grid on;keep_figure;
slice2=cut_sqw(sqw_file,proj,0.01,[-0.2,0.2],0.01,[-0.25,0.25]);
plot(compact(slice2));lz 0 10;grid on;keep_figure;
slice3=cut_sqw(sqw_file,proj,[-0.2,0.2],0.01,0.01,[-0.25,0.25]);
plot(compact(slice3));lz 0 10;grid on;keep_figure;

%We can see that we have covered 11 Bragg peaks in the horizontal
%scattering plane. By comparing the Bragg peak positions with the grid
%positions we can see the misalignment of the sample. This is especially
%visible in slice2 and slice3.

%Now we have to work out what the nominal Bragg peak positions are.
%Calculating it from the x- and y-axes labels of slice1 we get

bragg_peaks=[-3,-3,0; -2,-2,0; -1,-1,0; -3,-2,-1; -2,-1,-1;...
             -3,-1,-2; -2,0,-2; -1,1,-2; -2,1,-3; -1,2,-3; 0,3,-3];

%Now we have to get the actual Bragg peak positions by fitting Gaussians
%through our elastic scattering data. The function bragg_positions takes
%one radial and two transverse cuts though every nominal Bragg peak
%position. We have to define the cut length, the step size along the cut,
%the perpendicular integration ranges, and energy integration range.

[rlu0,width,wcut,wpeak]=bragg_positions(sqw_file,bragg_peaks,0.4,0.01,...
                                 0.2,0.4,0.01,0.2,0.25,'gauss','bin_ab');

%Use the command below to plot the fits and see how good they are. Scroll
%through the fits by pressing Return

bragg_positions_view(wcut,wpeak)

%After you are satisfied with your fit you can use the fitted Bragg peak
%positions stored in rlu0 to refine the lattice parameters and create the
%rotation matrix rlu_corr that relates the notational rlu to the true rlu.
                                 
alatt = [12.302,12.302,12.302];   % original lattice parameters
angdeg = [90,90,90];              % cubic symmetry
[rlu_corr,alatt_corr,angdeg_corr] = refine_crystal(rlu0, alatt, angdeg,...
    bragg_peaks,'fix_angdeg','fix_alatt_ratio');

%Now that we have found the misalignment described by the rotation matrix
%rlu_corr we can calculate the goniometer offsets that we can use in
%gen_sqw to correct for the sample misalignment.

u = [1,1,0]; %original u
v = [1,-1,2];%original v
alatt = [12.302,12.302,12.302];   % original lattice parameters
angdeg = [90,90,90];%cubic symmetry
omega=0; dpsi=0; gl=0; gs=0;%original goniometer values

[alatt_corr, angdeg_corr, dpsi, gl, gs] = crystal_pars_correct...
    (u, v, alatt, angdeg, omega, dpsi, gl, gs, rlu_corr);

%Like this we get the corrected lattice parameters and the values of the
%goniometers dpsi, gl, and gs. These can be used for any subsequent
%generation of sqw files to correct for the misalignment.
[alatt_corr,dpsi,gl,gs]

%Lastly if we do not want to generate a new sqw file at this point we can
%copy and correct the existing sqw file by
sqw_file_corr = [folder 'T15K_B3T_5p50meV_corr.sqw'];
copyfile(sqw_file,sqw_file_corr)
change_crystal_horace(sqw_file_corr, rlu_corr);

%Let us check slice2 and slice3 from above if the misalignment is now
%corrected:

sqw_file_corr = [folder 'T15K_B3T_5p50meV_corr.sqw'];

slice2_corr=cut_sqw(sqw_file_corr,proj,0.01,[-0.2,0.2],0.01,[-0.25,0.25]);
plot(compact(slice2_corr));lz 0 10;grid on;keep_figure;
slice3_corr=cut_sqw(sqw_file_corr,proj,[-0.2,0.2],0.01,0.01,[-0.25,0.25]);
plot(compact(slice3_corr));lz 0 10;grid on;keep_figure;

%Now that we have corrected the alignment we can apply symmetry operations
%to improve statistics by combining equivalent areas of reciprocal space.

%In this example we know that we have a 2-fold rotation axis along [1,1,0]
%and equivalent directions. One of the directions overed in our 140 degree
%rotation is [-1,0,-1]. We can include the following symmetrisation command
%in "gen_sqw" after the "transform_sqw" keyword:

%(x)(symmetrise_sqw(x,[-1,0,-1],[-1,1,1],[0,0,0]))

%A sqw file with the symmetry operation applied is located here:
sqw_file_corr_sym = [folder 'T15K_B3T_5p50meV_corr_sym.sqw'];

%To see what the operation has done to our dataset one can plot the
%horizontal scattering plane after symmetrisation:

slice1_sym=cut_sqw(sqw_file_corr_sym,proj,0.02,0.02,[-0.2,0.2],[-0.25,0.25]);
plot(compact(slice1_sym));lz 0 10;grid on;keep_figure;

%Looking at inealstic data we often suffer from weak statistics. Here you
%can see that symmetrisation has improved statistics for a particular slice
%through the sqw:

%before symmetrisation:
proj2.u=[-2,-1,-1]; proj2.v=[0,-1,1]; proj2.uoffset=[0,0,0,0]; proj2.type='rrr';
slice4_corr=cut_sqw(sqw_file_corr,proj2,0.03,[-0.1,0.1],[-0.1,0.1],0.04);
plot(compact(slice4_corr));lz 0 0.25;keep_figure;

%after symmetrisation
slice4_corr_sym=cut_sqw(sqw_file_corr_sym,proj2,0.03,[-0.1,0.1],[-0.1,0.1],0.04);
plot(compact(slice4_corr_sym));lz 0 0.25;keep_figure;

%Note: One has to be careful with symmetrisations. In this example we have
%applied a mirror plane symmetry for a 2-fold rotation axis. This is
%technically not correct. However we were only looking at a slice centered
%in a narrow region around the horizontal scattering plane where the error
%due to our symetry operation is minimal.


