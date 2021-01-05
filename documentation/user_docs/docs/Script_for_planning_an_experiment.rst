#################################
Script for planning an experiment
#################################

::

   %First, we can launch a simple planning GUI that is useful for a quick look, especially for systems with orthogonal lattices
   %It is less useful for detailed checks and/or non-orthogonal systems

   horace_planner

   %============================
   %Make a fake dataset that can be explored as if it was a real one. The fake signal corresponds to the average angle of the run
   %whose detector pixels contributed to that bin

   en=[0:10:500];%set energy range and step size for fake data to cover using a Matlab vector

   par_file='/my_path/etc/InstParFile.par';%Detector parameter file (see your instrument scientist to get one)

   fake_sqw_file='/my_path/etc/my_fake_file.sqw';%Filename for the fake sqw file that will be created

   efix=550;%set incident energy to be 550meV

   psi=[-75:5:75];%a range of sample orientations (psi) - notice that we use a coarse step size, as this speeds things up

   emode=1;%direct geometry instrument specified

   alatt=[2.87,2.87,2.87];%lattice parameters (Angstroms)

   angdeg=[90,90,90];%lattice angles (degrees)

   u=[1,0,0]; v=[0,1,0];%scattering plane, where u is // to ki, v is in the equatorial plane of the detectors and perpendicular to u

   omega=0; dpsi=0; gl=0; gs=0;%goniometer offset angles for the sample (usually all zero)

   fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg,u, v, psi, omega, dpsi, gl, gs)%Generate the fake file. This will take a few minutes

   %You can now take cuts and slices from the fake sqw file as you would from a real one
