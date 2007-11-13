tic;test_psd_data=get_spe('c:\temp\map06014.spe');toc
%tic;test_psd_det=get_phx('c:\temp\9cards_4_4to1.phx');toc
tic;test_psd_det=get_par('c:\temp\9cards_4_4to1.par');toc

tic;test_data=get_spe('c:\temp\test.spe');toc
%tic;test_det=get_phx('c:\temp\test.phx');toc
tic;test_det=get_par('c:\temp\test.par');toc

tmp_data=section_spe(test_data,[12:15],[5,6]);
tmp_det=section_par(test_det,[12:15]);


tic;[test_psd_data,test_psd_det,keep]=get_data('c:\temp\map06014.spe','c:\temp\9cards_4_4to1.par');toc
tic;test_psd_det0=get_par('c:\temp\9cards_4_4to1.par');toc

tic;[test_data,test_det,keep]=get_data('c:\temp\test.spe','c:\temp\test.par');toc
tic;test_det0=get_par('c:\temp\test.par');toc


efix=35;
emode=1;
alatt=2*pi*[1,1,1];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
type='rrr';
deg2rad=pi/180;
psi=45 *deg2rad;
omega=0 *deg2rad;
dpsi=0 *deg2rad;
gl=0 *deg2rad;
gs=0 *deg2rad;

[u_to_rlu, ucoords] = calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, test_psd_data, test_psd_det);
[u_to_rlu, ucoords] = calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, test_data, test_det);
[u_to_rlu, ucoords] = calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, tmp_data, tmp_det);

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
psi=45 *deg2rad;
omega=0 *deg2rad;
dpsi=0 *deg2rad;
gl=0 *deg2rad;
gs=0 *deg2rad;

% Old method - will write on a grid (see line in write_sqw_old.m for size)
[test_psd_data,test_psd_det,keep]=get_data('c:\temp\map06014.spe','c:\temp\9cards_4_4to1.par');
test_psd_det0=get_par('c:\temp\9cards_4_4to1.par');
fid=fopen('c:\temp\crap_ref.sqw','w');
write_sqw_old (fid, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, test_psd_data, test_psd_det, test_psd_det0)
fclose(fid);

% New method - single bin
spe_file_1='c:\temp\map06013.spe';
spe_file_2='c:\temp\map06014.spe';
spe_file_3='c:\temp\map06015.spe';
par_file='c:\temp\9cards_4_4to1.par';
sqw_file_1='c:\temp\crap_6013.sqw';
sqw_file_2='c:\temp\crap_6014.sqw';
sqw_file_3='c:\temp\crap_6015.sqw';
tic
write_spe_to_sqw (spe_file_1, par_file, sqw_file_1, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
toc
tic
write_spe_to_sqw (spe_file_2, par_file, sqw_file_2, efix+10, emode, alatt, angdeg, u, v, psi+6, omega, dpsi, gl, gs)
toc
tic
write_spe_to_sqw (spe_file_3, par_file, sqw_file_3, efix+20, emode, alatt, angdeg, u, v, psi+12, omega, dpsi, gl, gs)
toc

% Process to get file on 5^4 grid
infiles={'c:\temp\crap_6013.sqw','c:\temp\crap_6014.sqw','c:\temp\crap_6015.sqw'};
outfiles={'c:\temp\tmp_6013.sqw','c:\temp\tmp_6014.sqw','c:\temp\tmp_6015.sqw'};
bigtic
grid_size_in=5;
grid_size = write_nsqw_to_nsqw (infiles, outfiles, grid_size_in);
bigtoc

% Create a combined file
bigtic
bigfile='c:\temp\crap_all.sqw';
write_nsqw_to_sqw (outfiles, bigfile)
bigtoc



%=============================================
data.filename ='hello';
data.filepath = [];
data.title =[];
data.nfiles =3;
fout='c:\temp\crap.par';
fid=fopen(fout,'w');
write_sqw_main_header (fid, data)
fclose(fid);

fid=fopen(fout);
[tmp, mess] = get_sqw_main_header (fid);
fclose(fid);

%=============================================
% Test 32 bit integers
%=============================================
aa=rand(3,7);

fid=fopen('c:\temp\twonums.bin','w');
fwrite(fid, aa, 'float32');
fclose(fid);

fid=fopen('c:\temp\twonums.bin');
fseek(fid,48,'bof');
[raa,      count, ok, mess] = fread_catch(fid,[3,1],'float32'); if ~all(ok); return; end;
fclose(fid);
%=============================================
% Time to sort .v. time to check if in range
%=============================================
n=10000;
aa=rand(n,1);
bigtic
bb=aa(aa>0.5);
bigtoc(['Find top half for n=',num2str(n)])
bigtic
cc=sort(aa);
bigtoc(['Sort n=',num2str(n)])

%=============================================
% Test sort_pixels
%=============================================
% reference:    [urange,p,ix,npix]=sort_pixels(u,grid_size)
% development: [ix,npix,grid_size]=sort_pixels(u,urange,grid_size_in)

u=rand(4,100000);
u(3,:)=
urange=[0,0.2,0.2,0;0.8,0.8,0.8,0.8];
grid_size_in=2;

bigtic
[urange_ref,p_ref,ix_ref,npix_ref]=sort_pixels(u,grid_size_in);
bigtoc('old sort_pixels')

bigtic
step=(urange_ref(2,:)-urange_ref(1,:))./grid_size_in;
%urange = urange_ref + 0.1*[-step;step];
[ix,npix,grid_size]=sort_pixels_dev(u,urange,grid_size_in);
bigtoc('new sort_pixels')


% ==================================
% test find_irange_rot
% ==================================
urange=[0,2;0,2;0,2]';
rot=[1,1,0;-1,1,0;0,0,1]/sqrt(2);
trans=[0,0,0];
nn=100
p1=0:1/nn:2;
p2=0:1/nn:2;
p3=0:1/nn:2;
nel=length(p1)*length(p2)*length(p3)
tic;
irange = get_irange_rot(urange,rot,trans,p1,p2,p3);
toc;

% ==================================
% test find_irange
% ==================================





