function weight = sqw_bragg_blobs (qh,qk,ql,en,p,lattice)
% S(Q,w) model that places four dimensional Gaussians at Bragg positions
%
%   >> weight = sqw_bragg_blobs (qh,qk,ql,en,p,lattice)
%
%   qh,qk,ql,en Arrays of h,k,l,e
%   p           Array of parameters [q_fwhh,e_fwhh]:
%                   q_fwhh  FWHH of 3D Gaussian in reciprocal space (Ang)
%                   e_fwhh  FWHH in energy (meV)
%
%   lattice     [a,b,c,alf,bet,gam] lattice parameters (Ang and deg) for lattice

qsig=p(1)/sqrt(log(256));
esig=p(2)/sqrt(log(256));

% Conversion matrix to turn h,k,l into correponding values for the lattice defined by parameters
[b,arlu,angrlu,mess] = bmatrix(lattice(1:3),lattice(4:6));
if ~isempty(mess), error(mess), end

% Get h,k,l in new lattice and get weight
qrlu=[qh(:),qk(:),ql(:)]';
dqrlu=qrlu-round(qrlu);
dq=b*dqrlu;     % convert to orthonormal frame

% Handle case of Inf or NaN width as uniform value of unity for each component
if isfinite(qsig)
    weight=exp(-sum((dq/qsig).^2,1));
else
    weight=1;
end

if isfinite(esig)
    weight=weight.*exp(-(en(:)'/esig).^2);
end

weight=reshape(weight,size(qh));
