function weight = rod_sqw (qh,qk,ql,en,pars,lattice,rlp)
% Delta function in momentum, constant for all energies
%
%   >> weight = rod_sqw (qh,qk,ql,en,pars,lattice)
%   >> weight = rod_sqw (qh,qk,ql,en,pars,lattice,rlp)
%
% Input:
% ------
%   qh, qk, ql, en  Arrays of Q and energy values at which to evaluate dispersion
%
%   pars            [Amplitude, fwhh] - the peak intensity and width
%                  (FWHH in inverse Angstroms) of an energy independent mode
%
%   lattice         Crystal lattice parameters [a,b,c,alpha,beta,gamma]
%
% Optional:
%   rlp             Values of [qh,qk,ql] at which the rods of scattering
%                  occur: array size [np,3] where np is the number of points.
%                   If not given then assumes a Gaussian at every integer
%                  [h,k,l], truncated to the nearest rlp.
%
% Output:
% -------
%   weight          Spectral weight


amp=pars(1);
qsig=pars(2)/sqrt(log(256));

[b,~,~,mess] = bmatrix(lattice(1:3),lattice(4:6));
if ~isempty(mess)
    error(mess)
end

% Get h,k,l in new lattice and get weight
qrlu=[qh(:),qk(:),ql(:)]';
if ~exist('rlp','var')
    dqrlu=qrlu-round(qrlu);
    dq=b*dqrlu;
    weight=amp*exp(-(sum(dq.^2,1))/(2*qsig^2));
    weight=reshape(weight,size(qh));
else
    weight=zeros(1,numel(qh));
    for i=1:size(rlp,1)
        dqrlu=qrlu-repmat(rlp(i,:)',1,numel(qh));
        dq=b*dqrlu;
        weight=weight+amp*exp(-(sum(dq.^2,1))/(2*qsig^2));
    end
    weight=reshape(weight,size(qh));
end
