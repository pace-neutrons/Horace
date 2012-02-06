function test_1
%% Test ascii column data reader

qx=0.1:0.1:0.5;
qy=0.1:0.1:0.6;
qz=0.1:0.1:0.7;
en=10:0.5:14;

elastic_all_zero=1;

[qx3,qy3,qz3]=ndgrid(qx,qy,qz);
if elastic_all_zero
    qe3=zeros(size(qx3));  % this causes problems if use_mex==1 and grid_size_in~=1, because c routine doesn't like all values=0
else
    qe3=-0.001+0.002*rand(size(qx3));
end
s=qx3+10*qy3+100*qz3;

file_name='c:\temp\aaa_data_el.dat';
fid=fopen(file_name,'wt');
fprintf (fid, '%30.16g %30.16g %30.16g %30.16g %30.16g \n', [qx3(:),qy3(:),qz3(:),qe3(:),s(:)]');
fclose(fid);


% Read in data and create sqw file
% ---------------------------------
file_name='c:\temp\aaa_data_el.dat';
sqw_file='c:\temp\aaa_data_el.sqw';
efix=0;
emode=0;
alatt=2*pi*[1,1,1];
angdeg=[90,90,90];
uvec=[1,0,0];
vvec=[0,1,0];
psi=0;
omega=0; dpsi=0; gl=0; gs=0;
grid_size_in=3;
write_qspec_to_sqw (file_name, sqw_file, efix, emode, alatt, angdeg, uvec, vvec, psi, omega, dpsi, gl, gs, grid_size_in);


%% More complete test
qx=0.1:0.01:0.5;
qy=0.1:0.01:0.6;
qz=0.1:0.01:0.7;
en=10:0.5:14;

elastic_all_zero=0;

[qx3,qy3,qz3]=ndgrid(qx,qy,qz);
if elastic_all_zero
    qe3=zeros(size(qx3));  % this causes problems if use_mex==1 and grid_size_in~=1, because c routine doesn't like all values=0
else
    qe3=-0.001+0.002*rand(size(qx3));
end
s=qx3+2*qy3+4*qz3;

file_name='c:\temp\aaa_data_el.dat';
fid=fopen(file_name,'wt');
fprintf (fid, '%30.16g %30.16g %30.16g %30.16g %30.16g \n', [qx3(:),qy3(:),qz3(:),qe3(:),s(:)]');
fclose(fid);

% Create sqw file
file_name='c:\temp\aaa_data_el.dat';
sqw_file='c:\temp\aaa_data_el.sqw';
efix=0;
emode=0;
alatt=2*pi*[1,1,1];
angdeg=[90,90,90];
uvec=[1,0,0];
vvec=[0,1,0];
psi=0;
omega=0; dpsi=0; gl=0; gs=0;
grid_size_in=1;
write_qspec_to_sqw (file_name, sqw_file, efix, emode, alatt, angdeg, uvec, vvec, psi, omega, dpsi, gl, gs, grid_size_in);

% Read in sqw file and rebin
wtmp=read(sqw,sqw_file);

w3=cut_sqw(wtmp,0.03,0.03,0.03,[-Inf,Inf]);
