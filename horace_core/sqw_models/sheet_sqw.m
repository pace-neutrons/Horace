function weight = sheet_sqw (qh,qk,ql,en,pars,lattice,normal)
% Delta function in momentum along one direction of momentum, constant for all energies
%
%   >> weight = sheet_sqw (qh,qk,ql,en,pars,lattice)
%
% Input:
% ------
%   qh, qk, ql, en  Arrays of Q and energy values at which to evaluate dispersion
%
%   pars            [Amplitude, fwhh] - the peak intensity and width
%                  (FWHH in inverse Angstroms)
%
%   lattice         Crystal lattice parameters [a,b,c,alpha,beta,gamma]
%
%   normal          Direction of normal to sheet in rlu [hnorm,knorm,lnorm]
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

% Get normal and Q in crystal Cartesisn coordinates
n = b*normal(:);
n = (n/norm(n));
qcryst = b*[qh(:)';qk(:)';ql(:)'];

% Get component of Q along the normal
qperp_sqr = sum(bsxfun(@times,n,qcryst).^2,1);
clear qcryst    % get rid of a big work array

weight = amp*exp(qperp_sqr/(-2*qsig^2));
