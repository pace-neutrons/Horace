function weight=testfunc_rbmnf3_sqw(qh,qk,ql,en,par)
% Spin wave dispersion relation for simple cubic n.n. Heisenberg antiferromagnet
%
%   >> [wdisp,sf] = rbmnf3_disp (qh qk, ql, p)
%
% Input:
% ------
%   qh,qk,ql    Arrays of h,k,l
%   par         Parameters [Seff,SJ,gap,gamma,type]
%                   Seff    Intensity scale factor
%                   SJ      2zSJ Exchange constant (dispersion maximum; =9.6meV for RbMnF3)
%                   gap     Gap at Bragg positions
%                   gamma   Inverse lifetime broadening applied as a DSHO or Gaussian function
%                   type    =0 DSHO (default if not given); =1 Gaussian
%
% Output:
% -------
%   weight      Spectral weight

[wdisp,sf] = testfunc_rbmnf3_disp (qh,qk,ql,par(1:3));

gamma=par(4);
if numel(par)==4
    type=0;
else
    type=par(5);
end

if type==0
    T=0;    % zero temperature
    weight = sf .* (bose_times_eps(en,T) .* (4*gamma*wdisp)./(pi*((en.^2-wdisp.^2).^2+4*(gamma*en).^2)));
elseif type==1
    sig=gamma/sqrt(log(4));     % convert HWHH to sigma
    weight = (sf/(sig*sqrt(2*pi))).*exp(-0.5*((en-wdisp)/sig).^2);
else
    error('Unrecognised response function')
end


%=======================================================================================
function y=bose_times_eps(eps,T)
% Computes (<n>+1)*eps, where <n> is the Bose occupation function and eps is energy
%
%   >> y=bose_times_eps(eps,T)
%
% Input:
% ------
%   eps     Energy transfer, or array of energy transfers (meV)
%   T       Temperature (K)
%
% Output:
% -------
%   y       (<n>+1)*eps, where <n> is the Bose occupation function

kB=8.6173324e-2;

if T~=0
    y=(kB*T)*einstein(eps/(kB*T));
else
    if all(eps(:)>0)
        y=eps;
    else
        y=zeros(size(eps));
        y(eps>0)=eps(eps>0);
    end
end


%=======================================================================================
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
