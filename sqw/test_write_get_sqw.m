%================================================
% Write and read sqw file
%================================================

efix=35;
emode=1;
alatt=2*pi*[1,1,1];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
type='rrr';
deg2rad=pi/180;
psi_1=45 *deg2rad;
psi_2=51 *deg2rad;
psi_3=57 *deg2rad;
omega=0 *deg2rad;
dpsi=0 *deg2rad;
gl=0 *deg2rad;
gs=0 *deg2rad;

% New method - single bin
spe_file_1='c:\temp\map06013.spe';
spe_file_2='c:\temp\map06014.spe';
spe_file_3='c:\temp\map06015.spe';
par_file='c:\temp\9cards_4_4to1.par';
sqw_file_1='c:\temp\crap_6013.sqw';
sqw_file_2='c:\temp\crap_6014.sqw';
sqw_file_3='c:\temp\crap_6015.sqw';
write_spe_to_sqw (spe_file_1, par_file, sqw_file_1, efix, emode, alatt, angdeg, u, v, psi_1, omega, dpsi, gl, gs)
write_spe_to_sqw (spe_file_2, par_file, sqw_file_2, efix+10, emode, alatt, angdeg, u, v, psi_2, omega, dpsi, gl, gs)
write_spe_to_sqw (spe_file_3, par_file, sqw_file_3, efix+20, emode, alatt, angdeg, u, v, psi_3, omega, dpsi, gl, gs)

% Process to get file on 5^4 grid
infiles={'c:\temp\crap_6013.sqw','c:\temp\crap_6014.sqw','c:\temp\crap_6015.sqw'};
outfiles={'c:\temp\tmp_6013.sqw','c:\temp\tmp_6014.sqw','c:\temp\tmp_6015.sqw'};
grid_size_in=5;
grid_size = write_nsqw_to_nsqw (infiles, outfiles, grid_size_in);

% Create a combined file
bigfile='c:\temp\crap_all.sqw';
write_nsqw_to_sqw (outfiles, bigfile)

%================================================
% gen_sqw
%================================================
efix=[35,45,55];
emode=1;
alatt=2*pi*[1,1,1];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
type='rrr';
psi=[45,51,57];
omega=0;
dpsi=0;
gl=0;
gs=0;

spe_file={'c:\temp\map06013.spe','c:\temp\map06014.spe','c:\temp\map06015.spe'};
par_file='c:\temp\9cards_4_4to1.par';
sqw_file='c:\temp\crap_the_lot.sqw';

% To reproduce the above calls to write_... etc.
gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 5);

% As would really be done:
gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
