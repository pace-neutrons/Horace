function [rlu_corr,alatt,angdeg,rotmat,distance,rotangle] = orient_crystal(rlu_notional,rlu_real,rlu_errors,alatt0,angdeg0,varargin)
% Given the list of reciprocal lattice points and their real hkl positions,
% identify U and B Bussing and Levy** matrices specifying the crystal lattice
% parameters and crystal orientation.


%** Busing, W. R and Levy, H. A Angle calculations for 3- and 4-circle {X}-ray and neutron
%  diffractometers,Acta Crystallographica 22 (4) 1967  pp457-464
%
%
%
% Optional input parameter:
%   alatt_init      Initial lattice parameters for start of refinement [a,b,c] (Angstroms)
%   angdeg_init     Initial lattice angles for start of refinement [alf,bet,gam] (deg)
%                  If one or both of alatt_init and angdeg_init are not given, then the corresponding
%                  reference lattice parmaeters are taken as the initial values for refinement.
%
% Keywords (more than one is permitted if not inconsistent)
%   fix_lattice     Fix all lattice parameters [a,b,c,alf,bet,gam]
%                  i.e. only allow crystal orientation to be refined
%   fix_alatt       Fix [a,b,c] but allow lattice angles alf, bet and gam to be refined
%                  together with crystal orientation
%   fix_angdeg      Fix [alf,bet,gam] but allow pattice parameters [a,b,c] to be refined
%                  together with crystal orientation
%   fix_alatt_ratio Fix the ratio of the lattice parameters as given by the values in
%                  lattice_init, but allow the overall scale of the lattice to be refined
%                  together with crystal orientation
%   fix_orient      Fix the crystal orientation i.e. only refine lattice parameters
%
% Finer control of refoinement of lattice parameters: instead of fix_lattice, fix_angdeg,... use
%   free_alatt      Array length 3 of zeros or ones, 1=free, 0=fixed
%                  e.g. ...,'free_alatt',[1,0,1],... allows only lattice parameter b to vary
%   free_angdeg     Array length 3 of zeros or ones, 1=free, 0=fixed
%                  e.g. ...,'free_lattice',[1,1,0],... fixes lattice angle gam buts allows alf and bet to vary
%
%
% Output:
% -------
%   rlu_corr        Conversion matrix to relate notional rlu to true rlu, accounting for the the
%                  refined crystal lattice parameters and orientation
%                       qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
%
%   alatt           Refined lattice parameters [a,b,c] (Angstroms)
%
%   angdeg          Refined lattice angles [alf,bet,gam] (degrees)
%
%   rotmat          Rotation matrix that relates crystal Cartesian coordinate frame of the refined
%                  lattice and orientation as a rotation of the initial crystal frame. Coordinates
%                  in the two frames are related by
%                       v(i)= rotmat(i,j)*v0(j)
%
%   distance        Distances between peak positions and points given by true indexes, in input
%                  argument rlu, in the refined crystal lattice. (Ang^-1)
%
%   rotangle        Angle of rotation corresponding to rotmat (to give a measure
%                  of the misorientation) (degrees)
%
% The output argument rlu_corr, together with the input alatt0 and angdeg0, are sufficient to compute
% the other output arguments. That is why Horace functions that use the output of this function will
% generally only require rlu_corr.
%
% EXAMPLES
%   Want to refine crystal orientation only:
%   >> rlu_corr=refine_crystal (rlu0, alatt0, angdeg0, rlu, 'fix_lattice')
%
%   Want to refine lattice parameters a,b,c as well as crystal orientation:
%   >> [rlu_corr,alatt]=refine_crystal (rlu0, alatt0, angdeg0, rlu, 'fix_angdeg')

small=1e-10;

flags={'fix_lattice','fix_alatt','fix_alatt_ratio','fix_angdeg','fix_orientation'};
[ok,mess,fix_lattice,fix_alatt,fix_alatt_ratio,fix_angdeg,fix_orientation] = parse_char_options(varargin,flags);
if ~ok
    error('ORIENT_CRYSTAL:invalid_argument',mess)
end

% % Check input arguments
% if size(rlu0,2)~=3 || size(rlu0,1)<2 || numel(size(rlu0))~=2
%     error('Must be at least two input reciprocal lattice vectors, each given as triples (h,k,l)')
% end
% if numel(size(rlu))~=2 || ~all(size(rlu0)==size(rlu))
%     error('Must be the same number of reciprocal lattice vectors in reference and new coordinate frames, each given as a triple (h,k,l)')
% end
% if ~all(isfinite(rlu0(:)))  % catch case of rlu not being found - a common input is from bragg_positions
%     error('One or more positions of the true Bragg peak positions (input argument ''rlu'') is not finite.')
% end
%
% if isnumeric(alatt0) && numel(alatt0)==3 && all(alatt0>0) && isnumeric(angdeg0) && numel(angdeg0)==3  && all(angdeg0>0)
%     lattice0=[alatt0(:)',angdeg0(:)'];
% else
%     error('Check reference lattice parameters')
% end

[base_triplets,ind_valid]= build_triplets_list(rlu_notional,'bragg indexes');
[real_triplets,ind_valid]= build_triplets_list(rlu_real,'peak positions',ind_valid);
[peak_errors,~]= build_triplets_list(rlu_errors,'peak errors',ind_valid);

G = cellfun(G_tensor,base_triplets,real_triplets,'UniformOutput',false);

% Check if initial lattice parameters for refinement, if given
lattice_init=lattice0;
if numel(args)>=1
    if numel(args{1})==3 && isnumeric(args{1}) && all(args{1}>0)
        lattice_init(1:3)=args{1}(:)';
    else
        error('Check initial lattice parameters ([a,b,c]) for refinement')
    end
end
if numel(args)==2
    if numel(args{2})==3 && isnumeric(args{2}) && all(args{2}>0)
        lattice_init(4:6)=args{2}(:)';
    else
        error('Check initial lattice angles ([alf,bet,gam]) for refinement')
    end
end
if numel(args)>2
    error('Check number of input arguments')
end

% Check options
if present.free_alatt
    if islognum(opt.free_alatt) && numel(opt.free_alatt)==3
        if opt.fix_lattice || opt.fix_alatt || opt.fix_alatt_ratio
            error('Cannot use the option ''free_alatt'' with other keywords fixing lattice parameters a,b,c')
        end
    else
        error('Check value of ''free_alatt'' option')
    end
end

if present.free_angdeg
    if islognum(opt.free_angdeg) && numel(opt.free_angdeg)==3
        if opt.fix_lattice || opt.fix_angdeg
            error('Cannot use the option ''free_angdeg'' with other keywords fixing lattice parameters alf,bet,gam')
        end
    else
        error('Check value of ''free_angdeg'' option')
    end
end

if opt.fix_lattice && ...
        ((present.fix_alatt && ~opt.fix_alatt) || (present.fix_angdeg && ~opt.fix_angdeg) || (present.fix_alatt_ratio && ~opt.fix_alatt_ratio))
    error('Check consistency of options to fix lattice parameters')
elseif opt.fix_alatt && (present.fix_alatt_ratio && ~opt.fix_alatt_ratio)
    error('Check consistency of options to fix lattice parameters')
end


% Perform calculations
% --------------------
[b0,arlu,angrlu,mess] = bmatrix(lattice0(1:3),lattice0(4:6));
if ~isempty(mess), error(mess), end

[binit,arlu,angrlu,mess] = bmatrix(lattice_init(1:3),lattice_init(4:6));
if ~isempty(mess), error(mess), end

vcryst0=b0*rlu0';       % crystal Cartesian coords in reference lattice
vcryst_init=binit*rlu'; % crystal Cartesian coords in initial lattice

% Check lengths are all non-zero
lensqr0=sum(vcryst0.^2,1);
lensqr_init=sum(vcryst_init.^2,1);
if any(lensqr0<small)||any(lensqr_init<small), error('Check none of the reciprocal lattice vectors are at the origin'), end

% Get initial estimate of rotation vector
[rotmat_ave,rotvec_ave] = rotmat_average (vcryst0,vcryst_init);
if isempty(rotmat_ave)
    error('Check reciprocal lattice vectors in reference and new coordinate frames are not all collinear')
end

% Fit
% ---
nv=size(rlu,1);
vcryst0_3=repmat(vcryst0',3,1);     % Treble the number of vectors, as will compute three components of deviations

pars=[lattice_init,rotvec_ave(:)'];
pfree=[1,1,1,1,1,1,1,1,1];
pbind={};

if opt.fix_alatt || opt.fix_lattice
    pfree(1:3)=[0,0,0];
elseif opt.fix_alatt_ratio
    pbind={{2,1},{3,1}};
elseif present.free_alatt
    pfree(1:3)=opt.free_alatt;
end

if opt.fix_angdeg || opt.fix_lattice
    pfree(4:6)=[0,0,0];
elseif present.free_angdeg
    pfree(4:6)=opt.free_angdeg;
end

if opt.fix_orientation
    pfree(7:9)=[0,0,0];
end

[distance,fitpar] = multifit(vcryst0_3, zeros(3*nv,1), 0.01*ones(3*nv,1),...
    @reciprocal_space_deviation, {pars,rlu}, pfree, pbind,'list',0,'fit',[1e-4,50,-1e-6]);

% Had a problem when refining RbMnF3 that the fit parameters ended up have complex
% component that was less than the intrinsic eps. Catch this case and ignore
if ~isreal(fitpar.p)
    cmplx=imag(fitpar.p);
    if all(cmplx<10*eps)
        fitpar.p=real(fitpar.p);
        distance=real(distance);
    else
        error('Problem refining crystal orientation: imaginary fit parameters')
    end
end

rotvec=fitpar.p(7:9);
rotangle=norm(rotvec)*(180/pi);
rotmat=rotvec_to_rotmat2(rotvec);
alatt=fitpar.p(1:3);
angdeg=fitpar.p(4:6);
distance=sqrt(sum(reshape(distance,3,nv).^2,1))';

[b,arlu,angrlu,mess] = bmatrix(alatt,angdeg);
if ~isempty(mess), error(mess), end
rlu_corr=b\rotmat*b0;


%============================================================================================================
% Distance function for fitting
%============================================================================================================
function dist = reciprocal_space_deviation (x1,x2,x3,p,rlu)
% Function to calculate the distance between a point in reciprocal space and corresponding point in a reference orthonormal frame
%
%   >> dist = reciprocal_space_deviation (v0,p,rlu)
%
% Input:
% -------
%   x1,x2,x3    Array of coordinates in reference crystal Cartesian coordinates
%              This is n x 3 array repeated three times along first dimension
%   p           Parameters that can be fitted: [a,b,c,alf,bet,gam,theta1,theta2,theta3]
%                   a,b,c           lattice parameters (Ang)
%                   alf,bet,gam     lattice angles (deg)
%                   theta1,theta2,theta3    components of rotation vector linking
%                                          crystal Cartesian coordinates
%                                           v(i)=R_theta(i,j)*v0(j)
%   rlu         Components along a*, b*, c* in lattice defined by p (n x 3 array)
%
% Output:
% -------
%   dist        Column vector of deviations along x,y,z axes of reference crystal
%              Cartesian coordinates for each of the vectors rlu in turn

nv=size(rlu,1);

alatt=p(1:3);
angdeg=p(4:6);
rotvec=p(7:9);

b=bmatrix(alatt,angdeg);
R=rotvec_to_rotmat2(rotvec);
rlu_to_cryst0=R\b;
v=(rlu_to_cryst0*rlu')';
dv=v-[x1(1:nv),x2(1:nv),x3(1:nv)];

dist=reshape(dv',3*nv,1)./repmat(sqrt(sum(v.^2,2)),3,1);


%============================================================================================================
% Functions to compute average rotation matrix
%============================================================================================================
function [rotmat_ave,rotvec_ave] = rotmat_average (v0,v)
% Get estimate of 'average' rotation matrix relating two frames S0 and S
%
%   >> rotmat = rotmat_average (v0,v)
%
%   v0      Coords of vectors in frame S0 (3 x n array)
%   v       Coords of same vectors in grame S (3 x n array)
%
%   rotmat  Rotation matrix that 'on average' for each column of v0 and v satisfies
%               v(i) = rotmat(i,j)*v0(j)
%           We have errors on the precise values of v0 and v which is why this will not be exact

nv=size(v0,2);
if nv<2, error('Must have at least two vectors'), end
rotvec=zeros(3,nv*(nv-1)/2);
iin=zeros(1,nv*(nv-1)/2);
jin=zeros(1,nv*(nv-1)/2);
ok=false(1,nv*(nv-1)/2);
k=0;
for i=1:nv
    for j=i+1:nv
        k=k+1;
        iin(k)=i; jin(k)=j;
        [rotmat,ok(k)]=rotmat_from_uv(v0(:,i),v0(:,j),v(:,i),v(:,j));
        if ok(k), rotvec(:,k)=rotmat_to_rotvec2(rotmat); end
    end
end

n_ok=sum(ok);
if sum(ok)>0
    rotvec_ave=sum(rotvec(:,ok),2)/n_ok;
    rotmat_ave=rotvec_to_rotmat2(rotvec_ave);
else
    rotmat_ave=[];
    rotvec_ave=[];
end

%----------------------------------------------------------------------------------------
function [rotmat,ok,mess] = rotmat_from_uv (u0,v0,u,v)
% Get rotation matrix from two non-collinear vectors u,v expressed in two frames S0 and s
%
%   >> [rotmat,ok] = rotmat_from_uv (u0,v0,u,v)
%
%   u0, v0  Coordinates of two vectors in frame S0
%   u, v    Coordinates of same vectors in frame S
%
%   rotmat  Matrix that relates a vector expressed in the two frames as
%               r(i) = rotmat(i,j)*r0(j)


[xyz0,ok,mess]=orthonormal_set(u0,v0);
if ~ok, rotmat=[]; return, end
[xyz,ok,mess]=orthonormal_set(u,v);
if ~ok, rotmat=[]; return, end
rotmat=xyz/xyz0;

%----------------------------------------------------------------------------------------
function [xyz,ok,mess]=orthonormal_set(u,v)
small=1.0e-10;
if norm(u)<small || norm(v)<small
    xyz=[]; ok=false; mess='one or more input vectors has zero length'; return
end
x=u/norm(u);
y=v/norm(v);
z=cross(x,y);
if norm(z)>small
    z=z/norm(z);
else
    xyz=[]; ok=false; mess='two input vectors are collinear'; return
end
y=cross(z,x);
y=y/norm(y);    % to account for rounding errors

xyz=[x,y,z];
ok=true;
mess='';

function G=G_tensor(A,B)
UB = (A/B);
B = UB'*UB;
G = inv(B);

function [triplets,ind_valid]= build_triplets_list(vectors,name,varargin)
if numel(vectors) < 9
    error('ORIENT_CRYSTAL:invalid_argument',...
        'input %s has to have least 3 vectors',name);
end
if nargin>2
    ind_valid = varargin{1};
else
    n_vectors = size(vectors,1);
    vec_ind = 1:n_vectors;
    ind = nchoosek(vec_ind,3);
    vor = arrayfun(@(i,j,k)fvor(vectors,i,j,k),ind(:,1),ind(:,2),ind(:,3));
    ind_valid = vor>10*eps;
    ind_valid = ind(ind_valid,:);
end
n_triplets = size(ind_valid,1);
if n_triplets < 1
    error('ORIENT_CRYSTAL:invalid_argument',...
        'input %s need to have at least 3 vectors not located on a sinvle plain',name);
    
end
triplets = arrayfun(@(i)([vectors(ind_valid(i,1),:);vectors(ind_valid(i,2),:);vectors(ind_valid(i,3),:)]),...
    1:n_triplets,'UniformOutput',false);


function vor = fvor(vector,ind1,ind2,ind3)
v1 = vector(ind1,:);
v2 = vector(ind2,:);
v3 = vector(ind3,:);
vor =abs(cross(v1,v2)*v3');

