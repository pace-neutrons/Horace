function p = einstein(y)
% Calculates the function y/(1-exp(-y)), carefully looking after negative y and |y| near zero.
%
%   >> p = einstein(y)
%
% This is one of several variants of functions known as Einstein functions. It
% crops up in numerically robust computation of neutron scattering cross-sections

p=zeros(size(y));

yabs=abs(y);
ibig=yabs>0.1;
ibigneg=ibig & y<0;
if any(ibig(:))
    p(ibig)    = yabs(ibig) ./ (1 - exp(-yabs(ibig)));
    if any(ibigneg(:))
        p(ibigneg) = p(ibigneg) .* exp(-yabs(ibigneg));
    end
end
if ~all(ibig(:))
    p(~ibig)   = 1 + 0.5*y(~ibig).*( 1 + (1/6)*y(~ibig).*...
        (1 - (1/60)*(y(~ibig).^2).*(1-(1/42)*(y(~ibig).^2).*(1-(1/40)*(y(~ibig).^2) ))));
end
