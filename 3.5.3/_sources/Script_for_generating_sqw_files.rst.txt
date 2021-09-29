###############################
Script for generating sqw files
###############################

::

   %==================================================
   %Option 1 - make an sqw file from a complete list of existing runs (e.g. after an experiment has finished)

   data_path='/my_path/etc/';%set director where spe/nxspe files are located

   %par_file=[data_path,'my_par.par'];%if using spe files, uncomment this line
   par_file='';%if using nxspe files you do not need to specify a par file. Comment this line out if using spe files

   sqw_file=[data_path,'my_real_file.sqw'];%specify the name of the sqw file - we assume it goes in the same directory as the spe files

   efix=400;%set incident energy

   psi=[0:2:90];%set values of sample orientation psi for our runs. We went from 0 to 90 degrees in 2 degree steps here

   runno=[15052:15097];%list of run numbers. The nth run in this list must correspond to the nth value of psi in the previous list

   emode=1;%specify direct geometry spectrometer

   alatt=[3,4,5];%lattice parameters (Angstroms)

   angdeg=[90,90,120];%lattice angles (degrees)

   u=[1,0,0]; v=[0,1,0];%specify scattering plane, where u is the crystal direction // to ki when psi=0, v is another vector so that with u it specifies the equatorial plane

   omega=0; dpsi=0; gl=0; gs=0;%goniometer offsets for the sample (usually all zero)

   %Write a for-loop to create a cell array with the same number of elements as there are values of psi
   %Each element of the cell array is the full filename of the corresponding nxspe file
   for i=1:numel(psi)
       spefile{i}=[data_path,'map',num2str(runno(i)),'_processed.nxspe'];
   end

   %Finally, make the sqw file. This will take a few minutes (depending on the number of runs and the size of the data files)
   gen_sqw (spefile, par_file, sqw_file, efix, emode, alatt, angdeg,...
       u, v, psi, omega, dpsi, gl, gs)


   %==================================================
   %Option 2 - generate an sqw file on the fly during an experiment, so that further runs not yet measured (but planned) can be appended to it
   %this will avoid having to regenerate the entire sqw file all over again

   %The list of input arguments is exactly the same as above, with the difference that psi and spefile are a list of PLANNED scan angles, and
   %anticipated spe file names, only some of which will exist yet.

   %First time run through (sqw file does not yet exist), explicitly demanding that a new sqw file is created:
   accumulate_sqw (spefile, par_file, sqw_file, efix, emode, alatt, angdeg,...
       u, v, psi, omega, dpsi, gl, gs, 'clean')

   %Subsequent calls are the same, but without the 'clean' argument
   accumulate_sqw (spefile, par_file, sqw_file, efix, emode, alatt, angdeg,...
       u, v, psi, omega, dpsi, gl, gs)

   %Note that if you extend your range of psi from that originally planned in the first run through, then you will have to regenerate
   %the sqw file.


   %=================================================
   %Option 3 - after the experiment is over, and all corrections have been applied (especially alignment) then we
   %can symmetrise the entire dataset:

   gen_sqw (spefile, par_file, sym_sqw_file, efix, emode, alatt, angdeg,...
       u, v, psi, omega, dpsi, gl, gs,'transform_sqw',@(x)(symmetrise_sqw(x,v1,v2,v3)))

   %or more generally
   gen_sqw (spefile, par_file, sym_sqw_file, efix, emode, alatt, angdeg,...
       u, v, psi, omega, dpsi, gl, gs,'transform_sqw',@(x)(user_symmetrisation_routine(x))

   %In a separate m-file on the Matlab path, define the following function (for example):
   %
   % function wout = user_symmetrisation_routine(win)
   %
   % wout=symmetrise_sqw(win,[1,1,0],[0,0,1],[0,0,0]);%fold about line (1,1,0) in HK plane
   % wout=symmetrise_sqw(wout,[-1,1,0],[0,0,1],[0,0,0]);%fold about line (-1,1,0) in HK plane
   % wout=symmetrise_sqw(wout,[1,0,1],[0,1,0],[0,0,0]);%fold about line (1,0,1) in HL plane
   % wout=symmetrise_sqw(wout,[1,0,-1],[0,1,0],[0,0,0]);%fold about line (1,0,-1) in HL plane
   %
