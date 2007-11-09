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
write_spe_to_sqw (spe_file_1, par_file, sqw_file_1, efix, emode, alatt, angdeg, u, v, psi_1, omega, dpsi, gl, gs);
write_spe_to_sqw (spe_file_2, par_file, sqw_file_2, efix+10, emode, alatt, angdeg, u, v, psi_2, omega, dpsi, gl, gs);
write_spe_to_sqw (spe_file_3, par_file, sqw_file_3, efix+20, emode, alatt, angdeg, u, v, psi_3, omega, dpsi, gl, gs);

% Process to get file on 5^4 grid
infiles={'c:\temp\crap_6013.sqw','c:\temp\crap_6014.sqw','c:\temp\crap_6015.sqw'};
outfiles={'c:\temp\tmp_6013.sqw','c:\temp\tmp_6014.sqw','c:\temp\tmp_6015.sqw'};
grid_size_in=50;
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
sqw_file='c:\temp\crap_gen_sqw.sqw';

% To reproduce the above calls to write_... etc.
gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 5);

% As would really be done:
gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);


%================================================
% For testing differences
%================================================
file_1 = 'c:\temp\crap_all_ref.sqw';
file_2 = 'c:\temp\crap_gen_sqw.sqw';

file_1 = 'c:\temp\map06013.tmp';
file_2 = 'c:\temp\tmp_6013.sqw';


[m1,h1,p1,d1,mm1,pos1,np1,t1]=get_sqw(file_1,'-nopix');
[m2,h2,p2,d2,mm2,pos2,np2,t2]=get_sqw(file_2,'-nopix');
if np1~=np2 || ~isempty(mm1) || ~isempty(mm2)
    error('There is an incompatibility between the two files being tested')
end
blo=min(d1.npix(:)-d2.npix(:));
bhi=max(d1.npix(:)-d2.npix(:));
disp(['Pixels per bin: ',num2str(blo),'  ',num2str(bhi)])
nlump=1000000;
nmax=np1;
for i=1:nlump:nmax
    ihi=min(i+nlump-1,nmax);
    disp([int2str(i),'  ',int2str(ihi)])
    [m1,h1,p1,d1,mm1,pos1,np1,t1]=get_sqw(file_1,i,ihi);
    [m2,h2,p2,d2,mm2,pos2,np2,t2]=get_sqw(file_2,i,ihi);
    plo=min(d1.pix(:)-d2.pix(:));
    phi=max(d1.pix(:)-d2.pix(:));
    disp([num2str(plo),'  ',num2str(phi)])
end
 
