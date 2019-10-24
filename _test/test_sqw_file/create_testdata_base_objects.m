function create_testdata_base_objects
% ***************************************************************
% Create the saved sqw and mat files - ** ONLY RERUN IN EXTREMIS!
%
% THESE FUNCTION WERE CREATED WITH HORACE V2.1.1.
% IF YOU RECREATE THEM, THEN YOU NEGATE THE VALUE OF THESE TESTS
% YOU SHOULD ONLY DO SO IF THERE IS A REWRITE OF THE SQW FILE FORMAT
% TO A STRUCTURE THAT CANNOT BE MADE BACKWARDS COMPATIBLE. HERE ONLY
% FOR LATER USE IN THIS UNLIKELY SCENARIO

% Create sqw objects and save to a mat file:
%   two different files, each with one contributing spe file:  f1_1  f2_1
%   two different files, each with two contributing spe files:  f1_2  f2_2
%   two different files, each with three contributing spe files:  f1_3  f2_3

en=-10:0.5:30;
par_file='96dets.par';
efix=50;
emode=1;
alatt=[4,5,6];
angdeg=[91,92,93];
u=[1,1,0];
v=[1,0.2,5];
psi=17;
omega=2;
dpsi=0.1;
gl=2;
gs=-0.5;
gridsize=5;

sqw_file=fullfile(tempdir,'f1_1.sqw');
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, gridsize)
randomdata(sqw_file);

psi=20;
sqw_file=fullfile(tempdir,'f2_1.sqw');
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, gridsize)
randomdata(sqw_file);

psi=[31,32];
sqw_file=fullfile(tempdir,'f1_2.sqw');
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, gridsize)
randomdata(sqw_file);

psi=[41,45];
sqw_file=fullfile(tempdir,'f2_2.sqw');
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, gridsize)
randomdata(sqw_file);

psi=[51,53,55];
sqw_file=fullfile(tempdir,'f1_3.sqw');
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, gridsize)
randomdata(sqw_file);

psi=[61,63.5,67.5];
sqw_file=fullfile(tempdir,'f2_3.sqw');
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, gridsize)
randomdata(sqw_file);

% Read objects into memory
f1_1=read_sqw(fullfile(tempdir,'f1_1.sqw'));
f2_1=read_sqw(fullfile(tempdir,'f2_1.sqw'));
f1_2=read_sqw(fullfile(tempdir,'f1_2.sqw'));
f2_2=read_sqw(fullfile(tempdir,'f2_2.sqw'));
f1_3=read_sqw(fullfile(tempdir,'f1_3.sqw'));
f2_3=read_sqw(fullfile(tempdir,'f2_3.sqw'));

% The objects were written from Horace v2.1.1, so need to add dummy instrument and sample fields
f1_1=convert_to_v3(f1_1);


save('testdata_base_objects.mat','f1_1','f2_1','f1_2','f2_2','f1_3','f2_3')


%------------------------------------------------------------------------------
function randomdata(file)
% Make random signal and error
w=read_sqw(file);
npix=size(w.data.pix,2);
w.data.pix(8,:)=10*rand(1,npix);
w.data.pix(9,:)=1+0.1*rand(1,npix);
w=recompute_bin_data(w);
save(w,file);

function wout=recompute_bin_data(w)
% Given sqw_type object, recompute w.data.s and w.data.e from the contents of pix array
%
%   >> wout=recompute_bin_data(w)

% See also average_bin_data, which uses en essentially the same algorithm. Any changes
% to the one routine must be propagated to the other.

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

wout=w;

% Get the bin index for each pixel
nend=cumsum(w.data.npix(:));
nbeg=nend-w.data.npix(:)+1;
nbin=numel(w.data.npix);
npixtot=nend(end);
ind=zeros(npixtot,1);
for i=1:nbin
    ind(nbeg(i):nend(i))=i;
end

% Accumulate signal
s=accumarray(ind,w.data.pix(8,:),[nbin,1])./w.data.npix(:);
wout.data.s=reshape(s,size(w.data.npix));
e=accumarray(ind,w.data.pix(9,:),[nbin,1])./(w.data.npix(:).^2);
wout.data.e=reshape(e,size(w.data.npix));
nopix=(w.data.npix(:)==0);
wout.data.s(nopix)=0;
wout.data.e(nopix)=0;

%------------------------------------------------------------------------------
function wout=convert_to_v3(w)
% Add dummy instrument and sample fields
wout=w;
if isstruct(wout.header)
    wout.header.instrument=struct;
    wout.header.sample=struct;
else
    for i=1:numel(wout.main_header.nfiles)
        wout.header{i}.instrument=struct;
        wout.header{i}.sample=struct;
    end
end
