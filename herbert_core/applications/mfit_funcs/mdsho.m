function y = mdsho(x, p)
% Multiple dampled simple harmonic oscillator response functions
% 
%   >> y = mdsho(x,p)
%
% The response function is the normalised frequency response R(w) in
%       X''(w) =pi*w*X_stat * R(w)
%   where
%       X_stat = static susceptibility
%       integral(R(w),-Inf,Inf) = 1
% 
% R(w) is defined by two parameters:
%       w0      Oscillator frequency
%       gam     Inverse lifetime
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           p = [A_1, w0_1, gam_1, A_2, w0_2, gam_2, ...]
%       where
%           A       Weight factor
%           w0      Oscillator frequency/energy
%           gam     Inverse lifetime (same units as w0)
%
% Output:
% ========
%   y   Vector of calculated y-axis values

% T.G.Perring

if rem(length(p),3)==0
    ndsho=length(p)/3;
    A=p(1:3:end);
    w0=p(2:3:end);
    gam=p(3:3:end);
    y=zeros(size(x));
    for i=1:ndsho
        y = y + A(i) * (2*abs(gam(i))*w0(i)^2/pi)./...
            ((x.^2-w0(i)^2).^2 + (2*gam(i)*x).^2);
    end
else
    error ('Check number of parameters')
end
