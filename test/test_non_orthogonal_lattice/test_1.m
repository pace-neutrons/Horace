% Create a monoclinic lattice with c* at 70 degrees w.r.t. a*
% -----------------------------------------------------------
astar=1.5; bstar=2; cstar=0.5; beta=110;
lattice=[2*pi/(astar*sind(beta)), 2*pi/bstar, 2*pi/(cstar*sind(beta)), 90, beta, 90];


% Create large detector.dat, spectra.dat and par file for creating an sqw file
% -------------------------------------------------------------------------------
detector_table('detector_huge.txt',fullfile(tempdir,'detector_huge.dat'))
spectrum_table('spec_huge.txt',fullfile(tempdir,'spec_huge.dat'))
map_table('spec_huge.txt',fullfile(tempdir,'map_huge.map'))
old_formats(fullfile(tempdir,'detector_huge.dat'),fullfile(tempdir,'spec_huge.dat'),fullfile(tempdir,'map_huge.map'),'par')
par_file=fullfile(tempdir,'map_huge.par');

% Test files to look at h-k slices at different l in dnd objects
% ---------------------------------------------------------------

w3=d3d(lattice,[1,0,0],[-2.5,0.05,2.5],[0,1,0],[-2.5,0.05,2.5],[0,0,1],[-2.5,0.05,2.5]);
w3c=sqw_eval(w3,@sqw_bragg_blobs,{[0.2,10],lattice});

w2_0=d2d(lattice,[0,0,0],[1,0,0],[-2.5,0.05,2.5],[0,1,0],[-2.5,0.05,2.5]);
w2c_0=sqw_eval(w2_0,@sqw_bragg_blobs,{[0.2,10],lattice});

w2_1=d2d(lattice,[0,0,1],[1,0,0],[-2.5,0.05,2.5],[0,1,0],[-2.5,0.05,2.5]);
w2c_1=sqw_eval(w2_1,@sqw_bragg_blobs,{[0.2,10],lattice});

w2_2=d2d(lattice,[0,0,2],[1,0,0],[-2.5,0.05,2.5],[0,1,0],[-2.5,0.05,2.5]);
w2c_2=sqw_eval(w2_2,@sqw_bragg_blobs,{[0.2,10],lattice});

w2c_2_from_w3=cut(w3c,[],[],[1.96,2.04]);


% Create sqw file
% ----------------
% This takes interminatbly long. The problem is when reading the spe files; even with use_mex
% true it was using get_spe_matlab
en=[-1,1];
sqw_file=fullfile(tempdir,'elastic_monoclinic_huge.sqw');
efix=100;
emode=1;
alatt=lattice(1:3);
angdeg=lattice(4:6);
u=[1,0,0]; v=[0,1,0];
psi=0:0.5:1;
omega=0; dpsi=0; gl=0; gs=0;
grid_size_in=[50,50,50,1]; 
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg,...
                    u, v, psi, omega, dpsi, gl, gs, grid_size_in)
