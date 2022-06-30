function y = mdsho_bose(x, p)
% Multiple dampled simple harmonic oscillator response with Bose factor
% 
%   >> y = mdsho_bose(x,p)
%
% This function broadens the delta function response with Bose factor:
%       (<n(E)>+1)*deltafun(E-E0) + n(E)*deltafun(E+E0)
%
% with the response for a damped simple harmonic oscillator, and preserves
% the static susceptibility as recovered from Kramers-Kronig relations.
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           p = [A_1, E0_1, gam_1, A_2, E0_2, gam_2, ..., T]
%       where
%           A       Weight factor
%           E0      Oscillator energy (meV)
%           gam     Inverse lifetime (meV)
%             :
%           T       Temperature (K)
%
% Output:
% ========
%   y   Vector of calculated y-axis values

% T.G.Perring

if rem(length(p),3)==1
    ndsho=(length(p)-1)/3;
    A=p(1:3:end);
    E0=p(2:3:end);
    gam=p(3:3:end);
    T=p(end);
    y=zeros(size(x));
    for i=1:ndsho
        y = y + A(i) * (4*abs(gam(i))*abs(E0(i))/pi)./...
            ((x.^2-E0(i)^2).^2 + (2*gam(i)*x).^2);
    end
    y = y .* bose_times_eps(x,T);
else
    error ('Check number of parameters')
end
