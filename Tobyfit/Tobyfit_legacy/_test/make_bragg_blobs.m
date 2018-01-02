function weight = make_bragg_blobs_2 (qh,qk,ql,en,p,lattice0,lattice,rotvec)
% Blobs at Bragg positions, but on a lattice that is rotated and scaled w.r.t. input lattice
%
%   >> weight = make_bragg_blobs_2 (qh,qk,ql,en,p,lattice0,lattice,rotvec)
%
% Input:
% ------
%   qh,qk,ql,en Arrays of h,k,l,e in the reference lattice
%   p           Array of parameters [amp, q_fwhh,e_fwhh]:
%                   amp     Peak intensity of blob
%                   q_fwhh  FWHH of 3D Gaussian in reciprocal space (Ang)
%                   e_fwhh  FWHH in energy (meV)
%
%   lattice0    [a,b,c,alf,bet,gam] lattice parameters (Ang and deg) of reference lattice
%
%   lattice     Optional: [a,b,c,alf,bet,gam] lattice parameters (Ang and deg) of true lattice
%              (Default: lattice0)
%
%   rotvec      Optional: Rotation vector [th1,th2,th3] (rad)
%              (Default: [0,0,0])
%
% Output:
% -------
%   weight      Array of intensities at the data points

amp=p(1);
qsig=p(2)/sqrt(log(256));
esig=p(3)/sqrt(log(256));

% Conversion matrix to turn h,k,l into correponding values for the lattice defined by parameters
[b0,arlu,angrlu,mess] = bmatrix(lattice0(1:3),lattice0(4:6));
if ~isempty(mess), error(mess), end

if exist('lattice','var')
    [b,arlu,angrlu,mess] = bmatrix(lattice(1:3),lattice(4:6));
    if ~isempty(mess), error(mess), end
else
    b=b0;
end

if exist('rotvec','var')
    R=rotvec_to_rotmat2(rotvec');
else
    R=eye(3);
end
rlu_corr=b\(R*b0);

% Get h,k,l in new lattice and get weight
qrlu=rlu_corr*[qh(:),qk(:),ql(:)]';
dqrlu=qrlu-round(qrlu);
dq=b*dqrlu;     % convert back to orthonormal frame
weight=amp*exp(-(sum((dq/qsig).^2,1) + (en(:)'/esig).^2)/2);
weight=reshape(weight,size(qh));
