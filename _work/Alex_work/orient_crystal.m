function [rlu_corr,alatt,angdeg,rotmat] = orient_crystal(rlu_index,rlu_real,rlu_errors,alatt0,angdeg0,varargin)
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
if ~fix_lattice
    [alatt,angdeg] = refine_lattice(rlu_index,rlu_real,rlu_errors,alatt0,angdeg0,fix_alatt,fix_alatt_ratio,fix_angdeg);
    B0 = bmatrix(alatt0,angdeg0);
    B = bmatrix(alatt,angdeg);
    b_corr = B/B0;
else
    alatt = alatt0;
    angdeg=angdeg0;
    b_corr = eye(3);
end
if fix_orientation
    rotmat = eye(3);
else
    rotmat = build_rotation(rlu_index,rlu_real,rlu_errors,alatt,angdeg);
end

rlu_corr=rotmat*b_corr;


%============================================================================================================
% Functions to compute average rotation matrix
%============================================================================================================
function rot_mat = build_rotation(rlu_index,rlu_real,rlu_errors,alatt,angdeg)

B =bmatrix(alatt,angdeg);
r_t = (B*rlu_index');
r_k = (B*rlu_real');
%r_k_err = (B*rlu_errors');

[Tc,valid] = build_othro_sets(r_t);
Tphi = build_othro_sets(r_k,valid);

Ulist = cellfun(@(tf,tc)(tf*tc'),Tphi,Tc,'UniformOutput',false);
rotvec_list =cellfun(@rotmat_to_rotvec2,Ulist,'UniformOutput',false); 

rotvec = reshape([rotvec_list{:}],3,numel(rotvec_list));
rotvec_ave = sum(rotvec,2)/numel(rotvec_list);
rot_mat=rotvec_to_rotmat2(rotvec_ave);


function [ortho,valid] = build_othro_sets(vectors,varargin)
% Build orthonormal sets based on all non-parrallel pairs of input vectors
%
n_vectors = size(vectors,2);
vec_ind = 1:n_vectors;
ind = nchoosek(vec_ind,2);

v_sizes= sqrt(sum(vectors.*vectors));

ortho = arrayfun(@(i,j)build_ortho(vectors,v_sizes,i,j),ind(:,1),ind(:,2),...
    'UniformOutput',false);
if nargin ==1
    valid =cellfun(@(x)(~isempty(x)),ortho);
else
    valid = varargin{1};
end
ortho = ortho(valid);


function ortho_set = build_ortho(vectors,v_sizes,ind1,ind2)

e1 = vectors(:,ind1)/v_sizes(ind1);
v2 = vectors(:,ind2);

v2p = v2 - (v2'*e1)*e1; % The Gram–Schmidt orthonormalization
%sz = sqrt(sum(v2p.*v2p));
sz = sqrt(v2p'*v2p);
if sz<1.e-3
    ortho_set = [];
    return;
end
e2 = v2p/sz;
e3= cross(e1,e2);
det = e3'*e3;
if abs(det-1)>10*eps
    error('ORIENT_CRYSTAL:runtime_error',...
        'can not build orthogonal set from vectors [%f,%f,%f] and [%f,%f,%f]',...
        vectors(:,ind1),vectors(:,ind2));
end
ortho_set = [e1,e2,e3];




function [alatt,angdeg]=refine_lattice(rlu_index,rlu_real,rlu_errors,alatt0,angdeg0,fix_alatt,fix_alatt_ratio,fix_angdeg)
% refine lattice according to G-tensor procedure
%
% Entirely worng statistics
% needs mprovement either as described in
% Acta Cryst. A 1970 26(1) pp97-101
% or just by fitting to minimize the B'*B deviation from an average
%
B0 =bmatrix(alatt0,angdeg0);
r_k = (B0*rlu_real');
r_k_err = (B0*rlu_errors');
%
[base_triplets,ind_valid]= build_triplets_list(rlu_index','bragg indexes');
[rk_triplets,ind_valid]= build_triplets_list(r_k,'peak positions',ind_valid);
[rk_errors,~]= build_triplets_list(r_k_err,'peak errors',ind_valid);

G = cellfun(@G_tensor,rk_triplets,base_triplets,'UniformOutput',false);
latPar = cellfun(@get_lattice_fromG,G,'UniformOutput',false);
latPar = reshape([latPar{:}],6,numel(latPar));
lattice0 =  sum(latPar,2)/size(latPar,2);
alatt = lattice0(1:3);
angdeg= lattice0(4:6);


function G=G_tensor(h_phi,h_i)
UB = h_phi/h_i; % UB = h_phi*inv(h_i);
Gi = UB'*UB;
G = inv(Gi);

function [triplets,ind_valid]= build_triplets_list(vectors,name,varargin)
if numel(vectors) < 9
    error('ORIENT_CRYSTAL:invalid_argument',...
        'input %s has to have least 3 vectors',name);
end
n_vectors = size(vectors,2);
vec_ind = 1:n_vectors;
ind = nchoosek(vec_ind,3);
if nargin>2
    ind_valid = varargin{1};
else
    det = arrayfun(@(i,j,k)fvor(vectors,i,j,k),ind(:,1),ind(:,2),ind(:,3));
    ind_valid = det>10*eps;
end
ind = ind(ind_valid,:);

n_triplets = size(ind,1);
if n_triplets < 1
    error('ORIENT_CRYSTAL:invalid_argument',...
        'input %s need to have at least 3 vectors not located on a sinvle plain',name);
    
end
triplets = arrayfun(@(i)([vectors(:,ind(i,1))';vectors(:,ind(i,2))';vectors(:,ind(i,3))']'),...
    1:n_triplets,'UniformOutput',false);


function vor = fvor(vector,ind1,ind2,ind3)
v1 = vector(:,ind1)';
v2 = vector(:,ind2)';
v3 = vector(:,ind3)';
vor =abs(cross(v1,v2)*v3');

function alatt_angdeg=get_lattice_fromG(G)
% invert metric tensor according to Bussing Levy procedure
alatt= sqrt([G(1,1),G(2,2),G(3,3)]);
cosang = [G(2,3)/(alatt(2)*alatt(3)),G(1,3)/(alatt(1)*alatt(3)),G(1,2)/(alatt(1)*alatt(2))];
alatt = 2*pi*alatt;
angdeg = acosd(cosang);
alatt_angdeg = [alatt,angdeg];