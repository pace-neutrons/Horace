function y = conv_gau_ikcarp (x, sig_in, tauf_in, taus_in, R)
% Convolution of a normalised gaussian with normalised ikeda-carpenter function
%
%   >> y = conv_gau_ikcarp (y, sig, tauf, taus, R)
%
% Input:
% ------
%   x       Array of times at which to evaluate the function
%   tauf    Fast decay time (us)
%   taus    Slow decay time (us)
%   R       Weight of storage term (0<=R<=1)
%
% Output:
% -------
%   y       Array of values of the function
%
%
% Assumes |taus| >= |tauf| and 0<=R<=1. Taus and tauf must have the same sign
% (if both are negative then the function is reversed along the time axis)
% If sig~=0 and tauf~=0, then must have taus>tauf (problems as taus is close to tauf)
% 
% Limiting cases of sig=0, tauf=0, taus=0, R=0 or 1 handled correctly.
% 
% Problems can arise when tauf and/or taus are extremely small but non-zero.

if sign(taus_in*tauf_in)>=0  % allow one (or both) of tauf=0, taus=0
    tauf=abs(tauf_in); taus=abs(taus_in); sig=abs(sig_in);
else
    error('tauf and taus must have the same sign')
end

% perform convolutions:
if sig~=0 && tauf~=0 && taus~=0							% none of sig, tauf, taus are zero
    y=zeros(size(x));
    za = (sig/tauf - x/sig) / sqrt(2);
    zb = (sig/taus - x/sig) / sqrt(2);
    gam= (1/tauf - 1/taus);
    if gam==0
        error('Must have |taus|>|taus| if sig~=0')
    end
    fac = sqrt(2)*sig*gam;
    pa=(za>=0);
    pb=(zb>=0);
    
    papb=pa&pb;
    if any(papb(:))
        f0b = f0erfc(zb(papb));
        f0a = f0erfc(za(papb));
        f1a = f1erfc(za(papb));
        f2a = f2erfc(za(papb));
        y(papb)= ( exp(-0.5*(x(papb)/sig).^2) .* (  (1-R)*(sig^2)*f2a +...
            (0.5*R/taus) * ( ( f0b - ( f0a+fac*f1a+(fac^2)*f2a ) ) / gam^3 ) ) ) / (tauf^3);
    end
        
    panb=pa&~pb;
    if any(panb(:))
        g0b = 2 - exp(-zb(panb).^2).*f0erfc(abs(zb(panb)));
        vb	= (sig/taus)*((0.5*sig/taus)-x(panb)/sig);
        f0a = f0erfc(za(panb));
        f1a = f1erfc(za(panb));
        f2a = f2erfc(za(panb));
        gaux= exp(-0.5*(x(panb)/sig).^2);
        y(panb)= ( ((1-R)*(sig^2))*(gaux.*f2a)  +...
            (0.5*R/taus) * ( ( exp(vb).*g0b - gaux.*( f0a+fac*f1a+(fac^2)*f2a ) ) / gam^3 )...
            ) / (tauf^3);
    end
    
    napb=~pa&pb; % this cannot actually arise if taus>tauf, as we require
    if any(napb(:))
        f0b = f0erfc(zb(napb));
        g0a = 2 - (exp(-za(napb)^2))*f0erfc(abs(za(napb)));
        g1a = (exp(-za(napb).^2))/sqrt(pi) - za(napb).*g0a;
        g2a = (0.5*za(napb).^2+0.25d0).*g0a - 0.5*za(napb).*(exp(-za(napb).^2))/sqrt(pi);
        va	= (sig/tauf)*((0.5*sig/tauf)-x(napb)/sig);
        gaux= exp(-0.5*(x(napb)/sig).^2);
        y(napb)= ( ((1-R)*(sig^2))*(exp(va)).*g2a +...
            (0.5*R/taus) * ( ( gaux.*f0b - (exp(va))*( g0a+fac*g1a+(fac^2)*g2a ) ) / gam^3 )...
            ) / (tauf^3);
    end
    
    nanb=~pa&~pb;
    if any(nanb(:))
        g0b = 2 - exp(-zb(nanb).^2).*f0erfc(abs(zb(nanb)));
        vb	= (sig/taus)*((0.5*(sig/taus))-x(nanb)/sig);
        g0a = 2 - (exp(-za(nanb).^2)).*f0erfc(abs(za(nanb)));
        g1a = (exp(-za(nanb).^2))/sqrt(pi) - za(nanb).*g0a;
        g2a = (0.5*za(nanb).^2+0.25d0).*g0a - 0.5*za(nanb).*(exp(-za(nanb).^2))/sqrt(pi);
        va	= (sig/tauf)*(0.5*(sig/tauf)-x(nanb)/sig);

        y(nanb)= ( ((1-R)*(sig^2))*(exp(va)).*g2a +...
            (0.5*R/taus) * ( ( exp(vb).*g0b - (exp(va)).*( g0a+fac*g1a+(fac^2)*g2a ) ) / gam^3 )...
            ) / (tauf^3);
    end
    
elseif sig==0		% normal ikeda-carpenter function
    y = ikcarp (x, tauf, taus, R);
    
elseif tauf == 0	% convolution of gaussian with (delta function + exponential)
    y = (1-R)*(exp(-0.5*(x/sig).^2)/(sig*rt2pi)) + R*conv_gau_exp (x, sig, taus);
    
elseif taus == 0	% convolution of gaussian with chi^2
    y = conv_gau_chisqr (x, sig, tauf);
    
end
