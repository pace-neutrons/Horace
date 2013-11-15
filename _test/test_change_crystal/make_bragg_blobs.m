function weight = make_bragg_blobs (qh,qk,ql,en,p,lattice0,lattice,rotvec)
% Blobs at Bragg positions, but on a lattice that is rotated and scaled w.r.t. input lattice
%
%   >> weight = make_bragg_blobs (qh,qk,ql,en,p,lattice0,lattice,rotvec)
%
%   qh,qk,ql,en Arrays of h,k,l,e in the reference lattice
%   p           Array of parameters [q_fwhh,e_fwhh]:
%                   q_fwhh  FWHH of 3D Gaussian in reciprocal space (Ang)
%                   e_fwhh  FWHH in energy (meV)
%
%   lattice0    [a,b,c,alf,bet,gam] lattice parameters (Ang and deg) of reference lattice
%   lattice     [a,b,c,alf,bet,gam] lattice parameters (Ang and deg) of true lattice
%   rotvec      Rotation vector [th1,th2,th3] (rad)
%
% Author: T.G.Perring

qsig=p(1)/sqrt(log(256));
esig=p(2)/sqrt(log(256));

% Conversion matrix to turn h,k,l into correponding values for the lattice defined by parameters
[b0,arlu,angrlu,mess] = bmatrix(lattice0(1:3),lattice0(4:6));
if ~isempty(mess), error(mess), end

[b,arlu,angrlu,mess] = bmatrix(lattice(1:3),lattice(4:6));
if ~isempty(mess), error(mess), end

R=rotvec_to_rotmat2(rotvec');
rlu_corr=b\(R*b0);

% Get h,k,l in new lattice and get weight
qrlu=rlu_corr*[qh(:),qk(:),ql(:)]';
dqrlu=qrlu-round(qrlu);
dq=b*dqrlu;     % convert back to orthonormal frame
weight=exp(-(sum((dq/qsig).^2,1) + (en(:)'/esig).^2)/2);
weight=reshape(weight,size(qh));
