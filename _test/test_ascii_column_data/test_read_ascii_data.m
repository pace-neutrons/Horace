function test_read_ascii_data
% Test ascii column data reader
%
% This functionality of Horace was added to look at WISH data in about Nov 2011 by T.G.Perring. It is something of a fixup,
% and so deserves to be tested carefully.
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% Set all energy values in constructed data file to zero, or not
% --------------------------------------------------------------
% As of 25/10/2013: if all energies=0 this causes problems if use_mex==1 and grid_size_in~=1,
% because the c routine doesn't like all values=0

elastic_all_zero=0;     % =1 all energy values zero; =0 very narrow distribution around zero


% File names
% ----------
ascii_file=fullfile(tmp_dir,'testdata_read_ascii.dat');
sqw_file=fullfile(tmp_dir,'testdata_read_ascii.sqw');


% =============================================
% Test #1 - small file
% =============================================

% Create ASCII data file
% ----------------------
qx=0.1:0.1:0.5;
qy=0.1:0.1:0.6;
qz=0.1:0.1:0.7;
en=10:0.5:14;

[qx3,qy3,qz3]=ndgrid(qx,qy,qz);
if elastic_all_zero
    qe3=zeros(size(qx3));
else
    qe3=-0.001+0.002*rand(size(qx3));
end
s=qx3+10*qy3+100*qz3;

fid=fopen(ascii_file,'wt');
fprintf (fid, '%30.16g %30.16g %30.16g %30.16g %30.16g \n', [qx3(:),qy3(:),qz3(:),qe3(:),s(:)]');
fclose(fid);


% Read in data and create sqw file
% ---------------------------------
efix=0;
emode=0;
alatt=2*pi*[1,1,1];
angdeg=[90,90,90];
uvec=[1,0,0];
vvec=[0,1,0];
psi=0;
omega=0; dpsi=0; gl=0; gs=0;
grid_size_in=3;
write_qspec_to_sqw (ascii_file, sqw_file, efix, emode, alatt, angdeg, uvec, vvec, psi, omega, dpsi, gl, gs, grid_size_in);


% =============================================
% Test #2 - larger file
% =============================================
qx=0.1:0.01:0.5;
qy=0.1:0.01:0.6;
qz=0.1:0.01:0.7;
en=10:0.5:14;

[qx3,qy3,qz3]=ndgrid(qx,qy,qz);
if elastic_all_zero
    qe3=zeros(size(qx3));
else
    qe3=-0.001+0.002*rand(size(qx3));
end
s=qx3+2*qy3+4*qz3;


fid=fopen(ascii_file,'wt');
fprintf (fid, '%30.16g %30.16g %30.16g %30.16g %30.16g \n', [qx3(:),qy3(:),qz3(:),qe3(:),s(:)]');
fclose(fid);

% Create sqw file
efix=0;
emode=0;
alatt=2*pi*[1,1,1];
angdeg=[90,90,90];
uvec=[1,0,0];
vvec=[0,1,0];
psi=0;
omega=0; dpsi=0; gl=0; gs=0;
grid_size_in=3;
write_qspec_to_sqw (ascii_file, sqw_file, efix, emode, alatt, angdeg, uvec, vvec, psi, omega, dpsi, gl, gs, grid_size_in);

% Read in sqw file and rebin
wtmp=read(sqw,sqw_file);
w3=cut_sqw(wtmp,0.03,0.03,0.03,[-Inf,Inf]);


% Success announcement and cleanup
% --------------------------------
try
    delete(ascii_file)
    delete(sqw_file)
catch
    disp('Unable to delete temporary file(s)')
end
banner_to_screen([mfilename,': Test(s) passed'],'bot')
