function y=bose_times_eps(eps,T)
% Computes (<n>+1)*eps, where <n> is the Bose occupation function and eps is energy
%
%   >> y=bose_times_eps(eps,T)
%
%   eps     Energy transfer, or array of energy transfers (meV)
%   T       Temperature (K)

kB=8.6173324e-2;

if T~=0
    y=(kB*T)*einstein(eps/(kB*T));
else
    if all(eps(:))>0
        y=eps;
    else
        y=zeros(size(eps));
        y(eps>0)=eps(eps>0);
    end
end
