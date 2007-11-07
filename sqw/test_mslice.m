%=======================================================
% To test a standard file against mslice
%
% Checked that mslice and Horace match 19:30 29/6/07

spe_file = 'E:\fe\data_jul06\EI_400-PSI_0-BASE.SPE';

par_file = 'T:\experiments\cobalt\escience\9CARDS_4_4TO1.PAR';
sqw_file = 'C:\temp\EI_400-PSI_0-BASE.SQW';
tmp_file = 'C:\temp\EI_400-PSI_0-BASE_TMP.SQW';

efix=398.4;
emode=1;
alatt=2*pi*[2.87,2.87,2.87];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
deg2rad=pi/180;
psi=0 *deg2rad;
omega=0 *deg2rad;
dpsi=0 *deg2rad;
gl=0 *deg2rad;
gs=0 *deg2rad;

write_spe_to_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)

% Process to get file on grid
bigtic
grid_size_in=[1,101,51,1];
astar=2*pi/2.87;
urange_in = [[-100,100]*astar;[-2.025,3.025]*astar;[-1.025,1.525]*astar;[90,110]]';
grid_size = write_nsqw_to_nsqw (sqw_file, tmp_file, grid_size_in, urange_in)
bigtoc

% Get intensity, error for mslice slice:
slc=ms_slice
old.s=slc.intensity(1:end-1,1:end-1);
old.e=slc.error_int(1:end-1,1:end-1);

filenam='c:\temp\EI_400-PSI_0-BASE_TMP.SQW';
[refm,refh,refp,refd]=load_sqw(filenam,'a-');
new.s=squeeze(refd.s);
new.e=squeeze(refd.e);
new.npix=reshape(refd.npix,size(new.s));
new.s=(new.s./new.npix)';       % transpose as first axis is column
new.e=(sqrt(new.e)./new.npix)';

%=======================================================
