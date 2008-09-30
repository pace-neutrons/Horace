%% =====================================================================================================================
% Script to create sqw file
% =====================================================================================================================

% Use this block of commands to create an sqw file from all your spe files
%
% The function that does all the work is gen_sqw.
% Intermediate files with extension .tmp will first be created, one per spe file, and then
% the .tmp files combined into one huge output file.

indir='C:\temp\mnsi\';                      % source directory of spe files
par_file='C:\temp\mnsi\mnsi_apr08.par';     % detector parameter file
sqw_file='C:\temp\mnsi\crap.sqw';           % output sqw file

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



%% =====================================================================================================================
% Fix up script if a problem with the above
% =====================================================================================================================

% Sometimes one gets an error containing the message 'broken pipe' or 'unrecoverable read error'. In this case
% check if all the intermediate files exist (extension (.tmp). If so, then create a list of file names for the
%.tmp files, using a loop similar to that which creates the list of spe files, and then run

write_nsqw_to_sqw (tmp_file, sqw_file);

