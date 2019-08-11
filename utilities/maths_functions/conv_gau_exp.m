function y = conv_gau_exp(x, sig, tau)
% Convolution of normalised Gaussian with normalised cut-off exponential.
%
%   >> y = conv_gau_exp(x, sig, tau)
%
%   sig     Standard deviation of normalised Gaussian
%               (1/sqrt(2*pi*abs(sig))) * exp(-0.5(x/sig).^2)
%
%   tau     Decay constant of cut-off exponential
%               (1/abs(tau)) * exp (-x/tau)    x/tau  +ve
%                                         0    x/tau  -ve
%          (i.e. if tau is -ve, then the exponential is non-zero for -ve x)

y=zeros(size(x));

if sig~=0 && tau~=0
    if tau>0
        z=(abs(sig)/tau - x/abs(sig))/sqrt(2);
    else
        z=(-abs(sig)/tau + x/abs(sig))/sqrt(2);
    end
    zpos=(z>=0);

    y(zpos) = (exp(-0.5*(x(zpos)/sig).^2) .* f0erfc(z(zpos))) / (2*abs(tau));
    v=(abs(sig/tau)*sqrt(2))*(z(~zpos)-(abs(sig/tau)/sqrt(8)));
    y(~zpos) = (exp(v) .* (2-exp(-z(~zpos).^2).*f0erfc(-z(~zpos)))) / (2*abs(tau));
    
elseif sig==0 && tau~=0
    if tau>0, ok=(x>=0); else ok=(x<=0); end
    y(ok)=(1/abs(tau))*exp(-x(ok)/tau);
    
elseif tau~=0 && tau==0
    y=(1/(sqrt(2*pi)*abs(sig))) * exp(-0.5*(x/sig).^2);
    
else
    y(x==0)=Inf;
    
end
