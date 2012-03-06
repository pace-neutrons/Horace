function fake_data(indir,parfile,sqw_file,ei,emode,alatt,angdeg,u,v,psi_min,psi_max,...
    omega,dpsi,gl,gs)
%
% Function to make a fake sqw data file so that you can see what range of
% reciprocal space will be covered for a particular indicent energy and
% range of angles.
%
% fake_data(indir,parfile,sqw_file,ei,emode,alatt,angdeg,u,v,psi_min,psi_max,...
%    omega,dpsi,gl,gs);
%
% INPUTS:   indir - directory in which the fake data (SPE and SQW files)
%                   will be created
%           parfile - detector parameter file for the instrument used
%           sqw_file - file name (without path) of fake sqw file
%           ei - incident energy in meV
%           emode - 1 for direct geometry, 2 for indirect geometry
%           alatt - lattice parameters in form [a,b,c]
%           angdeg - lattice angles in form [alpha,beta,gamma]
%           u - direction of crystal parallel to ki
%           v - direction of crystal perpendicular to ki and in horizontal
%           plane
%           psi_min - minimum value of psi (crystal's rotation from
%           orientation defined by u and v)
%           psi_max - maximum value of psi
%           omega / dpsi / gl / gs - various goniometer angles, defined as
%           in gen_sqw (type help gen_sqw for more info, or see the Horace
%           manual).
%
% Note that this function will create 20 fake spe files (with all detectors
% registering 1 count) corresponding to 20 steps between psi_min and
% psi_max. The energy binning will be such that there are 10 steps from
% -ei/10 to +9ei/10. This is done to ensure faster execution of the
% function, and not to fill up your hard disk with fake data.
%     

%=====================
%Do some checks of the input formats before starting:
if ~isdir(indir)
    error('Check that the input directory exists');
end
if (exist(parfile,'file'))==0
    error('Check par file name');
end
if numel(alatt)~=3 || numel(angdeg)~=3
    error('Check that alatt and angdeg are vectors with 3 elements');
end
if numel(u)~=3 || numel(v)~=3
    error('Check that u and v are vectors with 3 elements');
end
if psi_min>=psi_max
    error('psi_min must be less than psi_max');
end
if psi_max>360
    error('psi_max must be less than 360');
end


%=====================
%Now make the fake data:
par_info= get_par(parfile);
[nrow,ncol]=size(par_info);
ndet=ncol;
%Calculate ndet (no. of detectors) from par file:

nfiles=20;
psi=linspace(psi_min,psi_max,nfiles);

%Make fake spe files
for i=1:20
    filestring=['dummy',num2str(i),'.spe'];
    fake_spe(ndet,-1*(ei/10),ei/20,(9*ei/10),filestring,indir,psi(i));
end

%Now generate the fake sqw file:
nfiles=20;
psi=linspace(psi_min,psi_max,nfiles);
spe_file=cell(1,nfiles);
for i=1:length(psi)
    spe_file{i}=fullfile(indir,['dummy',num2str(i),'.spe']);
    tmp_file{i}=fullfile(indir,['dummy',num2str(i),'.tmp']);
end
sqw_file=fullfile(indir,sqw_file);
gen_sqw(spe_file, parfile, sqw_file, ei, emode, alatt, angdeg, ...
    u, v, psi, omega, dpsi, gl, gs);