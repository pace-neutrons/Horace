function [alignment_info, error_estimate] = refine_crystal(rlu_actual,alatt0,angdeg0,rlu_expected,varargin)
% Refine crystal orientation and lattice parameters
%
%   >> alignment_info = refine_crystal(rlu_actual, alatt0, angdeg0, rlu_expected)
%   >> alignment_info = refine_crystal(rlu_actual, alatt0, angdeg0, rlu_expected, alatt_init, angdeg_init)
% Return estimates of the error in the crystal alignment fit
%   >> [..., error_estimate] = refine_crystal( ... )
%
% In addition, there are keyword arguments to control the refinement e.g.
%   >> alignment_info = refine_crystal(..., 'fix_angdeg')
%   >> alignment_info = refine_crystal(..., 'free_alatt', [1,0,1])
%
%
% This function is used to get the information necessary to relate the coordinates of a vector (h0,k0,l0)
% as expressed in an initial or reference lattice to the coordinates (h,k,l) in the true lattice.
% It does this by taking a set of points (h0,k0,l0) and the corresponding set of true indices
% (h,k,l), and refining the lattice parameters and orientation. The refined lattice parameters
% are also returned.
%
% The output from this function can be used to correct the crystal orientation and lattice parameters
% in Horace. Type >> help change_crystal_horace for more details.
%
% Input:
% ------
%   rlu_actual      Positions of reciprocal lattice vectors as h,k,l in reference lattice
%                   (n x 3 matrix, n=no. reflections)
%   alatt0          Reference lattice parameters [a,b,c] (Angstroms), which
%                   would provide bragg peaks at rlu_actual
%   angdeg0         Reference lattice angles [alph,bet,gam] (deg), which
%                   would provide bragg peaks at rlu_actual
%   rlu_expected    True indices (the indices would be expected in aligned lattice)
%                   of reciprocal lattice vectors (n x 3 matrix)
%
% Optional input parameter:
%   alatt_init     Initial lattice parameters for start of refinement [a,b,c] (Angstroms)
%   angdeg_init    Initial lattice angles for start of refinement [alph,bet,gam] (deg)
%                  If one or both of alatt_init and angdeg_init are not given, then the corresponding
%                  reference lattice parameters are taken as the initial values for refinement.
%
% Keywords (more than one is permitted if not inconsistent)
%   fix_lattice     Fix all lattice parameters [a,b,c,alph,bet,gam]
%                   i.e. only allow crystal orientation to be refined
%   fix_alatt       Fix [a,b,c] but allow lattice angles alph, bet and gam to be refined
%                   together with crystal orientation
%   fix_angdeg      Fix [alph,bet,gam] but allow lattice parameters [a,b,c] to be refined
%                   together with crystal orientation
%   fix_alatt_ratio Fix the ratio of the lattice parameters as given by the values in
%                   lattice_init, but allow the overall scale of the lattice to be refined
%                   together with crystal orientation
%   fix_orient      Fix the crystal orientation i.e. only refine lattice parameters
%
% Finer control of refinement of lattice parameters: instead of fix_lattice, fix_angdeg,... use
%   free_alatt      Array length 3 of zeros or ones, 1=free, 0=fixed
%                   e.g. ...,'free_alatt',[1,0,1],... allows only lattice parameter b to vary
%   free_angdeg     Array length 3 of zeros or ones, 1=free, 0=fixed
%                   e.g. ...,'free_lattice',[1,1,0],... fixes lattice angle gam buts allows alph and bet to vary
%   bind_alatt      Cell array of cell arrays following multifit convention of fixing the ratio of one lattice
%                   parameter to another, e.g. fix the ratio of a and b to be 1, but have c independent: {{2,1}}
%                   IMPORTANT - YOU MUST USE THIS ARGUMENT IN CONJUNCTION
%                   WITH free_alatt option - if you fix the ratio of a and
%                   b and allow the value to vary, but fix c then you would
%                   use free_alatt=[1,1,0]
%
%
% Output:
% -------
%  alignment_info  -- helper class, which contains information, necessary
%                     for the crystal alignment. The class contains the
%                     following fields, calculated by the procedure:
%
%      alatt          Refined lattice parameters [a,b,c] (Angstroms)
%      angdeg         Refined lattice angles [alph,bet,gam] (degrees)
%      rotmat         Rotation matrix that relates crystal Cartesian coordinate frame of the refined
%                     lattice and orientation as a rotation of the initial crystal frame. Coordinates
%                     in the two frames are related by
%                       v(i)= rotmat(i,j)*v0(j)
%      distance       Distances between peak positions and points given by true indexes, in input
%                     argument rlu_expected, in the refined crystal lattice. (Ang^-1)
%
%      rotangle       Angle of rotation corresponding to rotmat (to give a measure
%                     of the misorientation) (degrees)
%
% error_estimate  --  Structure containing estimated errors on the fit parameters as a result of refinement
%
%      alatt          Error on refined lattice parameters [a,b,c] (Angstroms)
%      angdeg         Error on refined lattice angles [alph,bet,gam] (degrees)
%      rotmat         Error on rotation matrix
%
% EXAMPLES
%   Want to refine crystal orientation only:
%   >> alignment_info =refine_crystal (rlu_actual, alatt0, angdeg0, rlu_expected, 'fix_lattice')
%    the alignment info would contain the initial lattice values i.e.  alatt0, angdeg0
%
%   Want to refine lattice parameters a,b,c as well as crystal orientation:
%   >> alignment_info=refine_crystal (rlu_actual, alatt0, angdeg0, rlu_expected, 'fix_angdeg')
%    the alignment info would contain the initial lattice angles i.e.  angdeg0

small=1e-10;

arglist=struct('fix_lattice',0,'fix_alatt',0,'fix_alatt_ratio',0,'fix_angdeg',0,'fix_orientation',0,'free_alatt',[1,1,1],'free_angdeg',[1,1,1],...
    'bind_alatt',0);
flags={'fix_lattice','fix_alatt','fix_alatt_ratio','fix_angdeg','fix_orientation'};
[args,opt,present] = parse_arguments(varargin,arglist,flags);

% if the options are consistent
check_options_consistency(present,opt);

% Check input arguments
lattice0 = check_input_arguments(rlu_actual,rlu_expected,alatt0,angdeg0);

% Check initial lattice parameters for refinement, if given, are acceptable
lattice_init = check_additional_args(lattice0,args{:});


% Perform calculations
% --------------------
b0    = bmatrix(lattice0(1:3),lattice0(4:6));
binit = bmatrix(lattice_init(1:3),lattice_init(4:6));

vcryst0=b0*rlu_actual';       % crystal Cartesian coords in reference lattice
vcryst_init=binit*rlu_expected'; % crystal Cartesian coords in initial lattice

% Check lengths are all non-zero
lensqr0=sum(vcryst0.^2,1);
lensqr_init=sum(vcryst_init.^2,1);
if any(lensqr0<small)||any(lensqr_init<small)
    error('HORACE:lattice_functions:invalid_argument', ...
        'Check none of the reciprocal lattice vectors are at the origin')
end

% Get initial estimate of rotation vector
[rotmat_ave,rotvec_ave] = rotmat_average (vcryst0,vcryst_init);
if isempty(rotmat_ave)
    error('HORACE:lattice_functions:invalid_argument', ...
        'Check reciprocal lattice vectors in reference and new coordinate frames are not all collinear')
end

% Fit
% ---
nv=size(rlu_expected,1);
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

if present.bind_alatt
    pbind=opt.bind_alatt;
end

if opt.fix_angdeg || opt.fix_lattice
    pfree(4:6)=[0,0,0];
elseif present.free_angdeg
    pfree(4:6)=opt.free_angdeg;
end

if opt.fix_orientation
    pfree(7:9)=[0,0,0];
end

kk = multifit (vcryst0_3, zeros(3*nv,1), 0.01*ones(3*nv,1));
% function to caclulate distance between actual and expected bragg peak
% positions in reciprocal space.
kk = kk.set_fun (@reciprocal_space_deviation, {pars,rlu_expected}, pfree, pbind);
kk = kk.set_options ('list', 0);
kk = kk.set_options ('fit',[1e-4,50,-1e-6]);
% disable possible parallel fitting as it does not make sence for
% refine_crystal data. The fitting for these data is faster serially.
clOb = set_temporary_config_options('hpc_config','parallel_multifit',false);
[distance,fitpar] = kk.fit();


% Had a problem when refining RbMnF3 that the fit parameters ended up have complex
% component that was less than the intrinsic eps. Catch this case and ignore
if ~isreal(fitpar.p)
    cmplx=imag(fitpar.p);
    if all(cmplx<10*eps)
        fitpar.p=real(fitpar.p);
        distance=real(distance);
    else
        error('HORACE:lattice_functions:runtime_error', ...
            'Problem refining crystal orientation: imaginary fit parameters')
    end
end


rotvec = fitpar.p(7:9);
alatt  = fitpar.p(1:3);
angdeg = fitpar.p(4:6);
distance=sqrt(sum(reshape(distance,3,nv).^2,1))';

error_estimate = struct('alatt', fitpar.sig(1:3), ...
    'angdeg', fitpar.sig(4:6), ...
    'rotvec', fitpar.sig(7:9));

alignment_info = crystal_alignment_info(alatt,angdeg,rotvec,distance);


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
if nv<2
    error('HORACE:lattice_functions:invalid_argument', ...
        'Must have at least two vectors')
end
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
%--------------------------------------------------------------------------
function check_options_consistency(present,opt)
% Check options are consistent
if present.free_alatt
    if islognum(opt.free_alatt) && numel(opt.free_alatt)==3
        if opt.fix_lattice || opt.fix_alatt || opt.fix_alatt_ratio
            error('HORACE:lattice_functions:invalid_argument', ...
                'Cannot use the option ''free_alatt'' with other keywords fixing lattice parameters a,b,c')
        end
    else
        error('HORACE:lattice_functions:invalid_argument', ...
            'Check value of ''free_alatt'' option')
    end
end

if present.bind_alatt
    if ~present.free_alatt
        error('HORACE:lattice_functions:invalid_argument', ...
            'Must use bind_alatt in conjunction with free_alatt option - type "help refine_crystal" for details');
    end
    if ~iscell(opt.bind_alatt)
        error('HORACE:lattice_functions:invalid_argument', ...
            'bind_alatt input must be a cell array - type "help refine_crystal" for details');
    end
    for i=1:numel(opt.bind_alatt)
        if ~iscell(opt.bind_alatt{i})
            error('HORACE:lattice_functions:invalid_argument', ...
                'bind_alatt must be a cell array of cell array(s)');
        elseif numel(opt.bind_alatt{i})~=2
            error('HORACE:lattice_functions:invalid_argument', ...
                'bind_alatt must be a cell array of cell array(s). The inner cell arrays must have only 2 (integer) elements in range 1 to 3');
        elseif opt.bind_alatt{i}{1}>3 || opt.bind_alatt{i}{1}<1 || opt.bind_alatt{i}{2}>3 || opt.bind_alatt{i}{2}<1
            error('HORACE:lattice_functions:invalid_argument', ...
                'bind_alatt must be a cell array of cell array(s). The inner cell arrays must have only 2 (integer) elements in range 1 to 3');
        else
            for j=1:2
                if opt.free_alatt(opt.bind_alatt{i}{j})==0
                    error('HORACE:lattice_functions:invalid_argument', ...
                        'If one lattice parameter is bound to another then free_alatt must be =1 for both of them');
                end
            end
        end
    end
end

if present.free_angdeg
    if islognum(opt.free_angdeg) && numel(opt.free_angdeg)==3
        if opt.fix_lattice || opt.fix_angdeg
            error('HORACE:lattice_functions:invalid_argument', ...
                'Cannot use the option ''free_angdeg'' with other keywords fixing lattice parameters alph,bet,gam')
        end
    else
        error('HORACE:lattice_functions:invalid_argument', ...
            'Check value of ''free_angdeg'' option')
    end
end

if opt.fix_lattice && ...
        ((present.fix_alatt && ~opt.fix_alatt) || (present.fix_angdeg && ~opt.fix_angdeg) || (present.fix_alatt_ratio && ~opt.fix_alatt_ratio))
    error('HORACE:lattice_functions:invalid_argument', ...
        'Check consistency of options to fix lattice parameters')
elseif opt.fix_alatt && (present.fix_alatt_ratio && ~opt.fix_alatt_ratio)
    error('HORACE:lattice_functions:invalid_argument', ...
        'Check consistency of options to fix lattice parameters')
end
%
function lattice0 = check_input_arguments(rlu_actual,rlu_expected,alatt0,angdeg0)
if size(rlu_actual,2)~=3 || size(rlu_actual,1)<2 || numel(size(rlu_actual))~=2
    error('HORACE:lattice_functions:invalid_argument', ...
        'Must be at least two input reciprocal lattice vectors, each given as triples (h,k,l)')
end
if numel(size(rlu_expected))~=2 || ~all(size(rlu_actual)==size(rlu_expected))
    error('HORACE:lattice_functions:invalid_argument', ...
        'Must be the same number of reciprocal lattice vectors in reference and new coordinate frames, each given as a triple (h,k,l)')
end
if ~all(isfinite(rlu_actual(:)))  % catch case of rlu_expected not being found - a common input is from bragg_positions
    error('HORACE:lattice_functions:invalid_argument', ...
        'One or more positions of the true Bragg peak positions (input argument ''rlu_expected'') is not finite.')
end

if isnumeric(alatt0) && numel(alatt0)==3 && all(alatt0>0) && isnumeric(angdeg0) && numel(angdeg0)==3  && all(angdeg0>0)
    lattice0=[alatt0(:)',angdeg0(:)'];
else
    error('HORACE:lattice_functions:invalid_argument', ...
        'Check reference lattice parameters')
end
%
function lattice_init = check_additional_args(lattice0,varargin)
lattice_init=lattice0;
if numel(varargin)>=1
    if numel(varargin{1})==3 && isnumeric(varargin{1}) && all(varargin{1}>0)
        lattice_init(1:3)=varargin{1}(:)';
    else
        error('HORACE:lattice_functions:invalid_argument', ...
            'Initial lattice parameters ([a,b,c]) should contan 3-vector of initial lattice parameters to fit.\n It is: %s', ...
            disp2str(varargin{1}))
    end
end
if numel(varargin)==2
    if numel(varargin{2})==3 && isnumeric(varargin{2}) && all(varargin{2}>0)
        lattice_init(4:6)=varargin{2}(:)';
    else
        error('HORACE:lattice_functions:invalid_argument', ...
            'Initial lattice angles ([alph,bet,gam]) should contan 3-vector of initial lattice angles to fit.\n It is: %s', ...
            disp2str(varargin{2}))
    end
end
if numel(varargin)>2
    error('HORACE:lattice_functions:invalid_argument', ...
        'Incorrect number of input arguments: (%d). Should be from 0 to 2', ...
        numel(varargin));
end
